#' creates a raster with the classified Normalized Burn Ratio (NBR) index
#' @description Creates a raster with the classified Normalized Burn Ratio (NBR) index 
#'
#' @param prefire name of the prefire product, e.g. LC80522102014165LGN00. It must be in the working directory.
#' @param postfire name of the postfire product, e.g. LC80522102014165LGN00. It must be in the working directory.
#' @return classified Normalized Burn Ratio (NBR) raster
#' @examples \dontrun{
#' prels8 <- ReadLandsat8("LC81880342014174LGN00")
#' postls8 <- ReadLandsat8("")
#' r <- ToNBRClass(prels8, postls8)
#' }
#'
#' @export
#' @import raster

ToNBRClass <- function(prefire, postfire) {

  # classify
  m <- c(-500, -251, 1, -205, -101, 2, -100, 99, 3, 100, 269, 4, 270, 439, 5, 440, 659, 6, 660, 1300, 7)
  class.mat <- matrix(m, ncol=3, byrow=TRUE)

  reclass <- reclassify(10^3 * dNBR(prefire, postfire), class.mat)
  return(reclass)

}
