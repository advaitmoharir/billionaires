/*---------------------------------------------------------
Exhibits for Forbes billionaires data (Jayadev and Moharir)
--------------------------------------------------------*/


/*---------------------------------------------------
SECTION 0: SETUP DATA (WORLD BANK AND FORBE)
--------------------------------------------------------*/

// Set project directories

here,set //ssc install here
global data "01_data"
global code "02_code"
global figures "03_exhibits"

// Clean GDP data

wbopendata,indicator("NY.GDP.MKTP.CD"; "NY.GDP.MKTP.KD"; "NY.GDP.PCAP.CD"; "NY.GDP.PCAP.KD") country(all) long nometadata clear //ssc install wbopendata
rename countrycode iso3c
keep if inrange(year,1997,2023) // 2024 data not there
keep iso3c year ny*
rename ny_gdp_mktp_cd gdp_current
rename ny_gdp_mktp_kd gdp_const
rename ny_gdp_pcap_cd gdppc_current
rename ny_gdp_pcap_kd gdppc_const
tempfile gdp
save `gdp',replace

// Clean billionaires dataset and match with world bank

* Import and only keep citizenship country
import delimited using "$data/all_billionaires_1997_2024.csv",clear
drop country_of_residence
rename country_of_citizenship country
isocodes country,gen(iso3c) //ssc install isocodes

* Destring net worth
gen nw=substr(net_worth,1,4)
destring nw,force replace
encode full_name,gen(bill_id)

*merge GDP data
merge m:1 iso3c year using `gdp',nogen keep(3)
rename iso3c countrycode
rename country countryname
save "$data/billgdp",replace


/*---------------------------------------------------
FIGURE-1: WEALTH CONCENTRATION VS GDP PER CAPITA
--------------------------------------------------------*/

use "$data/billgdp",clear

* Get billionaires/GDPPC
bys countrycode year:egen bill_count=count(bill_id)
gen n_bill_gdppc=bill_count/gdppc_current
replace countrycode="OTH" if (countrycode!="CHN" & countrycode!="USA" & countrycode!="IND")

* Make plot

keep year n_bill_gdppc bill_id gdppc_current gdppc_const gdp_current gdp_const countrycode countryname
replace gdp_current=gdp_current/1000000000
set scheme white_tableau //ssc install schemepack

*replace gdppc_current=log(gdppc_current)
drop if gdppc_current>100000 // Very long x-axis

twoway (sc n_bill_gdppc gdppc_current if countrycode=="IND") ///
       (sc n_bill_gdppc gdppc_current if countrycode=="CHN") ///
       (sc n_bill_gdppc gdppc_current if countrycode=="USA") ///
       (sc n_bill_gdppc gdppc_current if countrycode=="OTH"), ///
     legend(order(1 "India" 2 "China" 3 "USA" 4 "Others") pos(6) col(4)) ///
       ytitle("Billionaires/GDP Per Capita") xtitle("Nominal GDP per capita") xlab(,nogrid) ///
	   text(0.07 2650 "2023", place(ne) size(small))  text(0.0023 441.928 "1999", place(e) size(small)) ///
 text(0.004 1300 "2002", place(e) size(small))  text(0.039 13000 "2023", place(e) size(small)) ///
	   text(0.004 37133 "2001", place(w) size(small))  text(0.008 82770 "2023", place(s) size(small))

gr export "$figures/bill_gdppc.png",replace	

/*---------------------------------------------------
FIGURE-2: SHARE OF SELF-MADE BILLIONAIRES
--------------------------------------------------------*/

use "$data/billgdp",clear

* Define self made indicatpr
gen self=(self_made=="True")
replace self=. if mi(self_made)

* Make graph

collapse self,by(countrycode year) // Share of self made billionaires
keep if year>2010 // Definition seems to have changed. Sudden spike for all countries
twoway (line self year if countrycode=="IND") ///
       (line self year if countrycode=="CHN") ///
	       (line self year if countrycode=="USA"), ///
     legend(order(1 "India" 2 "China" 3 "USA") pos(6) col(3)) ///
       ytitle("Share of self-made billionaires") xtitle("") xlab(#12,nogrid) ylab(0(0.1)1)

gr export "$figures/self_made.png",replace

/*---------------------------------------------------
FIGURE-3: BILLIONAIRES NET WORTH VS STOCK MKT CAP 
--------------------------------------------------------*/

use "$data/mkt_cap",clear
merge 1:m countrycode year using "$data/billgdp",nogen keep(3) keepusing(nw)

* Rescale
replace nw=nw*1000000000
collapse (sum) nw,by(countrycode year market_cap_domestic)

*Share of mkt cp
gen nw_cap_share=nw/market_cap_domestic
drop if year<2010 | year>2022

twoway (line nw_cap_share year if countrycode=="IND") ///
       (line nw_cap_share year if countrycode=="CHN") ///
	       (line nw_cap_share year if countrycode=="USA"), ///
     legend(order(1 "India" 2 "China" 3 "USA") pos(6) col(3)) ///
       ytitle("Net worth as share of domestic market cap") xtitle("") xlab(#10,nogrid)  xsc(r(2010(1)2022)) ylab(#6)
	   
gr export "$figures/market_cap.png",replace


