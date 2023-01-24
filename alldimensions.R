# last updated: 24.01.2022

# Code to extract all unique dimension column names. 
# Uncomment and run, to update.
# 
# library(RODBC)
# library(dplyr)
# library(tidyr)
# library(stringr)
# DBroot <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/STYRING"
# KH_db  <- "KHELSA.mdb"
# kilde <- RODBC::odbcConnectAccess2007(paste(DBroot, KH_db, sep = "/"))#
# extradimensions <-
# sqlQuery(kilde, "SELECT TAB1, TAB2, TAB3 FROM FILGRUPPER") %>%
# pivot_longer(cols = everything()) %>%
# filter(!is.na(value)) %>%
# pull(value) %>%
# unique()

# List of all dimensions created manually, 
# to avoid having to connect to db when sourced

ALL_DIMENSIONS <- 
  c(# STANDARD DIMENSIONS
    "GEO", 
    "AAR", 
    "ALDER", 
    "KJONN", 
    "UTDANN", 
    "INNVKAT", 
    "LANDBAK",
    # ALL DIMENSIONS FROM TAB1-3
    "PROGNOSEAAR",
    "STATUS",
    "AARSAK",
    "SPM_ID",
    "TRINN",
    "OVER_UNDER",
    "BMI_KAT",
    "ULIK_MAAL",
    "LANDBAKG",
    "ICD",
    "KODEGRUPPE",
    "FERDNIVAA",
    "STONADSLENGDE",
    "YTELSE",
    "UTDNIVA",
    "INDIKATOR",
    "NIVA",
    "VAKSINE",
    "KMI_KAT",
    "FVEKTKATEGORI",
    "ARSAK",
    "FORNOYDHET",
    "SOES",
    "ANTALL_GANGER",
    "DELTARNAA",
    "NIVA_PLAGET",
    "HARVENN",
    "FORNOYD",
    "TYPE_VALG",
    "Utdanning",
    "Landbakgrunn",
    "land_kat",
    "UTDANNING",
    "DEPRESJON",
    "INNTAK",
    "Sivilstand",
    "STOTTE",
    "ANTALLGANGER",
    "VURDERING",
    "VEKT",
    "HAR",
    "TYPE",
    "FERIE",
    "POL",
    "BODD",
    "GRUNN",
    "MANED",
    "DATAKILDE",
    "HAR_POL",
    "NAVN",
    "SKJERMTID",
    "LOKALTILBUD",
    "JA_NEI",
    "NORM",
    "STOYKILDE",
    "LIVSKVALITET",
    "INNVAND",
    "HYPPIGHET_TRENING",
    "SVOMMEFERD",
    "MAAL",
    "REGELBRUDD")
