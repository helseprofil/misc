# misc
Andre relevante funksjoner som kan brukes i arbeidet med KHelse.

# installasjon
For å installere KHelse standard R pakke enklere, disse funksjoner kan brukes:

- `kh_install()` for å installere pakken fra *master* branch f.eks `kh_install("orgdata")`
- `kh_restore()` for å gjenopprette pakken fra *user* branch dvs. beholder alle
  tillegg pakke versjoner som brukes f.eks `kh_restore("khfunctions")`
  
For å tilgjengeligjøre og kunne bruke disse funksjonene, først må denne koden kjøres:

``` R
source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
```
