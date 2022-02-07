packages <- c("data.table", "haven")

ipkg <- function(pkg){
  newp <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if(length(newp)) install.packages(newp, repos = "https://cran.uib.no", dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipkg(packages)

if (!require(devtools)) install.packages("remotes",
                                         repos = "https://cran.uib.no",
                                         dependencies = TRUE)

indUrl <-"https://raw.githubusercontent.com/helseprofil/misc/main/chk-ind/chk-bar.R"
devtools::source_url(indUrl)

## devtools::source_gist("e2822c40ba1165e3b5ea7632034932bb", filename = "ind-chk.R")
## check_bar(ind = indDTA, bar = barDTA, path = fpath)
