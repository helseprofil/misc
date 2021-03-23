rm(list = ls())

## Read file downloaded from UDir
library(data.table)

folderUdir <-
  "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/VALIDERING/kodechk/udir"

fileUdir <- "20210322-1518_GSK.ElevundersoekelsenG.csv"

## setwd(file.path(folderUdir))
## shell("C:/Rtools/bin/tr.exe -d '\\r' < 20210322-1518_GSK.ElevundersoekelsenG.csv > udir_new.csv")


udt <- fread(file.path(folderUdir, fileUdir), skip = 2, sep = "\t", fill = TRUE)

for (j in seq_len(ncol(udt))){
  if(class(udt[[j]]) == 'character')
    set(udt, j = j, value = gsub("\r", "", udt[[j]]))
}




## ## Open original file and save as CSV ;
## fileCSV <- "20210322-1518_GSK.ElevundersoekelsenG_test.csv"

## udt2 <- fread(file.path(folderUdir, fileCSV))

## library(readr)
## udt2 <- read.table(file.path(folderUdir, fileUdir), sep = "")

## all_content = readLines(file.path(folderUdir, fileUdir))
## head(all_content)
## length(all_content)
## skip_first_line = all_content[-1]
## initData <- read.csv(textConnection(skip_first_line),
##                      row.names=NULL,
##                      header=T,
##                      stringsAsFactors = F)

## testDT <- fread(file.path(folderUdir, fileUdir), sep = 1)

## head(testDT)
## tail(testDT)


## KUBE fil
fileKub <- "F:\\Forskningsprosjekter\\PDB 2455 - Helseprofiler og til_\\PRODUKSJON\\PRODUKTER\\KUBER\\KOMMUNEHELSA\\KH2021NESSTAR\\MOBBING_1aar_0_2020-08-14-13-13.csv"
kdt <- fread(fileKub)

## dim(udt)
## ncol(udt)

xlcols <- c(LETTERS,
            do.call("paste0",CJ(LETTERS,LETTERS)),
            do.call("paste0",CJ(LETTERS,LETTERS,LETTERS)))[1:ncol(udt)]

## Use Excel colnames to make specification for column easier
setnames(udt, new = xlcols)

## We only need to keep kommune with 4 codes
## Column "Kommunekode" and "Organisasjonsnummer" should be equal. The rest in
## Organisasjonsnummer are schools id which is not needed

## OBS! Need to specify which column for Kommunekode and organisasjonsnummer 
Kommunekode = "D"
Organisasjonsnummer = "E"

## geoInd <- which(xlcols == Kommunekode | xlcols == Organisasjonsnummer)

udt <- udt[get(Kommunekode) == get(Organisasjonsnummer), ]




## Arguments
## -----------------------------------------
## Restructure dataset to be like the Kube
## eg. col J is both sex and trinn 7
## column K er Kjonn = gutt og trinn 7

## Which columns in the Udir raw data
cols = c("J", "K", "L")
## What these columns have
"J" = c(aar = 2016, kjonn = 0, trinn = 7)
"K" = c(aar = 2016, kjonn = 1, trinn = 7) 
"L" = c(aar = 2016, kjonn = 2, trinn = 7)

testdt <- udt[, .(D, J, K, L)][1:5]

mdt <- melt(testdt, id.vars = geoCol[1],
            measure.vars = cols,
            variable.factor = FALSE,
            value.name = "udir", 
            variable.name = "column")

## rowCol <- cols[1]
## indKjonn <- which(tolower(names(get(rowCol))) == "kjonn")
## indTrinn <- which(tolower(names(get(rowCol))) == "trinn")

## kj0 <- get(rowCol)[indKjonn]
## tr0 <- get(rowCol)[indTrinn]

## mdt[variable == cols[1], `:=`(kjonn = kj0, trinn = tr0)]


for (i in seq_along(cols)){
  rowCol <- cols[i]
  indAar <- which(tolower(names(get(rowCol))) == "aar")
  indKjonn <- which(tolower(names(get(rowCol))) == "kjonn")
  indTrinn <- which(tolower(names(get(rowCol))) == "trinn")

  aar0 <- get(rowCol)[indAar]
  kj0 <- get(rowCol)[indKjonn]
  tr0 <- get(rowCol)[indTrinn]

  mdt[column == cols[i], `:=`(aar = paste(aar0, aar0, sep = "_"),
                              kjonn = kj0,
                              trinn = tr0)][]
}

## Place aar at first column
setcolorder(mdt, "aar")

mdt[, geo := as.integer(D)][, D := NULL]

kdt[mdt, on = c(GEO = "geo", AAR = "aar", KJONN = "kjonn", TRINN = "trinn")]





## Alle koder omkoding
geotbl <- readRDS("../dataset/geoTable.rds")
#kommune som er slått sammen
komMrg <- readRDS("../dataset/kommuneMerge.rds") 
## kommuner som er delt
komDel <- readRDS("../dataset/kommuneDelt.rds")




