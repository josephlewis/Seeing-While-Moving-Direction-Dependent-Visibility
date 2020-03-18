#### LOAD REQUIRED LIBRARIES ####

library(raster)
library(rgdal)
library(sp)
library(rgeos)

#### COORDINATE SYSTEMS ####

osgb <- "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs"

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
elev_osgb <- raster::crop(elev_osgb, as(extent(341248, 351262, 509693, 523552), 'SpatialPolygons'))

#### WATERBODIES PREPROCESSING ####

# read Waterbodies shapefile
waterbodies <- rgdal::readOGR("./Data/Waterbodies/WFD_Lake_Water_Bodies_Cycle_2.shp")

# crop Waterbodies shapefile to elev_osgb extent
waterbodies <- raster::crop(waterbodies, elev_osgb)

# create raster based on Waterbodies shapefile
waterbodies <- raster::mask(elev_osgb, waterbodies)

# reclassify Waterbodies raster data values to 1 or 0. 
waterbodies <- reclassify(waterbodies, rcl = c(-Inf, Inf, 0, NA, NA, 1), right = TRUE)

#### EXPORT DIGITAL ELEVATION MODEL AND WATERBODIES ####

#writeRaster(elev_osgb, "./Outputs/elev_osgb_30m_SRTM.tif")
#writeRaster(waterbodies, "./Outputs/Waterbodies.tif")
