# VALIDERING: Ferdig kube sjekkes mot ORGdatafil (ELEVUNDERS?KELSEN).
# Resultatet fra kjøringen legges her: F:\Prosjekter\Kommunehelsa\PRODUKSJON\VALIDERING\kodechk\KUBE
# Det kommer ingen tilbakemelding i console (hvis alt går bra)


## Spesifisere sti til Kubefil. OBS! Må være double slash \\
stiTilKube = "F:\\Prosjekter\\Kommunehelsa\\PRODUKSJON\\PRODUKTER\\KUBER\\KOMMUNEHELSA\\KH2021NESSTAR\\"

## Navn til Kubefilen
kubeFil = "TRIVSEL_1_2020-07-02-09-32.csv"

## Spørsmål ID
valgSID = 307

## Lager fil under mappe KUBE i samme mappen med denne filen
lagFil = "Trivsel307.csv"


# Sett arbeidskatalog der scriptfilene ligger
setwd("F:\\Prosjekter\\Kommunehelsa\\PRODUKSJON\\VALIDERING\\kodechk")

### SOURCE FILE - DETTE SCRIPTET GJØR SELVE JOBBEN
source("valid2.r")


### BRUKSANVISNING:
### Ctrl+A for å velge alle
### Ctrl+Enter for å kjøre koden
