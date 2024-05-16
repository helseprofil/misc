#' ProfileSystems
#' 
#' This function installs all packages and projects needed for FHP/OVP-related work
#' 
#' If path is not provided, C:/Users/name/helseprofil will be the root folder for other
#' projects to be installed into. 
#' 
#' @param path root folder where you want the projects to be stored
#' @param all Default = TRUE, will install/update all objects
#' @param packages default = FALSE, if all = FALSE, set this option to TRUE to install CRAN packages
#' @param norgeo default = FALSE, if all = FALSE, set this option to TRUE to install norgeo
#' @param orgdata default = FALSE, if all = FALSE, set this option to TRUE to install orgdata
#' @param khfunctions default = FALSE, if all = FALSE, set this option to TRUE to install khfunctions
#' @param KHvalitetskontroll default = FALSE, if all = FALSE, set this option to TRUE to install khvalitetskontroll
#' 
#' @examples
#' 
#' source("https://raw.githubusercontent.com/helseprofil/misc/main/ProfileSystems.R")
#' 
#' Install everything with:
#' ProfileSystem(all = T)
#' 
#' Install specific parts with:
#' ProfileSystem(all = F, packages = T, khfunctions = T, KHvalitetskontroll = T)
#' 
#' Install to other path than `C:/Users/name/helseprofil`
#' ProfileSystem(path = "Your/Preferred/Path)
ProfileSystems <- function(path = NULL,
                           all = TRUE,
                           packages = FALSE,
                           norgeo = FALSE,
                           orgdata = FALSE,
                           khfunctions = FALSE,
                           KHvalitetskontroll = FALSE){
  
  if(isTRUE(all)){
    packages <- TRUE
    norgeo <- TRUE
    orgdata <- TRUE
    khfunctions <- TRUE
    KHvalitetskontroll <- TRUE
  }
  
  if(isTRUE(packages)){
    packages <- c("collapse",
                  "conflicted",
                  "data.table",
                  "devtools",
                  "DBI",
                  "dplyr",
                  "DT",
                  "epitools",
                  "forcats",
                  "foreign",
                  "fs",
                  "ggforce",
                  "ggh4x",
                  "ggplot2",
                  "ggtext",
                  "httr2",
                  "intervals",
                  "pak",
                  "plyr",
                  "purrr",
                  "readxl",
                  "remotes",
                  "RODBC",
                  "sas7bdat",
                  "sqldf",
                  "stringr",
                  "usethis",
                  "testthat",
                  "XML",
                  "zoo")
    
    missingpackages <- setdiff(packages, installed.packages()[, "Package"])
    
    if (length(missingpackages) > 0) {
      message(paste("Installing missing packages:", paste(missingpackages, collapse = ", ")))
      install.packages(missingpackages)
    }
  }
  
  # Install packages from GitHub
  if(isTRUE(norgeo)){
    message("\nInstalling norgeo...")
    remotes::install_github("helseprofil/norgeo")
  }
  
  if(isTRUE(orgdata)){
    message("\nInstalling orgdata...")
    remotes::install_github("helseprofil/orgdata")
  }
  # Set base folder for installing projects. Always create the helseprofil folder as well. 
  message("\nGenerating folders:")
  helseprofil <- file.path(fs::path_home(), "helseprofil")
  if(!fs::dir_exists(helseprofil)){
    fs::dir_create(helseprofil)
    cat("\n- ", helseprofil)
  } else {
    cat("\n- ", helseprofil, " already exists")
  }
  
  if(is.null(path)){
    path <- helseprofil
  } 
    
  if(!fs::dir_exists(path)){
      fs::dir_create(path)
      cat("\n- ", path)
  }

  message("\n\nR Projects will be installed into ", path)

  if(isTRUE(khfunctions)){
    message("\nInstalling khfunctions (master branch)...")
    khfunctions_repo <- "https://github.com/helseprofil/khfunctions.git"
    khfunctions_dir <- file.path(path, "khfunctions")
    if(fs::dir_exists(khfunctions_dir)){
      setwd(khfunctions_dir)
      invisible(system("git fetch origin master"))
      invisible(system("git reset --hard origin/master"))
      invisible(system("git pull"))
      message("khfunctions master branch restored to current GitHub version")
      } else {
        invisible(system(paste("git clone", khfunctions_repo, khfunctions_dir)))
        message("khfunctions cloned into: ", khfunctions_dir)
      }
  }
  
  if(isTRUE(KHvalitetskontroll)){
    message("\nInstalling KHvalitetskontroll (main branch)...")
    KHvalitetskontroll_repo <- "https://github.com/helseprofil/KHvalitetskontroll.git"
    KHvalitetskontroll_dir <- file.path(path, "KHvalitetskontroll")
    if(fs::dir_exists(KHvalitetskontroll_dir)){
      setwd(KHvalitetskontroll_dir)
      invisible(system("git fetch origin main"))
      invisible(system("git reset --hard origin/main"))
      invisible(system("git pull"))
      message("KHvalitetskontroll main branch restored to current GitHub version")
      } else {
        invisible(system(paste("git clone", KHvalitetskontroll_repo, KHvalitetskontroll_dir)))
        message("KHvalitetskontroll cloned into: ", KHvalitetskontroll_dir)
      }
  }
  
  message("\nWOHOO, done! \n\nOpen the .Rproj file in the project folders to use the systems.")
}
