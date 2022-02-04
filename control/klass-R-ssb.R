## remotes::install_github("statisticsnorway/klassR")
library("klassR")

head(GetKlass(klass = "115"))
SearchKlass("folketall")

befurl <- "https://data.ssb.no/api/v0/en/table/07459"


library(httr)
library(jsonlite)
befurl <- "https://data.ssb.no/api/v0/en/table/07459"

sget <- httr::GET(befurl)
stxt <- httr::content(sget, as = "text")
sjs <- jsonlite::fromJSON(stxt)

sdt <- sjs[["codes"]]
sdt
