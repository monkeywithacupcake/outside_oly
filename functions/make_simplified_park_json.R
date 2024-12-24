# prep park data from raw
# will fail because raw data is excluded
# included to show how to do it to extend

make_onp_data <- function(){
  onp_raw <- read_sf(file.path("data","raw", "OlympicTrailData.json"))
  onp <- onp_raw %>%
    group_by(TRAIL_NAME = TRLNAME) %>%
    dplyr::summarize(do_union=FALSE) %>%  # do_union=FALSE doesn't work as well
    st_cast("MULTILINESTRING") %>%
    ungroup() %>%
    mutate(len = as.numeric(st_length(geometry)))
  write_sf(onp, file.path("data", "ONP.geojson"))
}

make_onf_data <- function(){
  onf_raw <- read_sf(file.path("data","raw", "National_Forest_System_Trails_(Feature_Layer).geojson"))
  onf_raw <- onf_raw %>%
    filter(grepl("^0609", ADMIN_ORG)) 
  onf <- onf_raw %>%
    group_by(TRAIL_NAME) %>%
    dplyr::summarize(do_union=FALSE) %>%  # do_union=FALSE doesn't work as well
    st_cast("MULTILINESTRING") %>%
    ungroup() %>%
    mutate(len = as.numeric(st_length(geometry)))
  write_sf(onf, file.path("data", "ONF.geojson"))
}
  