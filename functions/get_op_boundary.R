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

bb_shrink <- function(bb, e) { # copied from stars::bb_shrink (not exported)
  stopifnot(inherits(bb, "bbox"))
  dx = diff(bb[c("xmin", "xmax")])
  dy = diff(bb[c("ymin", "ymax")])
  st_bbox(setNames(c(bb["xmin"] + e * dx, 
                     bb["ymin"] + e * dy, 
                     bb["xmax"] - e * dx, 
                     bb["ymax"] - e * dy), c("xmin", "ymin", "xmax", "ymax")),
          crs = st_crs(bb))
}

get_cropped_to_boundary <- function(geo, bbox){
  sf::st_crop(sf::st_transform(geo, crs = st_crs(bbox)), bbox)
}

get_wa_cropped <- function(bbox){
  wa_state <- tigris::states(cb = TRUE, resolution = "500k", year = 2020) %>%
    filter(STUSPS == "WA")
  
  get_cropped_to_boundary(wa_state, bbox)
}
