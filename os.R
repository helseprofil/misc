## Check OS for proper path
get_os <- function(){
  OS <- Sys.info()["sysname"]
  pathProfil <- switch(OS,
                       Linux="/mnt/F/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/",
                       Windows="F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/"
                       )
}
