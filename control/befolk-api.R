## install.packages("PxWebApiData")
library("PxWebApiData")
vignette("Introduction", package ="PxWebApiData")

befurl <- "https://data.ssb.no/api/v0/en/table/07459"
vars <- ApiData("https://data.ssb.no/api/v0/en/table/07459", returnMetaFrames = TRUE)
meta <- ApiData("https://data.ssb.no/api/v0/en/table/07459", returnMetaData = TRUE)

## Aggegate Kommune -------------------------------------

library(norgeo)
kmkode <- get_code("kommune", 2021)
kode <- as.character(paste0("K-", kmkode$code))
kode1 <- kode[1:100]
kode2 <- kode[101:200]
kode3 <- kode[201:300]
kode4 <- kode[301:346]
kode4 <- c(kode4, "K-Rest") #Rest are those kommuner that were merged

DD <- vector("list", 4)
tids <- as.character(1990:2021)
## Have to download manually one-by-one and not to loop
DD[[4]] <- ApiData("https://data.ssb.no/api/v0/en/table/07459",
                   Region = list("agg:KommSummer", kode4),
                   Tid = tids,
                   Kjonn = TRUE,
                   Alder = TRUE)

library(data.table)
dd <- vector("list",4)
dd[[4]] <- setDT(DD[[4]]$dataset)

DF <- data.table::rbindlist(dd)
setDT(DF)
DF
saveRDS(DF, "N:/Helseprofiler/control/BEF_SSB_1990_2021.rds")



## Loop break the connection every now and then
for (i in c(kode1, kode2, kode3, kode4)){
  df <- ApiData("https://data.ssb.no/api/v0/en/table/07459",
                Region = list("agg:KommSummer", i),
                Tid = tids,
                Kjonn = TRUE,
                Alder = TRUE)
  DD[[i]] <- df
}




## Cleaning SSB Population ---------------
str(DF)
DF[, .N, by=Alder]
DF[, GEO := gsub("^K-", "", Region)]
DF[, ALDER := gsub("^0+", "", Alder)]
DF[Alder == "105+", ALDER := sub("\\+$", "", ALDER)]
DF[ALDER == "", ALDER := "0"]
DF

DF[]


dd <- ApiData(befurl,
              Region = list("agg:KommSummer", "K-Rest"),
              Alder = TRUE,
              Kjonn = TRUE,
              Tid = 3i)



vars <- ApiData("https://data.ssb.no/api/v0/en/table/07459", returnMetaFrames = TRUE)
names(vars)
vars$Region
vars$ContentsCode

meta <- ApiData("https://data.ssb.no/api/v0/en/table/07459", returnMetaData = TRUE)
meta

tids <- as.character(1990:2021)
length(tids)
df <- ApiData("https://data.ssb.no/api/v0/en/table/07459", Region = TRUE, Tid = tids)
names(df)
DF <- head(df)[[1]]
names(DF)
setDT(DF)
DF


library(data.table)
DT <- setDT(df$dataset)
DT
DT[, .N, by = Tid]
DT[, .N, by = Region]
DT[Region == 0]
str(DT)

## ----------------------------------------------------- ##
##  Table 05196: Population by sex, age and citizenship  ##
## ----------------------------------------------------- ##
vars <- ApiData("https://data.ssb.no/api/v0/en/table/05196", returnMetaFrames = TRUE)
names(vars)
str(vars)
vars$Region
vars$ContentsCode

meta <- ApiData("https://data.ssb.no/api/v0/en/table/05196", returnMetaData = TRUE)
meta

tids <- as.character(1990:2021)
df <- ApiData("https://data.ssb.no/api/v0/en/table/05196", returnDataSet = 12)
head(df)
dim(df)
df
names(df)
str(df)
DF <- df$dataset
names(DF)
setDT(DF)
DF

?ApiData
