# To use, run this code:
# source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
# kh_install(orgdata) #vanlig bruker
# kh_install(khfunctions)
# kh_restore(orgdata) #utvikler
# kh_restore(khfunctions)
# kh_load(orgdata, ggplot2) # load eller installere flere pakker også from CRAN

# KHelse R packages and source files
# ----------------------------------
# package bat2bat is not mantained and excluded
khpkg <- c("orgdata", "norgeo", "KHompare", "lespdf")
khsrc <- c("khfunctions", "KHvalitetskontroll")

# Load or install any packages including those from CRAN
# ------------------------------------------------------
kh_load <- function(..., char, silent = FALSE){
  # char - If package names in a vector object
  if (missing(char)){
    pkgs <- as.character(match.call(expand.dots = FALSE)[[2]])
  } else {
    pkgs <- char
  }

  pkgs <- pkg_name(pkgs)
  stop_not_package(pkgs)
  install_cran_pkg(pkgs)
  install_kh_pkg(pkgs)

  if (silent){
    invisible(sapply(pkgs, require, character.only = TRUE))
  } else {
    suppressPackageStartupMessages(sapply(pkgs, require, character.only = TRUE))
  }
}


# Install specialized packages for KHelse
# ---------------------------------------
kh_install <- function(..., path = NULL,
                       char, packages = khpkg,
                       not.packages = khsrc,
                       upgrade = FALSE){
  # path - Specify the path to install/restore if not using default ie. c:/Users/YourUserName/helseprofil
  # char - If using character vector object
  # upgrade - if TRUE then upgrade all the dependencies
  warnOp <- getOption("warn")
  options(warn = -1)

  if (missing(char)){
    pkg <- as.character(match.call(expand.dots = FALSE)[[2]])
  } else {
    pkg <- char
  }

  repo_branch(x = pkg)

  pkg <- pkg_name(pkg)
  sourceGit <- is.element(pkg, not.packages)

  if (length(sourceGit) > 1)
    stop("Can't install more than one package at a time! Try `kh_load()` instead.")

  if (sourceGit){
    kh_restore(char = pkg, path = path)
  } else {
    pkg <- kh_package(pkg, upgrade, gitBranch)
  }

  khp <- intersect(pkg, packages)
  if (length(khp) != 0){
    if (!requireNamespace(pkg))
      stop(simpleError("Fail to install ", pkg, "!"))
  }

  msg <- msg_text(x = pkg, action = "install")
  msg_show(msg)
  options(warn = warnOp)
  invisible()
}


# Restore user branch for reproducibility ie. keep the same
# package version for dependencies
# -------------------------------------------------------------
kh_restore <- function(..., char, path = NULL){
  # char - Ignoring dots when imposing pkg as character in a vector object
  # path - Specify the path to install if not using default ie. c:/Users/YourUserName/helseprofil
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

  msg <- msg_text(x = pkg, action = "restore")

  msg_show(msg)
  options(warn = warnOp)
  Sys.sleep(4)

  # Activate project in RStudio
  proj <- paste0(pkg, ".Rproj")
  if(fs::file_exists(proj)){
    rstudioapi::openProject(proj, newSession = TRUE)
  }

  invisible()
}

# Make sourcing of branch for testing easily
# ------------------------------------------
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


# Helper functions
# -------------------------------------------------

# Ensure correct name as it is written in repos name
# Eg. KHfunctions repos name is khfunctions.
pkg_name <- function(x, kh.packages = c(khpkg, khsrc)){
  x <- setNames(x, x)
  x2 <- sapply(x, function(x) grep(paste0("^", x), kh.packages, ignore.case = T, value = T))
  x2 <- Filter(length, x2)
  x[names(x2)] <- x2
  x <- unlist(x, use.names = FALSE)
  return(x)
}

kh_package <- function(pkg = khpkg, upgrade = upgrade, branch = NULL){
  pkg <- pkg_name(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time! Try `kh_load()` instead.")

  install_cran_pkg("pak")

  if (requireNamespace(pkg, quietly = TRUE)){
    if (isTRUE(isNamespaceLoaded(pkg))){
      unloadNamespace(pkg)
    }
    remove.packages(pkg)
  }

  message("Start installing package ", pkg)
  z <- pkg

  if (!is.null(branch))
    pkg <- paste0(pkg, "@", branch)

  pkgRepo <- paste0("helseprofil/", pkg)
  pak::pkg_install(pkgRepo, upgrade = upgrade)
  invisible(z)
}

kh_repo <- function(pkg = c(khpkg, khsrc), ...){
  pkg <- pkg_name(pkg)
  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't restore more than one package at a time!")

  pkgs <- c("gert", "fs", "renv")
  install_cran_pkg(pkgs)

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

repo_branch <- function(x, sep = "@"){

  if(grepl(sep, x)){
    z <- unlist(strsplit(x, sep))
    x <- z[1]
    g <- z[2]
  } else {
    g <- NULL
  }

  assign("pkg", x, parent.frame())
  assign("gitBranch", g, parent.frame())
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
install_kh_pkg <- function(x, pkg = khpkg){
  kh.pkg <- intersect(x, pkg)
  kh <- kh.pkg[!(kh.pkg %in% installed.packages()[,"Package"])]

  if (length(kh))
    sapply(kh, function(x) kh_install(char = x))

  invisible()
}

# Install R package from CRAN
install_cran_pkg <- function(x, kh.packages = c(khpkg, khsrc)){

  cran <- setdiff(x, kh.packages)
  new.cran <- cran[!(cran %in% installed.packages()[,"Package"])]
  if(length(new.cran))
    install.packages(new.cran, repos = "https://cloud.r-project.org/")

  invisible()
}

stop_not_package <- function(x, not.pkg = khsrc){
  notPkg <- any(x %in% not.pkg)
  if (notPkg){
    pkgSrc <- intersect(x, not.pkg)[1]
    msg <- paste0(pkgSrc, " is not R package! Use `kh_install(", pkgSrc,")` instead.")
    stop(simpleError(msg))
  }

  invisible()
}

msg_text <- function(x , action = c("install", "restore"),
                     pkg = khpkg, not.pkg = khsrc,
                     sepafil = "SePaaFil.R"){

  notPkg <- any(x %in% not.pkg )
  if (grepl("^khvalitet", x, ignore.case = TRUE)){
    sepafil <- "Kvalitetskontroll.Rmd"
  }

  txt <- switch(action,
                install = "Successfully installed ",
                restore = "Restore completed! RStudio will restart in project "
                )

  if (notPkg){
    msg <- paste0(txt, x, ". Check `", sepafil, "` file for usage.")
  } else {
    msg <- paste0(txt, x, ". Load with `library(", x,")`")
  }

  return(msg)
}

msg_show <- function(msg, symbol = "thumb", type = "note"){
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

#' are_same
#' 
#' Check if two functions are identical, useful when developing a function to highlight differences. 
#'
#' @param f1 
#' @param f2 
are_same <- function(f1, f2) {
  f_new_text <- gsub("^#.*\n", "", deparse(f1))
  f_old_text <- gsub("^#.*\n", "", deparse(f2))
  
  if (identical(gsub("\\s", "", f_new_text), gsub("\\s", "", f_old_text))) {
    return(TRUE)
  } else {
    cat("The functions are not identical:\n")
    cat("=============================\n\n")
    diff <- diffobj::diffPrint(f_new_text, f_old_text)
    print(diff)
    return(FALSE)
  }
}

#' list_funs
#' 
#' returns a list of all functions from a package 
#' in the format `fun1\(|fun2\(|` etc. Useful to search a 
#' project for use of these functions when not specified with `package::function()`..
#'
#' @param package 
list_funs <- function(package = NULL) {
  
  funs <- getNamespaceExports(package)
  funs <- funs[order(funs)]
  
  # Add "\\" before characters that should be escaped (written by ChatGPT)
  escape_chars <- function(string) {
    chars_to_escape <- c("(", ")", "[", "]", "$", ".", "|")
    escaped_chars <- c("\\(", "\\)", "\\[", "\\]", "\\$", "\\.", "\\|")
    for (i in seq_along(chars_to_escape)) {
      string <- gsub(chars_to_escape[i], escaped_chars[i], string, fixed = TRUE)
    }
    return(string)
  }
  
  funs <- escape_chars(funs)
  
  regex_str <- paste0(funs, collapse = "\\(|")
  
  cat(paste0(regex_str, "\\("))
}
