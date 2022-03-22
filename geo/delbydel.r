## Les delbydel fil fra Oslo

add_codes <- function(file, code = "0301"){

  pkgs <- c("pdftools", "data.table", "stringr")
  pkg_install(pkgs)

  `:=` <- data.table::`:=`

  numerr <- is(code, "numeric")
  if (numerr) stop("code must be a character, use double quote!")

  rawFile <- pdftools::pdf_text(file)
  rawTbl <- stringr::str_split(rawFile, "\n")

  for (i in seq_len(length(rawTbl))){
    dt <- stringr::str_split_fixed(rawTbl[[i]][-1], " {2,}", 5)
    dt <- data.table::as.data.table(dt)
    cols <- names(dt)[-c(3,5)]
    dt[, (cols) := NULL]

    data.table::setnames(dt, new = c("Delbydel", "Grunnkrets"))

    for (j in 1:2){
      data.table::set(dt, j = j, value = stringr::str_extract(trimws(dt[[j]]), "^\\d+"))
    }

    dt[!is.na(Grunnkrets), Grunnkrets := paste0("0301", Grunnkrets) ]

    rawTbl[[i]] <- data.table::copy(dt)
  }

  data.table::rbindlist(rawTbl)
}

pkg_install <- function(pkgs){
  new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
  if(length(new.pkgs)) install.packages(new.pkgs, repos = "https://cloud.r-project.org/")
  invisible()
}
