# this is very focused rn, could generalize

get_bbox <- function(onp, onf){
  onp_bbox <- sf::st_bbox(onp)
  onf_bbox<- sf::st_bbox(onf)
  bbox <- sf::st_bbox(c(xmin = min(onp_bbox$xmin, onf_bbox$xmin),
                               xmax = max(onp_bbox$xmax, onf_bbox$xmax), 
                               ymax = max(onp_bbox$ymax, onf_bbox$ymax), 
                               ymin = min(onp_bbox$ymin, onf_bbox$ymin)
  ),
  crs = sf::st_crs(onp))
  return(bbox)
}


get_op_boundary <- function(bbox){
  wa_state <- tigris::states(cb = TRUE, resolution = "500k", year = 2020) %>%
    filter(STUSPS == "WA")
  
  sf::st_crop(sf::st_transform(wa_state, crs = st_crs(bbox)), bbox)
}
