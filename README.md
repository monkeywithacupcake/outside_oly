# Outside Oly

This R Project contains data and functions, so you can estimate how much of Olympic National Forest and Olympic National Park trails that you have covered.

# How to Use

At a high level, you are comparing the trails in the ONP and ONF maps that are included in the project with the part you have covered (ideally based on .gpx from your watch or AllTrails or Strava). 

1. setup - clone this repo

```sh
git clone git@github.com:monkeywithacupcake/outside_oly.git
cd outside_oly
```

2. build the base maps

```r
library(tidyverse)
library(sf)

for(fp in list.files("functions")){
  source(file.path("functions", fp))
}

# read in the onp and onf geodata
onp<- read_sf(file.path("data", "ONP.geojson"))
onf <- read_sf(file.path("data", "ONF.geojson"))

# get a cropped map of wa
bbox <- get_bbox(list(onp, onf))
wa_cropped <- get_wa_cropped(bbox)

```

3. drop your activies in `/data/done` and read them in

There is an example .gpx in the `/data/done`, so you can test this out. After practicing, drop your own .gpx files - maybe representing one epic backpacking trip, or a year or lifetime of .gpx files in to the `/data/done` folder. If you have a lot of .gpx, it will take a long time. Don't forget to remove the sample .gpx file to avoid misstating your coverage.

```r
# read in hikes
done <- read_gpx_in_folder(file.path("data", "done"))
done <- sf::st_crop(done, bbox)

# you do not have to aggregate by year and name
done_lines <- done %>%
  mutate(yr = lubridate::year(time)) %>%
  group_by(yr, name) %>%
  dplyr::summarize(do_union=FALSE) %>% 
  st_cast("MULTILINESTRING") %>%
  ungroup()
```

4. run the comparison

```r
onp_coverage <- get_coverage(big_sf = onp, little_sf = done_lines)
oo <- get_covered_portion(big_sf = onp, 
                          trail_coverage = onp_coverage, 
                          var = "TRAIL_NAME", tolerance = .95)
onp_w_me <- onp %>% left_join(oo)
```

At this point, onp_w_me has the trail that your track covers, its geometry, and the portion of the official trail that your track shows completed. 

```r
onp_w_me # this is the sample data with just one .gpx for Lake Angeles

Simple feature collection with 1 feature and 3 fields
Geometry type: MULTILINESTRING
Dimension:     XY
Bounding box:  xmin: -123.4391 ymin: 47.99549 xmax: -123.4254 ymax: 48.03898
Geodetic CRS:  WGS 84
# A tibble: 1 × 4
  TRAIL_NAME           len                                            geometry portion
* <chr>              <dbl>                               <MULTILINESTRING [°]>   <dbl>
1 LAKE ANGELES TRAIL 7642. ((-123.4316 48.03898, -123.4317 48.03893, -123.432…   0.715
```

If you are only interested in the portion, you can get it easily by removing the geometry

```r
onp_w_me %>% st_drop_geometry()
# A tibble: 1 × 3
  TRAIL_NAME           len portion
* <chr>              <dbl>   <dbl>
1 LAKE ANGELES TRAIL 7642.   0.715
```

```r
# you can also get a map
map_coverage(wa_cropped, trail_network = onp,
                         trail_coverage = onp_coverage, 
                         trail_coverage_portion = oo
)
```


## Other Uses

You may not care to get coverage but are just wanting a cleaner way to see your tracks versus some trail or other tracks. A simple little function here `map_track_v_trail()` has you. 

```r
# as an example read in the one example .gpx
this_track <- read_single_gpx(file.path("data","done","Lake_Angeles.gpx"),
                              crs = 4326) %>% group_by(name) %>%
  dplyr::summarize(do_union=FALSE) %>% 
  st_cast("MULTILINESTRING") %>%
  ungroup()

# maybe you want to compare it two the two trails that start in the same place
this_trail <- filter(onp, TRAIL_NAME %in% c('LAKE ANGELES TRAIL',
                                            'HEATHER PARK TRAIL'))
map_track_v_trail(trail_sf = this_trail, 
                  track_sf = this_track)
```
This results in: 

![Lake Angeles hike over Lake Angeles and Heather Park ONP trails](https://github.com/monkeywithacupcake/outside_oly/blob/main/img/lake_angeles_example_tvt.jpeg)

For a slightly more interesting plot, here's a few of the hikes I recorded on a multi-day trip through the seven lakes basin and high divide, overlaid on the loop. 

![Another Example showing a hike over ONP trails](https://github.com/monkeywithacupcake/outside_oly/blob/img/map_track_v_trail.jpeg)

# Future State

I'm working to build this out to a package but also to make it expandable and generic, so if you had local trails or another place that mattered to you, you could do a similar analysis.

[] Add error handling
[] Convert to Package

