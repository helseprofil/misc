library(data.table)
library(norgeo)
library(orgdata)

xlFolder <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/2022"
dt <- readRDS(file.path(xlFolder, "BEFOLK_SSBogBEF.rds"))
dt[GEO == 9999]

## EXCEL ---
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

str(dt)
dt[GEO %in% geoRS, border := 1]
dt[, .N, by=border]
dt[border == 1][order(DIFF)]

fwrite(dt,"F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/2022/GK_SSB_all.csv")


## SSB data ----------------------
library(data.table)
ssb <- readRDS("N:/Helseprofiler/control/BEF_SSB_1990_2021.rds")
setDT(ssb)
str(ssb)

vars <- c("GEO", "ALDER", "Tid")
for (j in vars) set(ssb, j=j, value = as.numeric(ssb[[j]]))

ssb[GEO == 1806 & Tid == 1999 & ALDER %in% 25:29]
ssb[GEO == 1806 & Tid == 1999 & ALDER %in% 0:4]
ssb[GEO == 1806 & Tid == 1999 & ALDER %in% 15:19]
ssb[GEO == 1806 & Tid == 1999 & ALDER %in% 35:39]
ssb[GEO == 1806 & Tid == 1999 & ALDER %in% 20:24]
ssb[Region %like% "^K-Rest"]
ssb[Region %like% "^K-99"]




## NORGEO ------------------

dd <- track_merge("k", 2018, 2021)
str(dd)
dd[currentCode == "1535"]
