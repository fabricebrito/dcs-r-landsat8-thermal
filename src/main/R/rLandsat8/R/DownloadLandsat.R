DownloadLandsat <- function(url, output.name) {
  # todo: use RCurl instead of the system call
  
  command.args <- paste0("-c cookies.txt -d 'username=", usgs.username, "&password=", usgs.password,"' https://earthexplorer.usgs.gov/login")
  
  # invoke the system call to curl.
  # I'd rather have done this with RCurl but couldn't get it working ;-(
  ret <- system2("curl", command.args, stdout=TRUE, stderr=TRUE)
  
  command.args <- paste0("-b cookies.txt -L ", url," -o ", output.name)
  ret <- system2("curl", command.args, stdout=TRUE, stderr=TRUE)
  
  file.remove(cookies.txt)
  
  return(ret)
  
}
