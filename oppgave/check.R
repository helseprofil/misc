library(data.table)

tt <- readRDS("kommdata.rds")

str(tt)

# antall menn og kvinner per år
tt[.(KJONN = c("mann", "kvinne"), to = 1:2), on = "KJONN", KJONN := i.to]

tt[, .N, by=.(AAR, KJONN)]
