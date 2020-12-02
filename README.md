# Seeing while moving: Direction-Dependent Visibility of Bronze Age Monuments in the Cumbrian High Fells, England

This repository contains all the data and scripts required to fully reproduce all analyses presented in the paper "Seeing while moving: Direction-Dependent Visibility of Bronze Age Monuments in the Cumbrian High Fells, England" authored by Lewis, J. 


Getting Started
---------------

1. Open project using Seeing-While-Moving-Direction-Dependent-Visibility.Rproj to ensure relative paths work.
2. Run the main R script in the R folder to reproduce the analyses. 
    + Note: The Least Cost Paths and Viewsheds results are available in the Outputs folder. 
    + The Direction Dependent Visibility function is in the Direction Dependent Visibility R script should you wish to use the function outside of this project. Note that you will need to set up GRASS in order for the function to work (see lines 64 to 73 of Direction Dependent Visibility calculation R script).
    
How Direction-Dependent Visibity is calculated
---------------

1. Calculate visibility in all directions from a location along the route.
2. Calculate angle between current location and location further along route. This represents the direction of movement when moving along the route.
3. Add a random value from a normal distribution (mean = 0, sd = 20). This emulates the moving of the head sideways. 
4. Identify potential visibility field based on direction of movement (62 degrees either side).
5. Clip visibility in all directions to potential visibility field when taking into account direction of movement.

![Direction Dependent Visibility](https://i.imgur.com/r5grlGg.gif)

File Structure
---------------

```
  .
  ├── Data
  │   └── Bronze Age Cairnfields
  │       ├── cairns.shp
  │       ├── cairns.prj
  │       ├── cairns.dbf
  │       ├── cairns.shx
  │       ├── results.xml
  │       ├── results (1).xml
  │   └── National_Character_Areas_England
  │       ├── National_Character_Areas_England.cpg
  │       ├── National_Character_Areas_England.dbf
  │       ├── National_Character_Areas_England.prj
  │       ├── National_Character_Areas_England.shp
  │       ├── National_Character_Areas_England.shx
  │       ├── National_Character_Areas_England.xml
  │   └── OS50
  │       ├── terrain-50-dtm_3789282
  │       ├── citations_orders_1627556.txt
  │       ├── contents_order_1627556.txt
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
  │   └── lcps
  │       ├── lcps.dbf
  │       ├── lcps.prj
  │       ├── lcps.shp
  │       ├── lcps.shx
  │   └── plots
  │       ├── lpc_routes.png
  │       ├── viewshed.png
  │       ├── lcp_viewshed.png
  │   └── viewsheds
  │       ├── cumulative_viewshed.tif
  │       ├── DDV_AtoB.tif
  │       ├── DDV_BtoA.tif
  │       ├── DDV_mean.tif
  ├── R
  │   └── main.R
  │   └── Direction Dependent Visibility.R 
  ├── README.md
  ├── Seeing-While-Moving-Direction-Dependent-Visibility.Rproj
  ├── Licenses.md
```

Session Info
---------------

```
R version 4.0.3 (2020-10-10)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19041)

Matrix products: default

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] tmap_3.2            xml2_1.3.2          rgrass7_0.2-1       XML_3.99-0.5        leastcostpath_1.7.8 spdep_1.1-5         sf_0.9-6            spData_0.3.8       
 [9] raster_3.3-13       rgeos_0.5-5         rgdal_1.5-18        sp_1.4-4           

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.5         lattice_0.20-41    deldir_0.1-29      png_0.1-7          class_7.3-17       gtools_3.8.2       digest_0.6.27      R6_2.5.0          
 [9] coda_0.19-4        e1071_1.7-4        ggplot2_3.3.2      pillar_1.4.6       rlang_0.4.8        rstudioapi_0.11    gdata_2.18.0       gmodels_2.18.1    
[17] Matrix_1.2-18      splines_4.0.3      htmlwidgets_1.5.2  igraph_1.2.6       munsell_0.5.0      compiler_4.0.3     base64enc_0.1-3    pkgconfig_2.0.3   
[25] tmaptools_3.1      htmltools_0.5.0    tidyselect_1.1.0   tibble_3.0.4       gridExtra_2.3      expm_0.999-5       codetools_0.2-16   viridisLite_0.3.0 
[33] crayon_1.3.4       dplyr_1.0.2        MASS_7.3-53        grid_4.0.3         nlme_3.1-149       lwgeom_0.2-5       gtable_0.3.0       lifecycle_0.2.0   
[41] DBI_1.1.0          magrittr_1.5       units_0.6-7        scales_1.1.1       KernSmooth_2.23-17 pbapply_1.4-3      viridis_0.5.1      LearnBayes_2.15.1 
[49] leafsync_0.1.0     leaflet_2.0.3      ellipsis_0.3.1     generics_0.0.2     vctrs_0.3.4        boot_1.3-25        RColorBrewer_1.1-2 tools_4.0.3       
[57] dichromat_2.0-0    leafem_0.1.3       glue_1.4.2         purrr_0.3.4        crosstalk_1.1.0.1  abind_1.4-5        parallel_4.0.3     colorspace_1.4-1  
[65] gdistance_1.3-6    stars_0.4-3        classInt_0.4-3    
```

License
---------------

CC-BY 3.0 unless otherwise stated (see Licenses.md)
