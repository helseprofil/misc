## Les delbydel fil fra Oslo

add_codes <- function(file, code = 0301, save = FALSE){

  pkgs <- c("pdftools", "data.table", "stringr", "fs")
  pkg_install(pkgs)

  `:=` <- data.table::`:=`

  numerr <- is(code, "numeric")
  if (numerr) code <- as.character(code)

  rawFile <- pdftools::pdf_text(file)
  rawTbl <- stringr::str_split(rawFile, "\n")

  for (i in seq_len(length(rawTbl))){
    dt <- stringr::str_split_fixed(rawTbl[[i]][-1], " {2,}", 5)
    dt <- data.table::as.data.table(dt)

    # Ny grunnkrets have no missing but when split with " {2,}"
    # move the codes to the missing of old grunnkrets
    dt[V5 == "", V5 := V4]
    cols <- names(dt)[-c(3,5)]
    dt[, (cols) := NULL]

    data.table::setnames(dt, new = c("Delbydel", "Grunnkrets"))

    for (j in 1:2){
      data.table::set(dt, j = j, value = stringr::str_extract(trimws(dt[[j]]), "^\\d+"))
    }

    # Add prefix code for Oslo
    dt[!is.na(Grunnkrets), Grunnkrets := paste0(code, Grunnkrets) ]
    dt[!is.na(Delbydel), Delbydel := paste0(code, Delbydel) ]

    rawTbl[[i]] <- data.table::copy(dt)
  }

  DT <- data.table::rbindlist(rawTbl)

  DT <- DT[Grunnkrets != ""]
  dupID <- DT[duplicated(Grunnkrets)][[1]]

  if (length(dupID) > 0){
    warning("Duplicated ID: ", dupID)
  }

  if (save){
    savePath <- file.path(fs::path_home(), "geo-codes")
    if (isFALSE(fs::dir_exists(savePath))) {
      fs::dir_create(savePath)
    }

    fileName <- paste0("Code", code, ".csv")
    filePath <- file.path(savePath, fileName)
    data.table::fwrite(DT, file = filePath, sep = ",")
    message("File is saved: ", filePath)
  }

  return(DT)
}

pkg_install <- function(pkgs){
  new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
  if(length(new.pkgs)) install.packages(new.pkgs, repos = "https://cloud.r-project.org/")
  invisible()
}
