#### LOAD REQUIRED LIBRARIES ####

library(raster)
library(rgrass7)
library(link2GI)
library(rgdal)
library(sp)
library(rgeos)
library(rgdal)

#### READ DDV FUNCTION AND MAKE AVAILABLE TO CURRENT SCRIPT ####

source("./R/Direction_Dependent_Visibility.R")

#### COORDINATE SYSTEMS ####

osgb <- "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs"

#### BRONZE AGE CAIRNS ####

cairns <- utils::read.csv("./Data/Bronze Age cairns/Bronze Age cairns.csv", stringsAsFactors = FALSE)

#### Least Cost Path ####

lcp <- rgdal::readOGR("./Outputs/least cost paths/south_to_north.shp")

#### DIGITAL ELEVATION MODEL PREPROCESSING ####

elev_files <- base::list.files(path = "./Data/SRTM/", pattern = ".hgt$", full.names = TRUE)

# read 30m SRTM raster data
elev_list <- base::lapply(elev_files, raster)

# merge SRTM raster data
elev <- base::do.call(raster::merge, elev_list)

# crop raster to smaller area to speed up projection of raster to osgb
elev <- crop(elev, as(extent(-3.2, -2.6, 54, 55), 'SpatialPolygons'))

# project SRTM raster data to osgb coordinate system
elev_osgb <- raster::projectRaster(elev, crs = osgb)

# crop raster to study area
elev_osgb <- raster::crop(elev_osgb, as(extent(333289, 358153, 502039, 531164), 'SpatialPolygons'))

#### SET-UP OF GRASS IN ORDER TO CALCULATE VISIBILITY ####

# find location where GRASS is installed
myGRASS = link2GI::findGRASS()

# initialise GRASS
#initGRASS(gisBase = myGRASS$instDir,
initGRASS(gisBase = myGRASS,
          gisDbase = tempdir(), location = "visibility", 
          mapset = "PERMANENT", override = TRUE)

#### CALCULATE DIRECTION DEPENDENT VISIBILITY ####

south_to_north_visibility <- DDV(route = lcp, dem = elev_osgb, coordinate_system = osgb, max_dist = 1000, horizontal_angle = 62, locs_futher_along_route = 1, observer_elev = 1.65, reverse = FALSE, binary = TRUE)

plot(south_to_north_visibility)

writeRaster(south_to_north_visibility, "./Outputs/visibility rasters/south_to_north_visibility.tif", overwrite = TRUE)

north_to_south_visibility <- DDV(route = lcp, dem = elev_osgb, coordinate_system = osgb, max_dist = 1000, horizontal_angle = 62, locs_futher_along_route = 1, observer_elev = 1.65, reverse = TRUE, binary = TRUE)

plot(north_to_south_visibility)

writeRaster(north_to_south_visibility, "./Outputs/visibility rasters/north_to_south_visibility.tif", overwrite = TRUE)






#raster::writeRaster(lcp_network_kd, "./Outputs/density rasters/lcp_network_kernel_density.tif")
