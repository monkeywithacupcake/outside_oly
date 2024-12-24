# map your map

map_coverage <- function(underlying_map, trail_coverage, 
                         title, caption){
  ggplot() + 
    geom_sf(data = underlying_map, fill = "grey95") +
    geom_sf(data = trail_coverage, aes(color = portion)) +
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