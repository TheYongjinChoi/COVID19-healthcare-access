********************************************************************************
/*----- Basic Setting -----*/
********************************************************************************

/*----- Essentials -----*/
#delimit ;
clear all;
cd "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\03.data\01.Survey\202006_COVID19";
set more off;

// Output width
set linesize 240;
display "{hline}";

// Color scheme for plots
grstyle clear;
set scheme s2color;
grstyle init;
grstyle set plain, box;
grstyle color background white;
//grstyle set color Set1;
grstyle yesno draw_major_hgrid yes;
grstyle yesno draw_major_ygrid yes;
grstyle color major_grid gs8;
grstyle linepattern major_grid dot;
grstyle set legend 4, box inside;
grstyle color ci_area gs12%50;

// Esttab Options
global esttab_opts nonumbers label nobaselevels interaction(" X ") compress star(* 0.1 ** 0.05 *** 0.01); //addnote("note")

/*----- Installing Packages -----*/
//ssc install estout, replace;
//ssc install catplot, replace;
//ssc install coefplot, replace;
//ssc install tabout, replace;
//ssc install grstyle, replace;
//ssc install palettes, replace;

********************************************************************************
/*----- Data Prep -----*/
********************************************************************************

/*----- Importing csv -----*/
clear all;
import delimited "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\03.data\01.Survey\202006_COVID19\COVID19Survey_20200613text_Ver1.0.csv", case(upper) clear;

drop if DURATION < 420;


/*----- Variables -----*/
// Treatment
capture label var TREATMENT "Treatment";
capture label define TREATMENT 0 "Control" 1 "Normal Unemployment" 2 "COVID19 Unemployment";
capture label values TREATMENT TREATMENT;

// MEDIA_FREQ: How much media coverage of Coronavirus have you been consuming in the past week?
gen MEDIA_FREQ = cond(MEDIA1 == "Very Little (less than weekly)", 0,
                         cond(MEDIA1 == "Somewhat (weekly)", 1,
                         cond(MEDIA1 == "A lot (daily)", 2, 3)));
capture label var MEDIA_FREQ "Media Consumption";
capture label define MEDIA_FREQ 0 "< Weekely" 1 "Weekly" 2 "Daily" 3 "> Daily";
capture label values MEDIA_FREQ MEDIA_FREQ;

// Media5: Primary source of media
capture gen MEDIA5_RAW = MEDIA5;
replace MEDIA5 = "0" if MEDIA5 == "CNN" | MEDIA5 == "MSNBC";
replace MEDIA5 = "1" if MEDIA5 == "Fox News";
replace MEDIA5 = "2" if MEDIA5 != "0" & MEDIA5 != "1";
destring MEDIA5, replace;
capture label var MEDIA5 "Primary Media Source";
capture label define MEDIA5 0 "CNN" 1 "Fox News" 2 "Others";
capture label values MEDIA5 MEDIA5;

replace MEDIA5_FOX = 0;
replace MEDIA5_FOX = 1 if MEDIA5_RAW == "Fox News";
capture label var MEDIA5_FOX "Fox News";
capture label define MEDIA5_FOX 0 "Others" 1 "Fox News Viewers";
capture label values MEDIA5_FOX MEDIA5_FOX;

capture gen MEDIA5_CNN = 0;
replace MEDIA5_CNN = 1 if MEDIA5_RAW == "CNN";
capture label var MEDIA5_CNN "CNN";
capture label define MEDIA5_CNN 0 "Others" 1 "CNN";
capture label values MEDIA5_CNN MEDIA5_CNN;

gen ALTERMEDIA = 0;
replace ALTERMEDIA = 1 if MEDIA5_RAW == "Alternative news media outlets (e.g., You Tube Channels)";

// Personal2: To what extent are you socially distancing?
capture gen PERSONAL2_RAW = PERSONAL2;
replace PERSONAL2 = "0" if PERSONAL2 == "Some of the time. I have reduced the amount of time that I am in public spaces, social gatherings or at work." | PERSONAL2 == "None of the time. I am doing everything I normally do.";
replace PERSONAL2 = "1" if PERSONAL2 == "All of the time. I am staying at home nearly all the time" | PERSONAL2 == "Most of the time. I only leave home to buy food or other essentials.";
destring PERSONAL2, replace;
capture label var PERSONAL2 "Degree of social distancing";
capture label define PERSONAL2 0 "Some or None" 1 "All or Most";
capture label values PERSONAL2 PERSONAL2;

// Personal3: Chances of going to a crowded place
capture gen PERSONAL3_RAW = PERSONAL3;
replace PERSONAL3 = "1" if PERSONAL3 == "Highly likely" | PERSONAL3 == "Likely";
replace PERSONAL3 = "0" if PERSONAL3 != "1";
destring PERSONAL3, replace;
capture label var PERSONAL3 "Chance of Going to a Crowded Place";
capture label define PERSONAL3 0 "Unlikely and Don't know" 1 "Likely";
capture label values PERSONAL3 PERSONAL3;

// Personal4: Should people be required to wear facial masks at public spaces?
capture gen PERSONAL4_RAW = PERSONAL4;
replace PERSONAL4 = "1" if PERSONAL4 == "Strongly agree" | PERSONAL4 == "Agree";
replace PERSONAL4 = "0" if PERSONAL4 != "1";
destring PERSONAL4, replace;
capture label var PERSONAL4 "Agreed to Face Covering";
capture label define PERSONAL4 0 "No or don't know" 1 "Yes";
capture label values PERSONAL4 PERSONAL4;

// WORRY1_1: How worried are you about each of the following: - Degree of Worry - Contracting the Coronavirus?
local vars WORRY1_1 WORRY1_2 WORRY1_3 WORRY1_4 WORRY1_5 WORRY1_6 WORRY1_7 WORRY1_8;

foreach name in `vars'{;
capture gen `name'_RAW = `name';
replace `name' = "1" if `name' == "Very Worried";
replace `name' = "1" if `name' == "Somewhat Worried";
replace `name' = "0" if `name' == "Not very worried";
replace `name' = "0" if `name' == "Not worried at all";
destring `name', replace;
capture label define `name' 0 "Not Worried" 1 "Worried";
capture label values `name' `name';
};

capture label var WORRY1_1 "Contracting Coronavirus";
capture label var WORRY1_2 "About complications";
capture label var WORRY1_3 "About complications to ";
capture label var WORRY1_4 "SD on the economy";
capture label var WORRY1_5 "SD on personal finances";
capture label var WORRY1_6 "Local health system capacity";
capture label var WORRY1_7 "School closing";
capture label var WORRY1_8 "Item shortages";

// Trust
gen TRST_NATGOV = 0;
gen TRST_STGOV = 0;
gen TRST_LOCGOV = 0;
gen TRST_MEDSCI = 0;
gen TRST_JNLST = 0;
gen TRST_K12PRCPL = 0;
gen TRST_BUSINESS = 0;

replace TRST_NATGOV = 1 if inlist(MEDIA61_1, "A great deal of confidence", "Complete confidence", "Some confidence");
replace TRST_STGOV = 1 if inlist(MEDIA61_2, "A great deal of confidence", "Complete confidence", "Some confidence");
replace TRST_LOCGOV = 1 if inlist(MEDIA61_3, "A great deal of confidence", "Complete confidence", "Some confidence");
replace TRST_MEDSCI = 1 if inlist(MEDIA61_4, "A great deal of confidence", "Complete confidence", "Some confidence");
replace TRST_JNLST = 1 if inlist(MEDIA61_5, "A great deal of confidence", "Complete confidence", "Some confidence");
replace TRST_K12PRCPL = 1 if inlist(MEDIA61_6, "A great deal of confidence", "Complete confidence", "Some confidence");
replace TRST_BUSINESS = 1 if inlist(MEDIA61_7, "A great deal of confidence", "Complete confidence", "Some confidence");

gen DISTRST_NATGOV = 0;
gen DISTRST_STGOV = 0;
gen DISTRST_LOCGOV = 0;
gen DISTRST_MEDSCI = 0;
gen DISTRST_JNLST = 0;
gen DISTRST_K12PRCPL = 0;
gen DISTRST_BUSINESS = 0;

replace DISTRST_NATGOV = 1 if inlist(MEDIA61_1, "No confidence at all", "Very little confidence");
replace DISTRST_STGOV = 1 if inlist(MEDIA61_2, "No confidence at all", "Very little confidence");
replace DISTRST_LOCGOV = 1 if inlist(MEDIA61_3, "No confidence at all", "Very little confidence");
replace DISTRST_MEDSCI = 1 if inlist(MEDIA61_4, "No confidence at all", "Very little confidence");
replace DISTRST_JNLST = 1 if inlist(MEDIA61_5, "No confidence at all", "Very little confidence");
replace DISTRST_K12PRCPL = 1 if inlist(MEDIA61_6, "No confidence at all", "Very little confidence");
replace DISTRST_BUSINESS = 1 if inlist(MEDIA61_7, "No confidence at all", "Very little confidence");


// Seriousness of COVID-19
replace POLICY2 = "1" if POLICY2 == "Very concerned";
replace POLICY2 = "0" if POLICY2 != "1";
destring POLICY2, replace;

replace POLICY3 = substr(POLICY3, 1, 7);
replace POLICY3 = "1" if POLICY3 == "This is";
replace POLICY3 = "0" if POLICY3 != "1";
destring POLICY3, replace;


// Culutural Cognition
forvalues x = 1(1)6 {;
    gen CULGOV`x' = cond(CULTURE11_`x' == "Agree Strongly" | CULTURE11_`x' == "Agree",  1, 0);
};

forvalues x = 1(1)7 {;
    gen CULSOC`x' = cond(CULTURE21_`x' == "Agree Strongly" | CULTURE21_`x' == "Agree",  1, 0);
};

// IDEOLOGY1: Republican, Democrat, or Independent
capture label var IDEOLOGY "Ideology";
capture label IDEOLOGY 0 "Republican" 1 "Democrat" 2 "Independent and Others";
capture label values IDEOLOGY IDEOLOGY;

capture encode IDEOLOGY7, gen(TRUMP);
recode TRUMP (2 = 1) (else = 0);

// Demographic3: Age
gen AGE = 2020 - DEMOGRAPHIC3;
replace AGE = 0 if AGE < 21;
replace AGE = 1 if AGE >= 21 & AGE <= 30;
replace AGE = 2 if AGE >= 31 & AGE <= 40;
replace AGE = 3 if AGE >= 41 & AGE <= 50;
replace AGE = 4 if AGE >= 51;
capture label var AGE "Age";
capture label define AGE 0 "<21" 1 "21-30" 2 "31-40" 3 "41-50" 4 ">51"
capture label values AGE AGE;

// Demographic10: Gender
drop if DEMOGRAPHIC10 == "Other, specify";
encode DEMOGRAPHIC10, gen(GENDER);

// Demographic11: Income level
gen INCOME = 0;
replace INCOME = 0 if DEMOGRAPHIC11 == "< $10,000" | DEMOGRAPHIC11 == "$10,001-$20,000";
replace INCOME = 1 if DEMOGRAPHIC11 == "$20,001-$50,000" | DEMOGRAPHIC11 == "$50,001-$75,000" | DEMOGRAPHIC11 == "$75,001-$150,000";
replace INCOME = 2 if DEMOGRAPHIC11 == "$150,001-$200,000" | DEMOGRAPHIC11 == ">$201,000-250,000" | DEMOGRAPHIC11 == "$250,001+";
capture label var INCOME "Income";
capture label define INCOME 0 "<$20,000" 1 "$20,001-$150,000" 2 ">$150,001";
capture label values INCOME INCOME;

// Demographic12: Race
gen RACE = DEMOGRAPHIC12;
replace RACE = "0" if RACE == "White";
replace RACE = "1" if RACE == "Black or African American";
replace RACE = "2" if RACE != "0" & RACE != "1";
destring RACE, replace;
capture label var RACE "Race";
capture label define RACE 0 "White" 1 "Black or African American" 2 "Others";
capture label values RACE RACE;

save "COVID19Survey_20200613", replace;

use "COVID19Survey_20200613", clear;

********************************************************************************
/*----- Data Prep -----*/
********************************************************************************

format PERSONAL2 PERSONAL4 WORRY1_1 WORRY1_2 WORRY1_4 WORRY1_8 TRST_NATGOV TRST_STGOV TRST_LOCGOV TRST_MEDSCI CULGOV1 POLICY3 %10.2f;
sum PERSONAL2 PERSONAL4 WORRY1_1 WORRY1_2 WORRY1_4 WORRY1_8 TRST_NATGOV TRST_STGOV TRST_LOCGOV TRST_MEDSCI CULGOV1 POLICY3, format;
estout using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\eTable1.rtf", cells("count mean sd min max") replace;

tab GENDER, nolabel;

gen AGE0 = 0;
gen AGE1 = 0;
gen AGE2 = 0;
gen AGE3 = 0;
gen AGE4 = 0;

replace AGE0 = 1 if AGE == 0;
replace AGE1 = 1 if AGE == 1;
replace AGE2 = 1 if AGE == 2;
replace AGE3 = 1 if AGE == 3;
replace AGE4 = 1 if AGE == 4;

gen IDEO0 = 0;
gen IDEO1 = 0;
gen IDEO2 = 0;

replace IDEO0 = 1 if IDEOLOGY == 0;
replace IDEO1 = 1 if IDEOLOGY == 1;
replace IDEO2 = 1 if IDEOLOGY == 2;

gen INCOME0 = 0;
gen INCOME1 = 0;
gen INCOME2 = 0;

replace INCOME0 = 1 if INCOME == 0;
replace INCOME1 = 1 if INCOME == 1;
replace INCOME2 = 1 if INCOME == 2;

gen RACE0 = 0;
gen RACE1 = 0;
gen RACE2 = 0;

replace RACE0 = 1 if RACE == 0;
replace RACE1 = 1 if RACE == 1;
replace RACE2 = 1 if RACE == 2;

gen MALE = 0;
replace MALE = 1 if GENDER == 2;
format MEDIA5_FOX IDEO0 IDEO1 IDEO2 AGE0 AGE1 AGE2 AGE3 AGE4 MALE INCOME0 INCOME1 INCOME2 RACE0 RACE1 RACE2 %10.2f;
sum MEDIA5_FOX IDEO0 IDEO1 IDEO2 AGE0 AGE1 AGE2 AGE3 AGE4 MALE INCOME0 INCOME1 INCOME2 RACE0 RACE1 RACE2, format;

tab MEDIA_FREQ, m;

disp "Social Distancing";
tab PERSONAL2;
tab PERSONAL2 if MEDIA_FREQ == 3;
tab PERSONAL2 if MEDIA_FREQ == 2;
tab PERSONAL2 if MEDIA_FREQ == 1;
tab PERSONAL2 if MEDIA_FREQ == 0;

disp "Face Covering";
tab PERSONAL4;
tab PERSONAL4 if MEDIA_FREQ == 3;
tab PERSONAL4 if MEDIA_FREQ == 2;
tab PERSONAL4 if MEDIA_FREQ == 1;
tab PERSONAL4 if MEDIA_FREQ == 0;

disp "COVID-19 Anxiety";
tab WORRY1_1;
tab WORRY1_1 if MEDIA_FREQ == 3;
tab WORRY1_1 if MEDIA_FREQ == 2;
tab WORRY1_1 if MEDIA_FREQ == 1;
tab WORRY1_1 if MEDIA_FREQ == 0;

tab WORRY1_2;
tab WORRY1_2 if MEDIA_FREQ == 3;
tab WORRY1_2 if MEDIA_FREQ == 2;
tab WORRY1_2 if MEDIA_FREQ == 1;
tab WORRY1_2 if MEDIA_FREQ == 0;

tab WORRY1_4;
tab WORRY1_4 if MEDIA_FREQ == 3;
tab WORRY1_4 if MEDIA_FREQ == 2;
tab WORRY1_4 if MEDIA_FREQ == 1;
tab WORRY1_4 if MEDIA_FREQ == 0;

tab WORRY1_8;
tab WORRY1_8 if MEDIA_FREQ == 3;
tab WORRY1_8 if MEDIA_FREQ == 2;
tab WORRY1_8 if MEDIA_FREQ == 1;
tab WORRY1_8 if MEDIA_FREQ == 0;

disp "Trust";
tab TRST_NATGOV;
tab TRST_NATGOV if MEDIA_FREQ == 3;
tab TRST_NATGOV if MEDIA_FREQ == 2;
tab TRST_NATGOV if MEDIA_FREQ == 1;
tab TRST_NATGOV if MEDIA_FREQ == 0;

tab TRST_STGOV;
tab TRST_STGOV if MEDIA_FREQ == 3;
tab TRST_STGOV if MEDIA_FREQ == 2;
tab TRST_STGOV if MEDIA_FREQ == 1;
tab TRST_STGOV if MEDIA_FREQ == 0;

tab TRST_LOCGOV;
tab TRST_LOCGOV if MEDIA_FREQ == 3;
tab TRST_LOCGOV if MEDIA_FREQ == 2;
tab TRST_LOCGOV if MEDIA_FREQ == 1;
tab TRST_LOCGOV if MEDIA_FREQ == 0;

tab TRST_MEDSC;
tab TRST_MEDSC if MEDIA_FREQ == 3;
tab TRST_MEDSC if MEDIA_FREQ == 2;
tab TRST_MEDSC if MEDIA_FREQ == 1;
tab TRST_MEDSC if MEDIA_FREQ == 0;

disp "Seriousness";
tab POLICY3;
tab POLICY3 if MEDIA_FREQ == 3;
tab POLICY3 if MEDIA_FREQ == 2;
tab POLICY3 if MEDIA_FREQ == 1;
tab POLICY3 if MEDIA_FREQ == 0;

tab CULGOV1;
tab CULGOV1 if MEDIA_FREQ == 3;
tab CULGOV1 if MEDIA_FREQ == 2;
tab CULGOV1 if MEDIA_FREQ == 1;
tab CULGOV1 if MEDIA_FREQ == 0;

disp "MEDIA5_FOX";
tab MEDIA5_FOX;
tab MEDIA5_FOX if MEDIA_FREQ == 3;
tab MEDIA5_FOX if MEDIA_FREQ == 2;
tab MEDIA5_FOX if MEDIA_FREQ == 1;
tab MEDIA5_FOX if MEDIA_FREQ == 0;

disp "Not worried";
tab WORRY1_1;
tab WORRY1_1 if MEDIA_FREQ == 3, label;
tab WORRY1_1 if MEDIA_FREQ == 2, label;
tab WORRY1_1 if MEDIA_FREQ == 1, label;
tab WORRY1_1 if MEDIA_FREQ == 0, label;

disp "Ideology";
tab IDEOLOGY;
tab IDEOLOGY if MEDIA_FREQ == 3, label;
tab IDEOLOGY if MEDIA_FREQ == 2, label;
tab IDEOLOGY if MEDIA_FREQ == 1, label;
tab IDEOLOGY if MEDIA_FREQ == 0, label;

disp "Age";
tab AGE;
tab AGE if MEDIA_FREQ == 3;
tab AGE if MEDIA_FREQ == 2;
tab AGE if MEDIA_FREQ == 1;
tab AGE if MEDIA_FREQ == 0;

disp "Gender";
tab GENDER;
tab GENDER if MEDIA_FREQ == 3;
tab GENDER if MEDIA_FREQ == 2;
tab GENDER if MEDIA_FREQ == 1;
tab GENDER if MEDIA_FREQ == 0;

disp "Income";
tab INCOME;
tab INCOME if MEDIA_FREQ == 3;
tab INCOME if MEDIA_FREQ == 2;
tab INCOME if MEDIA_FREQ == 1;
tab INCOME if MEDIA_FREQ == 0;

disp "Race";
tab RACE;
tab RACE if MEDIA_FREQ == 3;
tab RACE if MEDIA_FREQ == 2;
tab RACE if MEDIA_FREQ == 1;
tab RACE if MEDIA_FREQ == 0;

/* ----- Seven Measures ----- */
use "COVID19Survey_20200613", clear;
graph display, ysize(10) xsize(12);
    catplot PERSONAL2 MEDIA_FREQ, percent(MEDIA_FREQ)
    var1opts(label(labsize(small)))
    var2opts(label(labsize(small)) relabel(`r(relabel)'))
    ytitle("% Respondents", size(small))
    title("Social Distancing by Media Consumption", span size(medium)) blabel(bar, position(inside) format(%4.1f) size(vsmall) color(black))
    intensity(25);

capture label var RUMORS2_CORRECT "Correct Answers against COVID19 Rumors";
capture label RUMORS2_CORRECT 0 "Incorrect" 1 "Correct";
capture label values RUMORS2_CORRECT RUMORS2_CORRECT;
graph display, ysize(10) xsize(12);
    catplot RUMORS2_CORRECT MEDIA_FREQ, percent(MEDIA_FREQ)
    var1opts(label(labsize(small)))
    var2opts(label(labsize(small)) relabel(`r(relabel)'))
    ytitle("% Respondents", size(small))
    title("Correct Answers against COVID19 Rumors by Media Consumption", span size(medium)) blabel(bar, position(inside) format(%4.1f) size(vsmall) color(black))
    intensity(25);

graph display, ysize(10) xsize(12);
    catplot PERSONAL2 MEDIA_FREQ if NOT_WORRIED == 0, percent(MEDIA_FREQ)
    var1opts(label(labsize(small)))
    var2opts(label(labsize(small)) relabel(`r(relabel)'))
    ytitle("% Respondents", size(small))
    title("Social Distancing by Media Consumption (Not worried)", span size(medium)) blabel(bar, position(inside) format(%4.1f) size(vsmall) color(black))
    intensity(25);

graph display, ysize(10) xsize(12);
    catplot PERSONAL2 MEDIA_FREQ if NOT_WORRIED == 1, percent(MEDIA_FREQ)
    var1opts(label(labsize(small)))
    var2opts(label(labsize(small)) relabel(`r(relabel)'))
    ytitle("% Respondents", size(small))
    title("Social Distancing by Media Consumption (Others)", span size(medium)) blabel(bar, position(inside) format(%4.1f) size(vsmall) color(black))
    intensity(25);

graph display, ysize(10) xsize(12);
    catplot WORRY1_1 MEDIA_FREQ if NOT_WORRIED == 0, percent(MEDIA_FREQ)
    var1opts(label(labsize(small)))
    var2opts(label(labsize(small)) relabel(`r(relabel)'))
    ytitle("% Respondents", size(small))
    title("Social Distancing by Media Consumption (Not worried)", span size(medium)) blabel(bar, position(inside) format(%4.1f) size(vsmall) color(black))
    intensity(25);

graph display, ysize(10) xsize(12);
    catplot PERSONAL2 MEDIA_FREQ if NOT_WORRIED == 1, percent(MEDIA_FREQ)
    var1opts(label(labsize(small)))
    var2opts(label(labsize(small)) relabel(`r(relabel)'))
    ytitle("% Respondents", size(small))
    title("Social Distancing by Media Consumption (Others)", span size(medium)) blabel(bar, position(inside) format(%4.1f) size(vsmall) color(black))
    intensity(25);

********************************************************************************
/*----- Analysis -----*/
********************************************************************************

/*----- Figure 1. Social Distancing and Face Covering -----*/
eststo clear;
local outcomes PERSONAL2 PERSONAL4;
local title1 "(a) Social Distancing (All/Most of the Time))";
local title2 "(b) Face Covering (Strongly Agree / Agree)";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
        
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy)) 
    xsize(8) ysize(5) ylabel(0.4(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure1.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure1.png", replace;

/*----- Appendix 3. Social Distancing and Face Covering -----*/
esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix3.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 1)
    mgroups("Social Distancing" "Face Covering", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    wide
    $esttab_opts;

esttab lm1 mfx1 lm2 mfx2
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 1)
    mgroups("Social Distancing" "Face Covering", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(14)
    wide
    $esttab_opts;

/*----- Appendix 7. Logit: Social Distancing and Face Covering -----*/
eststo clear;
local outcomes PERSONAL2 PERSONAL4;
local title1 "(a) Social Distancing (All/Most of the Time))";
local title2 "(b) Face Covering (Strongly Agree / Agree)";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui logit `x' i.MEDIA_FREQ##i.MEDIA5_FOX WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
        
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy)) 
    xsize(8) ysize(5) ylabel(0.4(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure1_logit.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure1_logit.png", replace;

esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix5.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 5)
    mgroups("Social Distancing" "Face Covering", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    wide
    $esttab_opts;

esttab lm1 mfx1 lm2 mfx2
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 5)
    mgroups("Social Distancing" "Face Covering", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(14)
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    wide
    $esttab_opts;

/*----- Figure 2. COVID-19 Anxiety -----*/
eststo clear;
local outcomes WORRY1_1 WORRY1_2 WORRY1_4 WORRY1_8;
local title1 "(a) Contracting Coronavirus";
local title2 "(b) Serious Complication/Death from Coronavirus";
local title3 "(c) Effects of Social Distancing on the Economy";
local title4 "(d) Shortages of Necessary Items";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(6) ylabel(0.2(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2 g3 g4, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure2.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure2.png", replace;

esttab lm1 mfx1 lm2 mfx2 lm3 mfx3 lm4 mfx4
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix4.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 4)
    mgroups("Contracting Coronavirus" "Serious Complication/Death" "Effects on the Economy" "Shortages of Necessary Items", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

esttab lm1 mfx1 lm2 mfx2 lm3 mfx3 lm4 mfx4
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 4)
    mgroups("Contracting Coronavirus" "Serious Complication/Death" "Effects on the Economy" "Shortages of Necessary Items", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(17)
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

/*----- Figure 2. Logit: COVID-19 Anxiety -----*/
eststo clear;
local outcomes WORRY1_1 WORRY1_2 WORRY1_4 WORRY1_8;
local title1 "(a) Contracting Coronavirus";
local title2 "(b) Serious Complication/Death from Coronavirus";
local title3 "(c) Effects of Social Distancing on the Economy";
local title4 "(d) Shortages of Necessary Items";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui logit `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(6) ylabel(0.2(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2 g3 g4, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure2_logit.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure2_logit.png", replace;

esttab lm1 mfx1 lm2 mfx2 lm3 mfx3 lm4 mfx4
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix6.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 6)
    mgroups("Contracting Coronavirus" "Serious Complication/Death" "Effects on the Economy" "Shortages of Necessary Items", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

esttab lm1 mfx1 lm2 mfx2 lm3 mfx3 lm4 mfx4
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 6)
    mgroups("Contracting Coronavirus" "Serious Complication/Death" "Effects on the Economy" "Shortages of Necessary Items", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(15)
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

/*----- Figure 3. Trust -----*/
eststo clear;
local outcomes TRST_NATGOV TRST_STGOV TRST_LOCGOV TRST_MEDSCI;
local title1 "(a) National Government";
local title2 "(b) State Government";
local title3 "(c) Local Government";
local title4 "(d) Medical Scientists";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(6) ylabel(0.3(0.1)0.9)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2 g3 g4, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure3.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure3.png", replace;

esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix5.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 5)
    mgroups("National Gov." "State Gov." "Local Gov." "Medical Scientsts", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

esttab
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 5)
    mgroups("National Gov." "State Gov." "Local Gov." "Medical Scientsts", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(20)
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

/*----- Figure 3. Logit: Trust -----*/
eststo clear;
local outcomes TRST_NATGOV TRST_STGOV TRST_LOCGOV TRST_MEDSCI;
local title1 "(a) National Government";
local title2 "(b) State Government";
local title3 "(c) Local Government";
local title4 "(d) Medical Scientists";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui logit `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(6) ylabel(0.3(0.1)0.9)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2 g3 g4, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure3_logit.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure3_logit.png", replace;

esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix9.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 9)
    mgroups("National Gov." "State Gov." "Local Gov." "Medical Scientsts", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

esttab
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 9)
    mgroups("National Gov." "State Gov." "Local Gov." "Medical Scientsts", pattern(1 0 1 0 1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(15)
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

/*----- Figure 4. Government Interference -----*/
eststo clear;
local outcomes CULGOV1 POLICY3;
local title1 "(a) Government interferes too much";
local title2 "(b) Government is overreacting";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(5) ylabel(0(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure4.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure4.png", replace;

esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix6.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 6)
    mgroups("Intefere" "Overreacting", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(20) wide
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

esttab
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 6)
    mgroups("Intefere" "Overreacting", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(15) wide
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

/*----- Figure 4. Logit: Government Inteference -----*/
eststo clear;
local outcomes CULGOV1 POLICY3;
local title1 "(a) Government interferes too much";
local title2 "(b) Government is overreacting";

local num = 1;
foreach x in `outcomes' {;
    
    eststo lm`num': qui logit `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    eststo mfx`num': qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish post;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(5) ylabel(0(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);

graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure4_logit.gph", replace;
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure4_logit.png", replace;

esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix10.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 10)
    mgroups("Government interferes too much" "Government is overreacting", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins")
    varwidth(20) modelwidth(20) wide
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

esttab
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    ,replace b(4) ci(4) r2(4) ar2(4) scalar(F)
    title(Appendix 10)
    mgroups("Government interferes too much" "Government is overreacting", pattern(1 0 1 0))
    mtitles("Coefficients" "Margins" "Coefficients" "Margins") wide
    order(*.MEDIA_FREQ *._at#0.MEDIA5_FOX *.MEDIA5_FOX *._at#1.MEDIA5_FOX)
    $esttab_opts;

local outcomes CULGOV1 CULGOV2 CULGOV3 CULGOV4 CULGOV5 CULGOV6;

foreach x in `outcomes' {;
    eststo: qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish;
    
    marginsplot,
    ytitle("Point Estimates", margin(small)) xtitle("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    title("Figure. `X'") 
    plot1opts(pstyle(p1) msymbol(square)) plot2opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square)) legend(on order(1 "Others" 2 "Fox News Viewers"))
    ci2opts(color(gs10))
    xsize(8) ysize(5);
    graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\`x'.gph", replace;
};

local outcomes CULGOV1 CULGOV2 CULGOV3 CULGOV4 CULGOV5 CULGOV6;

foreach x in `outcomes' {;
    eststo: qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    qui margins MEDIA5_FOX 1.SOCMEDIA, at(MEDIA_FREQ=(0(1)3)) vsquish;
    
    marginsplot,
    ytitle("Point Estimates", margin(small)) xtitle("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    title("Figure. `X'") 
    plot1opts(pstyle(p1) msymbol(square)) plot2opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square)) legend(on order(1 "Others" 2 "Fox News Viewers"))
    ci2opts(color(gs10))
    xsize(8) ysize(5);
    graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\`x'.gph", replace;
};

/* ----- Figure 1 ----- */
eststo clear;
eststo: qui reg CULGOV1 MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA5_FOX MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
estimates store m1;
eststo: qui reg CULGOV1 MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA5_FOX MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE if WORRY1_1 == 0;
estimates store m1_2;
eststo: qui reg PERSONAL3 MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA5_FOX MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
estimates store m2;
eststo: qui reg PERSONAL3 MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA5_FOX MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE if WORRY1_1 == 0;
estimates store m2_2;

coefplot (m1, label(Social Distancing (All/Most of the Time)) mlabposition(12)), bylabel(Gov. interferes too much)
      || (m2), bylabel(Gov. is overreacting)
      || , keep(MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox 1.IDEOLOGY)
           xline(0, lp(dash) lc(gs12)) xtitle(Point Estimates, margin(small)) ytitle("How much media coverage of Coronavirus" "have you been consuming" "in the past week?")
           baselevels msymbol(s) byopts(row(1))
           xsize(10) ysize(6.5) subtitle(, fcolor(none) lstyle(none))
           //mlabel format(%9.2f) mlabsize(small)
           ciopts(recast(rcap))
           coeflabels(MEDIA_FREQ_Weekly = "Media (Weekly)"
                      MEDIA_FREQ_Daily = "Media (Daily)"
                      MEDIA_FREQ_MoreDaily = "Media (>Daily)"
                      MEDIA_FREQ_Weekly_Fox = `""Fox News x" "Media (Weekly)""'
                      MEDIA_FREQ_Daily_Fox = `""Fox News x" "Media (Daily)""'
                      MEDIA_FREQ_MoreDaily_Fox = `""Fox News x" "Media (>Daily)""'
                      1.IDEOLOGY = Republican);
//graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure1.gph", replace;
//graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure1.png", replace;

/*esttab
    using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix1.rtf"
    , replace ci r2 ar2 scalar(F) 
    title(Table 3. Multivariate) 
    nonumbers 
    mtitles("Social Distancing" "Social Distancing (No Worry)" "Face Covering" "Face Covering (No Worry)")
    //addnote("note") 
    label 
    nobaselevels noconstant
    interaction(" X ")
    varwidth(20)
    modelwidth(12)
    star(* 0.05 ** 0.01 *** 0.001);*/

esttab
    //using "Appendix1.rtf"
    , cells(b(fmt(a2)) "b(label(Coef.)) ci(label(95% CI))")
    r2 ar2 scalar(F) vce
    title(Appendix 1)
    nonumbers 
    mtitles("Social Distancing" "Social Distancing (No Worry)" "Face Covering" "Face Covering (No Worry)")
    //addnote("note") 
    label 
    nobaselevels
    interaction(" X ")
    varwidth(20)
    modelwidth(20)
    star(* 0.05 ** 0.01 *** 0.001);

gen CULGOV1_DUPL = CULGOV1;

gen CULGOV1_DUPL2 = CULGOV1;

use "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\01.data\01.Survey\202006_COVID19\COVID19Survey_20200613_3x.dta", clear; 

gen MEDIA_FREQ_Trgt_Weekly = 0;
gen MEDIA_FREQ_Trgt_Daily = 0;
gen MEDIA_FREQ_Trgt_MoreDaily = 0;

replace MEDIA_FREQ_Trgt_Weekly = MEDIA_FREQ_Weekly_CNN if MODEL == 1;
replace MEDIA_FREQ_Trgt_Daily = MEDIA_FREQ_Daily_CNN if MODEL == 1;
replace MEDIA_FREQ_Trgt_MoreDaily = MEDIA_FREQ_MoreDaily_CNN if MODEL == 1;

replace MEDIA_FREQ_Trgt_Weekly = MEDIA_FREQ_Weekly_Fox if MODEL == 2;
replace MEDIA_FREQ_Trgt_Daily = MEDIA_FREQ_Daily_Fox if MODEL == 2;
replace MEDIA_FREQ_Trgt_MoreDaily = MEDIA_FREQ_MoreDaily_Fox if MODEL == 2;

replace MEDIA_FREQ_Trgt_Weekly = MEDIA_FREQ_Weekly if MODEL == 3;
replace MEDIA_FREQ_Trgt_Daily = MEDIA_FREQ_Daily if MODEL == 3;
replace MEDIA_FREQ_Trgt_MoreDaily = MEDIA_FREQ_MoreDaily if MODEL == 3;

eststo clear;
eststo: qui reg CULGOV1 MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA5_FOX MEDIA5_CNN MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox MEDIA_FREQ_Trgt_Weekly MEDIA_FREQ_Trgt_Daily MEDIA_FREQ_Trgt_MoreDaily WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE if MODEL == 1;
estimates store m1;
eststo: qui reg CULGOV1 MEDIA_FREQ_Weekly MEDIA_FREQ_Daily MEDIA_FREQ_MoreDaily MEDIA5_FOX MEDIA5_CNN MEDIA_FREQ_Trgt_Weekly MEDIA_FREQ_Trgt_Daily MEDIA_FREQ_Trgt_MoreDaily MEDIA_FREQ_Weekly_CNN MEDIA_FREQ_Daily_CNN MEDIA_FREQ_MoreDaily_CNN WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE if MODEL == 2;
estimates store m2;
eststo: qui reg CULGOV1 MEDIA_FREQ_Trgt_Weekly MEDIA_FREQ_Trgt_Daily MEDIA_FREQ_Trgt_MoreDaily MEDIA5_FOX MEDIA5_CNN MEDIA_FREQ_Weekly_Fox MEDIA_FREQ_Daily_Fox MEDIA_FREQ_MoreDaily_Fox MEDIA_FREQ_Weekly_CNN MEDIA_FREQ_Daily_CNN MEDIA_FREQ_MoreDaily_CNN WORRY1_1 i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE if MODEL == 3;
estimates store m3;

coefplot (m1, recast(connected) label(CNN Viewers) mlabposition(7)) (m2, recast(connected) label(Fox News Viewers) mlabposition(7)) (m3, recast(connected) label(All Respondents) mcolor(gs10) lcolor(gs10)), bylabel(Gov. Interferes too much)
      || , keep(MEDIA_FREQ_Trgt_Weekly MEDIA_FREQ_Trgt_Daily MEDIA_FREQ_Trgt_MoreDaily) yline(0, lp(dash) lc(gs12)) ytitle(Point Estimates, margin(small)) xtitle("How much media coverage of Coronavirus have you been consuming in the past week?", margin(medium)) baselevels msymbol(s)
            xsize(8) ysize(5) subtitle(, fcolor(none) lstyle(none)) vertical ci(90)
            ciopts(recast(rcap)) byopts(row(2)) nooffsets;

local outcomes CULSOC1 CULSOC2 CULSOC3 CULSOC4 CULSOC5 CULSOC6 CULSOC7;

foreach x in `outcomes' {;
    eststo: qui reg `x' i.MEDIA_FREQ##i.MEDIA5_FOX i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    qui margins MEDIA5_FOX, at(MEDIA_FREQ=(0(1)3)) vsquish;
    
    marginsplot,
    ytitle("Point Estimates", margin(small)) xtitle("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    title("Figure. `x'") 
    plot1opts(pstyle(p1) msymbol(square)) plot2opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square)) legend(on order(1 "Others" 2 "Fox News Viewers"))
    ci2opts(color(gs10))
    xsize(8) ysize(5);
    graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\`x'.gph", replace;
};

eststo clear;
local outcomes PERSONAL2 PERSONAL4 WORRY1_1 WORRY1_2 WORRY1_4 WORRY1_8 TRST_NATGOV TRST_STGOV TRST_LOCGOV TRST_MEDSCI CULGOV1 CULGOV4;
local title1 "(a) Social Distancing" "(All/Most of the Time))";
local title2 "(b) Face Covering" "(Strongly Agree / Agree)";
local title3 "(c) Contracting Coronavirus";
local title4 "(d) Serious Complication/Death" "from Coronavirus";
local title5 "(e) Effects of Social Distancing on the Economy";
local title6 "(f) Shortages of Necessary Items";
local title7 "(g) National Government";
local title8 "(h) State Government";
local title9 "(i) Local Government";
local title10 "(j) Medical Scientists";
local title11 "(k) Government interferes" "too much";
local title12 "(i) It is not the Government's" "businees to protect people" "from hurting themselves";

local num = 1;
foreach x in `outcomes' {;
    
    eststo: qui reg `x' i.MEDIA_FREQ##i.SOCMEDIA i.IDEOLOGY i.AGE i.GENDER i.INCOME i.RACE;
    qui margins SOCMEDIA, at(MEDIA_FREQ=(0(1)3)) vsquish;
    
    qui marginsplot,
    title("`title`num''") xtitle("") ytitle("")
    plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))
    plot2opts(pstyle(p1) msymbol(square))
    ci1opts(color(gs10)) ci2opts(color(navy))
    xsize(8) ysize(6) ylabel(0.2(0.1)1)
    //ylabel(, nolabels)
    name(g`num', replace);
    local num = `num' + 1;
};

graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 g11 g12, 
    b1("How much media coverage of Coronavirus have you been consuming" "in the past week?")
    l1("Pr(Y = 1)")
    ycommon
    xsize(8) ysize(5);
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Figure_Social Media.png", replace;
