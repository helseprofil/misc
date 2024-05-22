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
  
  projects <- c("khfunctions", "KHvalitetskontroll")
  isProjects <- c(khfunctions, KHvalitetskontroll)
  projects <- projects[isProjects]
  
  if(length(projects) > 0){
    
    for(project in projects){
      branch <- data.table::fcase(project == "khfunctions", "master",
                                  project == "KHvalitetskontroll", "main",
                                  default = "main")
      message("\nInstalling ", project, " (", branch, " branch)...")
      repo <- paste0("https://github.com/helseprofil/", project, ".git")
      dir <- file.path(path, project)
      if(fs::dir_exists(dir)){
        setwd(dir)
        message("\n", dir, " already exists, updating master branch to current GitHub version...")
        invisible(system(paste0("git fetch origin ", branch)))
        invisible(system(paste0("git reset --hard origin/", branch)))
        invisible(system("git pull"))
      } else {
        invisible(system(paste("git clone", repo, dir)))
        message(project, " cloned into: ", dir)
      }
    }  
  }
  
  message("\nWOHOO, done! \n\nOpen the .Rproj file in the project folders to use the systems.")
}


#' Clones all projects into a folder
#'
#' @param path 
DevelopSystems <- function(path){
  
  
  projects <- c("misc", 
                "manual", 
                "khfunctions", 
                "KHvalitetskontroll", 
                "norgeo", 
                "orgdata", 
                "config", 
                "GeoMaster", 
                "snutter")
  
  if(is.null(path)){
    stop("Path not set")
  }
  
  if(!fs::dir_exists(path)){
    fs::dir_create(path)
  }
  
  for(project in projects){
    
    repo <- paste0("https://github.com/helseprofil/", project, ".git")
    dir <- file.path(path, project)
    
    if(!fs::dir_exists(dir)){
      invisible(system(paste("git clone", repo, dir)))
      message(project, " cloned into: ", dir)
    } else {
      message(dir, " already exists")
    }
    
  }
}

  