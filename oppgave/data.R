# Oppgaver til stillingen
## source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
## kh_install("orgdata")

library(orgdata)
library(data.table)
set.seed(25042022)

dt <- mf("ENPERSON", 272:273)
dt[, .N, by=AAR]

DT <- dt[LEVEL=="kommune"]
DT[, KJONN := sample(1:2, .N, replace = T)]
## 1 = mann 2 = kvinne
dim(DT)

DF <- DT[ANTALL > 5]
dim(DF)
DF

kom <- sample(unique(DF$GEO), 20)
kom
DF <- DF[GEO %in% kom]
DF

## Problem data --------
## Missing GEO
dtx1 <- data.table(GEO = 9999, LEVEL = "kommune", AAR = 2021, ALDER = 18, ANTALL = 10, KJONN = 1)
df <- rbindlist(list(DF, dtx1))
df

## omkode kjønn
str(df)
df[GEO == 4202]
df[, KJONN2 := as.character(KJONN)]
df[GEO == 4202 & AAR == 2020 & KJONN == 1, KJONN2 := "mann"]
df[GEO == 4202 & AAR == 2020 & KJONN == 2, KJONN2 := "kvinne"]
df[, KJONN := KJONN2]
df[, c("KJONN2", "LEVEL") := NULL]
df[, .N, by = KJONN]

saveRDS(df, "kommdata.rds")
kode <- data.table(KJONN = 1:2, CODE = c("mann", "kvinne"))
kode
df
df2020 <- df[AAR == 2020]
df2021 <- df[AAR == 2021]

fwrite(df2020, "komm2020.csv")
fwrite(df2021, "komm2021.csv")

## GEO kodes ----------
library(norgeo)
geo <- get_correspond("fylke", "kommune")
geo


## SQLite
library(RSQLite)

conn <- dbConnect(RSQLite::SQLite(), "oppgave.db")
dbWriteTable(conn, "data2020", df2020)
dbWriteTable(conn, "data2021", df2021)
dbWriteTable(conn, "tblCode", kode)
dbListTables(conn)



## Resultat fra ORGDATA Access
dd <- make_file("TEST_oppgave", implicitnull = FALSE)
dd
