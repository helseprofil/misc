
## UDir fil
udirfil <- "f:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/VALIDERING/kodechk/udir/20210319-1109_GSK.ElevundersoekelsenG.csv"

## KUBE fil
kubefil <- "f:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/MOBBING_1aar_0_2021-04-21-10-01.csv"

## Which columns in the Udir raw data
Kommunekode = "D"
Organisasjonsnummer = "E"
Kolonne = c("J", "K", "L")
uskip = TRUE #FALSE hvis første linje udir csv fil ikke starter med skip=

## What these columns have
J = c(aar = 2016, kjonn = 0, trinn = 7)
K = c(aar = 2016, kjonn = 1, trinn = 7) 
L = c(aar = 2016, kjonn = 2, trinn = 7)



## RUN Check
if (!require(devtools)) install.packages("devtools")
devtools::source_url("https://github.com/helseprofil/misc/blob/main/udir/udir-check.R?raw=TRUE")
udir_check()


