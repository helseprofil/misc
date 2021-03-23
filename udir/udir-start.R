
## UDir fil
udirfil <- "f:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/VALIDERING/kodechk/udir/20210322-1509_GSK.ElevundersoekelsenG.csv"

## KUBE fil
kubefil <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2021NESSTAR/MOBBING_1aar_0_2020-08-14-13-13.csv"

## Which columns in the Udir raw data
Kommunekode = "D"
Organisasjonsnummer = "E"
Kolonne = c("J", "K", "L")

## What these columns have
J = c(aar = 2019, kjonn = 0, trinn = 7)
K = c(aar = 2019, kjonn = 1, trinn = 7) 
L = c(aar = 2019, kjonn = 2, trinn = 7)



## RUN Check
if (!require(devtools)) install.packages("devtools")
devtools::source_url("https://github.com/helseprofil/misc/blob/main/udir/udir-check.R?raw=TRUE")
udir_check()
