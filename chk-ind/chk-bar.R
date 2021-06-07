packages <- c("data.table", "haven")

ipkg <- function(pkg){
  newp <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if(length(newp)) install.packages(newp, repos = "https://cran.uib.no", dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipkg(packages)

fpath <- "F:/Prosjekter/Kommunehelsa/PRODUKSJON/PRODUKTER/SSRS_filer/OVP/2020/Kommune/FigurOgTabell"
indDTA <- "Indikator_ny.dta"
barDTA <- "inndataBarometer.dta"

## indikator : fil for indikator
## barometer: fil for barometer
## path : Sti for disse filene

check_bar <- function(type = c("FHP", "OVP"),
                      year = NULL,
                      geo = c("fylke", "kommune", "bydel"),
                      indikator = NULL,
                      barometer = NULL,
                      path = NULL
                      ){

  cat("In progress ...")
  type <- match.arg(type)
  geo <- match.arg(geo)

  ## Barometer
  bar <- haven::read_dta(file.path(path, barometer))

  data.table::setDT(bar)
  barV1 <- c("stedskode_string",
             "stedskode_numeric",
             "indikator_kodet",
             "roede",
             "groenne",
             "hvitMprikk")
  bar[, setdiff(names(bar), barV1) := NULL]

  cat("...")
  data.table::setkey(bar, indikator_kodet)
  ## barometer id starts from 2 and is inverse of indikator id
  ## this makes it equivalent to indikator id
  bar[, kode := rev(indikator_kodet - 1)]

  ## Indicator
  cat("...")
  indraw <- haven::read_dta(file.path(path, indikator))
  
  data.table::setDT(indraw)
  indV1 <- grep("Verdi", names(indraw), value = TRUE)
  indVar <- c("Aar", "LPnr","Sted_kode", "SpraakId", indV1)
  indraw[, setdiff(names(indraw), indVar) := NULL]
  ind <- indraw[SpraakId == "BOKMAAL"]

  cat("... \n\n")
  withVar <- c("Aar", indV1)
  bar[ind, (withVar) := mget(withVar), on = c(stedskode_string = "Sted_kode", kode = "LPnr")]
  setnames(bar, "kode", "LPnr")
  bar

  outD <- bar[Verdi_lavesteGeonivaa == Verdi_referansenivaa, ][
    !is.na(roede) | !is.na(groenne) | !is.na(hvitMprikk)]

  return(outD)
}
