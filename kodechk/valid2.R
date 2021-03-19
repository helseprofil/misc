## Validering KUBE
## rm(list = rm())
## library(here)
## library(data.table)
## library(stringi)
## library(fs)
## library(openxlsx)

pkg <- c("here", "data.table", "stringi", "fs", "openxlsx")
newpkg <- pkg[!(pkg  %in% installed.packages()[, "Package"])]
if (length(newpkg)) install.packages(newpkg)
sapply(pkg, require, character.only = TRUE)

## Specify path
## here::set_here()
## here() # check the path is correct

## ========================
## GEO Tabell from Acess
## ========================
## packrat::opts$external.packages("RODBC")
## geofil <- "f:/Prosjekter/Kommunehelsa/PRODUKSJON/STYRING/KHELSA.mdb"
## geocon <- RODBC::odbcConnectAccess2007(geofil)
## geotbl <- as.data.table(RODBC::sqlQuery(geocon, "select * from KnrHarm"))
## saveRDS(geotbl, "geoTabel.rds")

## Alle koder omkoding
geotbl <- readRDS("geoTabel.rds")
#kommune som er slått sammen
komMrg <- readRDS("komMerge.rds") 
## kommuner som er delt
komDel <- readRDS("komDelt.RDS")

## =====================
## ORG FIL
## =====================

## base path ORG
stiOrg <- "F:/Prosjekter/Kommunehelsa/PRODUKSJON/ORGDATA/UDIR/ELEVUNDER/ORG/"

## Exclude all folder before 2017
dtFil <- data.table(fs::dir_ls(stiOrg))
allYr <- as.numeric(unlist(stri_extract_all(fs::dir_ls(stiOrg), regex="\\d+")))
dtFil <- dtFil[, yr := allYr][yr > 2016]
stiRaw <- dtFil$V1

## allYr <- as.numeric( unlist(stri_extract_all(fs::dir_ls(stiOrg), regex="\\d+")))
## utYear <- allYr[allYr > 2016]
## stiRaw <- fs::dir_ls(stiOrg, regexp = ".*\\d[7891]$")



## Gamle GEO som skal ut pga. sammenslåing eller deling
## ----------------------
## geoUt <- fread(here("geo_ut.csv"))[[1]]
## paste(geoUt, collapse = ", ")

## geoUt <- c(1805, 1854, 1850, 1849,
##            5011, 1612, 1571, 5012,
##            1613, 5013, 1617, 5024,
##            1638, 5023, 1636, 5016,
##            1622, 2100)

## Gamle geokode som må ut
komMergePre <- unique(komMrg$prev)
komDelPre <- unique(komDel$prev)
geoUtPre <- c(komMergePre, komDelPre)

## Ny geokode som må ut
komMergeNye <- unique(komMrg$code)
komDelNy <- unique(komDel$code)
geoUtNy <- c(komMergeNye, komDelNy)




## Excel filer
##-----------------
## List all files
pb <- txtProgressBar(min = 0, max = length(stiRaw), style = 3)
filXlList <- list()
for (i in 1:length(stiRaw)){
  setTxtProgressBar(pb, i)
  utfil <- fs::dir_ls(stiRaw[i], regexp = "*.sx$", recurse = TRUE)
  filXlList[[i]] <- utfil
}

filXlRaw <- unlist(filXlList, use.names = FALSE)

## Read all XL files
pb <- txtProgressBar(min = 0, max = length(filXlRaw), style = 3)
filXldt <- list()
for (i in 1:length(filXlRaw)){
  setTxtProgressBar(pb, i)
  utfil <- openxlsx::read.xlsx(filXlRaw[i])
  utName <- grep(pattern = "lsid$", names(utfil), ignore.case = TRUE,value = TRUE)
  setnames(utfil, utName, "sid")
  filXldt[[i]] <- utfil
}

filXlAll <- rbindlist(filXldt)

## slett gamle GEO pga. slått sammen eller delt til flere
filXl <- filXlAll[!(GeografiId %in% c(geoUtPre, geoUtNy)), ]


## CSV filer
## ---------------
## List all files
pb <- txtProgressBar(min = 0, max = length(stiRaw), style = 3)
filCsvRaw <- list()
for (i in 1:length(stiRaw)){
    setTxtProgressBar(pb, i)
    utfil <- fs::dir_ls(stiRaw[i], regexp = "*.csv$", recurse = TRUE)
    filCsvRaw[[i]] <- utfil
}

filCsvRawList <- unlist(filCsvRaw, use.names = FALSE)

## Read all CSV file
pb <- txtProgressBar(min = 0, max = length(filCsvRawList), style = 3)
filCsvDt <- list()
for (i in 1:length(filCsvRawList)){
  setTxtProgressBar(pb, i)
  utfil <- fread(filCsvRawList[i], encoding = "UTF-8")
  utName <- grep(pattern = "lsid$", names(utfil), ignore.case = TRUE,value = TRUE)
  setnames(utfil, utName, "sid")
  filCsvDt[[i]] <- utfil
}

filCsvAll <- rbindlist(filCsvDt, fill = TRUE) #fill if colnames differs

## slett gamle GEO pga. slått sammen eller delt til flere
filCsv <- filCsvAll[!(GeografiId %in% c(geoUtPre, geoUtNy)), ]

message("\n\n Prosessen å slå sammen tabellene pågår ...")

## Merge Alle ORG filer
##-----------------------
DT <- rbindlist(list(filXl, filCsv), use.names = TRUE, fill = TRUE)

## Make it like KUBE colnames and coding
## --------------------------------------------
## AAR kolonne som i KUBE stil
DT[, AAR := stri_join(Periode, "_", Periode)]

## GeografiId som ikke er tall kan slettes
DT[, GEOint := stri_extract_all(GeografiId, regex = "\\d+")][, GEOint := as.integer(GEOint)]
## convertere GEO til nye


### ==== Recode value by checking GEO tabell ======================
## Henter gamle GEO og bytt til de nye
DT[geotbl, on = c(GEOint = "GEO"), GEO := i.GEO_omk]
DT[is.na(GEO), GEO := GEOint] #For de som allerede omkodet i rawdata filer ie. 2020 mappen
DT[, GEOint := NULL] #Midlertidig kolonne for konvertering GEO til inte


## Omkode kjønn tilpasse kube A=0 G=1 J=2
DT[.(Kjonn = c("A", "G", "J"), to = 0:2), on = "Kjonn", KJONN := i.to]

## Valg Spørsmål
## -----------------
## Beholder bare valgte spørsmål
## valgSID = 307
dtValg <- DT[sid == valgSID, ][, SPM_ID := sid][, TRINN := Trinn][]

## ## Delete columns that are not needed
## colMed <- intersect(dtname1, dtname2)
## colUt <- setdiff(dtName_02, dtName_01)
colUt <- c("Inv", "Fin")
set(dtValg,, j = colUt, value = NULL)

## Key
keyVar <- c("GEO", "AAR", "KJONN", "TRINN")
setkeyv(dtValg, keyVar)


## ==============
## KUBE FIL
## ==============

## kubeSti <- "F:\\Prosjekter\\Kommunehelsa\\PRODUKSJON\\PRODUKTER\\KUBER\\KOMMUNEHELSA\\KH2020NESSTAR\\"
kubeSti = stiTilKube

fil_kube <- kubeFil

dtKube <- fread(file.path(kubeSti, fil_kube))

setkeyv(dtKube, keyVar)




## Merge Alle
## ==============

dtAlle <- dtValg[dtKube]


## Write to CSV
## ===============
writePath <- fs::dir_create(here::here("KUBE"))
## saveAs = "Trivsel2.csv"
filchg <- unlist(strsplit(lagFil, split = ".", fixed = TRUE))
saveAs  <- paste0(filchg[1], "_",
                  format(Sys.Date(), "%y%m%d"),
                  "_", format(Sys.time(), "%H%M"), ".", filchg[2])

## saveAs = lagFil
## write.xlsx(dtAlle, file = file.path(writePath,"Trivsel.xlsx"), colNames=TRUE, asTable = TRUE)
data.table::fwrite(dtAlle, file = file.path(writePath, saveAs), sep=";")

message("\n Prosessen er ferdig!")
