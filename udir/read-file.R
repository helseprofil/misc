## Read file downloaded from UDir

folderUdir <-
  "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/VALIDERING/kodechk/udir"

fileUdir <- "20210319-1109_GSK.ElevundersoekelsenG.csv"

library(data.table)
udt <- fread(file.path(folderUdir, fileUdir))

## dim(udt)
## ncol(udt)

xlcols <- c(LETTERS,
            do.call("paste0",CJ(LETTERS,LETTERS)),
            do.call("paste0",CJ(LETTERS,LETTERS,LETTERS)))[1:ncol(udt)]

setnames(udt, new = xlcols)

## We only need kommune with 4 codes
udt[D == E, komm := 1]

udt[komm == 1 & J == "*"]
