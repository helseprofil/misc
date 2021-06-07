if (!require(devtools)) install.packages("remotes",
                                         repos = "https://cran.uib.no",
                                         dependencies = TRUE)
devtools::source_gist("e2822c40ba1165e3b5ea7632034932bb", filename = "ind-chk.R")
check_bar(ind = indDTA, bar = barDTA, path = fpath)

