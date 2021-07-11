cap cd "/Users/kevincroke/Dropbox (Personal)/School Reopening_Research Note/_M4A Experiment/"

 use "/Users/kevincroke/Dropbox (Personal)/covid/COVID_Survey Data.dta", clear
 *use  "/Users/kevincroke/Dropbox (Personal)/School Reopening_Research Note/_M4A Experiment/COVID_Survey Data_analysis_Qualtrics_sample_only.dta

 
count  // 1782 obs
 
tab Finished // 1399
 
drop if Finished==0 // 383 dropped

sum Consent_2 AC AJ // diff consent questions by arm?
gen no_consent = (Consent_2==2 | AC==2 | AJ==2)

drop if no_consent==1
  
  *Ashley's code
  recode gc (1=1 "good responses") (2 4=.) (.=2 "non-Qualtrics responses"), generate(good_sample)
  recode good_sample (1 2= 1), generate(good_sample_dummy)
drop if good_sample==2 // 0 obs dropped here

*add blocks of Ashley's data cleaning code
 
  
***create treatment assignment variables

encode block, generate(study_condition)

recode study_condition (3=0 "control") (2=1 "arm 2") (1=3 "arm 1"), generate (studycondition)
 
gen any_treat = studycondition>0

gen arm1 = block=="arm1"
gen arm2 = block=="arm2"

gen covid_treat = any_treat==1 & study_condition==1


sum Comprehension* AH AI

sum Comprehension* AH AI if arm1==1
sum Comprehension* AH AI if arm2==1
sum Comprehension* AH AI if (arm1==0 & arm2==0)

gen q1 = (Comprehension1 ==1 & arm1==1)
replace q1 = . if arm1~=1
*gen q2 = (Comprehension2 ==1 & arm1==1)
*replace q2 = . if arm1~=1

gen q1_alt= (Comprehension1 ==2 & arm2==1)
replace q1_alt = . if arm2~=1
tab q1_alt

gen q2 = (Comprehension2 ==1 & any_treat==1)
replace q2 = . if any_treat==0
tab q2

gen attentive = (q1==1 & q2==1) if arm1==1
replace attentive = 1 if (q1_alt==2 & q2==1) & arm2==1
replace attentive = . if any_treat==0
tab attentive
 
gen attentive_all=attentive
replace attentive_all = 1 if any_treat==0
 
/*
foreach y in Comprehension* {
replace `y'=0 if `y'==2
}
*/


 **generate controls: 
 **age, party id, ideology,
 
gen birthyear= 2011-Demographic_3
gen age=2020-birthyear

gen under25 = (age<25) if !missing(age)
gen age25_44 = (age>=25 & age<44) if !missing(age)
gen age44_65 = (age>=44 & age<65) if !missing(age)
gen under40= (age<40) if !missing(age)
gen over65 = (age>=65) if !missing(age)

 
gen pid_dem =  Ideology_1==1 if !missing(Ideology_1)
gen pid_gop =  Ideology_1==4 if !missing(Ideology_1)
gen pid_ind = Ideology_1==5 if !missing(Ideology_1)

replace pid_ind =1 if Ideology_1==6 // recode "other" as independent

gen dem_lean = pid_dem
replace dem_lean =1 if pid_ind==1 & Ideology_2==10

gen gop_lean = pid_gop
replace gop_lean =1 if pid_ind==1 & Ideology_2==11



recode Ideology_5 (1=1 "far right") (4=2 "Center Right") (5=3 "neither right nor left") (6=4 "center left") (7=5 "far left"), generate(ideol_left_right_spectrum)

gen rightwing= ideol_left_right_spectrum<=2
replace rightwing=. if ideol_left_right_spectrum==.

tab Ideology_6
gen pol_engagement = (Ideology_6==1 | Ideology_6==4) if !missing(Ideology_6)
gen disengaged = (Ideology_6==6 | Ideology_6==7) if !missing(Ideology_6)


tab Ideology_7
gen trump_voter = (Ideology_7==5) if !missing(Ideology_7)
gen clinton_voter    = (Ideology_7==6) if !missing(Ideology_7)
gen non_voter =  (Ideology_7==1) if !missing(Ideology_7)

gen female = Demographic_10==1

tab Demographic_11
gen under20k =  (Demographic_11<17) if !missing(Demographic_11)
gen income20_75 = (Demographic_11==18 | Demographic_11==19) if !missing(Demographic_11)
gen income75_150 = Demographic_11==20 if !missing(Demographic_11)
gen income_150k = Demographic_11>=21 if !missing(Demographic_11)

gen income75k= (Demographic_11>19) if !missing(Demographic_11)



gen white = (Demographic_12==1) if !missing(Demographic_12)
gen hispanic = (Demographic_12==8) if !missing(Demographic_12)
*gen nonwhite = (Demographic_12~=1) if !missing(Demographic_12)
gen other_nonwhite = inlist(Demographic_12, 10, 11, 12, 13, 14)
gen afr_american = Demographic_12==9 if !missing(Demographic_12)

***
***Create macros
****

global age = "under25 age25_44 age44_65 over65"
global pid "pid_dem pid_ind pid_gop"
global income "income20_75 income75_150 income_150k"
global ethnic "white hispanic other_nonwhite afr_american"
global reg "est1 est2 est3 est4"


gen christian = (Demographic_8<=6) if !missing(Demographic_8)

*check sample balance
*reg balancevarname testgroupdummy
*test testgroupdummy 


recode HR_07_1 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_1_dummy)
label variable HR_07_1_dummy "Provides a basic tax financed health plan to everyone but allows people to buy supp. private health insurance allowed" 

recode HR_07_2 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_2_dummy) 
label variable HR_07_2_dummy "Requires many businesses and some individuals to pay more in taxes but eliminates health insurance premiums and deductibles" 

recode HR_07_3 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_3_dummy) 
label variable HR_07_3_dummy "Increase the taxes that you personally pay but decreases your overall costs for healthcare." 

recode HR_07_4 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_4_dummy) 
label variable HR_07_4_dummy "Provides a basic tax financed health plan to everyone but allows people to purchase supplementary private health insurance." 

 

recode Childcare_13 (1=1 "Kids are still in school/daycare") (4=2 "Kids are home with me/partner") ///
(5=3 "Kids are being watched by a grandparent") (6 7=4 "Other"), generate(childcare_source) 

label variable childcare_source "Which of the following best describes what you are currently doing for childcare?" 

recode Childcare_1 (1=1 "Yes, have school-age kids") (4=0 "No"), generate(have_school_age_kids)


recode HR_13 (1 8=1 "lost health insurance") (6 9=2 "someone close to me lost health insurance") ///
(4 5 =3 "No, unsure"), generate(health_insurance_situation) 

label variable health_insurance_situation "Have you or anyone close to you lost their health insurance in the last 6 months due to being laid off from work or for other reasons?" 


recode health_insurance_situation (1 2=1 "you personally or someone close to you lost health insurance") ///
(3=0 "health insurance situation unchanged"), generate (lost_insurance_dummy)

recode HR_14 (1=1 "ESI") (4=2 "Marketplace plan, with subsidy") ///
 (5=3 "Marketplace plan, without subsidy") (6=4 "Uninsured") (7=5 "Medicaid") (8 11=6 "Medicare (traditional or Advantage Plan") (9=7 "VA") (10=8 "Other"), generate(current_health_insurance)

  
global project_folder "/Users/kevincroke/Dropbox (Personal)/School Reopening_Research Note/_M4A Experiment/tables"
iebaltab age female white income75k pid_dem pol_engagement christian, grpvar(any_treat) ///
save("$project_folder/balancetable.xlsx") replace

foreach y in age under40 over65 female white afr_american income75k pid_dem trump_voter {
reg `y' any_treat
} 

 *clean M4A variable
 
 
recode HR_08 (1=1 "Strongly Favor") (4=2 "Somewhat Favor") (5=3 "Somewhat Oppose") (6=4 "Strongly Oppose") ///
 (7=7 "Don't know"), generate(support_M4A_likert)

 recode support_M4A_likert (1 2=1 "Favor") (3 4 7=0 "Oppose"), generate(support_M4A_dummy)
 recode support_M4A_likert (1 2=1 "Favor") (3 4=0 "Oppose"), generate(support_M4A_dummy2)

replace support_M4A_dummy2 = . if support_M4A_dummy2==7
 
 gen m4a = support_M4A_dummy
 gen m4a2 = support_M4A_dummy2

 
 *clean first variable
 
*recode HR_01_NEW (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4)(8=3) (9=2) (12=1), generate(HR01new_reverse_code)

recode HR_01_NEW (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4)(8=3) (9=2) (12=1), generate(HR01new_reverse_code)


gen govinsure =HR01new_reverse_code
gen govinsure_binary = (HR01new_reverse_code>5) if !missing(HR01new_reverse_code)


gen govinsure_alt=HR_01_NEW
replace govinsure_alt=. if HR_01_NEW==12


tab Media_8 // NCD diagnosis
gen no_ncd = Media_8=="10"
gen any_ncd = 1 - no_ncd
gen dm = regexm(Media_8, "1")
replace dm=0 if Media_8=="10"
gen hd  = regexm(Media_8, "4")
gen htn  = regexm(Media_8, "11")
gen asthma  = regexm(Media_8, "7")
gen cancer  = regexm(Media_8, "5")
gen hiv = regexm(Media_8, "6")
gen cld  = regexm(Media_8, "8")
gen other = regexm(Media_8, "9")

globa ncds "dm hd htn asthma cancer hiv cld other"

sum $ncds

egen ncd_count = rowtotal(dm hd htn asthma cancer hiv cld other)
tab ncd_count
gen multimorbidity = ncd_count>=2

gen fox  = Media_5==1

*code up loss of health insurance
tab HR_13
gen lost_hi_job= (HR_13==1) if !missing(HR_13)
lab var lost_hi_job "lost insurance due to job loss in last 6 months"

gen lost_hi= (HR_13==1 | HR_13==8) if !missing(HR_13)
lab var lost_hi "lost insurance due to job loss or other reason in last 6 months"

gen lost_hi_close= (HR_13==1 | HR_13==8 | HR_13==6 | HR_13==9) if !missing(HR_13)
lab var lost_hi_close "respondent or someone close lost insurance due to job loss or other reason in last 6 months"

**code up lost job
*in the context of the Stimulus section, we ask how job situations have changed since COVID
*this include questions

gen lost_job =regexm(Stimulus_1, "4")
lab var lost_job "respondent lost job since start of COVID"
gen lost_or_furloughed =lost_job
lab var lost_or_furloughed "respondent lost job or was furloughed since start of COVID"

gen lost_job_alt = regexm(Personal_7, "4")

gen lost_hi_covid_job = (lost_hi_job==1 & lost_job==1) 

replace lost_or_furloughed =1 if regexm(Stimulus_1, "10")

sum lost*


**low numbers - private sector, high numbers (10) mean support for government

**Table 1

tab support_M4A_likert


**Table 2

tab HR_11


**Table 3

sum HR01new_reverse_code, detail

**table 4 *balance



**table 6: 


tab m4a2 study_condition, chi2


**table 7


tab m4a2 any_treat, cell chi2


**table 8: mai experimental results
eststo clear
eststo: reg m4a2 arm* 
eststo: reg m4a2 arm* female $age $ethnic $income $pid
eststo: reg m4a2 any_treat
eststo: reg m4a2 any_treat female $age $ethnic $income $pid
estout $reg, cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) ///
starlevels(* .1 ** .05 *** .01) label mlabels("no controls" "controls"  "no controls" "controls")
estout $reg using "$project_folder/main_results.rtf", cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) starlevels(* .1 ** .05 *** .01) ///
label varlabels(_cons Constant) replace title(effect of priming on M4A support)


**table 9: 
eststo clear
eststo: reg m4a2 i.any_treat##i.lost_hi_job 
eststo: reg m4a2 i.any_treat##i.lost_hi_job female $age $ethnic $income $pid
eststo: reg m4a2 i.any_treat##i.lost_job 
eststo: reg m4a2 i.any_treat##i.lost_job female $age $ethnic $income $pid
estout $reg, cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) ///
starlevels(* .1 ** .05 *** .01) label mlabels("no controls" "controls"  "no controls" "controls")
estout $reg using "$project_folder/jobloss_treat.xls", cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) starlevels(* .1 ** .05 *** .01) ///
label varlabels(_cons Constant) replace title(effect of priming interacted with job loss)



**table 10: 
eststo clear
eststo: reg m4a2 i.any_treat##i.pid_gop 
eststo: reg m4a2 i.any_treat##i.pid_gop  i.any_treat##i.pid_ind   female $age $ethnic $income $pid
eststo: reg m4a2 i.any_treat##i.pid_gop  
eststo: reg m4a2 i.any_treat##i.pid_gop  i.any_treat##i.pid_ind  female $age $ethnic $income $pid
estout $reg, cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) ///
starlevels(* .1 ** .05 *** .01) label mlabels("no controls" "controls"  "no controls" "controls")
estout $reg using "$project_folder/party_treat.xls", cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) starlevels(* .1 ** .05 *** .01) ///
 label varlabels(_cons Constant) replace title(effect of priming interacted with party ID)

**table 11: interact job loss with Party ID
eststo clear
eststo: reg m4a2 i.lost_hi_job##i.pid_gop  
eststo: reg m4a2  i.lost_hi_job##i.pid_gop      female $age $ethnic $income $pid
eststo: reg m4a2 i.lost_hi##i.pid_gop  
eststo: reg m4a2  i.lost_hi##i.pid_gop     female $age $ethnic $income $pid
estout $reg, cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) ///
starlevels(* .1 ** .05 *** .01) label mlabels("no controls" "controls"  "no controls" "controls")
estout $reg using "$project_folder/party_jobloss.xls", cells(b(star fmt(3)) se(par)) stats(N, fmt(0) labels("Observations")) starlevels(* .1 ** .05 *** .01) ///
 label varlabels(_cons Constant) replace title(effect of job loss interacted with party ID)





**Table A1: Continuous Measure- Support M4A, Support Private Provision, 10 point scale, OLS

reg govinsure i.study_condition female $age $ethnic $income $pid
reg govinsure i.study_condition 

reg govinsure i.study_condition if good_sample==1

reg HR01new_reverse_code i.study_condition if good_sample==1


reg govinsure_alt i.study_condition $age $ethnic $income $pid





*why does this not correlate? 
corr support_M4A_dummy govinsure_binary




**interaction of lost health insurance? 

**lost health insurance
reg m4a2 i.any_treat##i.lost_hi female $age $ethnic $income $pid
k
**lost health insurance due to job loss
reg m4a2 i.any_treat##i.lost_hi_job female $age $ethnic $income $pid

**respondent or someone close lost insurance due to job loss or other reason
reg m4a2 i.any_treat##i.lost_hi_close female $age $ethnic $income $pid


**respondent lost job

reg m4a2 i.any_treat##i.lost_job female $age $ethnic $income $pid

reg m4a2 i.any_treat##i.lost_job_alt $age $ethnic $income pid_dem pid_ind
reg m4a2 i.any_treat##i.lost_hi_covid_job $age $ethnic $income pid_dem pid_ind

*Does this interact with PID?
reg m4a2 i.lost_hi##pid_dem $age $ethnic $income
reg m4a2 i.lost_hi##pid_gop $age $ethnic $income


reg support_M4A_dummy i.any_treat##i.lost_job $age $ethnic $income if pid_gop==1
reg support_M4A_dummy i.any_treat##i.lost_job $age $ethnic $income if pid_ind==1

reg support_M4A_dummy any_treat $age $ethnic $income $pid trump_voter




**interaction of party id?
foreach y in pid_dem pid_gop pid_ind {
reg support_M4A_dummy i.any_treat##i.`y' age female white
}


foreach y in pid_dem pid_gop pid_ind {
reg support_M4A_dummy i.any_treat##i.`y' $age $ethnic $income
}

*test for GOP with others in models

reg m4a2 i.any_treat##i.pid_gop i.any_treat##i.pid_ind $age $ethnic $income 
reg m4a2 i.any_treat##i.pid_dem  i.any_treat##i.pid_ind $age $ethnic $income 

reg m4a2 i.any_treat##i.pid_dem  i.any_treat##i.pid_gop $age $ethnic $income 

reg m4a2 i.lost_job##pid_dem $age $ethnic $income 


reg m4a2 i.any_treat##i.gop_lean  $age $ethnic $income 
reg m4a2 i.any_treat##i.dem_lean  $age $ethnic $income 

reg m4a2 i.any_treat##i.trump_voter  $age $ethnic $income 
reg m4a2 i.any_treat##i.clinton_voter  $age $ethnic $income 
reg m4a2 i.any_treat##i.non_voter  $age $ethnic $income 


reg m4a2 i.any_treat##i.pid_dem  i.any_treat##i.pid_ind $age $ethnic $income 


*pol engagement
reg m4a2 i.any_treat##i.disengaged $age $ethnic $income $pid
reg  m4a2 i.any_treat##i.pol_engagement $age $ethnic $income $pid


**treatment effect by NCD status
reg m4a2 i.any_treat##i.any_ncd $age $ethnic $income $pid


reg m4a2 i.any_treat##i.multimorbidity $age $ethnic $income $pid



*no additional effect of losing job on TE, but large independent effect of losing job on M4A support



