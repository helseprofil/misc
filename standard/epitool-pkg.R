## Get datasets from standard.R
library(epitools)


dtNorge <- dget("norge.txt")

## Ref http://finzi.psych.upenn.edu/R/library/epitools/html/ageadjust.direct.html
## Data from Fleiss, 1981, p. 249 
population <- c(230061, 329449, 114920, 39487, 14208, 3052,
                72202, 326701, 208667, 83228, 28466, 5375, 15050, 175702,
                207081, 117300, 45026, 8660, 2293, 68800, 132424, 98301, 
                46075, 9834, 327, 30666, 123419, 149919, 104088, 34392, 
                319933, 931318, 786511, 488235, 237863, 61313)
population <- matrix(population, 6, 6, 
                     dimnames = list(c("Under 20", "20-24", "25-29", "30-34", "35-39",
                                       "40 and over"), c("1", "2", "3", "4", "5+", "Total")))
population
count <- c(107, 141, 60, 40, 39, 25, 25, 150, 110, 84, 82, 39,
           3, 71, 114, 103, 108, 75, 1, 26, 64, 89, 137, 96, 0, 8, 63, 112,
           262, 295, 136, 396, 411, 428, 628, 530)
count <- matrix(count, 6, 6, 
                dimnames = list(c("Under 20", "20-24", "25-29", "30-34", "35-39",
                                  "40 and over"), c("1", "2", "3", "4", "5+", "Total")))
count

### Use average population as standard
standard<-apply(population[,-6], 1, mean)
standard

### This recreates Table 1 of Fay and Feuer, 1997
birth.order1<-ageadjust.direct(count[,1],population[,1],stdpop=standard)
round(10^5*birth.order1,1)

birth.order2<-ageadjust.direct(count[,2],population[,2],stdpop=standard)
round(10^5*birth.order2,1)

birth.order3<-ageadjust.direct(count[,3],population[,3],stdpop=standard)
round(10^5*birth.order3,1)

birth.order4<-ageadjust.direct(count[,4],population[,4],stdpop=standard)
round(10^5*birth.order4,1)

birth.order5p<-ageadjust.direct(count[,5],population[,5],stdpop=standard)
round(10^5*birth.order5p,1)


## Indirect standardization
## Ref http://finzi.psych.upenn.edu/R/library/epitools/html/ageadjust.indirect.html
#From Selvin (2004)
##enter data
dth60 <- c(141, 926, 1253, 1080, 1869, 4891, 14956, 30888,
           41725, 26501, 5928)

pop60 <- c(1784033, 7065148, 15658730, 10482916, 9939972,
           10563872, 9114202, 6850263, 4702482, 1874619, 330915)

dth40 <- c(45, 201, 320, 670, 1126, 3160, 9723, 17935,
           22179, 13461, 2238)

pop40 <- c(906897, 3794573, 10003544, 10629526, 9465330,
           8249558, 7294330, 5022499, 2920220, 1019504, 142532)

##calculate age-specific rates
rate60 <- dth60/pop60; rate60
rate40 <- dth40/pop40; rate40

#create array for display
tab <- array(c(dth60, pop60, round(rate60*100000,1), dth40, pop40,
               round(rate40*100000,1)),c(11,3,2))
agelabs <- c("<1", "1-4", "5-14", "15-24", "25-34", "35-44", "45-54",
             "55-64", "65-74", "75-84", "85+")
dimnames(tab) <- list(agelabs,c("Deaths", "Population", "Rate"),
                      c("1960", "1940"))
tab

##implement direct age standardization using 'ageadjust.direct'
dsr <- ageadjust.direct(count = dth40, pop = pop40, stdpop = pop60)
round(100000*dsr, 2) ##rate per 100,000 per year

##implement indirect age standardization using 'ageadjust.indirect'
isr <- ageadjust.indirect(count = dth40, pop = pop40,
                          stdcount = dth60, stdpop = pop60)
round(isr$sir, 2)         ##standarized incidence ratio
round(100000*isr$rate, 1) ##rate per 100,000 per year












## Ref https://epidemiological.net/2019/04/16/epi-101-direct-age-adjustment-by-hand-and-with-r/
age_groups <- c("0-15", "16-35", "36-55", "56-75", ">75") # Labels for Age Groups
population_a <- c(10000, 12000, 15000, 25000, 30000) # Population A
population_b <- c(25000, 15000, 20000, 12000, 11000) # Population B
deaths_a <- c(100, 600, 1050, 2500, 4500) # Deaths in Population A
deaths_b <- c(250, 750, 1400, 1200, 1650) # Deaths in Population B
std_pop <- c(20000,30000,35000,37000, 28000) # Population of Standard Population

df_a <- data.frame(age=age_groups, # Data frame for Population A
                   death=deaths_a,
                   fu=population_a, # fu (follow-up) can be person-time or population counts
                   population='A')

df_b <- data.frame(age=age_groups, # Data frame for Population B
                   death=deaths_b,
                   fu=population_b, # fu (follow-up) can be person-time or population counts
                   population='B')

df_all <- rbind(df_a, df_b) # Data frame combining both populations

df_pop <- data.frame(age=age_groups, # Data frame for the Standard/Reference Population
                     pop=std_pop)

df_all
df_pop

