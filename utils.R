## Install specialized packages for KHelse
kh_install <- c(pkg = c("orgdata", "norgeo", "KHompare", "bat2bat")){

  pkg <- match.arg(pkg)
  if (length(pkg) > 1) stop("Can't install more than one package at a time!")

  if(!requireNamespace("remotes")) install.packages("remotes")

  if (any(installed.packages() == pkg)){
    unloadNamespace(pkg)
    remove.packages(pkg)
  }

  pkgRepo <- paste0("helseprofil/", pkg)
  remotes::install_github(pkgRepo)
}
