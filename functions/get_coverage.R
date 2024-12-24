# get_coverage

#' Get Coverage
#' creates a sf df of the intersection of
#' what has been completed and the trail network
#' 
#' @param big_sf sf trail network map
#' @param little_sf sf trail gpx you completed
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

#' Get Covered Portion
#' creates a dataframe of all trails in the trail
#' network and identifies how much is completed
#' 
#' @param big_sf sf trail network map
#' @param trail_coverage sf output of get_coverage()
#' @param var string variable indicating trail name
#' @param tolerance numeric value you believe indicates
#' trail completion. defaults to 1, meaning 100% of official
#' trail length covered. practical completions may be lower.
#' @returns df one row for each row of big_sf with the
#' portion covered in trail_coverage 
get_covered_portion <- function(big_sf, 
                                trail_coverage, 
                                var = "TRAIL_NAME", 
                                tolerance = 1){
  
  if(!"len" %in% names(big_sf)){
    big_sf  %>%
      mutate(len = as.numeric(st_length(geometry)))
  }
  
  p <- select(st_set_geometry(big_sf, NULL), 
              all_of(var), full_len = len) %>%
    left_join(st_set_geometry(trail_coverage, NULL)) %>%
    mutate(portion = as.numeric(len/full_len),
           portion = if_else(portion > tolerance, 1, portion))
  return(select(p, all_of(var), portion))
}

#' get_covered_percent
#' @param big_sf sf trail network map
#' @param covered_portion output of get_covered_portion()
#' @param var string variable indicating trail name
#' 
#' @examples \dontrun{
#' tc <- get_coverage(trail_network, my_gpx_lines)
#' cp <- get_covered_portion(trail_network,tc, tolerance = 0.95)
#' get_covered_percent(trail_network, cp)
#' }
get_covered_percent <- function(big_sf,
                                covered_portion,
                                var = "TRAIL_NAME"){
  tot_p <- select(st_set_geometry(big_sf, NULL), 
                  all_of(var), full_len = len) %>%
    left_join(covered_portion) %>%
    mutate(covered = full_len * portion)
  tot_p <- as.numeric(sum(tot_p$covered, na.rm= TRUE)/sum(tot_p$full_len))
  print(paste("Total coverage of", 
              scales::percent_format()(tot_p),
              "not including any double coverage")
  )
  return(tot_p)
}
