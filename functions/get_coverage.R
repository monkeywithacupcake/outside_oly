# get_coverage

get_coverage <- function(big_sf, little_sf){
  # id trails touched more than 50 m (so not just the cross)
  # assume big_sf and little_sf geometry is linestrings
  my_poly <- little_sf %>%
    st_buffer(50) %>%  
    st_cast("POLYGON") %>%
    st_union() %>% st_make_valid()
  o <- st_intersection(big_sf, my_poly) %>%
    mutate(len = as.numeric(st_length(geometry))) %>%
    filter(as.numeric(len) > 50) 
  return(o)
}

# trail_coverage is output of get_coverage()
get_covered_portion <- function(big_sf, trail_coverage, var, tolerance = 1){
  
  if(!"len" %in% names(big_sf)){
    big_sf  %>%
      mutate(len = as.numeric(st_length(geometry)))
  }
  # returns list of total_complete and then complete by trail
  p <- trail_coverage %>%
    st_set_geometry(NULL)%>%
    left_join(select(st_set_geometry(big_sf, NULL), 
                     all_of(var), full_len = len)) %>%
    mutate(portion = as.numeric(len/full_len),
           portion = if_else(portion > tolerance, 1, portion))
  max_p <- p %>%
    group_by(TRAIL_NAME) %>%
    summarise(p = max(portion, na.rm=TRUE)) 
  tot_p <- select(st_set_geometry(big_sf, NULL), 
                  all_of(var), full_len = len) %>%
    left_join(max_p) %>%
    mutate(covered = full_len * p)
  tot_p <- as.numeric(sum(tot_p$covered, na.rm= TRUE)/sum(tot_p$full_len))
  print(paste("Total coverage of", 
              scales::percent_format()(tot_p),
              "not including any double coverage")
  )
  return(list(tot_p, select(p, all_of(var), portion)))
}
