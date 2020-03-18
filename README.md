# SEEING WHILE MOVING: DIRECTION-DEPENDENT VISIBILITY OF BRONZE AGE MONUMENTS ALONG A PREHISTORIC MOUNTAIN TRACK IN CUMBRIA, ENGLAND

This repository contains all the data and scripts required to fully reproduce all analyses presented in the paper "Seeing while moving: Direction-Dependent Visibility of Bronze Age Monuments Along a Prehistoric Mountain Track in Cumbria, England" authored by Lewis, J. 


Getting Started
---------------

1. Run FETE calculation R script in the R folder to reproduce the Least Cost Path Density and Least Cost Path Kernel Density shown in Figure 4.
    + **Caution: The From Everywhere to Everywhere calculation calculates 227,052 Least Cost Paths and takes approximately ~3 days to run.** 
    + Note: The Least Cost Path Density and Least Cost Path Kernel Density results are available in the Outputs folder. 
  
2. Run LCP calculation R script in the R folder to reproduce the Least Cost Paths shown in Figure 5. 

File Structure
---------------

```
  .
  ├── Data
  │   └── OD
  │       ├── origin_destination.shp
  │       ├── origin_destination.dbf
  │       ├── origin_destination.shx
  │   └── Regular Points
  │       ├── regular_locs.shp
  │       ├── regular_locs.dbf
  │       ├── regular_locs.shx
  │   └── SRTM
  │       ├── N54W003.hgt
  │       ├── N54W004.hgt
  │   └── Waterbodies
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.cpg
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.dbf
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.prj
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.sbn
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.sbx
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.shp
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.xml
  │       ├── WFD_Lake_Water_Bodies_Cycle_2.shx
  ├── Outputs
  │   └── density rasters
  │       ├── lcp_network_density.tif
  │       ├── lcp_network_kernel_density.tif
  │   └── least cost paths
  │       ├── north_to_south.dbf
  │       ├── north_to_south.prj
  │       ├── north_to_south.shp
  │       ├── north_to_south.shx
  │       ├── south_to_north.dbf
  │       ├── south_to_north.prj
  │       ├── south_to_north.shp
  │       ├── south_to_north.shx
  ├── R
  │   └── FETE calculation.R
  │   └── LCP calculation.R
  ├── README.md
```

