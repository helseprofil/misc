## indikator : fil for indikator
## barometer: fil for barometer
## base : Sti for disse filene

check_bar <- function(type = c("FHP", "OVP"),
                      year = NULL,
                      geo = c("fylke", "kommune", "bydel"),
                      indikator = null,
                      barometer = NULL,
                      base = NULL
                      ){

  type <- match.arg(type)
  geo <- tolower(geo)
  geo <- match.arg(geo)

  if (is.null(base)){
    base <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/SSRS_filer"
  }

  path <- file.path(base, type, year, geo, "FigurOgTabell")

  if (is.null(barometer)){
    barometer = "inndataBarometer.dta"
  }

  if (is.null(indikator)){
    indikator <- ifelse(geo == "fylke", "Indikator_F.dta", "Indikator_ny.dta")
  }

  message("Leser filer fra ", path)
  cat("In progress ...")

  ## Barometer
  bar <- haven::read_dta(file.path(path, barometer))

  data.table::setDT(bar)
  barV1 <- c("stedskode_string",
             "stedskode_numeric",
             "indikator_kodet",
             "LPnr",
             "roede",
             "groenne",
             "hvitMprikk")
  bar[, setdiff(names(bar), barV1) := NULL]

  cat("...")
  data.table::setkey(bar, indikator_kodet)

  ## barometer id starts from 2 and is inverse of indikator id
  ## this makes it equivalent to indikator id
  ## bar[, kode := rev(indikator_kodet - 1)]

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
  bar[ind, (withVar) := mget(withVar), on = c(stedskode_string = "Sted_kode", LPnr = "LPnr")]

  verdiCol <- ifelse(geo == "fylke", "Verdi_mellomGeonivaa", "Verdi_lavesteGeonivaa")
  outDT <- bar[get(verdiCol) == Verdi_referansenivaa, ][
    !is.na(roede) | !is.na(groenne) | !is.na(hvitMprikk)]

  return(outDT)
}
