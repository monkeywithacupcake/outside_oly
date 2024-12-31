# this is very focused rn, could generalize

#' @param geolist is a single geometry or a list of geometries
#'
get_bbox <- function(geolist){
  if(class(geolist)[[1]] != "list"){ geolist <- list(geolist)}
  bx <- lapply(geolist, st_bbox)
  bbox <- sf::st_bbox(c(xmin = min(unlist(lapply(bx, function(x) x[1])) ),
                        xmax = max(unlist(lapply(bx, function(x) x[3])) ), 
                        ymax = max(unlist(lapply(bx, function(x) x[4])) ), 
                        ymin = min(unlist(lapply(bx, function(x) x[2])) )
                ),
      crs = sf::st_crs(geolist[[1]])
  )
  return(bbox)
}


get_cropped_to_boundary <- function(geo, bbox){
  sf::st_crop(sf::st_transform(geo, crs = st_crs(bbox)), bbox)
}

get_wa_cropped <- function(bbox){
  wa_state <- tigris::states(cb = TRUE, resolution = "500k", year = 2020) %>%
    filter(STUSPS == "WA")
  
  get_cropped_to_boundary(wa_state, bbox)
}
