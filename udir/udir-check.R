
## UDir fil
udirfil <- "f:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/VALIDERING/kodechk/udir/20210322-1509_GSK.ElevundersoekelsenG.csv"

## KUBE fil
kubefil <- "F:\\Forskningsprosjekter\\PDB 2455 - Helseprofiler og til_\\PRODUKSJON\\PRODUKTER\\KUBER\\KOMMUNEHELSA\\KH2021NESSTAR\\MOBBING_1aar_0_2020-08-14-13-13.csv"


## Which columns in the Udir raw data
Kommunekode = "D"
Organisasjonsnummer = "E"
Kolonne = c("J", "K", "L")

## What these columns have
J = c(aar = 2016, kjonn = 0, trinn + = 7)
K = c(aar = 2016, kjonn = 1, trinn = 7) 
L = c(aar = 2016, kjonn = 2, trinn = 7)



udir_check <- function(udirfile = udirfil,
                       kubefile = kubefil,
                       kom = Kommunekode,
                       org = Organisasjonsnummer,
                       cols = Kolonne){

  ## csv file extracted from UDir website start with sep= and whitespace seperated
  ## Loading needs to exclude first line with sep= and long colnames in second line
  ## But the each line ends with \r that need to be cleaned up
  udt <- data.table::fread(udirfile, skip = 2, sep = "\t", fill = TRUE)

  for (j in seq_len(ncol(udt))){
    if(class(udt[[j]]) == 'character')
      data.table::set(udt, j = j, value = gsub("\r", "", udt[[j]]))
  }

  ## Use Excel colnames to make specification for column easier
  ## especially when colnames is very long. But watch out for F and T!
  xlcols <- c(LETTERS,
              do.call("paste0",CJ(LETTERS,LETTERS)),
              do.call("paste0",CJ(LETTERS,LETTERS,LETTERS)))[1:ncol(udt)]

  setnames(udt, new = xlcols)


  udt <- udt[get(kom) == get(org), ]

  mdt <- melt(udt,
              id.vars = kom,
              measure.vars = cols,
              variable.factor = FALSE,
              value.name = "udir", 
              variable.name = "column")

  
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

  ## Kube data
  kdt <- data.table::fread(kubefile)
  
  kdt[mdt, on = c(GEO = "geo", AAR = "aar", KJONN = "kjonn", TRINN = "trinn")]

  
  
}
