## Standardize data
##------------------
library(data.table)

rootPath <-
  "F:/Prosjekter/Kommunehelsa/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2020NESSTAR"

norskBef <- "BEFOLK_GK_NH_2020-03-17-15-59.csv"
fileExp <- "ABORT_NH_2020-03-09-11-31.csv"
colnm <- c("GEO", "ALDER", "TELLER", "RATE")
yr <- "2019_2019"

DT <- fread(file.path(rootPath, norskBef));DT
dt <- fread(file.path(rootPath, fileExp));dt

DT
DT[, .N, keyby = GEO]
DT[GEO == 0, .N, by = ALDER]
yrGp <- c("15_19", "20_24", "25_29", "30_34", "35_39", "40_44", "45_49")
DTR <- DT[GEO == 0 & ALDER %chin% yrGp & AAR == yr, ];DTR
Dtw <- DTR[, .(Total = sum(TELLER, na.rm = TRUE)), by = KJONN];Dtw

## data.table::rollup(DTR, sum(TELLER, na.rm = T), by = "KJONN")
DTs <- subset(DTR, KJONN == 2, select = colnm); DTs
DTW <- rbindlist(list(DTs, list(0, "15_49", Dtw$Total[Dtw$KJONN == 2])), fill = TRUE);DTW

dt[, .N, keyby = GEO]
dt[, .N, keyby = AAR]
dt[, .N, keyby = ALDER]

dtn <- subset(dt, GEO == 0 & AAR == yr , select = colnm);dtn
## dtnn <- rbindlist(list(dtn, list("0", "total", sum(dtn$TELLER, na.rm = TRUE))), fill = TRUE);dtnn
dtc <- subset(dt, GEO == 3 & AAR == yr , select = colnm);dtc
dtd <- subset(dt, GEO == 50 & AAR == yr , select = colnm);dtd

DTN <- DTW[dtn, on = "ALDER"];DTN
DTN[, crude := (i.TELLER / TELLER) * 1000];DTN

## Get data and calculate crute rate
## ---------------------------------
norskBef <- "BEFOLK_GK_NH_2020-03-17-15-59.csv"
fileExp <- "ABORT_NH_2020-03-09-11-31.csv"
## fileExp <- "ARBLEDIGE_NH_2020-03-26-09-03.csv"
## fileExp <- "ENPERSON_NH_2020-02-05-16-01.csv"
yrGp <- c("15_19", "20_24", "25_29", "30_34", "35_39", "40_44", "45_49")
## yrGp <- c("15_19", "20_24", "25_29", "30_34", "35_39", "40_44")
## yrGp <- c("15_29", "30_74")
yrEx <- c("45_49", "15_49")

sdata <- function(x, y, geo = NULL, yrGp, yrEx){
  ## x reference dataset
  ## y target dataset
  ## yrEx exclude age
  
  rootPath <-
    "F:/Prosjekter/Kommunehelsa/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2020NESSTAR"

  colnm <- c("GEO", "ALDER", "TELLER", "RATE")
  yr <- "2019_2019"

  DT <- data.table::fread(file.path(rootPath, x))
  dt <- data.table::fread(file.path(rootPath, y))
  
  DTR <- DT[GEO == geo & ALDER %chin% yrGp & AAR == yr, ]
  Dtw <- DTR[, .(Total = sum(TELLER, na.rm = TRUE)), by = KJONN]

  DTs <- subset(DTR, KJONN == 2, select = colnm)
  ## DTW <- rbindlist(list(DTs, list(geo, "15_49", Dtw$Total[Dtw$KJONN == 2])), fill = TRUE)

  dtn <- subset(dt, GEO == geo & AAR == yr & !(ALDER %chin% yrEx), select = colnm)
  
  DTN <- DTs[dtn, on = "ALDER"]
  DTN[, crude := (i.TELLER / TELLER) * 1000]
  setnames(DTN, "i.TELLER", "case")
  DTN[]
}

dtNorge <- sdata(norskBef, fileExp, geo = 0, yrGp, yrEx);dtNorge
dt3 <- sdata(norskBef, fileExp, geo = 3, yrGp, yrEx);dt3
dt30 <- sdata(norskBef, fileExp, geo = 30, yrGp, yrEx);dt30
dt50 <- sdata(norskBef, fileExp, geo = 50, yrGp, yrEx);dt50

## dput(setDF(dtNorge), "dtNorge.txt")
## dput(setDF(dt3), "dt3.txt")
## dput(setDF(dt30), "dt30.txt")
## dput(setDF(dt50), "dt50.txt")

## ------------
## START HERE
## -----------
library(data.table)
dtNorge<- setDT(dget("dtNorge.txt"))
dt3 <- setDT(dget("dt3.txt"))
dt30 <- setDT(dget("dt30.txt"))
dt50 <- setDT(dget("dt50.txt"))

## Direct standardize
## ------------------
## Reference population for total number of age-specific distribution
## implement the target rates to this reference population
dtNorge
dtNorge[, sum(case) / sum(TELLER) * 1000]
cols <- c("GEO", "ALDER", "TELLER")
DTS <- subset(dtNorge, select = cols);DTS


## target population 1
dt3
dt3[, sum(case) / sum(TELLER) * 1000] #crude rate
colt <- c("ALDER","TELLER", "case", "crude")
## dtt3 <- subset(dt3, select = colt);dtt3
dt3[, (setdiff(names(dt3),colt)) := NULL][]
DT3 <- DTS[dt3, on = "ALDER"];DT3
DT3[, exp_nr := (crude / 1000) * TELLER ][]
## rate per 1000
DT3[, sum(exp_nr) / sum(TELLER) * 1000]

library(epitools)
dirStd <- ageadjust.direct(count = dt3$case,
                           pop = dt3$TELLER,
                           stdpop = dtNorge$TELLER)
round(1e3 * dirStd, 2)


## target population 30
dt30
dt30[, sum(case) / sum(TELLER) * 1000]
colt <- c("ALDER","case", "crude")
dtt30 <- subset(dt30, select = colt);dtt30
DT30 <- DTS[dtt30, on = "ALDER"];DT30
DT30[, exp_nr := (crude / 1000) * TELLER ][]
## rate per 1000
DT30[, sum(exp_nr, na.rm = TRUE) / sum(TELLER, na.rm = TRUE) * 1000]

## target population 50
dt50
dt50[, sum(case) / sum(TELLER) * 1000]
colt <- c("ALDER","case", "crude")
dtt50 <- subset(dt50, select = colt);dtt50
DT50 <- DTS[dtt50, on = "ALDER"];DT50
DT50[, exp_nr := (crude / 1000) * TELLER ][]
## rate per 1000
DT50[, sum(exp_nr, na.rm = TRUE) / sum(TELLER, na.rm = TRUE) * 1000]


## --------------------------
## Indirect Standardization
## --------------------------
## 2 methods to calculate SMR 95% CI
## SMR higher than 1 indicate the risk higher in observed population
smr_conf =  function(observed, predicted){

  lower = ((sqrt(observed) - 1.96*0.5)^2)/ predicted
  upper = ((sqrt(observed) + 1.96*0.5)^2)/ predicted

  return(c(lower, upper))

}

smr_ci <- function(smr, observed){

  se <- smr / sqrt(observed)
  lower = smr - 1.96 * se
  upper = smr + 1.96 * se

  return(c(lower, upper))
}

## Implement the rates of reference population to the target population
dtNorge
DTi <- subset(dtNorge, select = c("ALDER", "crude")); DTi

## Crude ref.pop
refCrude <- dtNorge[, sum(case) / sum(TELLER) * 1000]; refCrude

incol <- c("ALDER", "TELLER", "case")
dt3
dt3i <- subset(dt3, select = incol);dt3i
dt3i[DTi, on = "ALDER", crude := crude]; dt3i
dt3i[, exp_nr := (crude / 1000) * TELLER]; dt3i
smr3i <- dt3i[, sum(case) / sum(exp_nr)];smr3i

## Indirect age-adjusted rate per 1000
refCrude
refCrude * smr3i
## 95% CI for SMR
smr_conf(sum(dt3i$case), sum(dt3i$exp_nr))
smr_ci(smr3i, sum(dt3i$case))


library(epitools)
indStdxx <- ageadjust.indirect(count = dt3i$case,
                               pop = dt3i$TELLER,
                             stdcount = dtNorge$case,
                             stdpop = dtNorge$TELLER)

indStdxx
round(indStdxx$sir, 2) #standardized incidence ratio (SMR)
round(1e3 * indStdxx$rate, 1)





dt30
dt30i <- subset(dt30, select = incol);dt30i
dt30i[DTi, on = "ALDER", crude := crude]; dt30i
dt30i[, exp_nr := (crude / 1000) * TELLER]; dt30i
smr30i <- dt30i[, sum(case) / sum(exp_nr)];smr30i

## Indirect age-adjusted rate per 1000
refCrude
refCrude * smr30i


dt50
dt50i <- subset(dt50, select = incol);dt50i
dt50i[DTi, on = "ALDER", crude := crude]; dt50i
dt50i[, exp_nr := (crude / 1000) * TELLER]; dt50i
smr50i <- dt50i[, sum(case) / sum(exp_nr)];smr50i

## Indirect age-adjusted rate per 1000
refCrude
refCrude * smr50i

indStdxx <- ageadjust.indirect(count = dt50i$case,
                               pop = dt50i$TELLER,
                               stdcount = dtNorge$case,
                               stdpop = dtNorge$TELLER)
indStdxx
round(indStdxx$sir, 2) #standardized incidence ratio
round(1e3 * indStdxx$rate, 1)




