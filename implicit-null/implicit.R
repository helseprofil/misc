## Check implicit null
path <-"F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/DEVELOP/Rawdata_implesitteNuller"

library(haven)
dt <- read_dta(file.path(path, "Dode_2016_2017.dta"))

library(data.table)
setDT(dt)
## dt[, .N, keyby=aar]

dt <- dt[, lapply(.SD, as.vector)]
## str(dt)

## ref <- sort(unique(dt$v4))
## aar <- unique(dt$aar)

## length(ref)
## length(unique(dt$v4[dt$aar == 2016]))
## length(unique(dt$v4[dt$aar == 2017]))

## dt - dataset
## var - Colname to be checked
## year - Colname for year
impnull <- function(dt, year, var){
  var <- as.character(deparse(substitute(var)))
  year <- as.character(deparse(substitute(year)))
  ref <- sort(unique(dt[[var]]))
  aar <- unique(dt[[year]])
  nn <- vector(mode = "list", length = length(aar))

  for (i in seq_along(aar)){
    yr <- aar[i]
    dd <- setdiff(ref, unique(dt[[var]][dt[[year]] == yr]))
    ## print(dd)
    nn[[i]] <- dd
    names(nn)[i] <- paste0("yr",yr)
  }
  return(nn)
}

nn <- impnull(dt, aar, v4)
nn
