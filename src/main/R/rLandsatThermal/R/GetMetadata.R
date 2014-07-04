GetMetadata <- function(product) {  

  meta.file <- paste0(product, "/", product, "_MTL.txt")
  
  textLines <- readLines(meta.file)
  
  counts <- count.fields(textConnection(textLines), sep="=")
  
  met <- read.table(text=textLines[counts == 2], as.is=TRUE, header=FALSE, sep="=", strip.white=TRUE, stringsAsFactors=FALSE)
  
  met <- read.table(text=textLines[counts == 2], as.is=TRUE, header=FALSE, sep="=", strip.white=TRUE, stringsAsFactors=FALSE, row.names = NULL, col.names=c("name", "value"))
  
  met <- met[!met$name == "GROUP", ] 
  met <- met[!met$name == "END_GROUP", ] 
  rownames(met) <- tolower(met[, "name"])
  met[, "name"] <- NULL
  
  return(list(metadata=as.list(as.data.frame(t(met), stringsAsFactors=FALSE))))
}
