# Seeing while moving: Direction-Dependent Visibility of Bronze Age Monuments Along a Prehistoric Mountain Track in Cumbria, England

This repository contains all the data and scripts required to fully reproduce all analyses presented in the paper "Seeing while moving: Direction-Dependent Visibility of Bronze Age Monuments Along a Prehistoric Mountain Track in Cumbria, England" authored by Lewis, J. 


Getting Started
---------------

1. Run Seeing-While-Moving-Direction-Dependent-Visibility.Rproj to ensure relative paths work.
2. Run the FETE calculation R script in the R folder to reproduce the Least Cost Path Density and Least Cost Path Kernel Density shown in Figure 4.
    + **Caution: The From Everywhere to Everywhere calculation calculates 227,052 Least Cost Paths and took approximately ~3 days to run on Intel Core i5 laptop with 8GB RAM** 
    + Note: The Least Cost Path Density and Least Cost Path Kernel Density results are available in the Outputs folder. 
  
3. Run the LCP calculation R script in the R folder to reproduce the Least Cost Paths shown in Figure 5. 
    + Note: The South to North and North to South Least Cost Path results are available in the Outputs folder. 

4. Run the Direction Dependent Visibility calculation R script in the R folder to reproduce  the visibility results shown in Figure 6.
    + Note: The South to North and North to South Visibility results are available in the Outputs folder. 
    + The Direction Dependent Visibility function is in the Direction Dependent Visibility R script should you wish to use the function outside of this project. Note that you will need to set up GRASS in order for the function to work (see lines 45 to 55 of Direction Dependent Visibility calculation R script).
    
How Direction-Dependent Visibity is calculated
---------------


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
  │   └── visibility rasters
  │       ├── south_to_north_visibility.tif
  │       ├── north_to_south_visibility.tif
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
  │   └── Direction Dependent Visibility calculation.R
  │   └── Direction_Dependent_Visibility.R  
  ├── README.md
  ├── Seeing-While-Moving-Direction-Dependent-Visibility.Rproj
  ├── Licenses.md
```

Session Info
---------------

```
R version 3.4.1 (2017-06-30)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

locale:
[1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252   
[3] LC_MONETARY=English_United Kingdom.1252 LC_NUMERIC=C                           
[5] LC_TIME=English_United Kingdom.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] rgrass7_0.1-12      XML_3.98-1.9        leastcostpath_1.2.1 gdistance_1.2-2     Matrix_1.2-10      
 [6] igraph_1.2.4.1      rgeos_0.4-3         rgdal_1.4-3         raster_2.8-19       sp_1.3-1           

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.3       lattice_0.20-35  codetools_0.2-15 grid_3.4.1       magrittr_1.5     pbapply_1.4-2   
 [7] tools_3.4.1      parallel_3.4.1   compiler_3.4.1   pkgconfig_2.0.2 
```

License
---------------

CC-BY 3.0 unless otherwise stated (see Licenses.md)
