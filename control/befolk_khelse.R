library(orgdata)
library(data.table)
library(norgeo)

## Read BEF file from KHfunction -------------------------
## normalizePath(readClipboard(), win = "/")
khpath <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/Publ.tidligere"
khfile <- "BEFOLK_GK_2021-04-07-10-16.csv"
dt <- read_file(file.path(khpath, khfile))

dt
str(dt)
dt[, LEVEL := fcase(
  GEO == 0, "land",
  nchar(GEO) %in% 3:4, "kommune",
  nchar(GEO) %in% 1:2, "fylke",
  nchar(GEO) %in% 5:6, "bydel",
  default = "none")]

df <- copy(dt)

dt <- dt[LEVEL == "kommune"]
dt[, .N, by= AAR]
dt[, .N, by=ALDER]
dt[, .N, by=LEVEL]

names(dt)
delCols <- c("RATE", "SMR", "SPVFLAGG")
dt[, (delCols) := NULL]
dt[, .N, by = ALDER]
dt

## SSB DATA --------
xlFolder <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/2022"
dtssb <- readRDS(file.path(xlFolder, "BEFOLK_SSB.rds"))
## saveRDS(dtssb, file.path(xlFolder, "BEFOLK_SSB.rds"))
dtssb[, .N, by = type]
dd <- dtssb[type %chin% c("group_kjonn", "group")]
dd
cols <- c("Tid", "ALDER", "type")
dd[, (cols) := NULL]
setnames(dd, c("Kjonn", "AGE"), c("KJONN", "ALDER" ))
dd

DT <- merge(dt, dd, by = c("AAR", "GEO", "ALDER", "KJONN"))
DT[order(AAR, GEO, ALDER, KJONN)]
DT[, DIFF := TELLER - TELLERssb]
DT[DIFF != 0][order(DIFF, decreasing = TRUE)]

saveRDS(DT, file.path(xlFolder, "BEF_SSBogKHELSE.rds"))

str(DT)

## EXCEL file for municipality border that have changed --------
rawSSB <- "1_Avvik_mellom _Raw_og_SSB.xlsx"
rawKH <- "2_Avvik_mellom_Raw_og_KHfunction.xls"

fileRawSSB <- read_file(file.path(xlFolder, rawSSB), skip = 2, header = TRUE, n_max = 21)
names(fileRawSSB)
geoRS <- as.numeric( fileRawSSB$V1[1:17] )
geoRS
## Alternative
fileRawSSB <- orgdata::read_file(file.path(xlFolder, rawSSB), range = "A5:A21", header = FALSE)
str(fileRawSSB)
geoRS <- as.integer(fileRawSSB$V1)
geoRS

DT[GEO %in% geoRS, border := 1]
DT[, .N, by=border]
DT[border == 1][order(DIFF)]
DT

fwrite(DT,"F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/2022/GK_SSB_KHfun.csv")

DT[GEO %in% c(5007, 5060) & ALDER == "0_4"][1:192]
options(datatable.print.topn=200)
