library(rgdal)
library(rgeos)
library(raster)
library(sp)
library(spdep) # for calculating gabriel graph
library(leastcostpath) # for calculating LCPs
library(rgrass7) # for calculating viewsheds
# use_sp() ensures that rgrass7 uses sp rather than stars library
use_sp()
library(xml2) # for creating cairnfield SpatialPoints from ADS records
library(tmap)  # for producing maps

#### READ DDV FUNCTION AND MAKE AVAILABLE TO CURRENT SCRIPT ####
source("./R/Direction Dependent Visibility.R")

#### LOAD AND MODIFY NECESSARY FILES ####

NCA <- readOGR("./Data/National_Character_Areas_England/National_Character_Areas_England.shp")
high_fells <- NCA[NCA$JCANAME == "Cumbria High Fells",]

elev_files <- list.files(path = "./Data/OS50/", pattern = ".asc$", full.names = TRUE, recursive = TRUE)
elev_list <- lapply(elev_files, raster::raster)
elev_osgb <- do.call(raster::merge, elev_list)
elev_osgb <- raster::crop(elev_osgb, rgeos::gBuffer(as(raster::extent(high_fells), "SpatialPolygons"), width = 1000))

crs(high_fells) <- crs(elev_osgb)

waterbodies <- readOGR("./Data/Waterbodies/WFD_Lake_Water_Bodies_Cycle_2.shp")
waterbodies <- raster::crop(waterbodies, elev_osgb)
crs(waterbodies) <- crs(elev_osgb)

#### CREATE SPATIALPOINTS OF BRONZE AGE CAIRNS ####

cairns_files <- list.files(path = "./Data/Bronze Age Cairnfields/", pattern = ".xml", full.names = TRUE)

cairns = list()

for (i in 1:length(cairns_files)) { 
  
  xml_doc <- xml2::read_xml(cairns_files[i])
  
  x <- as.numeric(xml2::xml_text(xml2::xml_find_all(xml_doc, "//ns:x")))
  y <- as.numeric(xml2::xml_text(xml2::xml_find_all(xml_doc, "//ns:y")))
  
  cairns[[i]] <- SpatialPoints(coords = cbind(x,y))
  
}

cairns <- do.call(rbind, cairns)

# remove cairns with duplicate coordinates
cairns <- cairns[!duplicated(cairns@coords),]
# remove cairns that are in the same raster cell - this is to ensure that LCPs aren't calculated from two cairns within the same raster cell
cairns <- cairns[!duplicated(cellFromXY(elev_osgb, cairns)),]

cairns <- raster::crop(x = cairns, high_fells)

cairns$ID <- 1:length(cairns)

writeOGR(obj = cairns, dsn = "./Data/Bronze Age Cairnfields", layer = "cairns", driver = "ESRI Shapefile")

#### CALCULATE VIEWSHEDS FROM BRONZE AGE CAIRNS ####

GRASS_loc <- "D:/GRASS GIS 7.6.0"
temp_loc <- "C:/"

initGRASS(gisBase = GRASS_loc,
          gisDbase = temp_loc, location = "visibility", 
          mapset = "PERMANENT", override = TRUE)

# set coordinate system as OSGB
execGRASS("g.proj", flags = c("c"), proj4 = "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs")

# write dem to GRASS
writeRAST(as(elev_osgb, "SpatialGridDataFrame"), "dem", overwrite = TRUE)

execGRASS("g.region", raster = "dem", flags = "p")

viewshed <- elev_osgb
viewshed[] <- 0

observer_height <- 1.65
distance <- 6000
locations <- cairns@coords

for (i in 1:length(cairns)) {
  
  print(paste0("Iteration Number: ", i))
  
  execGRASS("r.viewshed", flags = c("overwrite","b"), parameters = list(input = "dem", output = "viewshed", coordinates = unlist(c(locations[i,])),  observer_elevation = observer_height, max_distance = distance))
  
  single.viewshed <- readRAST("viewshed")
  
  single.viewshed <-  raster(single.viewshed, layer=1, values=TRUE)
  
  viewshed <- viewshed + single.viewshed
  
}

# calculate how much of the study area is visible
(sum(viewshed[] > 0) * res(elev_osgb)[1]^2) / (ncell(elev_osgb) * res(elev_osgb)[1]^2) * 100

viewshed[viewshed == 0] <- NA

#writeRaster(x = viewshed, filename = "./Outputs/viewsheds/cumulative_viewshed.tif", overwrite = TRUE)

#### CALCULATE DELAUNEY TRIANGLE FROM CAIRN LOCATIONS ####

neighbour_pts <- spdep::gabrielneigh(cairns)
locs_matrix <- base::cbind(neighbour_pts$from, neighbour_pts$to)

#### CREATE SLOPE AND WATERBODIES COST SURFACES ####

slope_cs <- leastcostpath::create_slope_cs(dem = elev_osgb, cost_function = "modified tobler", neighbours = 16)
waterbodies_cs <- leastcostpath::create_barrier_cs(raster = elev_osgb, barrier = waterbodies, neighbours = 16, field = 0, background = 1)

final_cs <- slope_cs * waterbodies_cs

#### CALCULATE LEAST COST PATHS BETWEEN DELAUNEY-DERIVED CAIRN LOCATIONS

lcps <- leastcostpath::create_lcp_network(cost_surface = final_cs, locations = cairns, nb_matrix = locs_matrix, cost_distance = FALSE, parallel = TRUE)

#writeOGR(obj = lcps, dsn = "./Outputs/lcps", layer = "lcps", driver = "ESRI Shapefile", overwrite_layer = TRUE)

#### CALCULATE DIRECTION DEPENDENT VISIBILITY ALONG EACH LEAST COST PATH

AtoB <- list()
BtoA <- list()

# length(lcps)

for (i in 1:5) { 
  
  print(paste0("Iteration Number: ", i))
  
  AtoB[[i]] <- DDV(route = lcps[i,], dem = elev_osgb, max_dist = distance, horizontal_angle = 62, locs_futher_along_route = 1, observer_elev = observer_height, reverse = FALSE, binary = FALSE)

BtoA[[i]] <- DDV(route = lcps[i,], dem = elev_osgb, max_dist = distance, horizontal_angle = 62, locs_futher_along_route = 1, observer_elev = observer_height, reverse = TRUE, binary = FALSE)

}

DDV_AtoB <- Reduce(`+`, AtoB)
DDV_BtoA <- Reduce(`+`, BtoA)

#writeRaster(x = DDV_AtoB, filename = "./Outputs/viewsheds/DDV_AtoB.tif", overwrite = TRUE)
#writeRaster(x = DDV_BtoA, filename = "./Outputs/viewsheds/DDV_BtoA.tif", overwrite = TRUE)

final_DDV <- (DDV_AtoB + DDV_BtoA) / 2

# calculate how much of the study area is visible
(sum(final_DDV[] > 0) * res(elev_osgb)[1]^2) / (ncell(elev_osgb) * res(elev_osgb)[1]^2) * 100

final_DDV[final_DDV == 0] <- NA

#writeRaster(x = final_DDV, filename = "./Outputs/viewsheds/DDV_mean.tif", overwrite = TRUE)

elev_osgb[elev_osgb < 0] <- NA

high_fells_line <- as(high_fells, "SpatialLines")

crs(high_fells_line) <- crs(elev_osgb)

viewshed_map <- tm_shape(elev_osgb, raster.downsample = FALSE) + 
  tm_raster(palette = viridis::cividis(n = 100, begin = 0, end = 1), n = 10, legend.show = TRUE, legend.reverse = TRUE, title = "Elevation (m)", colorNA = "#9ECAE1", showNA = FALSE, alpha = 0.6) + 
  tm_shape(viewshed, raster.downsample = FALSE) + 
  tm_raster(palette = viridis::plasma(n = 10, begin = 0, end = 1), n = 10, legend.show = TRUE, legend.reverse = TRUE, title = "Cumulative Visibility") + 
  tm_shape(waterbodies) + 
  tm_polygons(col = "#9ECAE1", border.col = "#9ECAE1", legend.show = TRUE) + 
  tm_shape(high_fells_line) + 
  tm_lines(col = "black", lwd = 2, lty = 2, legend.show = TRUE) + 
  tm_legend(show = TRUE, outside = TRUE, legend.position = c("right", "bottom")) + 
  tm_add_legend(type = "fill", labels = "Water", col = "#9ECAE1", border.col = "#9ECAE1") + 
  tm_add_legend(type = "line", labels = "High Fells", col = "black", lty = 2, lwd = 2) + 
  tm_scale_bar(position = c("right", "bottom"),breaks = c(0, 5, 10), text.color = "black") + 
  tm_layout(
    main.title = "A", 
    main.title.position = "left")

lcp_routes_map <- tm_shape(elev_osgb, raster.downsample = FALSE) + 
  tm_raster(palette = viridis::cividis(n = 100, begin = 0, end = 1), n = 10, legend.show = TRUE, legend.reverse = TRUE, title = "Elevation (m)", colorNA = "#9ECAE1", showNA = FALSE) + 
  tm_shape(waterbodies) + 
  tm_polygons(col = "#9ECAE1", border.col = "#9ECAE1", legend.show = TRUE) + 
  tm_shape(high_fells_line) + 
  tm_lines(col = "black", lwd = 2, lty = 2, legend.show = TRUE) + 
  tm_shape(lcps) + 
  tm_lines(col = "red", lwd = 4) + 
  tm_shape(cairns) + 
  tm_dots(col = "black", size = 0.2, legend.show = TRUE) + 
  tm_add_legend(type = "line", labels = "Least Cost Path", col = "red", lwd = 4) + 
  tm_legend(show = TRUE, outside = TRUE, legend.position = c("right", "bottom")) + 
  tm_add_legend(type = "symbol", labels = "Cairnfields", col = "black", border.col = "black") + 
  tm_add_legend(type = "fill", labels = "Water", col = "#9ECAE1", border.col = "#9ECAE1") + 
  tm_add_legend(type = "line", labels = "High Fells", col = "black", lty = 2, lwd = 2) + 
  tm_scale_bar(position = c("right", "bottom"),breaks = c(0, 5, 10), text.color = "white") + 
  tm_layout(
    main.title = "B", 
    main.title.position = "left")

lcp_viewshed_map <- tm_shape(elev_osgb, raster.downsample = FALSE) + 
  tm_raster(palette = viridis::cividis(n = 100, begin = 0, end = 1), n = 10, legend.show = TRUE, legend.reverse = TRUE, title = "Elevation (m)", colorNA = "#9ECAE1", showNA = FALSE, alpha = 0.6) + 
  tm_shape(final_DDV, raster.downsample = FALSE) + 
  tm_raster(palette = viridis::plasma(n = 10, begin = 0, end = 1), n = 10, legend.show = TRUE, legend.reverse = TRUE, title = "Cumulative Visibility") + 
  tm_shape(waterbodies) + 
  tm_polygons(col = "#9ECAE1", border.col = "#9ECAE1", legend.show = TRUE) + 
  tm_shape(high_fells_line) + 
  tm_lines(col = "black", lwd = 2, lty = 2, legend.show = TRUE) + 
  tm_legend(show = TRUE, outside = TRUE, legend.position = c("right", "bottom")) + 
  tm_add_legend(type = "fill", labels = "Water", col = "#9ECAE1", border.col = "#9ECAE1") + 
  tm_add_legend(type = "line", labels = "High Fells", col = "black", lty = 2, lwd = 2) + 
  tm_scale_bar(position = c("right", "bottom"),breaks = c(0, 5, 10), text.color = "black") + 
  tm_layout(
    main.title = "C", 
    main.title.position = "left")

# tmap::tmap_save(lcp_routes_map, "./outputs/plots/lpc_routes.png")
# tmap::tmap_save(viewshed_map, "./outputs/plots/viewshed.png")
# tmap::tmap_save(lcp_viewshed_map, "./outputs/plots/lcp_viewshed.png")

quantile(extract(viewshed, cairns), seq(0, 1, 0.25))
quantile(extract(final_DDV, cairns), seq(0, 1, 0.25))







