library(tidyverse)
library(sf)

for(fp in list.files("functions")){
  source(file.path("functions", fp))
}

# read in the onp and onf geodata
onp<- read_sf(file.path("data", "ONP.geojson"))
onf <- read_sf(file.path("data", "ONF.geojson"))

# get a cropped map of wa
bbox <- get_bbox(onp, onf)
wa_cropped <- get_op_boundary(bbox)


# read in hikes
# you will need to put a .gpx in /data/done
# i put one hike in there for it to do something
done <- read_gpx_in_folder(file.path("data", "done"))
done <- sf::st_crop(done, bbox)
done_lines <- done %>%
  mutate(yr = lubridate::year(time)) %>%
  group_by(yr, name) %>%
  dplyr::summarize(do_union=FALSE) %>%  # do_union=FALSE doesn't work as well
  st_cast("MULTILINESTRING") %>%
  ungroup()


onp_coverage <- get_coverage(onp, done_lines)
oo <- get_covered_portion(onp, onp_coverage, "TRAIL_NAME", .95)
onp_w_me <- onp %>%
  left_join(oo[[2]])
onf_coverage <- get_coverage(onf, done_lines)
oof <- get_covered_portion(onf, onf_coverage, "TRAIL_NAME", .95)
onf_w_me <- onf %>%
  left_join(oof[[2]])
w_me <- onp_w_me %>%
  bind_rows(onf_w_me)

for(yr in unique(done_lines$yr)){
  done_this_yr <- filter(done_lines, yr == yr)
  onp_coverage <- get_coverage(onp, done_this_yr)
  oo <- get_covered_portion(onp, onp_coverage, "TRAIL_NAME", .95)
  onp_w_me <- onp %>%
    left_join(oo[[2]])
  onf_coverage <- get_coverage(onf, done_this_yr)
  oof <- get_covered_portion(onf, onf_coverage, "TRAIL_NAME", .95)
  onf_w_me <- onf %>%
    left_join(oof[[2]])
  w_me <- onp_w_me %>%
    bind_rows(onf_w_me)
  completed <- w_me %>% filter(portion == 1) %>% pull(TRAIL_NAME)
  print(paste("completed in", yr, ":", toString(completed)))
  p <- map_coverage(wa_cropped, w_me, 
               title = paste("Olympic National Forest & Park covered", yr),
               caption = paste("official trails, together: ", 
                               scales::percent(oo[[1]]), "ONP &",
                               scales::percent(oof[[1]]), "ONF"))
  print(p)
}

