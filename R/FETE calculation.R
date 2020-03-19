#### LOAD REQUIRED LIBRARIES ####

library(raster)
library(rgdal)
library(sp)
library(rgeos)
library(gdistance)
library(leastcostpath)

#### COORDINATE SYSTEMS ####

osgb <- "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs"

#### ORIGINs AND DESTINATIONs USED IN FROM EVERYWHERE TO EVERYWHERE LEAST COST PATH CALCULATION ####

pts <- rgdal::readOGR("./Data/Regular Points/regular_locs.shp")

pts <- pts[unique(round(runif(10, 1, 477))),]

#### DIGITAL ELEVATION MODEL PREPROCESSING ####

elev_files <- base::list.files(path = "./Data/SRTM/", pattern = ".hgt$", full.names = TRUE)

# read 30m SRTM raster data
elev_list <- base::lapply(elev_files, raster)

# merge SRTM raster data
elev <- base::do.call(raster::merge, elev_list)

# crop raster to smaller area to speed up projection of raster to osgb
elev <- crop(elev, as(extent(-3.2, -2.6, 54, 55), 'SpatialPolygons'))

elev <- raster::aggregate(elev, 4)

# project SRTM raster data to osgb coordinate system
elev_osgb <- raster::projectRaster(elev, crs = osgb)

# crop raster to study area
elev_osgb <- raster::crop(elev_osgb, as(extent(333289, 358153, 502039, 531164), 'SpatialPolygons'))

#### WATERBODIES PREPROCESSING ####

# read Waterbodies shapefile
waterbodies <- rgdal::readOGR("./Data/Waterbodies/WFD_Lake_Water_Bodies_Cycle_2.shp")

# crop Waterbodies shapefile to elev_osgb extent
waterbodies <- raster::crop(waterbodies, elev_osgb)

# create raster based on Waterbodies shapefile
waterbodies <- raster::mask(elev_osgb, waterbodies)

# reclassify Waterbodies raster data values to 1 or 0. 
waterbodies <- raster::reclassify(waterbodies, rcl = c(-Inf, Inf, 0, NA, NA, 1), right = TRUE)

#### CREATE COST SURFACES ####

slope_cs <- leastcostpath::create_slope_cs(elev_osgb, cost_function = "modified tobler", neighbours = 16)

traverse_cs <- leastcostpath::create_traversal_cs(elev_osgb, neighbours = 16)

waterbodies_cs <- gdistance::transition(waterbodies, transitionFunction = min, 16)

final_cs <- slope_cs * traverse_cs * waterbodies_cs

#### COMPUTE FROM EVERYWHERE TO EVERYWHERE LEAST COST PATHS ####

lcp_network <- leastcostpath::create_FETE_lcps(cost_surface = final_cs, locations = pts, cost_distance = FALSE, parallel = TRUE)

#### COMPUTE LEAST COST PATH DENSITY ####

lcp_network_density <- leastcostpath::create_lcp_density(lcps = lcp_network, raster = elev_osgb, rescale = TRUE)

#writeRaster(lcp_network_density, "./Outputs/density rasters/lcp_network_density.tif", overwrite = TRUE)

#### COMPUTE LEAST COST PATH KERNEL DENSITY ####

fwModel <- raster::focalWeight(lcp_network_density, max(res(elev_osgb)) * 2, type='circle')

fwModel[fwModel>0] <- 1

lcp_network_kd <- raster::focal(lcp_network_density, w=fwModel ,fun=sum , na.rm=TRUE)

#raster::writeRaster(lcp_network_kd, "./Outputs/density rasters/lcp_network_kernel_density.tif")
