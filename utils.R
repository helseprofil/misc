## To use, run this code:
## source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
## kh_install(orgdata)
## kh_restore(khfunctions)


## Install specialized packages for KHelse ------------------------------
kh_install <- function(...){
  pkg <- kh_arg(...)
  kh_package(pkg)
  msg <- paste0("You can now use `library(", pkg,")`")
  message(msg)
  invisible()
}

kh_package <- function(pkg = c("orgdata", "norgeo", "KHompare", "bat2bat")){
  pkg <- pkg_name(pkg)
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  pkg_install("remotes")

  if (pkg %in% installed.packages()){
    unloadNamespace(pkg)
    remove.packages(pkg)
  }

  message("Start installing package ", pkg)
  pkgRepo <- paste0("helseprofil/", pkg)
  remotes::install_github(pkgRepo, upgrade = "always")
  invisible()
}


## Restore user branch for reproducibility ie. keep the same package version for
## dependencies
kh_restore <- function(...){
  pkg <- kh_arg(...)
  kh_repo(pkg)
  if (pkg == "khfunctions"){
    source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/KHfunctions.R")
    msg <- paste0("You can now use file `SePaaFil.R` in ", khPath)
  } else {
    msg <- paste0("You can now use `library(", pkg,")`")
  }

  message(msg)
  invisible()
}

kh_repo <- function(pkg = c("orgdata",
                            "norgeo",
                            "KHompare",
                            "bat2bat",
                            "khfunctions")){
  pkg <- pkg_name(pkg)
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  pkgs <- c("gert", "fs", "renv")
  pkg_install(pkgs)

  khRoot <- file.path(fs::path_home(), "helseprofil")
  if (!fs::dir_exists(khRoot)) fs::dir_create(khRoot)

  gitBranch <- switch(pkg,
                      khfunctions = "master",
                      "user")

  khPath <- file.path(khRoot, pkg)
  if (!fs::dir_exists(khPath)){
    khRepo <- paste0("https://github.com/helseprofil/", pkg)
    gert::git_clone(khRepo, path = khPath, branch = gitBranch)
    setwd(khPath)
    renv::activate()
    renv::restore()
  } else {
    setwd(khPath)
    gert::git_pull()
    renv::restore()
  }

  invisible()
}


kh_arg <- function(...){
  pkg <- tryCatch({
    unlist(list(...))
  },
  error = function(err){err})

  if (is(pkg, "error")){
    dots <- eval(substitute(alist(...)))
    pkg <- sapply(as.list(dots), deparse)
  }
  return(pkg)
}

pkg_install <- function(pkgs){
  new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
  if(length(new.pkgs)) install.packages(new.pkgs, repos = "https://cloud.r-project.org/")
  invisible()
}

pkg_name <- function(x){
  x <- tolower(x)
  if (x == "khompare"){
    x <- "KHompare"
  }
  return(x)
}
