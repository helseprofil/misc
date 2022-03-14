## Install specialized packages for KHelse
kh_install <- function(pkg = c("orgdata", "norgeo", "KHompare", "bat2bat")){
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  if(!requireNamespace("remotes")) install.packages("remotes")

  if (any(installed.packages() == pkg)){
    unloadNamespace(pkg)
    remove.packages(pkg)
  }

  message("Start installing package ", pkg)
  pkgRepo <- paste0("helseprofil/", pkg)
  remotes::install_github(pkgRepo)

  msg <- paste0("You can now use `library(", pkg,")`")
  message(msg)
  invisible()
}


## Clone user branch for reproducibility ie. keep the same package version for
## dependencies
kh_clone <- function(pkg = c("orgdata", "norgeo", "KHompare", "bat2bat", "khfunctions")){
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  pkgs <- c("gert", "fs", "renv")
  sapply(pkgs, function(x) {
    if(!requireNamespace(x))
      install.packages(x, repos = "https://cloud.r-project.org/")})

  khPath <- file.path(fs::path_home(), "helseprofil", pkg)

  if (!fs::dir_exists(khPath)){
    khRepo <- paste0("https://github.com/helseprofil/", pkg)
    gert::git_clone(khRepo, path = khPath, branch = "user")
    setwd(khPath)
    renv::restore()
  } else {
    setwd(khPath)
    gert::git_pull()
    renv::restore()
  }

  if (pkg == "khfunctions"){
    source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/KHfunctions.R")
    msg <- paste0("You can now use file `SePaaFil.R` in ", khPath)
  } else {
    msg <- paste0("You can now use `library(", pkg,")`")
  }

  message(msg)
  invisible()
}


## To use, run this code:
## source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
