## udirfile: CSV file downloaded from UDir website
## kubefile: CSV file from Kube run
## kom: Which column for Kommunekode in UDir dataset
## org: Which column for Organisasjonsnummer in UDir dataset
## cols: Which columns will be use for comparison
## skip: If csv file starts with skip=

udir_check <- function(udirfile = udirfil,
                       kubefile = kubefil,
                       kom = Kommunekode,
                       org = Organisasjonsnummer,
                       cols = Kolonne,
                       skip = uskip){

  pkg <- c("data.table", "gt")
  newpkg <- pkg[!(pkg  %in% installed.packages()[, "Package"])]
  if (length(newpkg)) install.packages(newpkg)
  sapply(pkg, require, character.only = TRUE)
  
  ## csv file extracted from UDir website start with sep= and whitespace seperated
  ## Loading needs to exclude first line with sep= and long colnames in second line
  ## But the each line ends with \r that need to be cleaned up
  ## Unless the sep is ; or , then fread as normal
  if (skip){
    udt <- data.table::fread(udirfile, skip = 2, sep = "\t", fill = TRUE)
    
    for (j in seq_len(ncol(udt))){
      if(class(udt[[j]]) == 'character')
        data.table::set(udt, j = j, value = gsub("\r", "", udt[[j]]))
    }

  } else {
    udt <- data.table::fread(udirfile)
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

  
  DT <- kdt[mdt, on = c(GEO = "geo", AAR = "aar", KJONN = "kjonn", TRINN = "trinn")]

  ## GEO setup
  ## geotbl <-
  ##   data.table::fread("https://raw.githubusercontent.com/helseprofil/misc/main/dataset/geoTable.csv")
  geomrg <- data.table::fread("https://raw.githubusercontent.com/helseprofil/misc/main/dataset/kommuneMerge.csv")
  geodel <-
    data.table::fread("https://raw.githubusercontent.com/helseprofil/misc/main/dataset/kommuneDelt.csv")

  geoUt <- c(unique(geomrg$code), unique(geodel$code))

  DT <- DT[!(GEO  %in% geoUt),]
  
  ## Show the prikk data
  DT[, check := fcase(udir == "*" & SPVFLAGG == 0, 2,
                      udir != "*" & SPVFLAGG == 3, 1,
                      default = 0)]
  
  DT <- DT[order(-check)][]

  ## Make html table
  udiTbl <- gt(DT) %>%
      tab_header(
        title = md("UDir prikking mot Kube")
      ) %>%
      tab_style(
        style = list(
          cell_fill(color = "#F9E3AA")),
        locations = cells_body(
          rows = check == 2))%>%
      tab_style(
        style = list(
          cell_fill(color = "lightgreen")),
        locations = cells_body(
          rows = check == 1))


    udiTbl
  }
