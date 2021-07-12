# Personal and vicarious health insurance loss during COVID-19 increases support for Universal Health Coverage

*Paper Authors: Ashley M. Fox, Yongjin Choi, Heather Lanthorn, and Kevin Croke </br>

* What's Included
    * Part I. Basic Setting
	* Part II. Data Prep
	* Part III. Main Results
      - Figure 1
      - Table 1
      - Table 2
      - Table 3
      - Table 4
      - Table 5
        - Table 5A
        - Table 5B
      - Table 6
        - Table 6A
        - Table 6B
      - Table 7
        - Table 7A
        - Table 7B
	* Part IV. Brief Statements
      - On page 14, "In the six months prior to our survey, 22% of respondents lost health insurance. ..."
      - On page 14, "24.74% of our under-65 sample reported being unemployed..."
      - On Page 16, "We cannot reject the null hypothesis that the two treatment treatments arms are equivalent (p=0.68)..."
    * Part V. Appendix Tables
      - Table A1
      - Table A2
      - Table A3
      - Table A4

## Part I. Basic Setting

### Delimiter, working directory, and description option


```stata
********************************************************************************
********************************************************************************
/*----- Title: Personal and vicarious health insurance loss during COVID-19 increases support for Universal Health Coverage*/
/*----- Paper Authors: Ashley M. Fox, Yongjin Choi, Heather Lanthorn, and Kevin Croke*/
********************************************************************************
********************************************************************************


********************************************************************************
/*----- Part I. Basic Setting -----*/
********************************************************************************

/*----- Essentials -----*/
// Initializing, delimiter, and working directory
#delimit cr
clear all
cd "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\103.Framing Single-Payer\06.Submission\JHPPL\rev1\M4A_Analysis"
set more off

// Output width
set linesize 240
display "{hline}"

// Color scheme for plots
set scheme s2color
grstyle init
grstyle color background white

// Image Repository
global myimg "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\103.Framing Single-Payer\06.Submission\JHPPL\rev1\img"
global esttab_opts nonumbers label interaction(" X ") compress star(* 0.1 ** 0.05 *** 0.01) //addnote("note")
```

    
    delimiter now cr
    
    C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\103.Fra
    > ming Single-Payer\06.Submission\JHPPL\rev1\M4A_Analysis
    
    
    
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    
    
    
    

### (Optional) Packages required


```stata
/*----- (Optional) Installing Packages -----*/
ssc install estout, replace
ssc install coefplot, replace
ssc install tabout, replace
ssc install grstyle, replace
ssc install palettes, replace
```

    checking grstyle consistency and verifying not already installed...
    installing into c:\ado\plus\...
    installation complete.
    

## Part II. Data Prep


```stata
********************************************************************************
/*----- Part II. Data Prep -----*/
********************************************************************************

/*----- Loading Raw Data -----*/
use "M4A_Analysis_Subset_JHPPL", clear

/*----- Variables -----*/
// Outcome: Support for Medicare-for-All
capture recode HR_08 (1 4=1 "Favor") (5 6 7=0 "Oppose or Don't Know"), generate(m4a)
capture label var m4a "Support for M4A"

recode HR_08 (1=1 "Strongly Favor") (4=2 "Somewhat Favor") (5=3 "Somewhat Oppose") (6=4 "Strongly Oppose") (7=7 "Don't know"), generate(support_M4A_likert)

// Alternative Outcomes: Health Programs
gen m4a_positive = HR_12_2==1
label var m4a_positive "Alternative: M4A Positive"
gen m4some_positive = HR_12_5==1
label var m4some_positive "Alternative: M4A for those who want it"
gen uhc_positive = HR_12_1==1
label var uhc_positive "Alternative: Universal Health Coverage (UHC)"
gen nhp_positive = HR_12_3==1
label var nhp_positive "Alternative: National Health Insurance"
gen obamacare_positive = HR_12_4==1
label var obamacare_positive "Alternative: Obamacare"

// Alternative Outcomes: Health Policy Reform
recode HR_11 (5 6=0 "Reversing the ACA/Other") (1=1 "Incremental ACA") (4=2 "M4A"), gen(HR_11_3cat)
capture label var HR_11_3cat "Health Reform Preference"
capture label values HR_11_3cat HR_11_3cat

gen m4a_select = HR_11==4
label var m4a_select "Alternative: M4A"
gen aca_extend = HR_11==1
label var aca_extend "Alternative: Incremental ACA"
gen aca_repeal = HR_11==5
label var aca_repeal "Alternative: Reversing ACA"
gen other_option = HR_11 == 6
label var other_option "Alternative: Other Options"

// Alternative Outcomes: Did COVID-19 Change Your Opinion on M4A?
label var Corona__HR_3 "Did COVID-19 Change Your Opinion on M4A?"
capture label define Corona__HR_3 1 "More Favorable" 4 "Less Favorable" 5 "Has not affected by opinion at all"
capture label values Corona__HR_3 Corona__HR_3

// Separate Treatments
capture gen treatment = cond(COVID_arm_dummy == 1, 2, cond(Airbnb_arm_dummy == 1, 1, 0))
capture label var treatment "Separate Treatment"
capture label define treatment 0 "Control" 1 "Airbnb Arm" 2 "COVID-19 Arm"
capture label values treatment treatment

recode treatment (0 1=0 "Other") (2=1 "COVID-19 Arm"), gen(covid_arm)
recode treatment (0 2=0 "Other") (1=1 "Airbnb Arm"), gen(airbnb_arm)

// Any Treatments
capture gen any_treat = studycondition > 0
capture label var any_treat "Pooled Treatment"

// Party Identity
recode Ideology_1 (1=0 "Democratic") (4=1 "Republican") (5 6=2 "Independent"), generate(pid)

// Insurance Loss
capture gen lost_hi= (HR_13==1 | HR_13==8) if !missing(HR_13)
lab var lost_hi "All HI Loss"

gen lost_hi_job = (HR_13==1) if !missing(HR_13)
lab var lost_hi_job "Job HI Loss"

recode HR_13 (1=0 "Lost HI due to losing job") (8=1 "Lost HI for other reasons") (6 9=2 "Someone close to me lost HI") (4 5=3 "No HI loss") if !missing(HR_13), gen(lost_hi_4cat)
lab var lost_hi_4cat "Lost HI due to job loss or other reason in last 6 months (4 categories)"

// Job Loss
capture gen lost_job = regexm(Stimulus_1, "4")
lab var lost_job "respondent lost job since start of COVID"

// Control Variables
capture recode Demographic_10 (1=1 "Female") (2 4=0 "Male and Other"), generate(female)
lab var female "Gender"

capture gen birthyear= 2011-Demographic_3
capture gen age = 2020-birthyear
recode age (0/24=0 "<25") (25/44=1 "25-44") (45/64=2 "45-64") (65/100=3 "65+"), generate(age_cat)
lab var age_cat "Age Groups"

recode Demographic_12 (1=0 "White") (9=1 "Black") (8=2 "Hispanic") (10 11 12 13 14=3 "Other"), generate(ethnic)
lab var ethnic "Race Ethnicity"

recode Demographic_11 (1 17=0 "Under 20K") (18 19=1 "20K-75K") (20=2 "75K-150K") (21/23=3 "Over 150K"), generate(income)
lab var income "Income"

// Other Variables
recode HR_14 (1=1 "ESI") (4=2 "Marketplace plan, with subsidy") (5=3 "Marketplace plan, without subsidy") (6=4 "Uninsured") (7=5 "Medicaid") (8 11=6 "Medicare (traditional or Advantage Plan") (9=7 "VA") (10=8 "Other"), generate(current_health_insurance)
lab var current_health_insurance "Current Health Insurance"

desc
```

    
    
    
    
    (671 differences between HR_08 and support_M4A_likert)
    
    
    
    
    
    
    
    
    
    
    
    (760 differences between HR_11 and HR_11_3cat)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    (908 differences between treatment and covid_arm)
    
    (456 differences between treatment and airbnb_arm)
    
    
    
    (1211 differences between Ideology_1 and pid)
    
    
    
    (188 missing values generated)
    
    
    (1211 differences between HR_13 and lost_hi_4cat)
    
    
    
    
    
    
    
    
    (1211 differences between age and age_cat)
    
    
    (1211 differences between Demographic_12 and ethnic)
    
    
    (1211 differences between Demographic_11 and income)
    
    
    (784 differences between HR_14 and current_health_insurance)
    
    
    
    Contains data from M4A_Analysis_Subset_JHPPL.dta
      obs:         1,399                          
     vars:            47                          1 Mar 2021 18:02
     size:       179,072                          
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                  storage   display    value
    variable name   type    format     label      variable label
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    HR_08           byte    %10.0g                HR_08
    HR_11           byte    %10.0g                HR_11
    HR_12_1         byte    %10.0g                HR_12_1
    HR_12_2         byte    %10.0g                HR_12_2
    HR_12_3         byte    %10.0g                HR_12_3
    HR_12_4         byte    %10.0g                HR_12_4
    HR_12_5         byte    %10.0g                HR_12_5
    HR_13           byte    %10.0g                HR_13
    HR_14           byte    %10.0g                HR_14
    Corona__HR_3    byte    %34.0g     Corona__HR_3
                                                  Did COVID-19 Change Your Opinion on M4A?
    Stimulus_1      str16   %16s                  Stimulus_1
    Ideology_1      byte    %10.0g                Ideology_1
    Demographic_3   byte    %10.0g                Demographic_3
    Demographic_10  byte    %10.0g                Demographic_10
    Demographic_11  byte    %10.0g                Demographic_11
    Demographic_12  byte    %10.0g                Demographic_12
    studycondition  long    %9.0g      studycondition
                                                  RECODE of study_condition (block)
    COVID_arm_dummy long    %9.0g      COVID_arm_dummy
                                                  RECODE of study_arms (RECODE of study_condition (block))
    Airbnb_arm_du~y long    %10.0g     Airbnb_arm_dummy
                                                  RECODE of study_arms (RECODE of study_condition (block))
    m4a             byte    %20.0g     m4a        Support for M4A
    support_M4A_l~t byte    %15.0g     support_M4A_likert
                                                  RECODE of HR_08 (HR_08)
    m4a_positive    float   %9.0g                 Alternative: M4A Positive
    m4some_positive float   %9.0g                 Alternative: M4A for those who want it
    uhc_positive    float   %9.0g                 Alternative: Universal Health Coverage (UHC)
    nhp_positive    float   %9.0g                 Alternative: National Health Insurance
    obamacare_pos~e float   %9.0g                 Alternative: Obamacare
    HR_11_3cat      byte    %23.0g     HR_11_3cat
                                                  Health Reform Preference
    m4a_select      float   %9.0g                 Alternative: M4A
    aca_extend      float   %9.0g                 Alternative: Incremental ACA
    aca_repeal      float   %9.0g                 Alternative: Reversing ACA
    other_option    float   %9.0g                 Alternative: Other Options
    treatment       float   %12.0g     treatment
                                                  Separate Treatment
    covid_arm       float   %12.0g     covid_arm
                                                  RECODE of treatment (Separate Treatment)
    airbnb_arm      float   %10.0g     airbnb_arm
                                                  RECODE of treatment (Separate Treatment)
    any_treat       float   %9.0g                 Pooled Treatment
    pid             byte    %11.0g     pid        RECODE of Ideology_1 (Ideology_1)
    lost_hi         float   %9.0g                 All HI Loss
    lost_hi_job     float   %9.0g                 Job HI Loss
    lost_hi_4cat    byte    %27.0g     lost_hi_4cat
                                                  Lost HI due to job loss or other reason in last 6 months (4 categories)
    lost_job        float   %9.0g                 respondent lost job since start of COVID
    female          byte    %14.0g     female     Gender
    birthyear       float   %9.0g                 
    age             float   %9.0g                 
    age_cat         float   %9.0g      age_cat    Age Groups
    ethnic          byte    %9.0g      ethnic     Race Ethnicity
    income          byte    %9.0g      income     Income
    current_healt~e byte    %39.0g     current_health_insurance
                                                  Current Health Insurance
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Sorted by: studycondition
         Note: Dataset has changed since last saved.
    


```stata
tab lost_hi_job lost_job, row col
```

    
    +-------------------+
    | Key               |
    |-------------------|
    |     frequency     |
    |  row percentage   |
    | column percentage |
    +-------------------+
    
               |  respondent lost job
        Job HI | since start of COVID
          Loss |         0          1 |     Total
    -----------+----------------------+----------
             0 |       968         88 |     1,056 
               |     91.67       8.33 |    100.00 
               |     90.47      62.41 |     87.20 
    -----------+----------------------+----------
             1 |       102         53 |       155 
               |     65.81      34.19 |    100.00 
               |      9.53      37.59 |     12.80 
    -----------+----------------------+----------
         Total |     1,070        141 |     1,211 
               |     88.36      11.64 |    100.00 
               |    100.00     100.00 |    100.00 
    


```stata

```

## Part III. Main Results

### Table 1. Main Outcome Variable – Support for Medicare for All


```stata
********************************************************************************
/*----- Part III. Analysis -----*/
********************************************************************************

/*----- Table 1. Main Outcome Variable – Support for Medicare for All -----*/
tab support_M4A_likert
tab m4a
```

    
    
    RECODE of HR_08 |
            (HR_08) |      Freq.     Percent        Cum.
    ----------------+-----------------------------------
     Strongly Favor |        442       36.50       36.50
     Somewhat Favor |        372       30.72       67.22
    Somewhat Oppose |        164       13.54       80.76
    Strongly Oppose |        135       11.15       91.91
         Don't know |         98        8.09      100.00
    ----------------+-----------------------------------
              Total |      1,211      100.00
    
    
         Support for M4A |      Freq.     Percent        Cum.
    ---------------------+-----------------------------------
    Oppose or Don't Know |        397       32.78       32.78
                   Favor |        814       67.22      100.00
    ---------------------+-----------------------------------
                   Total |      1,211      100.00
    

### Table 2. Balance across Study Arms


```stata
/*----- Table 2. Balance across Study Arms -----*/
tab age_cat treatment, col chi2
tab female treatment, col chi2
tab ethnic treatment, col chi2
tab income treatment, col chi2
tab pid treatment, col chi2
```

    
    
    +-------------------+
    | Key               |
    |-------------------|
    |     frequency     |
    | column percentage |
    +-------------------+
    
               |        Separate Treatment
    Age Groups |   Control  Airbnb Ar  COVID-19  |     Total
    -----------+---------------------------------+----------
           <25 |        90         47         41 |       178 
               |     20.55      12.02      10.73 |     14.70 
    -----------+---------------------------------+----------
         25-44 |       228        217        203 |       648 
               |     52.05      55.50      53.14 |     53.51 
    -----------+---------------------------------+----------
         45-64 |        73         73         95 |       241 
               |     16.67      18.67      24.87 |     19.90 
    -----------+---------------------------------+----------
           65+ |        47         54         43 |       144 
               |     10.73      13.81      11.26 |     11.89 
    -----------+---------------------------------+----------
         Total |       438        391        382 |     1,211 
               |    100.00     100.00     100.00 |    100.00 
    
              Pearson chi2(6) =  25.8376   Pr = 0.000
    
    
    +-------------------+
    | Key               |
    |-------------------|
    |     frequency     |
    | column percentage |
    +-------------------+
    
                   |        Separate Treatment
            Gender |   Control  Airbnb Ar  COVID-19  |     Total
    ---------------+---------------------------------+----------
    Male and Other |       199        198        184 |       581 
                   |     45.43      50.64      48.17 |     47.98 
    ---------------+---------------------------------+----------
            Female |       239        193        198 |       630 
                   |     54.57      49.36      51.83 |     52.02 
    ---------------+---------------------------------+----------
             Total |       438        391        382 |     1,211 
                   |    100.00     100.00     100.00 |    100.00 
    
              Pearson chi2(2) =   2.2510   Pr = 0.324
    
    
    +-------------------+
    | Key               |
    |-------------------|
    |     frequency     |
    | column percentage |
    +-------------------+
    
          Race |        Separate Treatment
     Ethnicity |   Control  Airbnb Ar  COVID-19  |     Total
    -----------+---------------------------------+----------
         White |       306        282        291 |       879 
               |     69.86      72.12      76.18 |     72.58 
    -----------+---------------------------------+----------
         Black |        64         52         42 |       158 
               |     14.61      13.30      10.99 |     13.05 
    -----------+---------------------------------+----------
      Hispanic |        30         25         20 |        75 
               |      6.85       6.39       5.24 |      6.19 
    -----------+---------------------------------+----------
         Other |        38         32         29 |        99 
               |      8.68       8.18       7.59 |      8.18 
    -----------+---------------------------------+----------
         Total |       438        391        382 |     1,211 
               |    100.00     100.00     100.00 |    100.00 
    
              Pearson chi2(6) =   4.4012   Pr = 0.623
    
    
    +-------------------+
    | Key               |
    |-------------------|
    |     frequency     |
    | column percentage |
    +-------------------+
    
               |        Separate Treatment
        Income |   Control  Airbnb Ar  COVID-19  |     Total
    -----------+---------------------------------+----------
     Under 20K |       109         82         67 |       258 
               |     24.89      20.97      17.54 |     21.30 
    -----------+---------------------------------+----------
       20K-75K |       160        148        147 |       455 
               |     36.53      37.85      38.48 |     37.57 
    -----------+---------------------------------+----------
      75K-150K |        82         75         73 |       230 
               |     18.72      19.18      19.11 |     18.99 
    -----------+---------------------------------+----------
     Over 150K |        87         86         95 |       268 
               |     19.86      21.99      24.87 |     22.13 
    -----------+---------------------------------+----------
         Total |       438        391        382 |     1,211 
               |    100.00     100.00     100.00 |    100.00 
    
              Pearson chi2(6) =   7.7606   Pr = 0.256
    
    
    +-------------------+
    | Key               |
    |-------------------|
    |     frequency     |
    | column percentage |
    +-------------------+
    
      RECODE of |
     Ideology_1 |
    (Ideology_1 |        Separate Treatment
              ) |   Control  Airbnb Ar  COVID-19  |     Total
    ------------+---------------------------------+----------
     Democratic |       185        165        157 |       507 
                |     42.24      42.20      41.10 |     41.87 
    ------------+---------------------------------+----------
     Republican |       148        142        143 |       433 
                |     33.79      36.32      37.43 |     35.76 
    ------------+---------------------------------+----------
    Independent |       105         84         82 |       271 
                |     23.97      21.48      21.47 |     22.38 
    ------------+---------------------------------+----------
          Total |       438        391        382 |     1,211 
                |    100.00     100.00     100.00 |    100.00 
    
              Pearson chi2(4) =   1.6669   Pr = 0.797
    

### Figure 1. Support for Medicare for all by Treatment Arm

![](img\Figure1_edited.png)


```stata
/*----- Figure 1. Support for Medicare for all by Treatment Arm -----*/
eststo clear
local title0 "Support for Medicare for all by Treatment Arm"

eststo m1: qui reg m4a any_treat
eststo mfx1: qui margins, at(any_treat=(0/1)) vsquish post
qui coefplot (mfx1, keep(1._at))/*
        */(mfx1, keep(2._at))/*
        */, title("(a) Pooled Treatment") xtitle("") ytitle("")/*
        */vertical legend(rows(1)) recast(bar) barwidth(0.5) fcolor(*.5) /*
        */citop ciopts(recast(rcap)) legend(off) format(%9.2f)  /*
        */coeflabels(1._at = "No Treatments" 2._at = "Pooled Treatment", notick labgap(2)) plotregion(margin(b=0)) baselevels /*
        */groups(any_treat = `""{bf:Any Arms}" "{bf:Model}""' *.treatment = `""{bf:Separate Arms}" "{bf:Model}""' any_treat2 lost_hi = `""{bf:Any Arms}" "{bf: w/ Insurance Loss}" "{bf:Model}""')/*
        */addplot(scatter @b @at, ms(i) mlabel(@b) mlabpos(2) mlabcolor(black)) ylab(, ang(hor))/*
        */note(" " " ") /*
        */name(g1, replace)

eststo m2: qui reg m4a i.treatment 
eststo mfx2: qui margins, at(treatment=(0/2)) vsquish post
qui coefplot (mfx2, keep(1._at))/*
        */(mfx2, keep(2._at))/*
        */(mfx2, keep(3._at))/*
        */, title("(b) Separate Treatment") xtitle("") ytitle("")/*
        */vertical legend(rows(1)) recast(bar) barwidth(0.5) fcolor(*.5) /*
        */citop ciopts(recast(rcap)) legend(off) format(%9.2f)  /*
        */coeflabels(1._at = "No Treatments" 2._at = "Airbnb Arm" 3._at = "COVID-19 Arm", notick labgap(2)) plotregion(margin(b=0)) baselevels /*
        */groups(any_treat = `""{bf:Any Arms}" "{bf:Model}""' *.treatment = `""{bf:Separate Arms}" "{bf:Model}""' any_treat2 lost_hi = `""{bf:Any Arms}" "{bf: w/ Insurance Loss}" "{bf:Model}""')/*
        */addplot(scatter @b @at, ms(i) mlabel(@b) mlabpos(2) mlabcolor(black)) ylab(, ang(hor))/*
        */note(" " " ") /*
        */name(g2, replace)

//graph combine g1 g2, /*
    */title("")/*
    */b1("")/*
    */l1("Predicted Probability (Support for M4A)")/*
    */ycommon xsize(11) ysize(5)

//graph save "$myimg\Figure1.gph", replace
//graph export "$myimg\Figure1.png", replace

esttab m1 mfx1 m2 mfx2/*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(4) ci(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Appendix) /*
    */nonumbers /*
    */mgroups("(a)" "(b)", pattern(1 0 1 0)) /*
    */mtitles("Coef" "Margins" "Coef" "Margins") /*
    */addnote("Controls included but not shown (age, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(20) modelwidth(12) compress /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    
    
    
    
    
    Appendix
    ------------------------------------------------------------------------------------
                                  (a)                             (b)                   
                                 Coef         Margins            Coef         Margins   
    ------------------------------------------------------------------------------------
    Pooled Treatment           0.0551**                                                 
                         [0.000,0.110]                                                   
    
    1._at                                      0.6370***                       0.6370***
                                         [0.593,0.681]                    [0.593,0.681]   
    
    2._at                                      0.6921***                       0.6854***
                                         [0.659,0.725]                    [0.639,0.732]   
    
    Airbnb Arm                                                 0.0484                   
                                                         [-0.016,0.112]                   
    
    COVID-19 Arm                                               0.0620*                  
                                                         [-0.002,0.126]                   
    
    3._at                                                                      0.6990***
                                                                         [0.652,0.746]   
    
    Constant                   0.6370***                       0.6370***                
                         [0.593,0.681]                    [0.593,0.681]                   
    ------------------------------------------------------------------------------------
    Observations                 1211            1211            1211            1211   
    R-squared                   0.003                           0.003                   
    Adjusted R-squared          0.002                           0.002                   
    F                          3.8611                          2.0095                   
    ------------------------------------------------------------------------------------
    95% confidence intervals in brackets
    Controls included but not shown (age, gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    

### Table 3. Experimental Priming Results


```stata
/*----- Table 3. Experimental Priming Results -----*/
eststo clear
eststo lm1: qui reg m4a i.treatment
eststo lm2: qui reg m4a i.treatment i.pid female i.age_cat i.ethnic i.income
eststo lm3: qui reg m4a any_treat
eststo lm4: qui reg m4a any_treat i.pid female i.age_cat i.ethnic i.income

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) p(3) r2(3) ar2(3) scalar(F) /*
    */order(2.treatment 1.treatment any_treat) /*
    */title(Table 3. Experimental Priming Results) /*
    */nonumbers /*
    */mgroups("Separate Treatment" "Pooled Treatment", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table3.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(2.treatment 1.treatment any_treat) /*
    */title(Table 3. Experimental Priming Results) /*
    */nonumbers /*
    */mgroups("Separate Treatment" "Pooled Treatment", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    
    
    Table 3. Experimental Priming Results
    ---------------------------------------------------------------------------------------------------------------------------
                    Separate ~t                                           Pooled Tr~t                                          
                    No controls                w/ controls                No controls                w/ controls               
    ---------------------------------------------------------------------------------------------------------------------------
    COVID-19 Arm          0.062*       (0.059)       0.057*       (0.071)                                                      
    Airbnb Arm            0.048        (0.138)       0.046        (0.137)                                                      
    Pooled Treatm~t                                                             0.055**      (0.050)       0.051*       (0.056)
    Republican                                      -0.159***     (0.000)                                 -0.158***     (0.000)
    Independent                                     -0.159***     (0.000)                                 -0.159***     (0.000)
    Gender                                          -0.105***     (0.000)                                 -0.105***     (0.000)
    25-44                                            0.045        (0.254)                                  0.045        (0.255)
    45-64                                           -0.032        (0.480)                                 -0.032        (0.487)
    65+                                             -0.224***     (0.000)                                 -0.224***     (0.000)
    Black                                           -0.066        (0.115)                                 -0.066        (0.113)
    Hispanic                                        -0.049        (0.380)                                 -0.049        (0.376)
    Other                                           -0.040        (0.406)                                 -0.040        (0.403)
    20K-75K                                         -0.049        (0.168)                                 -0.049        (0.171)
    75K-150K                                         0.024        (0.578)                                  0.024        (0.573)
    Over 150K                                        0.093**      (0.028)                                  0.094**      (0.027)
    Constant              0.637***     (0.000)       0.803***     (0.000)       0.637***     (0.000)       0.803***     (0.000)
    ---------------------------------------------------------------------------------------------------------------------------
    Observations           1211                       1211                       1211                       1211               
    R-squared             0.003                      0.115                      0.003                      0.115               
    Adjusted R-sq~d       0.002                      0.104                      0.002                      0.105               
    F                     2.010                     11.081                      3.861                     11.934               
    ---------------------------------------------------------------------------------------------------------------------------
    p-values in parentheses
    Controls included but not shown (gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table3.rtf)
    

### Table 4. Health insurance Loss and Medicare for All Favorability 


```stata
/*----- Table 4. Health insurance Loss and Medicare for All Favorability  -----*/
eststo clear
eststo lm1: qui reg m4a lost_hi any_treat i.pid female i.age_cat i.ethnic i.income
eststo lm2: qui reg m4a lost_hi any_treat i.pid female i.age_cat i.ethnic i.income if current_health_insurance != 6
eststo lm3: qui reg m4a lost_hi_job any_treat i.pid female i.age_cat i.ethnic i.income
eststo lm4: qui reg m4a lost_hi_job any_treat i.pid female i.age_cat i.ethnic i.income if current_health_insurance != 6

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(lost_hi lost_hi_job) /*
    */title(Table 4. Health Insurance Loss and Medicare for All Favorability ) /*
    */nonumbers /*
    */mgroups("Lost HI" "Lost HI Due to Job", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table4.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(lost_hi lost_hi_job) /*
    */title(Table 4. Health Insurance Loss and Medicare for All Favorability ) /*
    */nonumbers /*
    */mgroups("Lost HI" "Lost HI Due to Job", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    
    
    Table 4. Health Insurance Loss and Medicare for All Favorability
    ---------------------------------------------------------------------------------------------------------------------------
                        Lost HI                                           Lost HI D~b                                          
                    No controls                w/ controls                No controls                w/ controls               
    ---------------------------------------------------------------------------------------------------------------------------
    All HI Loss           0.099***     (0.032)       0.104***     (0.033)                                                      
    Job HI Loss                                                                 0.151***     (0.039)       0.150***     (0.039)
    Pooled Treatm~t       0.055**      (0.027)       0.074**      (0.029)       0.059**      (0.027)       0.078***     (0.029)
    Republican           -0.162***     (0.030)      -0.141***     (0.032)      -0.160***     (0.030)      -0.139***     (0.032)
    Independent          -0.150***     (0.034)      -0.169***     (0.037)      -0.148***     (0.034)      -0.169***     (0.037)
    Gender               -0.095***     (0.028)      -0.093***     (0.030)      -0.097***     (0.027)      -0.095***     (0.029)
    25-44                 0.056        (0.040)       0.061        (0.040)       0.052        (0.040)       0.054        (0.040)
    45-64                -0.008        (0.046)       0.002        (0.047)      -0.015        (0.046)      -0.007        (0.047)
    65+                  -0.192***     (0.054)      -0.083        (0.084)      -0.200***     (0.053)      -0.095        (0.084)
    Black                -0.072*       (0.041)      -0.071*       (0.043)      -0.075*       (0.041)      -0.075*       (0.043)
    Hispanic             -0.044        (0.055)      -0.044        (0.056)      -0.043        (0.055)      -0.044        (0.056)
    Other                -0.038        (0.048)       0.006        (0.051)      -0.045        (0.048)      -0.001        (0.051)
    20K-75K              -0.047        (0.035)      -0.063*       (0.039)      -0.048        (0.035)      -0.065*       (0.038)
    75K-150K              0.026        (0.042)       0.046        (0.045)       0.022        (0.042)       0.041        (0.045)
    Over 150K             0.096**      (0.042)       0.084*       (0.045)       0.092**      (0.042)       0.079*       (0.045)
    Constant              0.757***     (0.056)       0.743***     (0.058)       0.764***     (0.055)       0.754***     (0.057)
    ---------------------------------------------------------------------------------------------------------------------------
    Observations           1211                       1011                       1211                       1011               
    R-squared             0.122                      0.105                      0.126                      0.109               
    Adjusted R-sq~d       0.111                      0.092                      0.115                      0.096               
    F                    11.829                      8.303                     12.264                      8.662               
    ---------------------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table4.rtf)
    

### Table 5. Experimental and Personal Insurance Loss by Partisanship

#### Panel 5A. Experimental priming interacted with party Identity


```stata
/*----- Table 5. Experimental and Personal Insurance Loss by Partisanship  -----*/
// Panel 5A: Experimental priming interacted with party Identity
eststo clear
eststo lm1: qui reg m4a i.treatment##ib2.pid
eststo lm2: qui reg m4a i.treatment##ib2.pid female i.age_cat i.ethnic i.income
eststo lm3: qui reg m4a any_treat##ib2.pid
eststo lm4: qui reg m4a any_treat##ib2.pid female i.age_cat i.ethnic i.income

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(2.treatment#0.pid 2.treatment#1.pid 2.treatment 1.treatment#0.pid 1.treatment#1.pid 1.treatment 1.any_treat#0.pid 1.any_treat#1.pid 1.any_treat) /*
    */title(Table 5. Panel A: Experimental priming interacted with party Identity) /*
    */nonumbers /*
    */mgroups("Separate Treatment" "Pooled Treatment", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(20) modelwidth(9) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table5_A.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(2.treatment#0.pid 2.treatment#1.pid 2.treatment 1.treatment#0.pid 1.treatment#1.pid 1.treatment 1.any_treat#0.pid 1.any_treat#1.pid 1.any_treat) /*
    */title(Table 5. Panel A: Experimental priming interacted with party Identity) /*
    */nonumbers /*
    */mgroups("Separate Treatment" "Pooled Treatment", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (age, gender, race, income)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    
    
    Table 5. Panel A: Experimental priming interacted with party Identity
    ----------------------------------------------------------------------------------------------------------------
                         Separat~t                                     Pooled ~t                                    
                         No cont~s              w/ cont~s              No cont~s              w/ cont~s             
    ----------------------------------------------------------------------------------------------------------------
    COVID-19 Arm X Dem~c     0.068      (0.085)     0.071      (0.082)                                              
    COVID-19 Arm X Rep~n     0.035      (0.087)     0.005      (0.084)                                              
    COVID-19 Arm             0.021      (0.068)     0.025      (0.066)                                              
    Airbnb Arm X Democ~c     0.007      (0.084)     0.014      (0.081)                                              
    Airbnb Arm X Repub~n    -0.029      (0.087)    -0.040      (0.084)                                              
    Airbnb Arm               0.055      (0.068)     0.055      (0.065)                                              
    Pooled Treatment=1~c                                                   0.037      (0.072)     0.042      (0.069)
    Pooled Treatment=1~n                                                   0.003      (0.074)    -0.018      (0.072)
    Pooled Treatment=1                                                     0.038      (0.058)     0.040      (0.056)
    Democratic               0.161***   (0.057)     0.132**    (0.055)     0.161***   (0.057)     0.132**    (0.055)
    Republican               0.049      (0.059)     0.012      (0.057)     0.049      (0.059)     0.012      (0.057)
    Gender                                         -0.106***   (0.028)                           -0.106***   (0.028)
    25-44                                           0.046      (0.040)                            0.046      (0.040)
    45-64                                          -0.034      (0.046)                           -0.033      (0.046)
    65+                                            -0.224***   (0.053)                           -0.223***   (0.053)
    Black                                          -0.065      (0.042)                           -0.066      (0.042)
    Hispanic                                       -0.047      (0.055)                           -0.048      (0.055)
    Other                                          -0.043      (0.048)                           -0.043      (0.048)
    20K-75K                                        -0.049      (0.036)                           -0.049      (0.035)
    75K-150K                                        0.025      (0.043)                            0.025      (0.043)
    Over 150K                                       0.093**    (0.043)                            0.094**    (0.042)
    Constant                 0.552***   (0.045)     0.652***   (0.062)     0.552***   (0.045)     0.651***   (0.062)
    ----------------------------------------------------------------------------------------------------------------
    Observations              1211                   1211                   1211                   1211             
    R-squared                0.032                  0.116                  0.031                  0.115             
    Adjusted R-squared       0.025                  0.103                  0.027                  0.104             
    F                        4.936                  8.682                  7.751                 10.401             
    ----------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table5_A.rtf)
    

#### Panel 5B. Effect of Health Insurance Loss Interacted with Party Identity


```stata
// Panel 5B: Effect of Health Insurance Loss Interacted with Party Identity
eststo clear
eststo lm1: qui reg m4a lost_hi##ib2.pid
eststo lm2: qui reg m4a lost_hi##ib2.pid female i.age_cat i.ethnic i.income
eststo lm3: qui reg m4a lost_hi_job##ib2.pid
eststo lm4: qui reg m4a lost_hi_job##ib2.pid female i.age_cat i.ethnic i.income

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(1.lost_hi#0.pid 1.lost_hi#1.pid 1.lost_hi 1.lost_hi_job#0.pid 1.lost_hi_job#1.pid 1.lost_hi_job) /*
    */title(Table 5. Panel B: Effect of Insurance Loss Interacted with Party Identity) /*
    */nonumbers /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(20) modelwidth(9) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table5_B.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(1.lost_hi#0.pid 1.lost_hi#1.pid 1.lost_hi 1.lost_hi_job#0.pid 1.lost_hi_job#1.pid 1.lost_hi_job) /*
    */title(Table 5. Panel B: Effect of Insurance Loss Interacted with Party Identity) /*
    */nonumbers /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (age, gender, race, income)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(25) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    
    
    Table 5. Panel B: Effect of Insurance Loss Interacted with Party Identity
    ----------------------------------------------------------------------------------------------------------------
                         No cont~s              w/ cont~s              No cont~s              w/ cont~s             
    ----------------------------------------------------------------------------------------------------------------
    All HI Loss=1 X De~c     0.024      (0.094)     0.031      (0.092)                                              
    All HI Loss=1 X Re~n     0.210**    (0.095)     0.203**    (0.092)                                              
    All HI Loss=1            0.053      (0.081)     0.000      (0.079)                                              
    Job HI Loss=1 X De~c                                                   0.051      (0.126)     0.064      (0.122)
    Job HI Loss=1 X Re~n                                                   0.177      (0.128)     0.170      (0.123)
    Job HI Loss=1                                                          0.097      (0.112)     0.044      (0.108)
    Democratic               0.175***   (0.038)     0.152***   (0.037)     0.171***   (0.036)     0.148***   (0.036)
    Republican              -0.009      (0.039)    -0.052      (0.039)     0.018      (0.037)    -0.027      (0.037)
    Gender                                         -0.098***   (0.028)                           -0.100***   (0.027)
    25-44                                           0.061      (0.040)                            0.059      (0.039)
    45-64                                           0.002      (0.046)                           -0.005      (0.046)
    65+                                            -0.181***   (0.054)                           -0.190***   (0.053)
    Black                                          -0.068      (0.041)                           -0.073*     (0.041)
    Hispanic                                       -0.047      (0.055)                           -0.043      (0.055)
    Other                                          -0.036      (0.048)                           -0.042      (0.048)
    20K-75K                                        -0.042      (0.035)                           -0.044      (0.035)
    75K-150K                                        0.034      (0.042)                            0.025      (0.042)
    Over 150K                                       0.102**    (0.042)                            0.095**    (0.042)
    Constant                 0.568***   (0.030)     0.646***   (0.054)     0.569***   (0.029)     0.651***   (0.053)
    ----------------------------------------------------------------------------------------------------------------
    Observations              1211                   1211                   1211                   1211             
    R-squared                0.052                  0.125                  0.049                  0.124             
    Adjusted R-squared       0.048                  0.114                  0.045                  0.113             
    F                       13.165                 11.337                 12.426                 11.267             
    ----------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table5_B.rtf)
    

### Table 6. Alternative measures of public opinion about health programs

#### Panel 6A. Effect of experimental priming on alternative outcomes


```stata
/*----- Table 6. Alternative measures of public opinion about health programs  -----*/
// Panel 6A. Effect of experimental priming on alternative outcomes
eststo clear
local num = 1
foreach y in m4a_positive m4some_positive uhc_positive nhp_positive obamacare_positive    {
eststo lm`num': qui reg `y' any_treat i.pid female i.age_cat i.ethnic i.income
local num = `num' + 1
}

esttab lm1 lm2 lm3 lm4 lm5 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel A: Effect of experimental priming on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "M4A Some" "UHC" "NHI" "Obamacare") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(7) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 lm5 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel A: Effect of experimental priming on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "M4A Some" "UHC" "NHI" "Obamacare") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    Table 6. Panel A: Effect of experimental priming on alternative outcomes
    --------------------------------------------------------------------------------------------------------------
                        M4A            M4A S~e                UHC                NHI            Obama~e           
    --------------------------------------------------------------------------------------------------------------
    Pooled Treatm~t   0.071**  (0.028)   0.045    (0.028)   0.034    (0.027)   0.023    (0.028)   0.019    (0.028)
    Republican       -0.237*** (0.031)  -0.217*** (0.031)  -0.244*** (0.030)  -0.128*** (0.032)  -0.348*** (0.031)
    Independent      -0.164*** (0.036)  -0.191*** (0.036)  -0.197*** (0.035)  -0.163*** (0.036)  -0.280*** (0.036)
    Gender           -0.081*** (0.029)  -0.065**  (0.029)  -0.103*** (0.028)  -0.136*** (0.029)  -0.075*** (0.029)
    25-44             0.099**  (0.042)   0.054    (0.042)   0.091**  (0.040)   0.051    (0.042)   0.018    (0.041)
    45-64             0.002    (0.048)   0.029    (0.048)  -0.011    (0.046)  -0.012    (0.049)  -0.081*   (0.048)
    65+              -0.089    (0.056)  -0.102*   (0.056)  -0.108**  (0.054)  -0.132**  (0.056)  -0.061    (0.055)
    Black            -0.067    (0.043)  -0.120*** (0.044)  -0.053    (0.042)  -0.046    (0.044)  -0.026    (0.043)
    Hispanic         -0.084    (0.058)  -0.116**  (0.058)  -0.110**  (0.056)  -0.048    (0.058)  -0.019    (0.057)
    Other             0.040    (0.051)  -0.032    (0.051)  -0.045    (0.049)  -0.076    (0.051)  -0.078    (0.050)
    20K-75K           0.000    (0.037)   0.041    (0.037)   0.065*   (0.036)   0.026    (0.038)   0.012    (0.037)
    75K-150K          0.092**  (0.045)   0.114**  (0.045)   0.140*** (0.043)   0.115**  (0.045)   0.091**  (0.044)
    Over 150K         0.177*** (0.045)   0.131*** (0.045)   0.244*** (0.043)   0.197*** (0.045)   0.217*** (0.044)
    Constant          0.611*** (0.057)   0.679*** (0.057)   0.667*** (0.055)   0.629*** (0.057)   0.666*** (0.056)
    --------------------------------------------------------------------------------------------------------------
    Observations       1211               1211               1211               1211               1211           
    R-squared         0.120              0.090              0.151              0.113              0.160           
    Adjusted R-sq~d   0.110              0.080              0.141              0.103              0.151           
    F                12.522              9.079             16.328             11.740             17.544           
    --------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (pooled treatment, gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf)
    

#### Panel 6B. Effect of insurance loss on alternative outcomes


```stata
// Panel 6B. Effect of insurance loss on alternative outcomes
eststo clear
local num = 1
foreach y in m4a_positive m4some_positive uhc_positive nhp_positive obamacare_positive    {
eststo lm`num': qui reg `y' lost_hi i.pid female i.age_cat i.ethnic i.income
local num = `num' + 1
}

esttab lm1 lm2 lm3 lm4 lm5 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel B: Effect of insurance loss on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "M4A Some" "UHC" "NHI" "Obamacare") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(7) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 lm5 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel B: Effect of insurance loss on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "M4A Some" "UHC" "NHI" "Obamacare") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    Table 6. Panel B: Effect of insurance loss on alternative outcomes
    --------------------------------------------------------------------------------------------------------------
                        M4A            M4A S~e                UHC                NHI            Obama~e           
    --------------------------------------------------------------------------------------------------------------
    All HI Loss      -0.083**  (0.034)  -0.031    (0.034)   0.007    (0.033)   0.007    (0.034)   0.072**  (0.034)
    Republican       -0.233*** (0.031)  -0.216*** (0.031)  -0.243*** (0.030)  -0.128*** (0.032)  -0.351*** (0.031)
    Independent      -0.172*** (0.036)  -0.194*** (0.036)  -0.197*** (0.035)  -0.163*** (0.037)  -0.274*** (0.036)
    Gender           -0.091*** (0.029)  -0.069**  (0.029)  -0.103*** (0.028)  -0.136*** (0.029)  -0.069**  (0.029)
    25-44             0.099**  (0.042)   0.056    (0.042)   0.096**  (0.040)   0.055    (0.042)   0.028    (0.041)
    45-64            -0.005    (0.049)   0.031    (0.049)  -0.003    (0.047)  -0.006    (0.049)  -0.060    (0.048)
    65+              -0.104*   (0.057)  -0.105*   (0.057)  -0.100*   (0.055)  -0.126**  (0.057)  -0.034    (0.056)
    Black            -0.062    (0.044)  -0.118*** (0.044)  -0.053    (0.042)  -0.046    (0.044)  -0.030    (0.043)
    Hispanic         -0.089    (0.058)  -0.118**  (0.058)  -0.110**  (0.056)  -0.048    (0.059)  -0.016    (0.057)
    Other             0.038    (0.051)  -0.033    (0.051)  -0.045    (0.049)  -0.076    (0.051)  -0.077    (0.050)
    20K-75K           0.002    (0.037)   0.042    (0.037)   0.067*   (0.036)   0.027    (0.038)   0.014    (0.037)
    75K-150K          0.093**  (0.045)   0.115**  (0.045)   0.142*** (0.043)   0.116**  (0.045)   0.094**  (0.044)
    Over 150K         0.180*** (0.044)   0.133*** (0.045)   0.246*** (0.043)   0.198*** (0.045)   0.220*** (0.044)
    Constant          0.681*** (0.057)   0.714*** (0.057)   0.679*** (0.055)   0.637*** (0.057)   0.643*** (0.056)
    --------------------------------------------------------------------------------------------------------------
    Observations       1211               1211               1211               1211               1211           
    R-squared         0.119              0.088              0.150              0.113              0.163           
    Adjusted R-sq~d   0.110              0.079              0.140              0.103              0.154           
    F                12.486              8.933             16.192             11.688             17.927           
    --------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (pooled treatment, gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf)
    


```stata
// Panel 6B. Effect of insurance loss on alternative outcomes
eststo clear
local num = 1
foreach y in m4a_positive m4some_positive uhc_positive nhp_positive obamacare_positive    {
eststo lm`num': qui reg `y' lost_hi i.pid female i.age_cat i.ethnic i.income if pid != 
local num = `num' + 1
}

esttab lm1 lm2 lm3 lm4 lm5 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel B: Effect of insurance loss on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "M4A Some" "UHC" "NHI" "Obamacare") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(7) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 lm5 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel B: Effect of insurance loss on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "M4A Some" "UHC" "NHI" "Obamacare") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    Table 6. Panel B: Effect of insurance loss on alternative outcomes
    --------------------------------------------------------------------------------------------------------------
                        M4A            M4A S~e                UHC                NHI            Obama~e           
    --------------------------------------------------------------------------------------------------------------
    All HI Loss      -0.064    (0.044)   0.003    (0.044)   0.022    (0.042)   0.002    (0.045)   0.060    (0.044)
    Independent      -0.182*** (0.037)  -0.211*** (0.037)  -0.213*** (0.036)  -0.181*** (0.038)  -0.293*** (0.037)
    Gender           -0.066*   (0.036)  -0.012    (0.036)  -0.059*   (0.035)  -0.107*** (0.037)  -0.034    (0.036)
    25-44             0.067    (0.049)   0.015    (0.048)   0.056    (0.047)   0.014    (0.050)  -0.016    (0.049)
    45-64             0.045    (0.058)   0.059    (0.057)   0.034    (0.055)   0.025    (0.059)  -0.033    (0.058)
    65+              -0.004    (0.070)  -0.033    (0.069)  -0.027    (0.067)  -0.078    (0.071)   0.066    (0.070)
    Black            -0.085*   (0.049)  -0.115**  (0.049)  -0.078*   (0.047)  -0.086*   (0.050)  -0.024    (0.049)
    Hispanic         -0.056    (0.064)  -0.149**  (0.063)  -0.107*   (0.062)  -0.068    (0.066)  -0.024    (0.064)
    Other             0.045    (0.062)   0.000    (0.062)  -0.066    (0.060)  -0.103    (0.064)  -0.075    (0.063)
    20K-75K          -0.014    (0.044)   0.039    (0.044)   0.101**  (0.042)   0.062    (0.045)   0.037    (0.044)
    75K-150K          0.070    (0.055)   0.097*   (0.055)   0.130**  (0.053)   0.081    (0.056)   0.089    (0.055)
    Over 150K         0.135**  (0.055)   0.072    (0.055)   0.184*** (0.053)   0.156*** (0.057)   0.133**  (0.056)
    Constant          0.681*** (0.067)   0.703*** (0.066)   0.668*** (0.064)   0.648*** (0.068)   0.646*** (0.067)
    --------------------------------------------------------------------------------------------------------------
    Observations        778                778                778                778                778           
    R-squared         0.079              0.071              0.106              0.085              0.116           
    Adjusted R-sq~d   0.064              0.056              0.092              0.070              0.102           
    F                 5.439              4.842              7.547              5.898              8.364           
    --------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (pooled treatment, gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf)
    


```stata
tab pid
```

    
      RECODE of |
     Ideology_1 |
    (Ideology_1 |
              ) |      Freq.     Percent        Cum.
    ------------+-----------------------------------
     Democratic |        507       41.87       41.87
     Republican |        433       35.76       77.62
    Independent |        271       22.38      100.00
    ------------+-----------------------------------
          Total |      1,211      100.00
    

### Table 7. Alternative Measures of Public Opinion about Health Policy Reform

#### Panel 7A. Effect of experimental priming on alternative outcomes


```stata
/*----- Table 7. Alternative measures of public opinion about health programs  -----*/
// Panel 7A. Effect of experimental priming on alternative outcomes
eststo clear
local num = 1
foreach y in m4a_select aca_extend aca_repeal other_option {
eststo lm`num': qui reg `y' any_treat i.pid female i.age_cat i.ethnic i.income
local num = `num' + 1
}

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 7. Panel A: Effect of experimental priming on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "Expanding ACA" "Reversing ACA" "Other Option") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 7. Panel A: Effect of experimental priming on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "Expanding ACA" "Reversing ACA" "Other Option") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    Table 7. Panel A: Effect of experimental priming on alternative outcomes
    ---------------------------------------------------------------------------------------------------------------------------
                            M4A                Expanding~A                Reversing~A                Other Opt~n               
    ---------------------------------------------------------------------------------------------------------------------------
    Pooled Treatm~t       0.019        (0.030)      -0.011        (0.029)      -0.012        (0.022)       0.004        (0.010)
    Republican           -0.085**      (0.033)      -0.082**      (0.032)       0.135***     (0.024)       0.032***     (0.011)
    Independent          -0.037        (0.038)      -0.082**      (0.037)       0.108***     (0.028)       0.011        (0.013)
    Gender               -0.063**      (0.031)       0.007        (0.030)       0.032        (0.022)       0.024**      (0.010)
    25-44                 0.073*       (0.044)      -0.043        (0.043)      -0.020        (0.032)      -0.010        (0.015)
    45-64                 0.067        (0.051)      -0.079        (0.050)      -0.005        (0.037)       0.017        (0.017)
    65+                  -0.102*       (0.059)       0.020        (0.057)       0.076*       (0.043)       0.005        (0.020)
    Black                -0.031        (0.046)       0.075*       (0.045)      -0.032        (0.033)      -0.012        (0.015)
    Hispanic              0.085        (0.061)      -0.062        (0.060)      -0.026        (0.044)       0.003        (0.020)
    Other                 0.064        (0.053)       0.001        (0.052)      -0.065*       (0.039)      -0.000        (0.018)
    20K-75K               0.031        (0.039)      -0.008        (0.038)      -0.017        (0.029)      -0.006        (0.013)
    75K-150K             -0.023        (0.047)       0.058        (0.046)      -0.035        (0.034)       0.001        (0.016)
    Over 150K            -0.018        (0.047)       0.108**      (0.046)      -0.078**      (0.034)      -0.012        (0.016)
    Constant              0.450***     (0.060)       0.422***     (0.058)       0.122***     (0.043)       0.006        (0.020)
    ---------------------------------------------------------------------------------------------------------------------------
    Observations           1211                       1211                       1211                       1211               
    R-squared             0.028                      0.023                      0.052                      0.020               
    Adjusted R-sq~d       0.018                      0.013                      0.042                      0.010               
    F                     2.697                      2.189                      5.045                      1.906               
    ---------------------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (pooled treatment, gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_A.rtf)
    

#### Panel 7B. Effect of insurance loss on alternative outcomes


```stata
// Panel 7B. Effect of insurance loss on alternative outcomes
eststo clear
local num = 1
foreach y in m4a_select aca_extend aca_repeal other_option {
eststo lm`num': qui reg `y' lost_hi i.pid female i.age_cat i.ethnic i.income
local num = `num' + 1
}

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel B: Effect of insurance loss on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "Expanding ACA" "Reversing ACA" "Other Option") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)

esttab lm1 lm2 lm3 lm4 /*
    */using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_B.rtf"/*
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order() /*
    */title(Table 6. Panel B: Effect of insurance loss on alternative outcomes) /*
    */nonumbers /*
    */mtitles("M4A" "Expanding ACA" "Reversing ACA" "Other Option") /*
    */addnote("Controls included but not shown (pooled treatment, gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    Table 6. Panel B: Effect of insurance loss on alternative outcomes
    ---------------------------------------------------------------------------------------------------------------------------
                            M4A                Expanding~A                Reversing~A                Other Opt~n               
    ---------------------------------------------------------------------------------------------------------------------------
    All HI Loss          -0.098***     (0.036)       0.193***     (0.035)      -0.076***     (0.026)      -0.019        (0.012)
    Republican           -0.081**      (0.033)      -0.089***     (0.032)       0.137***     (0.024)       0.033***     (0.011)
    Independent          -0.046        (0.038)      -0.064*       (0.037)       0.101***     (0.028)       0.009        (0.013)
    Gender               -0.072**      (0.031)       0.026        (0.030)       0.025        (0.022)       0.022**      (0.010)
    25-44                 0.064        (0.044)      -0.023        (0.042)      -0.030        (0.032)      -0.012        (0.015)
    45-64                 0.047        (0.051)      -0.034        (0.049)      -0.026        (0.037)       0.013        (0.017)
    65+                  -0.131**      (0.060)       0.083        (0.058)       0.048        (0.043)      -0.000        (0.020)
    Black                -0.025        (0.046)       0.064        (0.044)      -0.028        (0.033)      -0.011        (0.015)
    Hispanic              0.080        (0.061)      -0.052        (0.059)      -0.030        (0.044)       0.002        (0.020)
    Other                 0.062        (0.053)       0.004        (0.052)      -0.066*       (0.039)      -0.000        (0.018)
    20K-75K               0.030        (0.039)      -0.005        (0.038)      -0.019        (0.028)      -0.006        (0.013)
    75K-150K             -0.025        (0.047)       0.062        (0.045)      -0.038        (0.034)       0.000        (0.016)
    Over 150K            -0.018        (0.047)       0.111**      (0.045)      -0.080**      (0.034)      -0.012        (0.016)
    Constant              0.502***     (0.060)       0.332***     (0.058)       0.149***     (0.044)       0.017        (0.020)
    ---------------------------------------------------------------------------------------------------------------------------
    Observations           1211                       1211                       1211                       1211               
    R-squared             0.034                      0.048                      0.058                      0.022               
    Adjusted R-sq~d       0.024                      0.038                      0.048                      0.012               
    F                     3.257                      4.628                      5.709                      2.098               
    ---------------------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (pooled treatment, gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    
    (note: file C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_B.rtf not found)
    (output written to C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2019_Framing Single-Payer\06.Submission\JHPPL\rev1\img\Table6_B.rtf)
    

## Part IV. Brief Statements

### On Page 14, "In the six months prior to our survey, 22% of respondents lost health insurance. ..."

"In the six months prior to our survey, 22% of respondents lost health insurance. More than half (13% of total) of these respondents lost health insurance because of losing their job, while the remaining 9% lost health insurance for other reasons. Another 23% report that someone close to them lost health insurance."


```stata
********************************************************************************
/*----- Part IV. Brief Statements -----*/
********************************************************************************

/*----- On Page 14 -----*/
tab lost_hi_4cat
```

    
        RECODE of HR_13 (HR_13) |      Freq.     Percent        Cum.
    ----------------------------+-----------------------------------
      Lost HI due to losing job |        155       12.80       12.80
      Lost HI for other reasons |        112        9.25       22.05
    Someone close to me lost HI |        279       23.04       45.09
                     No HI loss |        665       54.91      100.00
    ----------------------------+-----------------------------------
                          Total |      1,211      100.00
    

### On page 14, "24.74% of our under-65 sample reported being unemployed..."

"Compared to the national unemployment rate in June 2020 (11.2%), 24.74% of our under-65 sample reported being unemployed (The Economic Daily, 2020)"


```stata
/*----- On page 24, "24.74% of our under-65 sample reported being unemployed" -----*/
tab lost_hi if age_cat != 3 & !missing(HR_13), m
```

    
           lost |
      insurance |
     due to job |
        loss or |
          other |
      reason in |
         last 6 |
         months |      Freq.     Percent        Cum.
    ------------+-----------------------------------
              0 |        803       75.26       75.26
              1 |        264       24.74      100.00
    ------------+-----------------------------------
          Total |      1,067      100.00
    

### On Page 16, "We cannot reject the null hypothesis that the two treatment treatments arms are equivalent (p=0.68)..."


```stata
/*----- On Page 16, "We cannot reject the null hypothesis that the two treatment treatments arms are equivalent (p=0.68)..." -----*/
ttest m4a if treatment != 0, by(treatment)
```

    
    Two-sample t test with equal variances
    ------------------------------------------------------------------------------
       Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
    ---------+--------------------------------------------------------------------
    Airbnb A |     391     .685422    .0235132    .4649425    .6391936    .7316504
    COVID-19 |     382    .6989529    .0235006    .4593147    .6527458      .74516
    ---------+--------------------------------------------------------------------
    combined |     773    .6921087    .0166141    .4619202    .6594945    .7247229
    ---------+--------------------------------------------------------------------
        diff |           -.0135309    .0332485               -.0787991    .0517374
    ------------------------------------------------------------------------------
        diff = mean(Airbnb A) - mean(COVID-19)                        t =  -0.4070
    Ho: diff = 0                                     degrees of freedom =      771
    
        Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
     Pr(T < t) = 0.3421         Pr(|T| > |t|) = 0.6841          Pr(T > t) = 0.6579
    

## Part V. Appendix Tables

### Table A1. Alternative DV: Support Public, Private, Incremental


```stata
********************************************************************************
/*----- Part V. Appendix Tables -----*/
********************************************************************************

/*----- Table A1. Alternate DV: Support Public, Private, Incremental -----*/
tab HR_11_3cat
```

    
              Health Reform |
                 Preference |      Freq.     Percent        Cum.
    ------------------------+-----------------------------------
    Reversing the ACA/Other |        226       18.66       18.66
            Incremental ACA |        451       37.24       55.90
                        M4A |        534       44.10      100.00
    ------------------------+-----------------------------------
                      Total |      1,211      100.00
    

### Table A2. Experimental Priming Results with Don’t Know Excluded


```stata
/*----- Table A2. Experimental Priming Results with Don’t Know Excluded -----*/
eststo clear
eststo lm1: qui reg m4a i.treatment if support_M4A_likert != 7
eststo lm2: qui reg m4a i.treatment i.pid female i.age_cat i.ethnic i.income if support_M4A_likert != 7
eststo lm3: qui reg m4a any_treat if support_M4A_likert != 7
eststo lm4: qui reg m4a any_treat i.pid female i.age_cat i.ethnic i.income if support_M4A_likert != 7

esttab lm1 lm2 lm3 lm4 /*
    //using "C:\Users\NoMoreTicket\OneDrive - University at Albany - SUNY\05.Research\2020_Media Consumption and Social Distancing\02.STATA Outputs\Appendix2.rtf"
    */,replace b(3) se(3) r2(3) ar2(3) scalar(F) /*
    */order(2.treatment 1.treatment any_treat) /*
    */title(Table 3. Experimental Priming Results) /*
    */nonumbers /*
    */mgroups("Separate Treatment" "Pooled Treatment", pattern(1 0 1 0)) /*
    */mtitles("No controls" "w/ controls" "No controls" "w/ controls") /*
    */addnote("Controls included but not shown (gender, race, income, party ID)") /*
    */label /*
    */nobaselevels /*
    */interaction(" X ") /*
    */varwidth(15) modelwidth(11) compress wide /*
    */star(* 0.1 ** 0.05 *** 0.01)
```

    
    
    
    
    
    
    
    Table 3. Experimental Priming Results
    ---------------------------------------------------------------------------------------------------------------------------
                    Separate ~t                                           Pooled Tr~t                                          
                    No controls                w/ controls                No controls                w/ controls               
    ---------------------------------------------------------------------------------------------------------------------------
    COVID-19 Arm          0.022        (0.032)       0.026        (0.031)                                                      
    Airbnb Arm            0.027        (0.032)       0.031        (0.031)                                                      
    Pooled Treatm~t                                                             0.025        (0.028)       0.028        (0.027)
    Republican                                      -0.161***     (0.029)                                 -0.161***     (0.029)
    Independent                                     -0.127***     (0.035)                                 -0.127***     (0.035)
    Gender                                          -0.046*       (0.027)                                 -0.046*       (0.027)
    25-44                                            0.074*       (0.040)                                  0.074*       (0.040)
    45-64                                           -0.020        (0.046)                                 -0.020        (0.046)
    65+                                             -0.237***     (0.053)                                 -0.237***     (0.053)
    Black                                           -0.051        (0.042)                                 -0.051        (0.042)
    Hispanic                                        -0.060        (0.055)                                 -0.060        (0.055)
    Other                                           -0.033        (0.048)                                 -0.033        (0.048)
    20K-75K                                         -0.052        (0.036)                                 -0.052        (0.036)
    75K-150K                                        -0.025        (0.042)                                 -0.025        (0.042)
    Over 150K                                        0.055        (0.042)                                  0.055        (0.042)
    Constant              0.715***     (0.022)       0.836***     (0.054)       0.715***     (0.022)       0.837***     (0.054)
    ---------------------------------------------------------------------------------------------------------------------------
    Observations           1113                       1113                       1113                       1113               
    R-squared             0.001                      0.103                      0.001                      0.103               
    Adjusted R-sq~d      -0.001                      0.091                     -0.000                      0.092               
    F                     0.400                      8.975                      0.779                      9.673               
    ---------------------------------------------------------------------------------------------------------------------------
    Standard errors in parentheses
    Controls included but not shown (gender, race, income, party ID)
    * p<0.1, ** p<0.05, *** p<0.01
    

### Table A3. Experimental Analysis with Inverse Probability Reweighting


```stata
/*----- Table A3. Experimental Analysis with Inverse Probability Reweighting -----*/
teffects ipw (m4a) (covid_arm age female ethnic income pid) if airbnb_arm!=1
teffects ipw (m4a) (airbnb_arm age female ethnic income pid) if covid_arm!=1
teffects ipw (m4a) (any_treat age female ethnic income pid)
```

    
    
    Iteration 0:   EE criterion =  1.456e-23  
    Iteration 1:   EE criterion =  2.812e-33  
    
    Treatment-effects estimation                    Number of obs     =        820
    Estimator      : inverse-probability weights
    Outcome model  : weighted mean
    Treatment model: logit
    ------------------------------------------------------------------------------------------
                             |               Robust
                         m4a |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------------------+----------------------------------------------------------------
    ATE                      |
                   covid_arm |
    (COVID-19 Arm vs Other)  |   .0616363   .0315626     1.95   0.051    -.0002253    .1234979
    -------------------------+----------------------------------------------------------------
    POmean                   |
                   covid_arm |
                      Other  |   .6370633   .0226961    28.07   0.000     .5925798    .6815468
    ------------------------------------------------------------------------------------------
    
    
    Iteration 0:   EE criterion =  2.921e-26  
    Iteration 1:   EE criterion =  6.851e-34  
    
    Treatment-effects estimation                    Number of obs     =        829
    Estimator      : inverse-probability weights
    Outcome model  : weighted mean
    Treatment model: logit
    ----------------------------------------------------------------------------------------
                           |               Robust
                       m4a |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -----------------------+----------------------------------------------------------------
    ATE                    |
                airbnb_arm |
    (Airbnb Arm vs Other)  |    .050036   .0317596     1.58   0.115    -.0122117    .1122838
    -----------------------+----------------------------------------------------------------
    POmean                 |
                airbnb_arm |
                    Other  |   .6374656    .022681    28.11   0.000     .5930116    .6819196
    ----------------------------------------------------------------------------------------
    
    
    Iteration 0:   EE criterion =  4.507e-17  
    Iteration 1:   EE criterion =  1.417e-32  
    
    Treatment-effects estimation                    Number of obs     =      1,211
    Estimator      : inverse-probability weights
    Outcome model  : weighted mean
    Treatment model: logit
    ------------------------------------------------------------------------------
                 |               Robust
             m4a |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
    ATE          |
       any_treat |
       (1 vs 0)  |   .0550179   .0274127     2.01   0.045       .00129    .1087459
    -------------+----------------------------------------------------------------
    POmean       |
       any_treat |
              0  |   .6372367   .0226614    28.12   0.000     .5928213    .6816522
    ------------------------------------------------------------------------------
    

### Table A4. Did COVID-19 Change Your Opinion on M4A?


```stata
tab Corona__HR_3
```

    
      Did COVID-19 Change Your Opinion |
                               on M4A? |      Freq.     Percent        Cum.
    -----------------------------------+-----------------------------------
                        More Favorable |        657       54.25       54.25
                        Less Favorable |        221       18.25       72.50
    Has not affected by opinion at all |        333       27.50      100.00
    -----------------------------------+-----------------------------------
                                 Total |      1,211      100.00
    
