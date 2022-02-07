# Sjekk tall på barometer

Brukes til å se barometer som ble avrundet

Slik skal argumentene brukes
----------------------------
```R
profiltype  <- "FHP"
aargang <- 2021
geonivaa <- "Kommune"
fpath <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/SSRS_filer"
indDTA <- "Indikator_ny.dta"
barDTA <- "inndataBarometer.dta"

result <- check_bar( type = profiletype, year = aargang, geo = geonivaa, base = fpath)
```
