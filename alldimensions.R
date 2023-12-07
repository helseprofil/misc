# last updated: 01.03.2023

# Code to extract all unique dimension column names from ACCESS. 
# Uncomment and run, to update.
# 
# library(RODBC)
# library(data.table)
# DBroot <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/STYRING"
# KH_db  <- "KHELSA.mdb"
# kilde <- RODBC::odbcConnectAccess2007(paste(DBroot, KH_db, sep = "/"))
# 
# extradimensions <- sqlQuery(kilde, "SELECT TAB1, TAB2, TAB3 FROM FILGRUPPER")
# setDT(extradimensions)
# extradimensions <- melt(extradimensions, measure.vars = c("TAB1", "TAB2", "TAB3"))[!is.na(value), unique(value)]
# 
# # To get a text string to copy and replace list below:
# cat(sprintf('"%s"', paste(extradimensions, collapse = '",\n"')))

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
    "VAKSINE",
    "KMI_KAT",
    "FVEKTKATEGORI",
    "ARSAK",
    "FORNOYDHET",
    "ANTALL_GANGER",
    "DELTARNAA",
    "NIVA_PLAGET",
    "HARVENN",
    "FORNOYD",
    "TYPE_VALG",
    "Utdanning",
    "DEPRESJON",
    "INNTAK",
    "STOTTE",
    "ANTALLGANGER",
    "VURDERING",
    "VEKT",
    "HAR",
    "TYPE",
    "FERIE",
    "BODD",
    "GRUNN",
    "MANED",
    "NAVN",
    "SKJERMTID",
    "LOKALTILBUD",
    "JA_NEI",
    "BH_NORM",
    "STOYKILDE",
    "LIVSKVALITET",
    "INNVAND",
    "HYPPIGHET_TRENING",
    "SVOMMEFERD",
    "MAAL",
    "REGELBRUDD",
    "TRINN",
    "NIVA",
    "SOES",
    "Landbakgrunn",
    "UTDANNING",
    "POL",
    "DATAKILDE",
    "land_kat",
    "Sivilstand",
    "HAR_POL")

# Manually add special dimension (QALY-kube)
ALL_DIMENSIONS <- c(ALL_DIMENSIONS,
                    "ALDERl")
