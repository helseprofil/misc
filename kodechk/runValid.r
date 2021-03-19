# VALIDERING: Ferdig kube sjekkes mot ORGdatafil (ELEVUNDERS?KELSEN).
# Resultatet fra kj�ringen legges her: F:\Prosjekter\Kommunehelsa\PRODUKSJON\VALIDERING\kodechk\KUBE
# Det kommer ingen tilbakemelding i console (hvis alt g�r bra)


## Spesifisere sti til Kubefil. OBS! M� v�re double slash \\
stiTilKube = "F:\\Prosjekter\\Kommunehelsa\\PRODUKSJON\\PRODUKTER\\KUBER\\KOMMUNEHELSA\\KH2021NESSTAR\\"

## Navn til Kubefilen
kubeFil = "TRIVSEL_1_2020-07-02-09-32.csv"

## Sp�rsm�l ID
valgSID = 307

## Lager fil under mappe KUBE i samme mappen med denne filen
lagFil = "Trivsel307.csv"


# Sett arbeidskatalog der scriptfilene ligger
setwd("F:\\Prosjekter\\Kommunehelsa\\PRODUKSJON\\VALIDERING\\kodechk")

### SOURCE FILE - DETTE SCRIPTET GJ�R SELVE JOBBEN
source("valid2.r")


### BRUKSANVISNING:
### Ctrl+A for � velge alle
### Ctrl+Enter for � kj�re koden
