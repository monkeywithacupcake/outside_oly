# read all the .gpx in a folder

read_single_gpx <- function(fpath, crs){
  gpx <- fpath %>%
    xmlTreeParse(useInternalNodes = TRUE) %>%
    xmlRoot %>%
    xmlToList %>%
    (function(x) x$trk) %>%
    (function(x) unlist(x[names(x) == "trkseg"], recursive = FALSE)) %>%
    map_df(function(x) as.data.frame(t(unlist(x)), stringsAsFactors=FALSE))
  
  gpx <- st_as_sf(x = gpx,                         
                  coords = c(".attrs.lon", ".attrs.lat"),
                  crs = crs)
  gpx <- gpx %>%
    mutate(name = stringr::str_squish(tools::file_path_sans_ext(basename(fpath))))
  return(gpx)
}


read_gpx_in_folder <- function(folder_name){
  library(sf)
  library(XML)
  myfiles = list.files(path=folder_name, pattern=".+\\.gpx", full.names=TRUE)
  # for(fname in myfiles){
  #   print(stringr::str_squish(tools::file_path_sans_ext(basename(fname))))
  # }
  fixed_crs <- st_crs(read_sf(myfiles[[1]]))
  sfdf <- myfiles |>
    map(read_single_gpx) |>  
    bind_rows()
  sfdf <- st_set_crs(sfdf, fixed_crs)
  return(sfdf)
}


