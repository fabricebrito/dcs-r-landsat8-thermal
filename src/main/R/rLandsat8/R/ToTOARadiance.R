#' creates a raster with the TOA radiance 
#' @description Creates a raster with the TOA radiance
#'
#' @param landsat8 list returned by rLandsat8::ReadLandsat8
#' @param band Landsat 8 bandname (one of "aerosol", "blue", "green", "red", "nir", "swir1", "swir2", "panchromatic", "cirrus", "tirs1", "tirs2" 
#' @return TOA Radiance raster
#' @examples \dontrun{
#' ls8 <- ReadLandsat8("LC80522102014165LGN00"
#' r <- ToTOARadiance(ls8, "tirs1)
#' }
#'
#' @export
#' @import raster

ToTOARadiance <- function(landsat8, band) {

  bandnames <-c("aerosol", "blue", "green", "red",
  "nir", "swir1", "swir2",
  "panchromatic",
  "cirrus",
  "tirs1", "tirs2")
  
  # todo check if band is in bandnames

  idx <- seq_along(bandnames)[sapply(bandnames, function(x) band %in% x)]

  ml <- landsat8$metadata$[[paste0("radiance_mult_band_",idx)]]
  al <- landsat8$metadata$[[paste0("radiance_add_band_",idx)]]
  
  TOArad <- landsat8$band[["tirs1"]] * ml + al
  
  return(TOArad)
  
}
