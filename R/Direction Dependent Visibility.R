DDV <- function(route, dem, coordinate_system, max_dist = 1000, horizontal_angle = 62, locs_futher_along_route = 1 ,  observer_elev = 1.65,   reverse = FALSE, binary = TRUE) {

  # set coordinate system as OSGB
  execGRASS("g.proj", flags = c("c"), parameters = list(proj4= coordinate_system))

  # write dem to GRASS
  writeRAST(as(dem, "SpatialGridDataFrame"), "dem", overwrite = TRUE)

  execGRASS("g.region", raster = "dem", flags = "p")

  spdf <- as.data.frame(coordinates(route))

  # if reverse is TRUE reverse order of coordinates.
  if (reverse) {
    spdf <- spdf[seq(dim(spdf)[1],1),]

  }

  # create view raster with same properties as provided dem. This raster will contain the results from the visibility calculations
  view <- dem
  view[] <- 0

  for (i in seq_along(1:nrow(spdf))) {
    
    # calculate visibility using GRASS
    execGRASS("r.viewshed", flags = c("overwrite","b"), parameters = list(input = "dem",output = "view", coordinates =unlist(c(spdf[i,])), observer_elevation = observer_elev, max_distance = max_dist))

    # read Raster files from GRASS into R
    single.viewshed <- readRAST("view")
    # convert SpatialGridDataFrame to raster
    single.viewshed <-  raster(single.viewshed, layer=1, values=TRUE)

    # if iteration number is not equal to the number of locations along the route then calculate the angle between the current location and a location further along the route. If the iteration number is equal to the number of locations along the route, then use the previously calculated angle between the current location and a location further along the route.
    if (i != nrow(spdf)) {

      # calculate x and y difference between location further along the route and the current location
      dx = spdf[i + locs_futher_along_route, 1] - spdf[i, 1]
      dy = spdf[i + locs_futher_along_route, 2] - spdf[i, 2]

      # bearing in radians from current location to location further along the route
      theta = (base::atan2(dy,dx))

      # convert radians to degrees
      theta_degrees <- theta * 180 / pi

      # vector of left and right horizonatal bearing
      t1 <- c(theta_degrees + horizontal_angle, theta_degrees - horizontal_angle)

      # if negative, add 360 to make positive
      t2 <- ifelse(t1 < 0, t1 + 360, t1)

      # convert degrees to radians
      t2 <- t2 * (pi / 180)

      # calculate distance needed for sides of triangle
      range <- max_dist / cos(horizontal_angle * pi / 180)

    }

    # Calculate points needed to create triangle polygon
    xym <-
      rbind(
        spdf[i, ],
        c(spdf[i, 1] + range * cos(t2[1]), spdf[i, 2] + range * sin(t2[1])),
        c(spdf[i, 1] + range * cos(t2[2]), spdf[i, 2] + range * sin(t2[2])),
        spdf[i, ]
      )

    # create SpatialPolygons
    p = Polygon(xym)
    ps = Polygons(list(p),1)
    sps = SpatialPolygons(list(ps))

    # clip SpatialPolygons to circle buffer of max_dist width
    sps <- raster::intersect(sps, gBuffer(SpatialPoints(spdf[i,]), byid = FALSE, id = 1, width = max_dist))

    # create new Raster of sps
    single.viewshed <- mask(x = single.viewshed, mask = sps, updatevalue = 0)

    # replace NA values with
    #single.viewshed[is.na(single.viewshed)] <- 0

    # add visibility results to view raster
    view <- view + single.viewshed
  }
  
  if (binary) {
    view[view > 1] <- 1
  }

  return(view)

}





