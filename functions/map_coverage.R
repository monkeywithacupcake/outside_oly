# map your map

#' Map Coverage
#' @description 
#' Creates a visual representation of the portion 
#' of trails covered overlaying the trail network
#' 
#' @param underlying_map sf that might represent the 
#' area around your trail network. For the examples,
#' I am using the Olympic Peninsula of Washington to 
#' underly the Oly National Forest and Park trails
#' @param trail_network sf the trail network data 
#' same data as used as big_sf in the other functions.
#' In the examples, this is sf from ONF.geojson and ONP.geojson
#' @param trail_coverage sf output of get_coverage()
#' @param trail_coverage_portion df has TRAIL_NAME 
#' and portion covered; output of get_covered_portion()
#' @param title string title you want for your map. 
#' defaults to "Your Completed Trail Network"
#' @param caption string caption you want for your map. 
#' defaults to "created with outside_oly"
map_coverage <- function(underlying_map, 
                         trail_network,
                         trail_coverage, 
                         trail_coverage_portion,
                         title = "Your Completed Trail Network", 
                         caption = "created with outside_oly"){
  
  trails_w_color <- trail_coverage %>%
    left_join(trail_coverage_portion)
  
  ggplot() + 
    geom_sf(data = underlying_map, fill = "grey95") +
    geom_sf(data = trail_network, color = "grey80") +
    geom_sf(data = trails_w_color, aes(color = portion)) +
    scale_color_viridis_c(option = "turbo", 
                          na.value = "grey80", direction = -1,
                          breaks = 0.2*0:5, 
                          labels = scales::percent(0.2*0:5) ) +
    theme_void() +
    labs(title = title,
         color = "", 
         caption = caption
         
    )
}