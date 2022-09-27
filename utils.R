## To use, run this code:
## source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
## kh_install(orgdata)
## kh_restore(khfunctions)
## kh_load(orgdata, ggplot2) # load eller installere flere pakker også from CRAN


## load packages and install if not allready found ----------------------
kh_load <- function(..., silent = FALSE){
  pkgs <- kh_arg(...)
  pkgs <- pkg_name(pkgs)
  pk <- pkg_install(pkgs)
  pkg_kh(pk)

  if (silent){
    invisible(sapply(pkgs, require, character.only = TRUE))
  } else {
    sapply(pkgs, require, character.only = TRUE)
  }
}


## Install specialized packages for KHelse ------------------------------
kh_install <- function(..., path = NULL){

  warnOp <- getOption("warn")
  options(warn = -1)

  pkg <- kh_arg(...)

  pkf <- grepl("khfun", pkg, ignore.case = TRUE)
  pkk <- grepl("khvalitet", pkg, ignore.case = TRUE)
  if (pkf){
    kh_restore(pkg, path = path)
    msg <- paste0("Successfully installed ", pkg, ". Check `SePaaFil.R` file for usage.")
  } else if (pkk){
    kh_restore(pkg, path = path)
    msg <- paste0("Successfully installed ", pkg, ". Open `Kvalitetskontroll.Rmd for usage")
  } else {
    pkg <- kh_package(pkg)
    msg <- paste0("Successfully installed ", pkg, ". Load package with `library(", pkg,")`")
  }

  if (pkg == "orgdata"){
    if (!requireNamespace("orgdata"))
      stop("Fail to install ", pkg, "!")
  }

  show_msg(msg)
  options(warn = warnOp)
  invisible()
}

show_msg <- function(msg, symbol = "thumb", type = "note"){
  if (requireNamespace("orgdata", quietly = TRUE)){
    orgdata:::is_color_txt(x = "",
                           msg = msg,
                           type = type,
                           emoji = TRUE,
                           symbol = symbol)
  } else {
    message(msg)
  }

  invisible()
}


## Restore user branch for reproducibility ie. keep the same package version for
## dependencies ---------------------------------------------------------
kh_restore <- function(..., path = NULL){
  warnOp <- getOption("warn")
  options(warn = -1)

  pkg <- kh_arg(...)
  pkg <- kh_repo(pkg, path)

  khPath <- getwd()

  if (pkg == "khfunctions"){
    source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/KHfunctions.R", encoding = "latin1")
    msg <- paste0("RStudio will reload in 3 sec. You can use file `SePaaFil.R` in ", khPath)
  } else if (pkg == "KHvalitetskontroll"){
    msg <- paste0("RStudio will reload in 3 sec. You can use file `Kvalitetskontroll.Rmd` in ", khPath)
  } else {
    msg <- paste0("Successfully installed ", pkg, ". Use `library(", pkg,")`")
  }

  if (requireNamespace("orgdata", quietly = TRUE)){
    orgdata:::is_color_txt(x = "",
                           msg = msg,
                           type = "note",
                           emoji = TRUE)
  } else {
    message(msg)
  }

  options(warn = warnOp)
  Sys.sleep(4)

  # Activate project in RStudio
  proj <- paste0(pkg, ".Rproj")
  if(fs::file_exists(proj)){
    rstudioapi::openProject(proj, newSession = TRUE)
  }

  invisible()
}

## Make sourcing of branch for testing easily
kh_source <- function(repo, branch, file, encoding = NULL){

  gitBase <- "https://raw.githubusercontent.com/helseprofil"
  gitURL <- paste(gitBase, repo, branch, file, sep = "/")
  message("Source file ", gitURL)
  message("From branch ", branch)

  if (is.null(encoding)){
    source(gitURL)
  } else {
    source(gitURL, encoding = encoding)
  }

  invisible()
}

## Helper functions -------------------------------------------------
kh_package <- function(pkg = c("orgdata", "norgeo", "KHompare")){
  # package bat2bat not mantained and excluded
  pkg <- pkg_name(pkg)
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  pkg_install("remotes")

  if (requireNamespace(pkg, quietly = TRUE)){
    if (isTRUE(isNamespaceLoaded(pkg))){
      unloadNamespace(pkg)
    }
    remove.packages(pkg)
  }

  message("Start installing package ", pkg)
  pkgRepo <- paste0("helseprofil/", pkg)
  remotes::install_github(pkgRepo, upgrade = "always")
  invisible(pkg)
}


kh_repo <- function(pkg = c("orgdata",
                            "norgeo",
                            "KHompare",
                            ## "bat2bat",
                            "khfunctions",
                            "KHvalitetskontroll"), ...){
  pkg <- pkg_name(pkg)
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't restore more than one package at a time!")

  pkgs <- c("gert", "fs", "renv")
  pkg_install(pkgs)

  gitBranch <- switch(pkg,
                      khfunctions = "master",
                      KHvalitetskontroll = "main",
                      "user")

  khPath <- kh_root(pkg, ...)
  if (!fs::dir_exists(khPath)){
    khRepo <- paste0("https://github.com/helseprofil/", pkg)
    gert::git_clone(khRepo, path = khPath, branch = gitBranch)
  }

  setwd(khPath)
  gert::git_pull()
  renv::activate()
  renv::restore()
  invisible(pkg)
}

kh_root <- function(pkg, path = NULL){
  if (is.null(path)) {
    path <- file.path(fs::path_home(), "helseprofil")
  }

  if (!fs::dir_exists(path)) fs::dir_create(path)

  x  <- file.path(path, pkg)
  return(x)
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

pkg_kh <- function(pkg){

  khpkg <- c("orgdata", "norgeo", "KHompare")
  kh <- intersect(pkg, khpkg)

  if (length(kh) > 0)
    sapply(kh, kh_install)

  invisible()
}

pkg_install <- function(pkgs){
  notPkg <- any(pkgs == "khfunctions")
  if (notPkg){
    stop("KHfunctions is not a package! Use `kh_install(khfunctions)` instead.")
  }

  new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
  if(length(new.pkgs))
    install.packages(new.pkgs, repos = "https://cloud.r-project.org/")

  return(new.pkgs)
}

pkg_name <- function(x){
  x <- tolower(x)
  y <- "khompare"
  z <- "khvalitetskontroll"

  if (any(x == y)){
    ind <- grep(y, x)
    x[ind] <- "KHompare"
  }
  
  if (any(x == z)){
    ind <- grep(z, x)
    x[ind] <- "KHvalitetskontroll"
  }

  return(x)
}


