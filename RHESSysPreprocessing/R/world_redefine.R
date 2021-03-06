#' World Redefine
#'
#' Generates redefine worldfiles for use in RHESSys specifically to modify exisitng worldfile values via
#' replacing values or multipliers.
#' Currently includes functionality for GRASS GIS (depreciated) and raster data, and works on both unix and windows. 3/4/19.
#' @param template Template file used to generate redefine worldfile for RHESSys. Use "-9999" to retain
#' values of exisintg worldfile. Generic strucutre is:
#' <state variable> <operator> <value/map>. Levels are difined by lines led by "_", structured
#' <levelname> <map> <count>. Whitespace and tabs are ignored.  Maps referred to must be supplied
#' by your chosen method of data input(GRASS or raster), set using the "type" arguement.
#' @param worldfile Name and path of redefine worldfile to be created.
#' @param type Input file type to be used. Default is raster. "Raster" type will use rasters
#' in GeoTiff or equivalent format (see Raster package), with file names  matching those indicated in the template.
#' ASCII is supported, but 0's cannot be used as values for data. "GRASS" will attempt to autodetect the version of
#' GRASS GIS being used (6.x or 7.x).  GRASS GIS type can also be set explicitly to "GRASS6" or "GRASS7".
#' @param typepars Parameters needed based on input data type used. If using raster type, typepars should be a string
#' indicating the path to a folder containing the raster files that are referenced by the template.
#' For GRASS GIS type, typepars is a vector of 5 character strings. GRASS GIS parameters: gisBase, home, gisDbase, location, mapset.
#' Example parameters are included in an example script included in this package. See initGRASS help
#' for more info on parameters.
#' @param overwrite Overwrite existing redefine worldfile. FALSE is default and prompts a menu if worldfile already exists.
#' @seealso \code{\link{readRAST}}, \code{\link{raster}}
#' @author Will Burke
#' @export

world_redefine = function(template,
                          name,
                          type = 'Raster',
                          typepars,
                          overwrite = FALSE) {
  world_gen(
    template = template,
    worldfile = name,
    type = type,
    typepars = typepars,
    overwrite = overwrite,
    header = FALSE,
    asprules = NULL
  )
}
