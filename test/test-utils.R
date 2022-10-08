source("./utils.R")
kh_load(tinytest)

pkgName <- c("norgeo", "data.table", "orgdata", "tinytest")
expect_equal(pkg_name(c("norg","data.table","orgda", "tinytest")), pkgName)
