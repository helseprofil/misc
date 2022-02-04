remotes::install_github("ropengov/pxweb", force = TRUE)

library("pxweb")


# Fetching data from StatBank (Statistics Norway)
d <- pxweb_interactive("data.ssb.no")

befurl <- "https://data.ssb.no/api/v0/en/table/07459"
bdata <- pxweb_get(befurl, dd)
