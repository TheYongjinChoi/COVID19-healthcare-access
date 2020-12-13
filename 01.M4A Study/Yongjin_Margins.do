********************************************************************************
/*----- Basic Setting -----*/
********************************************************************************

/*----- Essentials -----*/
// Initializing, delimiter, and working directory
#delimit cr
clear all
cd "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL"
set more off

// Output width
set linesize 240
display "{hline}"

// Color scheme for plots
set scheme s2color
grstyle init
grstyle color background white

/*----- (Optional) Installing Packages -----*/
//ssc install estout, replace;
//ssc install catplot, replace;
//ssc install coefplot, replace;
//ssc install tabout, replace;
//ssc install grstyle, replace;
//ssc install palettes, replace;

********************************************************************************
/*----- Data Prep -----*/
********************************************************************************

/*----- Simply, loading a cleaned dta from COVID_Survey Data_analysis_Qualtrics_sample_only -----*/
use "COVID_Survey Data_analysis_Qualtrics_sample_only", clear

// Variables
gen treatment = cond(COVID_arm_dummy == 1, 2, cond(Airbnb_arm_dummy == 1, 1, 0))
tab treatment
capture label var treatment "Treatment";
capture label define treatment 0 "Control" 1 "Airbnb Arm" 2 "COVID-19 Arm";
capture label values treatment treatment;

// Labeling
label var COVID_arm_dummy "COVID-19 Study Arm (Arm 1)"
label var Airbnb_arm_dummy "Airbnb Study Arm (Arm 2)"
label var female "Female"

/*----- Table 1 -----*/
tab support_M4A_likert

/*----- Table 2 -----*/
tab HR_11

/*----- Table 3 -----*/
sum HR01new_reverse_code, detail

/*----- Table 4 -----*/
// w/controls and nocontrols columns were switched

eststo clear
eststo m1: qui ologit support_M4A_DK COVID_arm_dummy
eststo m2: qui ologit support_M4A_DK COVID_arm_dummy i.Party_ID female i.age_cat i.race_cat i.income_cat
eststo mfx2: qui margins, at(COVID_arm_dummy=(0/1)) vsquish
qui marginsplot, ytitle("", margin(small)) xtitle("") title("(a) COVID-19 arm (no controls)") name(g2, replace)/*
               */plot(, label("Don't know" "Oppose" "Favor"))/*
               */xsize(8) ysize(5)/*
               */plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))/*
               */ci1opts(color(gs10))/*
               */plot2opts(pstyle(p2) msymbol(square))/*
               */plot3opts(pstyle(p1) msymbol(square))/*
               */xlab(-.25 " " 0 "Control" 1 "Treatment" 1.25 " ", notick)

eststo m3: qui ologit support_M4A_DK Airbnb_arm_dummy
eststo m4: qui ologit support_M4A_DK Airbnb_arm_dummy i.Party_ID female i.age_cat i.race_cat i.income_cat
eststo mfx4: qui margins, at(Airbnb_arm_dummy=(0 1)) vsquish
qui marginsplot, ytitle("", margin(small)) xtitle("") title("(b) Airbnb arm (w/ controls)") name(g4, replace)/*
               */plot(, label("Don't know" "Oppose" "Favor"))/*
               */xsize(8) ysize(5)/*
               */plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))/*
               */ci1opts(color(gs10))/*
               */plot2opts(pstyle(p2) msymbol(square))/*
               */plot3opts(pstyle(p1) msymbol(square))/*
               */xlab(-.25 " " 0 "Control" 1 "Treatment" 1.25 " ", notick)

qui graph combine g2 g4, l1("Support for M4A (Probability)") ycommon xsize(8) ysize(5)
graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\STATA_Outputs\Table4.grh", replace
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\STATA_Outputs\Table4.png", replace


esttab m1 m2 mfx2 m3 m4 mfx4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(2) ci(3) r2(3) ar2(3) scalar(F) /*
    */order(COVID_arm_dummy Airbnb_arm_dummy) /*
    */title(Table 4. Ordered Logit) /*
    */nonumbers /*
    */mgroups("COVID-19 Arm" "Airbnb Arm", pattern(1 0 0 1 0 0)) /*
    */mtitles("No controls" "w/ controls" "Margins" "No controls" "w/ controls" "Margins") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(25) modelwidth(15) compress /*
    */star(* 0.1 ** 0.05 *** 0.01)

//margins COVID_arm_dummy, vsquish

/*----- Table 4 with multinomial logit -----*/
eststo clear
eststo m1: qui mlogit support_M4A_DK i.treatment
eststo m2: qui mlogit support_M4A_DK i.treatment lost_insurance_dummy i.Party_ID female i.age_cat i.race_cat i.income_cat
qui margins, at(treatment=(0 1 2)) vsquish
qui marginsplot, ytitle("", margin(small)) xtitle("") title("(a) Treatment") name(g2_1, replace)/*
               */plot(, label("Don't know" "Oppose" "Favor"))/*
               */xsize(8) ysize(5)/*
               */plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))/*
               */ci1opts(color(gs10))/*
               */plot2opts(pstyle(p2) msymbol(square))/*
               */plot3opts(pstyle(p1) msymbol(square))/*
               */xlab(-.3 " " 0 "Control" 1 "Airbnb Arm" 2 "COVID-19 Arm" 2.3 " ", notick)

qui margins, at(lost_insurance_dummy=(0 1)) vsquish
qui marginsplot, ytitle("", margin(small)) xtitle("") title("(b) Experienced or Heard" "Insurance Loss") name(g2_2, replace)/*
               */plot(, label("Don't know" "Oppose" "Favor"))/*
               */xsize(8) ysize(5)/*
               */plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))/*
               */ci1opts(color(gs10))/*
               */plot2opts(pstyle(p2) msymbol(square))/*
               */plot3opts(pstyle(p1) msymbol(square))/*
               */xlab(-.25 " " 0 "Control" 1 "Lost Insurance" 1.25 " ", notick)

qui graph combine g2_1 g2_2, l1("Support for M4A (Probability)") ycommon xsize(8) ysize(5)
graph save "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\STATA_Outputs\Table4_mlogit.grh", replace
graph export "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\STATA_Outputs\Table4_mlogit.png", replace

esttab /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(2) ci(3) r2(3) ar2(3) scalar(F) /*
    */order(COVID_arm_dummy Airbnb_arm_dummy) /*
    */title(Table 4. Multinomial Logit) /*
    */nonumbers /*
    */mtitles("No controls" "w/ controls)") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(30) modelwidth(27) compress /*
    */star(* 0.1 ** 0.05 *** 0.01)

/*----- Table 5 with multinomial logit -----*/
// Typos in the second column
// Plots are not complete

eststo clear
local factors Party_ID lost_job lost_insurance_dummy
local title1 "(a) Party ID No Interaction"
local title2 "(b) Party ID w/ Interaction"
local title3 "(c) Job Loss No Interaction"
local title4 "(d) Job Loss w/ Interaction"
local title5 "(e) Insurance Loss No Interaction"
local title6 "(f) Insurance Loss w/ Interaction"

local num = 1
foreach x in `factors' {
    eststo m`num': qui ologit support_M4A_DK i.any_treat i.`x' female i.age_cat i.race_cat i.income_cat
    local num = `num' + 1
    if "`x'" == "Party_ID" {
        qui margins any_treat, at(`x'=(1 2 3)) vsquish
    }
    else {
        qui margins any_treat, at(`x'=(0 1)) vsquish
    }    
    qui marginsplot, ytitle("", margin(small)) xtitle("") title("`title`num''") name(g2_2, replace)/*
                   */plot(, label("Don't know" "Oppose" "Favor"))/*
                   */xsize(8) ysize(5)/*
                   */plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))/*
                   */ci1opts(color(gs10))/*
                   */plot2opts(pstyle(p2) msymbol(square))/*
                   */plot3opts(pstyle(p1) msymbol(square))/*
                   */xlab(-.25 " " 0 "Control" 1 "Lost Insurance" 1.25 " ", notick)

    eststo m`num': qui ologit support_M4A_DK i.any_treat##i.`x' female i.age_cat i.race_cat i.income_cat
    local num = `num' + 1
    if "`x'" == "Party_ID" {
        qui margins any_treat, at(`x'=(1 2 3)) vsquish
    }
    else {
        qui margins any_treat, at(`x'=(0 1)) vsquish
    }
    qui marginsplot, ytitle("", margin(small)) xtitle("") title("`title`num''") name(g2_2, replace)/*
                   */plot(, label("Don't know" "Oppose" "Favor"))/*
                   */xsize(8) ysize(5)/*
                   */plot1opts(mcolor(gs10) lcolor(gs10) lpattern("--") msymbol(square))/*
                   */ci1opts(color(gs10))/*
                   */plot2opts(pstyle(p2) msymbol(square))/*
                   */plot3opts(pstyle(p1) msymbol(square))/*
                   */xlab(-.25 " " 0 "Control" 1 "Lost Insurance" 1.25 " ", notick)
}


esttab /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(2) ci(3) r2(3) ar2(3) scalar(F) /*
    */order(any_treat Party_ID) /*
    */title(eTable 1) /*
    */nonumbers /*
    */mgroups("Party ID" "Job Loss" "Insurance Loss", pattern(1 0 1 0 1 0)) /*
    */mtitles("No Interaction" "w/ Interaction" "No Interaction" "w/ Interaction" "No Interaction" "w/ Interaction") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(30) modelwidth(27) compress /*
    */star(* 0.1 ** 0.05 *** 0.01)
