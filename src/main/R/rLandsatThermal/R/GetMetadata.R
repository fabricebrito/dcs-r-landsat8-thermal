GetMetadata <- function(landsat, field) {  

  meta.file <- paste0(landsat, "/", landsat, "_MTL.txt")
  
  textLines <- readLines(meta.file)
  
  counts <- count.fields(textConnection(textLines), sep="=")
  
  metadata <- read.table(text=textLines[counts == 2], header=TRUE, sep="=", strip.white=TRUE, stringsAsFactors=FALSE)
  
  colnames(metadata) <- c("name", "value")
  
  metadata <- metadata[!metadata$name == "GROUP", ] 
  metadata <- metadata[!metadata$name == "END_GROUP", ] 
  
  return(metadata[metadata$name == field, "value"])

}
