# misc
Andre relevante funksjoner som kan brukes i arbeidet med KHelse.

# installasjon
For å installere KHelse standard R pakke enklere, disse funksjoner kan brukes:

- `kh_install()` for å installere pakken fra *master* branch f.eks `kh_install("orgdata")`
- `kh_clone()` for å klone pakken fra *user* branch og beholder versjoner til
  alle pakkene som brukes f.eks `kh_clone("khfunctions")`
  
For å kunne bruke disse funksjonene, kjør:

``` R
source("https://raw.githubusercontent.com/helseprofil/misc/main/utils.R")
```
