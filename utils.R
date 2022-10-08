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
  pkg_cran_install(pkgs)
  pkg_kh_install(pkgs)

  if (silent){
    invisible(sapply(pkgs, require, character.only = TRUE))
  } else {
    sapply(pkgs, require, character.only = TRUE)
  }

  invisible()
}


## Install specialized packages for KHelse ------------------------------
kh_install <- function(..., path = NULL, char, packages = khpkg, not.packages = khsrc){

  warnOp <- getOption("warn")
  options(warn = -1)

  if (missing(char)){
    pkg <- as.character(match.call(expand.dots = FALSE)[[2]])
  } else {
    pkg <- char
  }

  pkg <- pkg_name(pkg)
  sourceGit <- is.element(pkg, not.packages)

  if (sourceGit){
    kh_restore(char = pkg, path = path)
  } else {
    pkg <- kh_package(pkg)
  }

  khp <- intersect(pkg, packages)
  if (length(khp) != 0){
    if (!requireNamespace(pkg))
      stop(simpleError("Fail to install ", pkg, "!"))
  }

  msg <- show_done_msg(x = pkg, action = "install")
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

  msg <- show_done_msg(x = pkg, action = "restore")

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
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  pkg_cran_install("remotes")

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
  pkg_cran_install(pkgs)

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

# Install KHelse packages from Github
pkg_kh_install <- function(pkg, packages = khpkg){

  kh.pkg <- intersect(pkg, packages)
  kh <- kh.pkg[!(kh.pkg %in% installed.packages()[,"Package"])]

  if (length(kh))
    sapply(kh, function(x) kh_install(char = x))

  invisible()
}

# Install R package from CRAN
pkg_cran_install <- function(pkg, kh.packages = c(khpkg, khsrc)){

  # needed when using kh_load
  pkinst <- stop_not_package(pkg)
  pkinst <- setdiff(pkg, kh.packages)

  new.pkinst <- pkinst[!(pkinst %in% installed.packages()[,"Package"])]
  if(length(new.pkinst))
    install.packages(new.pkinst, repos = "https://cloud.r-project.org/")

  invisible()
}

stop_not_package <- function(pkg, not.pkg = khsrc){

  Rpkg <- setdiff(pkg, not.pkg)
  notPkg <- any(pkg %in% not.pkg )
  if (notPkg){
    pkgSrc <- intersect(pkg, not.pkg)[1]
    msg <- paste0(pkgSrc, " is not an R package! Use `kh_install(", pkgSrc,")` instead")
    stop(simpleError(msg))
  }

  invisible(Rpkg)
}

# Ensure correct name as in repos
pkg_name <- function(x, kh.names = c(khpkg, khsrc)){
  x <- setNames(x, x)
  # Exclude other packages that aren't KHelse
  x2 <- sapply(x, function(x) grep(paste0("^", x), kh.names, ignore.case = T, value = T))
  x2 <- Filter(length, x2)
  x[names(x2)] <- x2
  x <- unname(unlist(x))
  return(x)
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

show_done_msg <- function(x , action = c("install", "restore"),
                          pkg = khpkg, not.pkg = khsrc,
                          sepafil = "SePaaFil.R"){

  notPkg <- any(x %in% not.pkg )
  if (grepl("^khvalitet", x, ignore.case = TRUE)){
    sepafil <- "Kvalitetskontroll.Rmd"
  }

  msgAct <- switch(action,
                   install = "Successfully installed ",
                   restore = "Successfully restored. RStudio will restart in project "
                   )

  if (notPkg){
    msg <- paste0(msgAct, pkg, ". Check `", sepafil, "` file for usage.")
  } else {
    msg <- paste0(msgAct, pkg, ". Load with `library(", pkg,")`")
  }

  return(msg)
}
