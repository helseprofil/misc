# Sjekk mot SSB sine tall
if(!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("helseprofil/orgdata")
normalizePath(readClipboard(), win = "/")

library(orgdata)
update_orgdata(ref = "dev")

gk <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/DATERT/csv/BEFOLK_GK_2022-01-21-10-14.csv"
df <- read_file(gk)


str(df)
df[, LEVEL := fcase(GEO == 0, "land",
                    nchar(GEO) %in% 3:4, "kommune",
                    nchar(GEO) %in% 1:2, "fylke",
                    nchar(GEO) %in% 5:6, "bydel",
                    default = "none")]

df

agep <- df[, .N, by=ALDER]
agep[, agp := sub("_", ":", ALDER)]
setnames(agep, c("ALDER", "agp"), c("to","AGE"))
agep[, N := NULL]
agep



## SSB ---------
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



## dtkom[ssbkom, on = "GEO"]

## str(dtkom)
## str(ssbkom)



## ## -----------------------------
## ## skom[, GRP := lapply(seq(.N), function(x) fcase(AGE %in% eval(str2lang(agep[x]$AGE)), agep[x]$to))]
## skom[, .N, by = AGE]
## skom
