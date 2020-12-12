///Support for UHC data cleaning and Analysis////

recode HR_01_NEW (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4)(8=3) (9=2) (12=1), generate(HR01new_reverse_code)

recode HR_08 (1=1 "Strongly Favor") (4=2 "Somewhat Favor") (5=3 "Somewhat Oppose") (6=4 "Strongly Oppose")
(7=7 "Don't know"), generate(support_M4A_likert)

recode support_M4A_likert (1 2=1 "Favor") (3 4 7=0 "Oppose"), generate(support_M4A_dummy)

encode block, generate(study_condition)

recode study_condition (3=0 "control") (2=1 "arm 2") (1=2 "arm 1"), generate (studycondition)

bysort studycondition: summarize HR01new_reverse_code

recode HR_07_1 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_1_dummy)
label variable HR_07_4_dummy "Provides a basic tax financed health plan to everyone but allows people to purchase supplementary private health insurance." 

recode HR_07_2 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_2_dummy)
label variable HR_07_2_dummy "Requires many businesses and some individuals to pay more in taxes but eliminates health insurance premiums and deductibles" 

recode HR_07_3 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_3_dummy)
label variable HR_07_3_dummy "Increase the taxes that you personally pay but decreases your overall costs for healthcare." 

recode HR_07_4 (1 2=1 "Favor") (4 5 6=0 "Oppose, unsure"), generate(HR_07_4_dummy)
label variable HR_07_4_dummy "Provides a basic tax financed health plan to everyone but allows people to purchase supplementary private health insurance." 

recode HR_13 (1 8=1 "lost health insurance") (6 9=2 "someone close to me lost health insurance") (4 5 =3 "No, unsure"), generate(health_insurance_situation)
label variable health_insurance_situation "Have you or anyone close to you lost their health insurance in the last 6 months due to being laid off from work or for other reasons?" 

recode health_insurance_situation (1 2=1 "you personally or someone close to you lost health insurance") (3=0 "health insurance situation unchanged"), generate (lost_insurance_dummy)

recode HR_14 (1=1 "ESI") (4=2 "Marketplace plan, with subsidy")  (5=3 "Marketplace plan, without subsidy") (6=4 "Uninsured") (7=5 "Medicaid") (8 11=6 "Medicare (traditional or Advantage Plan") (9=7 "VA") (10=8 "Other"), generate(current_health_insurance)

///. bysort studycondition: summarize HR01new_reverse_code

------------------------------------------------------------------------------------------------------------
-> studycondition = control

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        486    6.518519     3.21316          1         10

------------------------------------------------------------------------------------------------------------
-> studycondition = arm 2

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        407    6.565111    3.089799          1         10

------------------------------------------------------------------------------------------------------------
-> studycondition = arm 1

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        403    6.674938    3.110893          1         10

/////M4A Question
. tab support_M4A_dummy studycondition, col chi2

 RECODE of |
support_M4 |
  A_likert |
(RECODE of |    RECODE of study_condition
     HR_08 |             (block)
  (HR_08)) |   control      arm 2      arm 1 |     Total
-----------+---------------------------------+----------
    Oppose |       168        127        124 |       419 
           |     34.71      31.20      30.77 |     32.38 
-----------+---------------------------------+----------
     Favor |       316        280        279 |       875 
           |     65.29      68.80      69.23 |     67.62 
-----------+---------------------------------+----------
     Total |       484        407        403 |     1,294 
           |    100.00     100.00     100.00 |    100.00 

          Pearson chi2(2) =   1.9355   Pr = 0.380
////

bysort block: summarize support_M4A_likert

///

ttest HR01new_reverse_code == experimental_dummy

. bysort block: summarize support_M4A_likert

-------------------------------------------------------------------------------------------------------
-> block = arm1

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
support_M4~t |        403    2.300248    1.531323          1          7

-------------------------------------------------------------------------------------------------------
-> block = arm2

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
support_M4~t |        407    2.326781    1.653134          1          7

-------------------------------------------------------------------------------------------------------
-> block = control

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
support_M4~t |        484    2.522727    1.807936          1          7


////

***ANALYSIS BY PARTYID*****

tab support_M4A_dummy Party_ID, col, if studycondition ==0
tab support_M4A_dummy Party_ID , col, if studycondition ==1
tab support_M4A_dummy Party_ID , col, if studycondition ==3

tab support_M4A_dummy studycondition, col chi2, if  Party_ID ==1
tab support_M4A_dummy studycondition , col chi2, if Party_ID ==2
tab support_M4A_dummy studycondition , col chi2, if Party_ID  ==3

bysort studycondition: summarize HR01new_reverse_code if  Party_ID ==1
bysort studycondition: summarize HR01new_reverse_code if  Party_ID ==2
bysort studycondition: summarize HR01new_reverse_code if  Party_ID ==3

tab M4A_Incrementalism_Private studycondition , col chi2, if Party_ID  ==1
tab M4A_Incrementalism_Private studycondition , col chi2, if Party_ID  ==2
tab M4A_Incrementalism_Private studycondition , col chi2, if Party_ID  ==3

logistic support_M4A_dummy i.studycondition i.Party_ID i.studycondition##Party_ID


Logistic regression                             Number of obs     =      1,223
                                                LR chi2(8)        =      41.46
                                                Prob > chi2       =     0.0000
Log likelihood = -753.73797                     Pseudo R2         =     0.0268

-----------------------------------------------------------------------------------------
      support_M4A_dummy | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
         studycondition |
                 arm 2  |   1.358158    .335756     1.24   0.216     .8366065    2.204852
                 arm 1  |   1.608363   .4144693     1.84   0.065     .9705828    2.665236
                        |
               Party_ID |
            Republican  |   .5922159    .138204    -2.24   0.025     .3748325    .9356706
           Independent  |   .4727135   .1192444    -2.97   0.003     .2883222    .7750291
                        |
studycondition#Party_ID |
      arm 2#Republican  |   .8135053   .2805468    -0.60   0.550      .413822    1.599216
     arm 2#Independent  |   .9172442   .3522645    -0.22   0.822     .4320997     1.94709
      arm 1#Republican  |   .7748823   .2742151    -0.72   0.471     .3872691    1.550453
     arm 1#Independent  |   .7081628   .2771528    -0.88   0.378     .3288512    1.524989
                        |
                  _cons |    2.54717   .4128878     5.77   0.000     1.853877    3.499732
-----------------------------------------------------------------------------------------
Note: _cons estimates baseline odds.


*****ANALYSIS BY LOST INSURANCE*********
tab support_M4A_dummy studycondition, col chi2, if  lost_insurance_dummy==1
tab support_M4A_dummy studycondition , col chi2, if lost_insurance_dummy==0

generate studycondition_lostinsurance= studycondition+lost_insurance_dummy
recode studycondition_lostinsurance (0=0 "Control, no change in insurance") (1=1 "Arm 2, no change in insurance") (2=2 "Arm 2,lost insurance") (3=3 "Arm 1, no change in insurance") (4=4 "Arm 1, lost insurance"), generate(studycondition_lostinsurance_rec)

logistic support_M4A_dummy i.studycondition  
logistic support_M4A_dummy i.studycondition lost_insurance_dummy i.studycondition_lostinsurance_rec 
logistic support_M4A_dummy i.studycondition lost_insurance_dummy i.studycondition#lost_insurance_dummy  

regress HR01new_reverse_code i.studycondition
regress HR01new_reverse_code i.studycondition lost_insurance_dummy i.studycondition_lostinsurance_rec 
regress HR01new_reverse_code i.studycondition lost_insurance_dummy i.studycondition#lost_insurance_dummy 


regress HR01new_reverse_code i.studycondition i.studycondition##lost_insurance_dummy 
regress HR01new_reverse_code i.studycondition i.studycondition##econ_harm_lockdown_dummy


recode studycondition (3=2), generate (studycondition_)
recode studycondition_ (0=0 "Control") (1 2=1 "Experimental"), generate (experimental_dummy)

**Recoding Multiple Response Option Questions******
///Economic Effects of Lockdowns: 
//Work from home  (1)//Lost job  (4) //Furloughed  (10) //Reduced hours  (5) 
// Pay cut  (6) // Work more hours  (7) //Increased pay (i.e., from working overtime/hazard pay)  (8) 
//Nothing changed (i.e., was retired; already worked from home, etc)  (9) 

split Stimulus_1, parse(,) destring
recode Stimulus_11 (4=4) (else=0)
recode Stimulus_12 (4=4) (else=0)
recode Stimulus_13 (4=4) (else=0)
recode Stimulus_14 (4=4) (else=0)
recode Stimulus_15 (4=4) (else=0)
recode Stimulus_16 (4=4) (else=0)
recode Stimulus_17 (4=4) (else=0)
recode Stimulus_18 (4=4) (else=0)
generate lost_job2= Stimulus_11+ Stimulus_12+ Stimulus_13+ Stimulus_14+ Stimulus_15 + Stimulus_16+ Stimulus_17+ Stimulus_18

tab lost_job2

  lost_job2 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,637       91.86       91.86
          4 |        145        8.14      100.00
------------+-----------------------------------
      Total |      1,782      100.00

drop Stimulus_11 Stimulus_12 Stimulus_13 Stimulus_14 Stimulus_15 Stimulus_16 Stimulus_17 Stimulus_18
rename lost_job2 lost_job
recode lost_job (4=1)

split Stimulus_1, parse(,) destring

recode Stimulus_11 (10=10) (else=0)
recode Stimulus_12 (10=10) (else=0)
recode Stimulus_13 (10=10) (else=0)
recode Stimulus_14 (10=10) (else=0)
recode Stimulus_15 (10=10) (else=0)
recode Stimulus_16 (10=10) (else=0)
recode Stimulus_17 (10=10) (else=0)
recode Stimulus_18 (10=10) (else=0)

generate furloughed= Stimulus_11+ Stimulus_12+ Stimulus_13+ Stimulus_14+ Stimulus_15+ Stimulus_16+ Stimulus_17+ Stimulus_18
recode furloughed (10=1)

tab furloughed

 furloughed |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,659       93.10       93.10
         10 |        123        6.90      100.00
------------+-----------------------------------
      Total |      1,782      100.00


drop Stimulus_11 Stimulus_12 Stimulus_13 Stimulus_14 Stimulus_15 Stimulus_16 Stimulus_17 Stimulus_18

split Stimulus_1, parse(,) destring
recode Stimulus_11 (6=6) (else=0)
recode Stimulus_12 (6=6) (else=0)
recode Stimulus_13 (6=6) (else=0)
recode Stimulus_14 (6=6) (else=0)
recode Stimulus_15 (6=6) (else=0)
recode Stimulus_16 (6=6) (else=0)
recode Stimulus_17 (6=6) (else=0)
recode Stimulus_18 (6=6) (else=0)

generate pay_cut= Stimulus_11+ Stimulus_12+ Stimulus_13+ Stimulus_14+ Stimulus_15 + Stimulus_16+ Stimulus_17+ Stimulus_18
drop Stimulus_11 Stimulus_12 Stimulus_13 Stimulus_14 Stimulus_15 Stimulus_16 Stimulus_17 Stimulus_18
tab pay_cut

    pay_cut |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,660       93.15       93.15
          6 |        122        6.85      100.00
------------+-----------------------------------
      Total |      1,782      100.00
recode pay_cut (6=1)


split Stimulus_1, parse(,) destring
recode Stimulus_11 (1=1) (else=0)
recode Stimulus_12 (1=1) (else=0)
recode Stimulus_13 (1=1) (else=0)
recode Stimulus_14 (1=1) (else=0)
recode Stimulus_15 (1=1) (else=0)
recode Stimulus_16 (1=1) (else=0)
recode Stimulus_17 (1=1) (else=0)
recode Stimulus_18 (1=1) (else=0)

generate work_from_home= Stimulus_11+ Stimulus_12+ Stimulus_13+ Stimulus_14+ Stimulus_15 + Stimulus_16+ Stimulus_17+ Stimulus_18
drop Stimulus_11 Stimulus_12 Stimulus_13 Stimulus_14 Stimulus_15 Stimulus_16 Stimulus_17 Stimulus_18
tab work_from_home
work_from_h |
        ome |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,225       68.74       68.74
          1 |        557       31.26      100.00
------------+-----------------------------------
      Total |      1,782      100.00


generate econ_harm_lockdown= lost_job+ furloughed+ pay_cut
tab econ_harm_lockdown

econ_harm_l |
    ockdown |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,455       81.65       81.65
          1 |        276       15.49       97.14
          2 |         39        2.19       99.33
          3 |         12        0.67      100.00
------------+-----------------------------------
      Total |      1,782      100.00

recode econ_harm_lockdown (1 2 3=1 "lost job, were furloughed or lost pay") (0=0),  generate(econ_harm_lockdown_dummy)

bysort studycondition: summarize support_M4A_likert if econ_harm_lockdown_dummy==1

tab support_M4A_dummy studycondition, col, if econ_harm_lockdown_dummy ==1, chi2
tab support_M4A_dummy studycondition, col, if econ_harm_lockdown_dummy ==0, chi2

tab support_M4A_dummy studycondition, col, if close_person_lostjob ==1, chi2
tab support_M4A_dummy studycondition, col, if close_person_lostjob ==0, chi2


//Stimulus/Lock-down Questions//

split Stimulus_5, parse(,) destring
recode Stimulus_51 (1=1) (else=0)
recode Stimulus_52 (1=1) (else=0)
recode Stimulus_53 (1=1) (else=0)
recode Stimulus_54 (1=1) (else=0)
recode Stimulus_55 (1=1) (else=0)
generate check_from_gov= Stimulus_51+ Stimulus_52+ Stimulus_53+ Stimulus_54+ Stimulus_55
label variable check_from_gov "Received a stimulus check"
tab check_from_gov
drop Stimulus_51 Stimulus_52 Stimulus_53 Stimulus_54 Stimulus_55 

split Stimulus_5, parse(,) destring
recode Stimulus_51 (4=1) (else=0)
recode Stimulus_52 (4=1) (else=0)
recode Stimulus_53 (4=1) (else=0)
recode Stimulus_54 (4=1) (else=0)
recode Stimulus_55 (4=1) (else=0)
generate small_bus_loan= Stimulus_51+ Stimulus_52+ Stimulus_53+ Stimulus_54+ Stimulus_55
label variable small_bus_loan "Received a small business loan"
tab small_bus_loan
drop Stimulus_51 Stimulus_52 Stimulus_53 Stimulus_54 Stimulus_55 

split Stimulus_5, parse(,) destring
recode Stimulus_51 (5=1) (else=0)
recode Stimulus_52 (5=1) (else=0)
recode Stimulus_53 (5=1) (else=0)
recode Stimulus_54 (5=1) (else=0)
recode Stimulus_55 (5=1) (else=0)
generate unemploy_ben= Stimulus_51+ Stimulus_52+ Stimulus_53+ Stimulus_54+ Stimulus_55
label variable unemploy_ben "Received unemployment benefits"
tab unemploy_ben
drop Stimulus_51 Stimulus_52 Stimulus_53 Stimulus_54 Stimulus_55 

split Stimulus_5, parse(,) destring
recode Stimulus_51 (6=1) (else=0)
recode Stimulus_52 (6=1) (else=0)
recode Stimulus_53 (6=1) (else=0)
recode Stimulus_54 (6=1) (else=0)
recode Stimulus_55 (6=1) (else=0)
generate no_stim_received= Stimulus_51+ Stimulus_52+ Stimulus_53+ Stimulus_54+ Stimulus_55
label variable no_stim_received "Did not receive check, loan or unemployment benefits"
tab no_stim_received
drop Stimulus_51 Stimulus_52 Stimulus_53 Stimulus_54 Stimulus_55 

split Stimulus_5, parse(,) destring
recode Stimulus_51 (7=1) (else=0)
recode Stimulus_52 (7=1) (else=0)
recode Stimulus_53 (7=1) (else=0)
recode Stimulus_54 (7=1) (else=0)
recode Stimulus_55 (7=1) (else=0)
generate unsure_stim_received= Stimulus_51+ Stimulus_52+ Stimulus_53+ Stimulus_54+ Stimulus_55
label variable unsure_stim_received "unsure if received check, loan or unemployment benefits"
tab unsure_stim_received
drop Stimulus_51 Stimulus_52 Stimulus_53 Stimulus_54 Stimulus_55 

generate received_pandemic_support= check_from_gov+ small_bus_loan+ unemploy_ben

tab Stimulus_5_8_TEXT
 
recode Stimulus_6 (1=1 "Nothing. Let the market run its course") (4=2 "More direct payments to workers affected by the Coronavirus") (5=3 "More stimulus for small and large businesses to enable them to keep operating") (6=4 "Guarantee the salary of all workers") (7=5 "Other"), generate(stimulus6_rec)
label variable stimulus6_rec "When it comes to responding to the economic issues presented by the Coronavirus, which of the following would you most want to see the government do"

recode Policy_1 (1=0 "Not at all- has not affected my finances personally") (4=1 "A little – affected my finances but not severely") (5=2 "A lot- lost significant income as a consequence"), generate(lost_income_ord)
label variable lost_income_ord "How much would you say that social distancing in response to the Coronavirus has affected you from an economic standpoint?"

recode Policy_2 (1=2 "Very concerned") (4=1 "Somewhat concerned") (5=0 "Not concerned at all"), generate(concern_lockdown_ord) 
label variable concern_lockdown_ord "if the social distancing measures currently in place in your area are maintained through June 1st, how concerned are you that you will be worse-off economically at that date than you are now?"

recode Policy_3 (1=0 "Overreaction") (6=2 "Social distancing justified, but reopen as soon as possible") (7=3 "Continue social distancing as long as necessary"), generate(attitude_SD)
label variable attitude_SD "Which of the following best describes your own belief about the seriousness of Coronavirus as a threat to the nation’s health and the need for social distancing measures?"

recode Policy_4 (1=1 "prioritize putting people back to work") (6=0 "prioritize safety"), generate(return_work_dummy)
label variable return_work_dummy "Which of the following statements do you agree with more"

//Policy Responses Until June 1
split Policy_5, parse(,) destring
recode Policy_51 (11=1) (else=0)
recode Policy_52 (11=1) (else=0)
recode Policy_53 (11=1) (else=0)
recode Policy_54 (11=1) (else=0)
recode Policy_55 (11=1) (else=0)
recode Policy_56 (11=1) (else=0)
recode Policy_57 (11=1) (else=0)
recode Policy_58 (11=1) (else=0)
recode Policy_59 (11=1) (else=0)
recode Policy_510 (11=1) (else=0)
recode Policy_511 (11=1) (else=0)
generate issue_stay_at_home_order= Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable issue_stay_at_home_order "When it comes to responding to the Coronavirus...Gov should issue a stay-at-home order... AT LEAST until June 1st"
tab issue_stay_at_home_order
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (20=1) (else=0)
recode Policy_52 (20=1) (else=0)
recode Policy_53 (20=1) (else=0)
recode Policy_54 (20=1) (else=0)
recode Policy_55 (20=1) (else=0)
recode Policy_56 (20=1) (else=0)
recode Policy_57 (20=1) (else=0)
recode Policy_58 (20=1) (else=0)
recode Policy_59 (20=1) (else=0)
recode Policy_510 (20=1) (else=0)
recode Policy_511 (20=1) (else=0)
generate close_camps= Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable close_camps "When it comes to responding to the Coronavirus...close camps AT LEAST until June 1st"
tab close_camps
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (17=1) (else=0)
recode Policy_52 (17=1) (else=0)
recode Policy_53 (17=1) (else=0)
recode Policy_54 (17=1) (else=0)
recode Policy_55 (17=1) (else=0)
recode Policy_56 (17=1) (else=0)
recode Policy_57 (17=1) (else=0)
recode Policy_58 (17=1) (else=0)
recode Policy_59 (17=1) (else=0)
recode Policy_510 (17=1) (else=0)
recode Policy_511 (17=1) (else=0)
generate close_schools= Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable close_schools "When it comes to responding to the Coronavirus...close schools AT LEAST until June 1st"
tab close_schools
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (18=1) (else=0)
recode Policy_52 (18=1) (else=0)
recode Policy_53 (18=1) (else=0)
recode Policy_54 (18=1) (else=0)
recode Policy_55 (18=1) (else=0)
recode Policy_56 (18=1) (else=0)
recode Policy_57 (18=1) (else=0)
recode Policy_58 (18=1) (else=0)
recode Policy_59 (18=1) (else=0)
recode Policy_510 (18=1) (else=0)
recode Policy_511 (18=1) (else=0)
generate close_universities= Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable close_universities "When it comes to responding to the Coronavirus...close universities AT LEAST until June 1st"
tab close_universities
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (21=1) (else=0)
recode Policy_52 (21=1) (else=0)
recode Policy_53 (21=1) (else=0)
recode Policy_54 (21=1) (else=0)
recode Policy_55 (21=1) (else=0)
recode Policy_56 (21=1) (else=0)
recode Policy_57 (21=1) (else=0)
recode Policy_58 (21=1) (else=0)
recode Policy_59 (21=1) (else=0)
recode Policy_510 (21=1) (else=0)
recode Policy_511 (21=1) (else=0)
generate wear_masks= Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable wear_masks "When it comes to responding to the Coronavirus...wear masks AT LEAST until June 1st"
tab wear_masks
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (14=1) (else=0)
recode Policy_52 (14=1) (else=0)
recode Policy_53 (14=1) (else=0)
recode Policy_54 (14=1) (else=0)
recode Policy_55 (14=1) (else=0)
recode Policy_56 (14=1) (else=0)
recode Policy_57 (14=1) (else=0)
recode Policy_58 (14=1) (else=0)
recode Policy_59 (14=1) (else=0)
recode Policy_510 (14=1) (else=0)
recode Policy_511 (14=1) (else=0)
generate stay_at_home_heavily_affected= Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable stay_at_home_heavily_affected "When it comes to responding to the Coronavirus...issue stay at home orders only in heavily affected areas AT LEAST until June 1st"
tab stay_at_home_heavily_affected
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (15=1) (else=0)
recode Policy_52 (15=1) (else=0)
recode Policy_53 (15=1) (else=0)
recode Policy_54 (15=1) (else=0)
recode Policy_55 (15=1) (else=0)
recode Policy_56 (15=1) (else=0)
recode Policy_57 (15=1) (else=0)
recode Policy_58 (15=1) (else=0)
recode Policy_59 (15=1) (else=0)
recode Policy_510 (15=1) (else=0)
recode Policy_511 (15=1) (else=0)
generate voluntary_social_distancing = Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable voluntary_social_distancing "When it comes to responding to the Coronavirus...encourage voluntary social distancing but not issue stay-at-home orders AT LEAST until June 1st"
tab voluntary_social_distancing
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (16=1) (else=0)
recode Policy_52 (16=1) (else=0)
recode Policy_53 (16=1) (else=0)
recode Policy_54 (16=1) (else=0)
recode Policy_55 (16=1) (else=0)
recode Policy_56 (16=1) (else=0)
recode Policy_57 (16=1) (else=0)
recode Policy_58 (16=1) (else=0)
recode Policy_59 (16=1) (else=0)
recode Policy_510 (16=1) (else=0)
recode Policy_511 (16=1) (else=0)
generate targeted_stay_at_home_order_66 = Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable targeted_stay_at_home_order_66 "When it comes to responding to the Coronavirus...issue a targetted stay-at-home order only for those age 65+ ...until AT LEAST June 1st"
tab targeted_stay_at_home_order_66
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (19=1) (else=0)
recode Policy_52 (19=1) (else=0)
recode Policy_53 (19=1) (else=0)
recode Policy_54 (19=1) (else=0)
recode Policy_55 (19=1) (else=0)
recode Policy_56 (19=1) (else=0)
recode Policy_57 (19=1) (else=0)
recode Policy_58 (19=1) (else=0)
recode Policy_59 (19=1) (else=0)
recode Policy_510 (19=1) (else=0)
recode Policy_511 (19=1) (else=0)
generate Cancel_large_events = Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable Cancel_large_events "When it comes to responding to the Coronavirus...cancel large events  like concerts, conferences, sporting events ...until AT LEAST June 1st"
tab Cancel_large_events
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

split Policy_5, parse(,) destring
recode Policy_51 (22=1) (else=0)
recode Policy_52 (22=1) (else=0)
recode Policy_53 (22=1) (else=0)
recode Policy_54 (22=1) (else=0)
recode Policy_55 (22=1) (else=0)
recode Policy_56 (22=1) (else=0)
recode Policy_57 (22=1) (else=0)
recode Policy_58 (22=1) (else=0)
recode Policy_59 (22=1) (else=0)
recode Policy_510 (22=1) (else=0)
recode Policy_511 (22=1) (else=0)
generate social_distancing_work_schools = Policy_51+ Policy_52+ Policy_53+ Policy_54+ Policy_55 + Policy_56+ Policy_57+ Policy_58+ Policy_59+ Policy_510+ Policy_511
label variable social_distancing_work_schools "When it comes to responding to the Coronavirus... encourage social distancing at workplaces/schools ...until AT LEAST June 1st"
tab social_distancing_work_schools
drop Policy_51 Policy_52 Policy_53 Policy_54 Policy_55 Policy_56 Policy_57 Policy_58 Policy_59 Policy_510 Policy_511

generate Policy_Stringency_all_policies= close_camps + close_universities + wear_masks + voluntary_social_distancing + targeted_stay_at_home_order_66 + Cancel_large_events + social_distancing_work_schools + close_schools + issue_stay_at_home_order
tab Policy_Stringency_all_policies

generate Less_stringent_policies_only= voluntary_social_distancing + targeted_stay_at_home_order_66 + social_distancing_work_schools
tab Less_stringent_policies_only

generate more_stringent_policies_only= close_camps + close_universities + wear_masks +  Cancel_large_events + close_schools + issue_stay_at_home_order
tab more_stringent_policies_only

//POLICY RESPONSES PAST JUNE 1
split Policy_6, parse(,) destring
recode Policy_61 (1=1) (else=0)
recode Policy_62 (1=1) (else=0)
recode Policy_63 (1=1) (else=0)
recode Policy_64 (1=1) (else=0)
recode Policy_65 (1=1) (else=0)
recode Policy_66 (1=1) (else=0)
recode Policy_67 (1=1) (else=0)
recode Policy_68 (1=1) (else=0)
recode Policy_69 (1=1) (else=0)
recode Policy_610 (1=1) (else=0)
recode Policy_611 (1=1) (else=0)
generate stay_at_home_order_past_June1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable stay_at_home_order_past_June1 "When it comes to responding to the Coronavirus...Gov should issue a stay-at-home order... PAST June 1st"
tab stay_at_home_order_past_June1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (12=1) (else=0)
recode Policy_62 (12=1) (else=0)
recode Policy_63 (12=1) (else=0)
recode Policy_64 (12=1) (else=0)
recode Policy_65 (12=1) (else=0)
recode Policy_66 (12=1) (else=0)
recode Policy_67 (12=1) (else=0)
recode Policy_68 (12=1) (else=0)
recode Policy_69 (12=1) (else=0)
recode Policy_610 (12=1) (else=0)
recode Policy_611 (12=1) (else=0)
generate stay_home_heavily_aff_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable stay_home_heavily_aff_pastJune1 "When it comes to responding to the Coronavirus...Gov should issue a stay-at-home order only for heavily affected areas... PAST June 1st"
tab stay_home_heavily_aff_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (4=1) (else=0)
recode Policy_62 (4=1) (else=0)
recode Policy_63 (4=1) (else=0)
recode Policy_64 (4=1) (else=0)
recode Policy_65 (4=1) (else=0)
recode Policy_66 (4=1) (else=0)
recode Policy_67 (4=1) (else=0)
recode Policy_68 (4=1) (else=0)
recode Policy_69 (4=1) (else=0)
recode Policy_610 (4=1) (else=0)
recode Policy_611 (4=1) (else=0)
generate vol_soc_dist_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable vol_soc_dist_pastJune1 "When it comes to responding to the Coronavirus...encourage voluntary social distancing but not issue stay-at-home orders... PAST until June 1st"
tab vol_soc_dist_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (6=1) (else=0)
recode Policy_62 (6=1) (else=0)
recode Policy_63 (6=1) (else=0)
recode Policy_64 (6=1) (else=0)
recode Policy_65 (6=1) (else=0)
recode Policy_66 (6=1) (else=0)
recode Policy_67 (6=1) (else=0)
recode Policy_68 (6=1) (else=0)
recode Policy_69 (6=1) (else=0)
recode Policy_610 (6=1) (else=0)
recode Policy_611 (6=1) (else=0)
generate older_people_stayhome_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable older_people_stayhome_pastJune1 "When it comes to responding to the Coronavirus...issue a targetted stay-at-home order only for those age 65+ ...PAST June 1st"
tab older_people_stayhome_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (11=1) (else=0)
recode Policy_62 (11=1) (else=0)
recode Policy_63 (11=1) (else=0)
recode Policy_64 (11=1) (else=0)
recode Policy_65 (11=1) (else=0)
recode Policy_66 (11=1) (else=0)
recode Policy_67 (11=1) (else=0)
recode Policy_68 (11=1) (else=0)
recode Policy_69 (11=1) (else=0)
recode Policy_610 (11=1) (else=0)
recode Policy_611 (11=1) (else=0)
generate close_camps_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable close_camps_pastJune1 "When it comes to responding to the Coronavirus...close camps ...PAST June 1st"
tab close_camps_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (7=1) (else=0)
recode Policy_62 (7=1) (else=0)
recode Policy_63 (7=1) (else=0)
recode Policy_64 (7=1) (else=0)
recode Policy_65 (7=1) (else=0)
recode Policy_66 (7=1) (else=0)
recode Policy_67 (7=1) (else=0)
recode Policy_68 (7=1) (else=0)
recode Policy_69 (7=1) (else=0)
recode Policy_610 (7=1) (else=0)
recode Policy_611 (7=1) (else=0)
generate close_schools_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable close_schools_pastJune1 "When it comes to responding to the Coronavirus...close schools ...PAST June 1st"
tab close_schools_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (8=1) (else=0)
recode Policy_62 (8=1) (else=0)
recode Policy_63 (8=1) (else=0)
recode Policy_64 (8=1) (else=0)
recode Policy_65 (8=1) (else=0)
recode Policy_66 (8=1) (else=0)
recode Policy_67 (8=1) (else=0)
recode Policy_68 (8=1) (else=0)
recode Policy_69 (8=1) (else=0)
recode Policy_610 (8=1) (else=0)
recode Policy_611 (8=1) (else=0)
generate close_universities_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable close_universities_pastJune1 "When it comes to responding to the Coronavirus...close universities ...PAST June 1st"
tab close_universities_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (9=1) (else=0)
recode Policy_62 (9=1) (else=0)
recode Policy_63 (9=1) (else=0)
recode Policy_64 (9=1) (else=0)
recode Policy_65 (9=1) (else=0)
recode Policy_66 (9=1) (else=0)
recode Policy_67 (9=1) (else=0)
recode Policy_68 (9=1) (else=0)
recode Policy_69 (9=1) (else=0)
recode Policy_610 (9=1) (else=0)
recode Policy_611 (9=1) (else=0)
generate cancel_large_events_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable cancel_large_events_pastJune1 "When it comes to responding to the Coronavirus...cancel large events ...PAST June 1st"
tab cancel_large_events_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

split Policy_6, parse(,) destring
recode Policy_61 (13=1) (else=0)
recode Policy_62 (13=1) (else=0)
recode Policy_63 (13=1) (else=0)
recode Policy_64 (13=1) (else=0)
recode Policy_65 (13=1) (else=0)
recode Policy_66 (13=1) (else=0)
recode Policy_67 (13=1) (else=0)
recode Policy_68 (13=1) (else=0)
recode Policy_69 (13=1) (else=0)
recode Policy_610 (13=1) (else=0)
recode Policy_611 (13=1) (else=0)
generate wear_masks_pastJune1= Policy_61+ Policy_62+ Policy_63+ Policy_64+ Policy_65 + Policy_66+ Policy_67+ Policy_68+ Policy_69+ Policy_610+ Policy_611
label variable wear_masks_pastJune1 "When it comes to responding to the Coronavirus...wear masks ...PAST June 1st"
tab wear_masks_pastJune1
drop Policy_61 Policy_62 Policy_63 Policy_64 Policy_65 Policy_66 Policy_67 Policy_68 Policy_69 Policy_610 Policy_611

recode Policy_Stringency_all_policies (0=0 "do nothing") (1=1 "supports at least one SD measure") (2/9= 2 "supports 2+ SD measures"), generate(Policy_Stringency_cat)
tab Policy_Stringency_cat

**Childcare Recode
recode Childcare_13 (1=1 "Kids are still in school/daycare") (4=2 "Kids are home with me/partner") (5=3 "Kids are being watched by a grandparent") (6 7=4 "Other"), generate(childcare_source)
label variable childcare_source "Which of the following best describes what you are currently doing for childcare?" 
recode Childcare_1 (1=1 "Yes, have school-age kids") (4=0 "No"), generate(have_school_age_kids)

***Demographics******
recode Ideology_1 (1=1 "Democrat") (4=2 "Republican") (5 6=3 "Independent"), generate(Party_ID)
recode Ideology_5 (1=1 "far right") (4=2 "Center Right") (5=3 "neither right nor left") (6=4 "center left") (7=5 "far left"), generate(ideol_left_right_spectrum)
recode Ideology_8 (1 4= 0 "not planning to vote/not eligible") (5=1 "Trump") (12=2 "Biden") (11=3 "undecided") (10=4 "Other"), generate(vote_2020)
label variable vote_2020  "Who do you plan to vote in the 2020 Presidential election?"
gen birthyear= 2011-Demographic_3
gen age=2020-birthyear
gen under40= (age<40) if !missing(age)
gen over65 = (age>=65) if !missing(age)
recode Demographic_11 (1 17=1 "<$20,000") (18 19 = 2 "$20,000-$74,999") (20=3 "$75,000-$149,000") (21 22 23=4 "$150,000+"), generate(income_cat)
///////////////////////////
**Cultural Cognition********
//////////////////////////

**lower number means more libertarian; higher number more communitarian (or pro-gov intervention)
recode Culture_1_1_1 (1=1 "Agree Strongly") (2=2 "Agree") (3=3 "Neither Agree nor Disagree") (4=4 "Disagree") (5=5 "Disagree Strongly"), generate(CC_1)
label variable CC_1 "The government interferes far too much in our everyday lives" 
recode Culture_1_1_2 (1=5 "Agree Strongly") (2=4 "Agree") (3=3 "Neither Agree nor Disagree") (4=2 "Disagree") (5=1 "Disagree Strongly"), generate(CC_2)
label variable CC_2 "Sometimes government needs to make laws that protect people from hurting themselves (reverse coded)"
recode Culture_1_1_3 (1=1 "Agree Strongly") (2=2 "Agree") (3=3 "Neither Agree nor Disagree") (4=4 "Disagree") (5=5 "Disagree Strongly"), generate(CC_3)
label variable CC_3 "It’s not the government’s business to try to protect people from hurting themselves"
recode Culture_1_1_4 (1=1 "Agree Strongly") (2=2 "Agree") (3=3 "Neither Agree nor Disagree") (4=4 "Disagree") (5=5 "Disagree Strongly"), generate(CC_4)
label variable CC_4 "The government should stop telling people how to live their lives"
recode Culture_1_1_5 (1=5 "Agree Strongly") (2=4 "Agree") (3=3 "Neither Agree nor Disagree") (4=2 "Disagree") (5=1 "Disagree Strongly"), generate(CC_5)
label variable CC_5 "The government should do more to advance society’s goals even if that means limiting the freedom of choices of individuals (reverse coded)"
recode Culture_1_1_6 (1=5 "Agree Strongly") (2=4 "Agree") (3=3 "Neither Agree nor Disagree") (4=2 "Disagree") (5=1 "Disagree Strongly"), generate(CC_6)
label variable CC_6 "Government should put limits on the choices individuals can make so they do not get in the way of what is good for society (reverse coded)"

generate CC_Communitarian_Index=  CC_1 + CC_2 + CC_3 + CC_4 + CC_5 + CC_6

**CC_Index- ordinal scale
** -1=more libertarian; 1=more communitarian (pro-gov); 0= in btw
recode Culture_1_1_1 (1 2=-1 "Agree") (3=0 "Neither Agree nor Disagree") (4 5=1 "Disagree"), generate(CC_1_ord)
label variable CC_1_ord "The government interferes far too much in our everyday lives" 
recode Culture_1_1_2 (1 2=1 "Agree") (3=0 "Neither Agree nor Disagree") (4 5=-1 "Disagree"), generate(CC_2_ord)
label variable CC_2_ord "Sometimes government needs to make laws that protect people from hurting themselves (reverse coded)"
recode Culture_1_1_3 (1 2=-1 "Agree") (3=0 "Neither Agree nor Disagree") (4 5=1 "Disagree"), generate(CC_3_ord)
label variable CC_3_ord "It’s not the government’s business to try to protect people from hurting themselves"
recode Culture_1_1_4 (1 2=-1 "Agree ") (3=0 "Neither Agree nor Disagree") (4 5=1 "Disagree"), generate(CC_4_ord)
label variable CC_4_ord "The government should stop telling people how to live their lives"
recode Culture_1_1_5 (1 2=1 "Agree") (3=0 "Neither Agree nor Disagree") (4 5=-1 "Disagree"), generate(CC_5_ord)
label variable CC_5_ord "The government should do more to advance society’s goals even if that means limiting the freedom of choices of individuals (reverse coded)"
recode Culture_1_1_6 (1 2=1 "Agree") (3=0 "Neither Agree nor Disagree") (4 5=-1 "Disagree"), generate(CC_6_ord)
label variable CC_6_ord "Government should put limits on the choices individuals can make so they do not get in the way of what is good for society (reverse coded)"
tab CC_1_ord
tab CC_2_ord
tab CC_3_ord
tab CC_4_ord
tab CC_5_ord
tab CC_6_ord
generate CC_Communitarian_ord=  (CC_1_ord + CC_2_ord + CC_3_ord + CC_4_ord + CC_5_ord + CC_6_ord)/6
tab CC_Communitarian_ord
recode CC_Communitarian_ord ( -.8333333 -.6666667 -.5  -.3333333 -.1666667 = -1 "Libertarian leaning") (0=0 "neutral") ( .1666667 .3333333 .5  .6666667 .8333333  = 1 "Communitarian leaning"), generate(CC_Communitarian_ord2)

tab wear_masks_pastJune1 CC_Communitarian_ord2 , col chi2 
LEAST June |  RECODE of CC_Communitarian_ord
       1st | Libertari    neutral  Communita |     Total
-----------+---------------------------------+----------
         0 |       233        366        190 |       789 
           |     63.32      73.35      53.98 |     64.73 
-----------+---------------------------------+----------
         1 |       135        133        162 |       430 
           |     36.68      26.65      46.02 |     35.27 
-----------+---------------------------------+----------
     Total |       368        499        352 |     1,219 
           |    100.00     100.00     100.00 |    100.00 

          Pearson chi2(2) =  34.3753   Pr = 0.000


  s...wear |
  masks AT |       RECODE of Ideology_1
LEAST June |           (Ideology_1)
       1st |  Democrat  Republica  Independe |     Total
-----------+---------------------------------+----------
         0 |       298        308        186 |       792 
           |     58.32      70.64      67.39 |     64.76 
-----------+---------------------------------+----------
         1 |       213        128         90 |       431 
           |     41.68      29.36      32.61 |     35.24 
-----------+---------------------------------+----------
     Total |       511        436        276 |     1,223 
           |    100.00     100.00     100.00 |    100.00 

          Pearson chi2(2) =  16.7425   Pr = 0.000
		  
///**Media
*School free meals
split Media_16, parse(,) destring
recode Media_161 (1=1) (else=0)
recode Media_162 (1=1) (else=0)
recode Media_163 (1=1) (else=0)
recode Media_164 (1=1) (else=0)
recode Media_165 (1=1) (else=0)
recode Media_166 (1=1) (else=0)
generate food_bank= Media_161 + Media_162 + Media_163 + Media_164 + Media_165 + Media_166 
label variable food_bank "In the last two weeks have you (or other adults in your household) sought food assistance from ... a food bank"
tab food_bank if good_sample ==1
drop Media_161  Media_162  Media_163  Media_164  Media_165  Media_166 

split Media_16, parse(,) destring
recode Media_161 (2=1) (else=0)
recode Media_162 (2=1) (else=0)
recode Media_163 (2=1) (else=0)
recode Media_164 (2=1) (else=0)
recode Media_165 (2=1) (else=0)
recode Media_166 (2=1) (else=0)
generate not_sought_foodassist= Media_161 + Media_162 + Media_163 + Media_164 + Media_165 + Media_166 
label variable not_sought_foodassist "Have not sought food assistance in the last two weeks"
tab not_sought_foodassist if good_sample ==1
drop Media_161  Media_162  Media_163  Media_164  Media_165  Media_166 

split Media_16, parse(,) destring
recode Media_161 (4=1) (else=0)
recode Media_162 (4=1) (else=0)
recode Media_163 (4=1) (else=0)
recode Media_164 (4=1) (else=0)
recode Media_165 (4=1) (else=0)
recode Media_166 (4=1) (else=0)
generate soup_kitchen= Media_161 + Media_162 + Media_163 + Media_164 + Media_165 + Media_166 
label variable soup_kitchen "In the last two weeks have you (or other adults in your household) sought food assistance from ... a soup kitchen"
tab soup_kitchen if good_sample ==1
drop Media_161  Media_162  Media_163  Media_164  Media_165  Media_166 

split Media_16, parse(,) destring
recode Media_161 (7=1) (else=0)
recode Media_162 (7=1) (else=0)
recode Media_163 (7=1) (else=0)
recode Media_164 (7=1) (else=0)
recode Media_165 (7=1) (else=0)
recode Media_166 (7=1) (else=0)
generate EBT= Media_161 + Media_162 + Media_163 + Media_164 + Media_165 + Media_166 
label variable EBT "In the last two weeks have you (or other adults in your household) sought food assistance from ... EBT/food stamps"
tab EBT if good_sample ==1
drop Media_161  Media_162  Media_163  Media_164  Media_165  Media_166 

split Media_16, parse(,) destring
recode Media_161 (6=1) (else=0)
recode Media_162 (6=1) (else=0)
recode Media_163 (6=1) (else=0)
recode Media_164 (6=1) (else=0)
recode Media_165 (6=1) (else=0)
recode Media_166 (6=1) (else=0)
generate community_distribution= Media_161 + Media_162 + Media_163 + Media_164 + Media_165 + Media_166 
label variable community_distribution "In the last two weeks have you (or other adults in your household) sought food assistance from ... community distribution programs"
tab community_distribution if good_sample ==1
drop Media_161  Media_162  Media_163  Media_164  Media_165  Media_166 

split Media_16, parse(,) destring
recode Media_161 (5=1) (else=0)
recode Media_162 (5=1) (else=0)
recode Media_163 (5=1) (else=0)
recode Media_164 (5=1) (else=0)
recode Media_165 (5=1) (else=0)
recode Media_166 (5=1) (else=0)
generate school_free_meal= Media_161 + Media_162 + Media_163 + Media_164 + Media_165 + Media_166 
label variable school_free_meal "In the last two weeks have you (or other adults in your household) sought food assistance from ... a school district"
tab school_free_meal if good_sample ==1
drop Media_161  Media_162  Media_163  Media_164  Media_165  Media_166 

generate number_of_food_assist=school_free_meal+EBT+community_distribution+soup_kitchen+food_bank 

recode Media_17 (1=1 "yes, skipped meals") (2=0 "No, did not skip meals"), generate(food_insecurity_dummy)


***Sample to Include in Analysis*******
. tab gc

         gc |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,124       80.34       80.34
          2 |        188       13.44       93.78
          4 |         87        6.22      100.00
------------+-----------------------------------
      Total |      1,399      100.00

. recode gc (1=1 "good responses") (2 4=.) (.=2 "non-Qualtrics responses"), generate(g
> ood_sample)
(658 differences between gc and good_sample)

. tab good_sample

      RECODE of gc (gc) |      Freq.     Percent        Cum.
------------------------+-----------------------------------
         good responses |      1,124       74.59       74.59
non-Qualtrics responses |        383       25.41      100.00
------------------------+-----------------------------------
                  Total |      1,507      100.00

. recode good_sample (1 2= 1), generate(good_sample_dummy)
(383 differences between good_sample and good_sample_dummy)

tab female  if good_sample==1
tab female  if good_sample==2

sum age if good_sample==1
sum age if good_sample==2

tab race_cat if good_sample==1
tab race_cat if good_sample==2

drop if good_sample==2
save "/Users/af475569/Dropbox/M4A_School Reopening_Analysis/_M4A Experiment/COVID_Survey Data_analysis_Qualtrics_sample_only.dta"

//Kevin's code
*create age variables
gen birthyear= 2011-Demographic_3
gen age=2020-birthyear
gen under40= (age<40) if !missing(age)
gen over65 = (age>=65) if !missing(age)
*create “any treat” summy
gen any_treat = studycondition>0
 
*create Dem ID
gen pid_dem =  Ideology_1==1 if !missing(Ideology_1)
 
*basic regressions
reg support_M4A_dummy any_treat
reg support_M4A_dummy any_treat pid_dem
reg support_M4A_dummy any_treat under40 over65

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

**FINAL M4A Analysis**

sum HR01new_reverse_code if good_sample==1

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |      1,124    6.532918    3.134529          1         10


. bysort studycondition: sum HR01new_reverse_code  if good_sample==1

------------------------------------------------------------------------------
-> studycondition = control

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        374    6.435829     3.19767          1         10

------------------------------------------------------------------------------
-> studycondition = arm 2

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        374    6.529412    3.082936          1         10

------------------------------------------------------------------------------
-> studycondition = arm 1

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        376    6.632979    3.127236          1         10


bysort any_treat: sum HR01new_reverse_code  if good_sample==1

---------------------------------------------------------------------------> any_treat = 0

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        374    6.435829     3.19767          1         10

-----------------------------------------------------------------------------> any_treat = 1

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
HR01new_re~e |        750    6.581333    3.103583          1         10

. ttest HR01new_reverse_code, by(any_treat), if good_sample==1

Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
       0 |     374    6.435829    .1653476     3.19767    6.110699    6.760959
       1 |     750    6.581333    .1133268    3.103583    6.358857    6.803809
---------+--------------------------------------------------------------------
combined |   1,124    6.532918    .0934952    3.134529    6.349473    6.716363
---------+--------------------------------------------------------------------
    diff |           -.1455045    .1984625               -.5349039     .243895
------------------------------------------------------------------------------
    diff = mean(0) - mean(1)                                      t =  -0.7332
Ho: diff = 0                                     degrees of freedom =     1122

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.2318         Pr(|T| > |t|) = 0.4636          Pr(T > t) = 0.7682

. regress HR01new_reverse_code i.studycondition if good_sample==1

      Source |       SS           df       MS      Number of obs   =     1,124
-------------+----------------------------------   F(2, 1121)      =      0.37
       Model |    7.294601         2   3.6473005   Prob > F        =    0.6903
    Residual |  11026.4874     1,121  9.83629565   R-squared       =    0.0007
-------------+----------------------------------   Adj R-squared   =   -0.0011
       Total |   11033.782     1,123   9.8252734   Root MSE        =    3.1363

--------------------------------------------------------------------------------
HR01new_reve~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
studycondition |
        arm 2  |   .0935829    .229348     0.41   0.683    -.3564168    .5435826
        arm 1  |   .1971498   .2290428     0.86   0.390    -.2522511    .6465508
               |
         _cons |   6.435829   .1621735    39.68   0.000     6.117631    6.754027
--------------------------------------------------------------------------------

. regress HR01new_reverse_code any_treat if good_sample==1

      Source |       SS           df       MS      Number of obs   =     1,124
-------------+----------------------------------   F(1, 1122)      =      0.54
       Model |  5.28346876         1  5.28346876   Prob > F        =    0.4636
    Residual |  11028.4986     1,122  9.82932135   R-squared       =    0.0005
-------------+----------------------------------   Adj R-squared   =   -0.0004
       Total |   11033.782     1,123   9.8252734   Root MSE        =    3.1352

------------------------------------------------------------------------------
HR01new_re~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
   any_treat |   .1455045   .1984625     0.73   0.464     -.243895    .5349039
       _cons |   6.435829    .162116    39.70   0.000     6.117744    6.753914
------------------------------------------------------------------------------


recode HR01new_reverse_code (1/4=-1 "favor private provision") (5=0 "neutral") (6/10=1 "favor public provision"), generate(HR01_3cat)

. tab HR01_3cat

              RECODE of |
   HR01new_reverse_code |
   (RECODE of HR_01_NEW |
           (HR_01_NEW)) |      Freq.     Percent        Cum.
------------------------+-----------------------------------
favor private provision |        385       31.79       31.79
                neutral |         75        6.19       37.99
 favor public provision |        751       62.01      100.00
------------------------+-----------------------------------
                  Total |      1,211      100.00

. ologit HR01_3cat any_treat if good_sample==1

Iteration 0:   log likelihood = -945.33609  
Iteration 1:   log likelihood = -945.03503  
Iteration 2:   log likelihood = -945.03501  

Ordered logistic regression                     Number of obs     =      1,124
                                                LR chi2(1)        =       0.60
                                                Prob > chi2       =     0.4378
Log likelihood = -945.03501                     Pseudo R2         =     0.0003

------------------------------------------------------------------------------
   HR01_3cat |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
   any_treat |   .0991894   .1276568     0.78   0.437    -.1510134    .3493922
-------------+----------------------------------------------------------------
       /cut1 |  -.6740608   .1061098                     -.8820323   -.4660894
       /cut2 |  -.3935851   .1047543                     -.5988998   -.1882703
------------------------------------------------------------------------------

. ologit HR01_3cat i.studycondition  if good_sample==1

Iteration 0:   log likelihood = -945.33609  
Iteration 1:   log likelihood = -944.99881  
Iteration 2:   log likelihood = -944.99878  

Ordered logistic regression                     Number of obs     =      1,124
                                                LR chi2(2)        =       0.67
                                                Prob > chi2       =     0.7137
Log likelihood = -944.99878                     Pseudo R2         =     0.0004

--------------------------------------------------------------------------------
     HR01_3cat |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
studycondition |
        arm 2  |   .1190231   .1475031     0.81   0.420    -.1700777     .408124
        arm 1  |   .0792561   .1474791     0.54   0.591    -.2097976    .3683099
---------------+----------------------------------------------------------------
         /cut1 |  -.6740715   .1061101                     -.8820434   -.4660995
         /cut2 |   -.393579   .1047544                      -.598894   -.1882641
--------------------------------------------------------------------------------

regress HR01new_reverse_code any_treat#i.Party_ID if good_sample==1

regress HR01new_reverse_code i.studycondition#i.Party_ID if good_sample==1

      Source |       SS           df       MS      Number of obs   =     1,124
-------------+----------------------------------   F(8, 1115)      =      3.87
       Model |  298.174367         8  37.2717958   Prob > F        =    0.0002
    Residual |  10735.6077     1,115  9.62834768   R-squared       =    0.0270
-------------+----------------------------------   Adj R-squared   =    0.0200
       Total |   11033.782     1,123   9.8252734   Root MSE        =     3.103

--------------------------------------------------------------------------------------
HR01new_reverse_code |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------------+----------------------------------------------------------------
      studycondition#|
            Party_ID |
 control#Republican  |  -.5314043    .370031    -1.44   0.151     -1.25744    .1946313
control#Independent  |   1.051135   .4122616     2.55   0.011     .2422388    1.860031
     arm 2#Democrat  |  -.0426291   .3454405    -0.12   0.902    -.7204158    .6351576
   arm 2#Republican  |  -.1119954   .3581648    -0.31   0.755    -.8147483    .5907575
  arm 2#Independent  |    1.03253   .4223227     2.44   0.015     .2038934    1.861167
     arm 1#Democrat  |   .6129223   .3477535     1.76   0.078    -.0694027    1.295247
   arm 1#Republican  |  -.3463431   .3546933    -0.98   0.329    -1.042285    .3495985
  arm 1#Independent  |   .6819128   .4205598     1.62   0.105    -.1432651    1.507091
                     |
               _cons |    6.36747   .2408362    26.44   0.000     5.894927    6.840013
--------------------------------------------------------------------------------------


tab M4A_Incrementalism_Private
ologit M4A_Incrementalism_Private i.studycondition  if good_sample==1
ologit M4A_Incrementalism_Private any_treat#i.Party_ID  if good_sample==1


recode M4A_Incrementalism_Private (0 1=0 "private or incrementalism") (2=1 "M4A"), generate(M4A_truebelievers)
logistic M4A_truebelievers studycondition if good_sample==1
logistic M4A_truebelievers any_treat  if good_sample==1

recode M4A_Incrementalism_Private (0 1=0 "private or incrementalism") (2=1 "M4A"), generate(M4A_truebelievers)

**support_M4A_dummy
logistic support_M4A_dummy any_treat  if good_sample==1

Logistic regression                             Number of obs     =      1,124
                                                LR chi2(1)        =       3.86
                                                Prob > chi2       =     0.0493
Log likelihood = -702.15602                     Pseudo R2         =     0.0027

-----------------------------------------------------------------------------------
support_M4A_dummy | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
        any_treat |   1.302778   .1746819     1.97   0.049       1.0017    1.694349
            _cons |   1.791045   .1931453     5.40   0.000     1.449817    2.212583
-----------------------------------------------------------------------------------

logistic support_M4A_dummy i.studycondition  if good_sample==1
Logistic regression                             Number of obs     =      1,124
                                                LR chi2(2)        =       3.95
                                                Prob > chi2       =     0.1391
Log likelihood = -702.11488                     Pseudo R2         =     0.0028

-----------------------------------------------------------------------------------
support_M4A_dummy | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
   studycondition |
           arm 2  |   1.273392   .1982873     1.55   0.121     .9384615    1.727856
           arm 1  |   1.332958   .2082657     1.84   0.066     .9813456    1.810552
                  |
            _cons |   1.791045   .1931453     5.40   0.000     1.449817    2.212583
-----------------------------------------------------------------------------------
Note: _cons estimates baseline odds.

**Distribution across study arms
recode age (0/24=0 "<25") (25/44=1 "25-44") (45/64=2 "45-64") (65/100=3 "65+"), generate(age_cat)

tab female studycondition, col chi2
tab race_cat studycondition, col chi2
tab income_cat studycondition, col chi2
tab Party_ID studycondition, col chi2
tab age_cat studycondition, col chi2
ttest age, by(studycondition)

**Bivariates
tab support_M4A_dummy  study_arms, col chi2
tab support_M4A_dummy  any_treat , col chi2

**FINAL MODELS

//Main

logistic support_M4A_dummy i.study_arms
outreg2 using M4A_main, replace excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy i.study_arms female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy any_treat 
outreg2 using M4A_main, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main, excel  bdec(2) level(95) eform cti(odds ratio) ci

//Main with Coefficients

logistic support_M4A_dummy i.study_arms
outreg2 using M4A_main, replace excel  bdec(2) level(95) ci
logistic support_M4A_dummy i.study_arms female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main, excel  bdec(2) level(95)  ci
logistic support_M4A_dummy any_treat 
outreg2 using M4A_main, excel  bdec(2) level(95)  ci
logistic support_M4A_dummy any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main, excel  bdec(2) level(95)  ci

//Party_ID Interaction

logistic support_M4A_dummy i.study_arms##i.Party_ID
outreg2 using M4A_interact_PartyID, replace excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy i.study_arms##i.Party_ID female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_interact_PartyID, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy any_treat##i.Party_ID
outreg2 using M4A_interact_PartyID, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy any_treat##i.Party_ID female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_interact_PartyID, excel  bdec(2) level(95) eform cti(odds ratio) ci

//lost_insurance_dummy Interaction

logistic support_M4A_dummy i.study_arms##lost_insurance_dummy
outreg2 using M4A_interact_lost_insure, replace excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy i.study_arms##lost_insurance_dummy female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_interact_lost_insure, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy any_treat##lost_insurance_dummy
outreg2 using M4A_interact_lost_insure, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic support_M4A_dummy any_treat##lost_insurance_dummy female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_interact_lost_insure, excel  bdec(2) level(95) eform cti(odds ratio) ci

//Additional Measures (HR01new_reverse_code)
regress HR01new_reverse_code i.study_arms 
outreg2 using M4A_HR01new_reverse_code, replace excel  bdec(2) level(95) ci
regress HR01new_reverse_code i.study_arms female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_HR01new_reverse_code, excel  bdec(2) level(95) ci
regress HR01new_reverse_code any_treat 
outreg2 using M4A_HR01new_reverse_code, excel  bdec(2) level(95) ci
regress HR01new_reverse_code any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_HR01new_reverse_code, excel  bdec(2) level(95) ci
 
//Additional Measures (HR01_3cat)
ologit HR01_3cat i.study_arms 
outreg2 using M4A_HR01_3cat, replace excel  bdec(2) level(95) eform cti(odds ratio) ci
ologit HR01_3cat i.study_arms female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_HR01_3cat, excel  bdec(2) level(95) eform cti(odds ratio) ci
ologit HR01_3cat any_treat 
outreg2 using M4A_HR01_3cat, excel  bdec(2) level(95) eform cti(odds ratio) ci
ologit HR01_3cat any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_HR01_3cat, excel  bdec(2) level(95) eform cti(odds ratio) ci

//Additional Measures (HR01_3cat)
logistic more_supportive_M4A i.study_arms 
outreg2 using M4A_more_supportive_M4A, replace excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic more_supportive_M4A i.study_arms female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_more_supportive_M4A, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic more_supportive_M4A any_treat 
outreg2 using M4A_more_supportive_M4A, excel  bdec(2) level(95) eform cti(odds ratio) ci
logistic more_supportive_M4A any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_more_supportive_M4A, excel  bdec(2) level(95) eform cti(odds ratio) ci
 
**Opinion_change_M4A

. tab Opinion_change_M4A

    Has Coronavirus made you think |
  more about whether the US should |
                  move towards a “ |      Freq.     Percent        Cum.
-----------------------------------+-----------------------------------
                    More Favorable |        657       54.25       54.25
                    Less Favorable |        221       18.25       72.50
Has not affected my opinion at all |        333       27.50      100.00
-----------------------------------+-----------------------------------
                             Total |      1,211      100.00

							 
recode Opinion_change_M4A (1=1 "more favorable") (2 3=0 "no change/less favorable"), generate(more_supportive_M4A)

***Robustness Checks**
//Using Study Arm Dummies
recode study_arms (2=1 "COVID-19 prime") (0 1=0 "control"), generate(COVID_arm)
recode study_arms (1=1 "Airbnb prime") (0 2=0 "control"), generate(Airbnb_arm)

logistic support_M4A_dummy COVID_arm
outreg2 using M4A_main_treatment_dummies, replace excel  bdec(2) level(95) ci
logistic support_M4A_dummy COVID_arm female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_treatment_dummies, excel  bdec(2) level(95)  ci
logistic support_M4A_dummy Airbnb_arm 
outreg2 using M4A_main_treatment_dummies, excel  bdec(2) level(95)  ci
logistic support_M4A_dummy Airbnb_arm female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_treatment_dummies, excel  bdec(2) level(95)  ci

**M4A "DK" removed analysis
recode support_M4A_likert (7=.), generate(support_M4A_likert_miss)

tab support_M4A_likert_miss

  RECODE of |
support_M4A |
    _likert |
 (RECODE of |
      HR_08 |
   (HR_08)) |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        442       39.71       39.71
          2 |        372       33.42       73.14
          3 |        164       14.73       87.87
          4 |        135       12.13      100.00
------------+-----------------------------------
      Total |      1,113      100.00

recode support_M4A_likert_miss (1 2=1 "support M4A") (3 4=0 "oppose M4A"), generate(support_M4A_dummy_miss)

logistic support_M4A_dummy_miss i.study_arms
outreg2 using M4A_main_DK, replace excel  bdec(2) level(95)  
logistic support_M4A_dummy_miss i.study_arms female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_DK, excel  bdec(2) level(95)
logistic support_M4A_dummy_miss any_treat 
outreg2 using M4A_main_DK, excel  bdec(2) level(95)
logistic support_M4A_dummy_miss any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_DK, excel  bdec(2) level(95) 

logistic support_M4A_dummy_miss COVID_arm
outreg2 using M4A_main_treatment_dummies_logit, replace excel  bdec(2) level(95) ci
logistic support_M4A_dummy_miss COVID_arm female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_treatment_dummies_logit, excel  bdec(2) level(95)  ci
logistic support_M4A_dummy_miss Airbnb_arm 
outreg2 using M4A_main_treatment_dummies_logit, excel  bdec(2) level(95)  ci
logistic support_M4A_dummy_miss Airbnb_arm female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_treatment_dummies_logit, excel  bdec(2) level(95)  ci

ologit support_M4A_likert_miss COVID_arm
outreg2 using M4A_main_treatment_dummies_ologit, replace excel  bdec(2) level(95) ci
ologit support_M4A_likert_miss COVID_arm female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_treatment_dummies_ologit, excel  bdec(2) level(95)  ci
ologit support_M4A_likert_miss Airbnb_arm 
outreg2 using M4A_main_treatment_dummies_ologit, excel  bdec(2) level(95)  ci
ologit support_M4A_likert_miss Airbnb_arm female i.age_cat i.race_cat i.income_cat i.Party_ID
outreg2 using M4A_main_treatment_dummies_ologit, excel  bdec(2) level(95)  ci

//Testing each study arm separately

recode study_arms (0=0 "control") (1=1 "Airbnb arm") (2=.), generate(Airbnb_arm_dummy)
recode study_arms (0=0 "control") (1=.) (2=1 "COVID arm"), generate(COVID_arm_dummy)

COVID_arm_dummy Airbnb_arm_dummy

logistic support_M4A_dummy COVID_arm_dummy
logistic support_M4A_dummy Airbnb_arm_dummy

logistic support_M4A_dummy_miss COVID_arm_dummy
logistic support_M4A_dummy_miss Airbnb_arm_dummy

logistic M4A_truebelievers COVID_arm 
logistic M4A_truebelievers Airbnb_arm 


ologit support_M4A_likert_miss COVID_arm_dummy
ologit support_M4A_likert_miss Airbnb_arm_dummy

ologit M4A_Incrementalism_Private COVID_arm
ologit M4A_Incrementalism_Private Airbnb_arm

reg HR01new_reverse_code COVID_arm_dummy
reg HR01new_reverse_code Airbnb_arm_dummy

logistic More_fav_M4A i.PartyID_rec i.age_cat i.race_cat i.income_cat female received_pandemic_support have_school_age_kids lost_job lost_insurance_dummy


**Ologit Improved
ologit support_M4A_DK any_treat
outreg2 using M4A_main_treatment_dummies_ologit_, replace excel  bdec(2) level(95) ci
ologit support_M4A_DK  any_treat female i.age_cat i.race_cat i.income_cat i.Party_ID lost_insurance_dummy food_insecurity_dummy lost_job
outreg2 using M4A_main_treatment_dummies_ologit_, excel  bdec(2) level(95) ci
ologit support_M4A_DK  any_treat any_treat##i.Party_ID 
outreg2 using M4A_main_treatment_dummies_ologit_, excel  bdec(2) level(95) ci
ologit support_M4A_DK  any_treat any_treat##i.Party_ID female i.age_cat i.race_cat i.income_cat i.Party_ID lost_insurance_dummy food_insecurity_dummy lost_job
outreg2 using M4A_main_treatment_dummies_ologit_, excel  bdec(2) level(95) ci
ologit support_M4A_DK  any_treat any_treat##lost_job 
outreg2 using M4A_main_treatment_dummies_ologit_, excel  bdec(2) level(95) ci
ologit support_M4A_DK  any_treat any_treat##lost_job female i.age_cat i.race_cat i.income_cat i.Party_ID lost_insurance_dummy food_insecurity_dummy lost_job
outreg2 using M4A_main_treatment_dummies_ologit_, excel  bdec(2) level(95) ci


outreg2 using M4A_main_treatment_dummies_ologit_, excel  bdec(2) level(95)  ci
ologit support_M4A_DK COVID_arm_dummy
ologit support_M4A_DK Airbnb_arm_dummy
