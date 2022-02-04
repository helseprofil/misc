# Sjekk mot SSB sine tall
if(!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("helseprofil/orgdata")
## normalizePath(readClipboard(), win = "/")

library(orgdata)
library(data.table)
update_orgdata(ref = "dev")

## Data fra 1986 - 2021 -------------
BB <- read_file("https://data.ssb.no/api/v0/dataset/26975.csv?lang=no", header = FALSE)
BB



## BEFOLK 2021 data ---------------------
gk <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/DATERT/csv/BEFOLK_GK_2022-01-21-10-14.csv"
df <- read_file(gk)

str(df)
df[, LEVEL := fcase(
  GEO == 0, "land",
  nchar(GEO) %in% 3:4, "kommune",
  nchar(GEO) %in% 1:2, "fylke",
  nchar(GEO) %in% 5:6, "bydel",
  default = "none")]
df
df[GEO == 0, LEVEL := "land"]
df[, .N, by= AAR]
df[, .N, by=ALDER]
df[, .N, by=LEVEL]

names(df)
delCols <- c("RATE", "SMR", "SPVFLAGG")
df[, (delCols) := NULL]
df[, .N, by = ALDER]
df


## Renset SSB data 1990 - 2021 and merge with BEFOLK_GK ----------------
xlFolder <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/2022"
dt <- readRDS(file.path(xlFolder, "BEFOLK_SSB.rds"))
## saveRDS(dt, file.path(xlFolder, "BEFOLK_SSB.rds"))
dt[, .N, by = type]
dd <- dt[type %chin% c("group_kjonn", "group")]
dd
cols <- c("Tid", "ALDER", "type")
dd[, (cols) := NULL]
setnames(dd, c("Kjonn", "AGE"), c("KJONN", "ALDER" ))
dd

DT <- merge(df, dd, by = c("AAR", "GEO", "ALDER", "KJONN"))
DT[order(AAR, GEO, ALDER, KJONN)]
DT[, DIFF := TELLER - TELLERssb]
DT[DIFF != 0][order(DIFF, decreasing = TRUE)]

saveRDS(DT, file.path(xlFolder, "BEFOLK_SSBogBEF.rds"))



## SSB data ---------
skom <- read_file("https://data.ssb.no/api/v0/dataset/1080.csv?lang=no", header = FALSE, skip = 1)
skom
skom[, GEO := as.numeric(gsub("\\D.+$", "", V1))]
skom[, AGE := gsub(".*\\s(\\d+)\\s.*", "\\1", V2)]
skom[.N, AGE := 105][, AGE := as.numeric(AGE)]
setnames(skom, "V5", "BEFOLK")
str(skom)

vnm <- intersect(paste0("V", 1:ncol(skom)), names(skom))
vnm
skom[, (vnm) := NULL ]
skom

aggp <- data.table(AGE = unique(skom$AGE))
setkey(aggp, AGE)
aggp[, GRP:= ceiling(seq(.N)/5)]
aggp

AGRP <- aggp[, {dt = copy(.SD)
  dt[, to := paste0(min(AGE), "_", max(AGE))]
  dt}, by = GRP]

AGRP[, GRP := NULL]
AGRP

skom
skom[AGRP, on = "AGE", ALDER := i.to]

skom[, TELLERssb := sum(BEFOLK), by = .(GEO, ALDER)]
setkey(skom, GEO, ALDER)
ssbkom <- unique(skom, by = c("GEO", "ALDER"))
setkey(ssbkom, GEO, AGE)
ssbkom
ssbkom[, c("AGE", "BEFOLK") := NULL]
ssbkom[, .N, by = ALDER]


dtkom <- df[LEVEL == "kommune"]
setkey(dtkom, GEO, ALDER)
dtkom

DT <- merge(dtkom, ssbkom, by.x = c("GEO", "ALDER"), by.y = c("GEO", "ALDER"))
DT2021 <- DT[AAR == "2021_2021" & KJONN == 0]
DT2021[, DIFF := TELLER - TELLERssb]
DT2021
DT2021[DIFF > 0, ]
#fwrite(DT2021, "BEFGK2022.csv")

### -----------------
dt <- readRDS("N:/Helseprofiler/control/BEF_SSB_1990_2021.rds")
dt

## Cleaning SSB Population ---------------
str(dt)
orgdata::se_fil(dt)

dt[, GEO := gsub("^K-", "", Region)]
dt[Region == "K-Rest", GEO := 9999]

dt[, ALDER := gsub("^0+", "", Alder)]
dt[Alder == "105+", ALDER := sub("\\+$", "", ALDER)]
dt[ALDER == "", ALDER := "0"]
dt

vars <- c("Kjonn", "Tid", "GEO", "ALDER")
for (j in vars) set(dt, j=j, value = as.numeric(dt[[j]]))

aggp <- data.table(AGE = unique(as.numeric(dt$ALDER)))
setkey(aggp, AGE)
aggp[, GRP:= ceiling(seq(.N)/5)]
aggp

AGRP <- aggp[, {dta = copy(.SD)
  dta[, to := paste0(min(AGE), "_", max(AGE))]
  dta}, by = GRP]

AGRP[, GRP := NULL]
AGRP
str(AGRP)

dt[AGRP, on = c(ALDER = "AGE"), AGE := i.to]
str(dt)
dt[, type := "person"]
dd <- copy(dt)

dt[, TELLERssb := sum(value), by = .(Tid, GEO, Kjonn, AGE)]
setkey(dt, GEO, ALDER)
utVal <- c("Region", "Alder", "ContentsCode")
dt[, (utVal) := NULL]
dt
dt[Tid == "1990"]

## Total Kjønn ------
kb <- dt[, .(TELLERssb = sum(value)), by = .(Tid, GEO, ALDER)]
kb[, type := "person_kjonn"]
kbg <- dt[, .(TELLERssb = sum(value)), by = .(Tid, GEO, AGE)]
kbg[, type := "group_kjonn"]
DTK <- rbindlist(list(kb, kbg), fill = TRUE, use.names = TRUE)
DTK[, Kjonn := 0]
DTK

## Total Age group ----
sssbkom <- unique(dt, by = c("Tid", "GEO", "Kjonn", "AGE"))
setkey(ssbkom, GEO, ALDER)
ssbkom
ssbkom[, type := "group"]
ssbkom[, .N, by = AGE]
ssbkom[, value := NULL]

dt[, TELLERssb := value]
dt[, value := NULL]


DT <- rbindlist(list(dt, DTK, ssbkom), fill = TRUE, use.names = TRUE)
DT
DT[, .N, by = type]
DT[type == "person", AGE := NA]
DT[, .N, by = Kjonn]

DT[, AAR := paste0(Tid, "_", Tid)]
str(DT)
setcolorder(DT, "AAR")

xlFolder <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/2022"
fwrite(DT, file.path(xlFolder, "BEFOLK_SSB_all.csv"))
## ## Type:
## person - Per individ
## group - Aldergrupper
## person_kjonn - person total kjonn
## group_kjonn - aldergruppe total kjonn

DT[, .N, by = type]



### -------------------------------------------------------------

DT[AAR == "1990_1990" & GEO == 301 & AGE == "0_4"]
DT[AAR == "1990_1990" & GEO == 301 & Kjonn == 0]


dt[GEO == 301 & ALDER %in% c(100:104) & Tid == 1990 ][order(Kjonn)]
saveRDS(dt, "N:/Helseprofiler/control/BEF_SSB_AGEGRP_1990_2021.rds")


gk <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/DATERT/csv/BEFOLK_GK_2022-01-21-10-14.csv"
df <- read_file(gk)

str(df)
df[, LEVEL := fcase(nchar(GEO) %in% 3:4, "kommune",
                    nchar(GEO) %in% 1:2, "fylke",
                    nchar(GEO) %in% 5:6, "bydel",
                    default = "none")]
df
df[GEO == 0, LEVEL := "land"]
df[, .N, by= AAR]

dtkom <- df[LEVEL == "kommune"]
dtkom <- dtkom[KJONN!=0]
setkey(dtkom, GEO, ALDER)
dtkom

DT <- merge(dtkom, ssbkom, by.x = c("AAR", "GEO", "KJONN", "ALDER"), by.y = c("AAR","GEO", "Kjonn", "AGE"))
DT[, c("RATE", "SMR", "SPVFLAGG") := NULL]
setkey(DT, AAR, GEO, ALDER)
DT[, DIFF := TELLER - TELLERssb]
DT[DIFF != 0, ]

DT[AAR == "1990_1990" & GEO == 301 & ALDER == "5_9"]
DT[order(DIFF, decreasing = TRUE)]

fwrite(DT, "N:/Helseprofiler/control/BEFmotSSB_1990_2021.csv", sep = ";")

DT2021 <- DT[AAR == "2021_2021" & KJONN == 0]
DT2021[, DIFF := TELLER - TELLERssb]
DT2021
DT[AAR == "2019_2019"][DIFF!=0, ]


## dtkom[ssbkom, on = "GEO"]

## str(dtkom)
## str(ssbkom)



## ## -----------------------------
## ## skom[, GRP := lapply(seq(.N), function(x) fcase(AGE %in% eval(str2lang(agep[x]$AGE)), agep[x]$to))]
## skom[, .N, by = AGE]
## skom
