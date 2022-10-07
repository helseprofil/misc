## To use, run this code:
## source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
## kh_install(orgdata)
## kh_restore(khfunctions)
## kh_load(orgdata, ggplot2) # load eller installere flere pakker også from CRAN

## KHelse R packages and source files
khpkg <- c("orgdata", "norgeo", "KHompare")
khsrc <- c("khfunctions", "KHvalitetskontroll")

## load packages and install if not allready found ----------------------
kh_load <- function(..., silent = FALSE){
  pkgs <- as.character(match.call(expand.dots = FALSE)[[2]])
  pkgs <- pkg_name(pkgs)
  pk <- pkg_install(pkgs)
  pkg_kh(pk)

  if (silent){
    invisible(sapply(pkgs, require, character.only = TRUE))
  } else {
    sapply(pkgs, require, character.only = TRUE)
  }

  invisible()
}


## Install specialized packages for KHelse ------------------------------
kh_install <- function(..., path = NULL, packages = khpkg, not.packages = khsrc){

  warnOp <- getOption("warn")
  options(warn = -1)

  pkg <- as.character(match.call(expand.dots = FALSE)[[2]])
  pkg <- pkg_name(pkg)
  sourceGit <- is.element(pkg, not.packages)

  if (sourceGit){
    pkg <- is_not_package_msg(pkg, path)
  } else {
    pkg <- kh_package(pkg)
    msg <- paste0("Successfully installed ", pkg, ". Load package with `library(", pkg,")`")
  }

  khp <- intersect(pkg, packages)
  if (length(khp) != 0){
    if (!requireNamespace(pkg))
      stop("Fail to install ", pkg, "!")
  }

  show_msg(msg)
  options(warn = warnOp)
  invisible()
}


## Restore user branch for reproducibility ie. keep the same package version for
## dependencies ---------------------------------------------------------
kh_restore <- function(..., char, path = NULL){
  # char - Ignoring dots when imposing pkg as character
  warnOp <- getOption("warn")
  options(warn = -1)

  if (missing(char)){
    pkg <- as.character(match.call(expand.dots = FALSE)[[2]])
  } else {
    pkg <- char
  }

  pkg <- pkg_name(pkg)
  pkg <- kh_repo(pkg, path)
  khPath <- getwd()

  msg <- switch(pkg,
                khfunctions = {
                  source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/KHfunctions.R", encoding = "latin1")
                  paste0("RStudio will reload in 3 sec. You can use file `SePaaFil.R` in ", khPath)
                },
                KHvalitetskontroll = {
                 paste0("RStudio will reload in 3 sec. You can use file `Kvalitetskontroll.Rmd` in ", khPath)
                },
                paste0("Successfully installed ", pkg, ". Use `library(", pkg,")`")
                )

  show_msg(msg)
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
kh_package <- function(pkg = khpkg){
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


kh_repo <- function(pkg = c(khpkg, khsrc), ...){
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

pkg_kh <- function(pkg, packages = khpkg){

  kh <- intersect(pkg, packages)

  if (length(kh) > 0)
    sapply(kh, kh_install)

  invisible()
}

pkg_install <- function(pkinst){

  stop_not_package(pkinst)

  new.pkinst <- pkinst[!(pkinst %in% installed.packages()[,"Package"])]
  if(length(new.pkinst))
    install.packages(new.pkinst, repos = "https://cloud.r-project.org/")

  return(new.pkinst)
}

stop_not_package <- function(pkg, not.pkg = khsrc){
  notPkg <- any(pkg %in% not.pkg )
  if (notPkg){
    stop(pkg, " is not a package! Use `kh_install(", pkg,")` instead")
  }

  invisible()
}

# Ensure correct name as in repos
pkg_name <- function(x, kh.names = c(khpkg, khsrc)){
  x <- paste0("^", x)
  grep(x, kh.names, ignore.case = TRUE, value = TRUE)
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

# Repos that aren't R package
is_not_package_msg <- function(pkg, path, not.pkg = khsrc, sepafil = "SePaaFil.R"){

  notPkg <- any(pkg %in% not.pkg )
  if (grepl("^khvalitet", pkg, ignore.case = TRUE)){
    sepafil <- "Kvalitetskontroll.Rmd"
  }

  if (notPkg){
    kh_restore(char = force(pkg), path = path)
    mss <- paste0("Successfully installed ", pkg, ". Check `SePaaFil.R` file for usage.")
  }

  assign("msg", mss, envir = sys.frames()[[1]])
  return(pkg)
}
