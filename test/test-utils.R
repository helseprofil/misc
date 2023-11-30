source("./utils.R")
kh_load(tinytest)

pkgName <- c("norgeo", "data.table", "orgdata", "tinytest")
expect_equal(pkg_name(c("norg","data.table","orgda", "tinytest")), pkgName)

expect_error(kh_load(orgdata, khfun))

expect_equal(pkg_name("ORGdata"), c(ORGdata = "orgdata"))
