# misc
Denne repo inneholder ymse funksjoner eller filer som er relevante i arbeidet
med KHelse eller som referanser.

# Pakke installasjon
For å installere KHelse standard R pakker enklere, disse funksjoner kan brukes:

- `kh_install()` for å installere pakken til vanlig bruk f.eks `kh_install(orgdata)`
- `kh_restore()` for å videre utvikle pakken fra *user* branch dvs. beholder alle
  tillegg pakke versjoner som brukes f.eks `kh_restore(orgdata)`
  
For å tilgjengeligjøre og kunne bruke disse funksjonene, først må denne koden kjøres:

``` R
source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
```

Standard branch for installasjon er `master` eller `main`. For å bruke andre
branch kan gjøres ved bruk av `@` f.eks for å installere fra branch `iss007`

``` R
kh_install(orgdata@iss007)
```

`

# Bonus 

Hvis man vil *load* pakker så kan man bruke `pkg_load()`. Denne funksjonen skal
installere pakker hvis ikke allerede finnes i `.libPaths()` før *loading*.
Denne funksjonen gjelder bare for KHelse relaterte pakker og pakker som finnes på CRAN.

``` R
pkg_load(dplyr, ggplot2, norgeo)
```
