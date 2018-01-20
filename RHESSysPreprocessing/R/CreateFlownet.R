#' CreateFlownet
#'
#' Creates the flow network used by RHESSys
#' @param cfname The name of the flow network file to be created.  Will be coerced to have ".flow" extension if not already present.
#' @param type GIS type to be used. Currently only supports GRASS GIS.
#' @param readin The file containng map names of maps to be used in to
#' create the flow network.  This is autogenerated by world_gen, but
#' still needs the streams map to be specified.
#' @param typepars Parameters needed based on GIS type used. These are automatically inherited from world_gen,
#' but can be overwritten if you want to use a differen GIS environment. For Grass GIS type, typepars is a
#' vector of 5 character strings. GRASS GIS parameters: gisBase, home, gisDbase, location, mapset.
#' Example parameters are shown in the example script for world_gen. See initGRASS help for more info on parameters.

CreateFlownet = function(cfname, type = "GRASS", readin = "cf_maps", typepars = "load") {

  # ---------- Read and check inputs ----------

  cfmaps = as.matrix(read.table("cf_maps",header=TRUE))

  if (cfmaps[10,2]=="none"|is.na(cfmaps[10,2])) { # Check for streams map, since it isn't automatically generated. Menu allows input of stream map
    t = menu(c("Specify map","Abort function"),
             title="Missing stream map. Specify one now, or abort function and edit cf_maps file?")
    if (t==2) {stop("Function aborted")}
    if (t==1) {
      stream = readline("Stream map:")
      cfmaps[10,2] = stream
      write.table(cfmaps,file="cf_maps",sep="\t\t",row.names=FALSE,quote = FALSE)
    }
  }

  cfbasename = basename(cfname) # Coerce .flow extension
  if (startsWith(cfbasename,"Flow.") | startsWith(cfbasename,"flow.")) {
    cfbasename = paste(substr(cfbasename,6,nchar(cfbasename)),".flow",sep="")
    cfname = paste(substr(cfname, 1, (nchar(dirname(cfname))+1)),cfbasename,sep="")
  } else if(!endsWith(cfbasename,".flow")) {
    cfbasename = paste(cfbasename,".flow",sep="")
    cfname = paste(substr(cfname, 1, (nchar(dirname(cfname))+1)),cfbasename,sep="")
  }

  if(typepars =="load") {load("typepars")}

  mapsin = cfmaps[cfmaps[,2]!="none" & cfmaps[,1]!="cell_length",2]

  # ---------- Use GIS_read to ingest maps and convert them to an array ----------

  readmap = GIS_read(type, mapsin, typepars)
  map_ar = as.array(readmap)
  map_ar_clean = map_ar[!apply(is.na(map_ar), 1, all), !apply(is.na(map_ar), 2, all), ]
  #map_ar_clean = map_ar
  dimnames(map_ar_clean)[[3]] = colnames(readmap@data)



  raw_patch_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="patch",2]]
  raw_patch_elevation_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="z",2]]
  raw_hill_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="hillslope",2]]
  raw_basin_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="basin",2]]
  raw_zone_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="zone",2]]
  raw_slope_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="slope",2]]
  raw_stream_data = map_ar_clean[, ,cfmaps[cfmaps[,1]=="stream",2]]
  cell_length = as.numeric(cfmaps[cfmaps[,1]=="cell_length",2])


  CF1 = patch_data_analysis(
    raw_patch_data,
    raw_patch_elevation_data,
    raw_hill_data,
    raw_basin_data,
    raw_zone_data,
    raw_slope_data,
    raw_stream_data,
    cell_length
  )


  CF2 = make_flow_table(CF1, cfname)
}