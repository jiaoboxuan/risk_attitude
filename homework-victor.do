/* 
Code for Victor Jiao
Note: 
- Professor Harrison's provided template is corrupted for no given reason,
so I'm replicating his template in a separate do-file. 
- I will provide as much description as necessary to explain the programming
operations, but as the assignment requirements suggest, anyone should not have
to read my do-file to understand my actions.

*/

**# Setup
* change relative working directory
* NOTE: This needs to be changed when running on a different device. On a MacBook, the slashes must be forward instead of backward. 
cd "C:\Users\bjiao\OneDrive - The University of Chicago\Desktop\College\ECON 21160\Week 7 (Harrison)\homework"

* log the file
log using "homework-victor.smcl", replace

* configurations and certifications
capture: version 18
set more off
capture: set processors 1
set scheme stcolor
capture: set scheme stcolor
graph set window fontface "Candara"

* install esttab
ssc install estout

* tell us what version ran
about

* read in the homework data
use dohmen, clear

**# Descriptive functions
* description of a few variables that may be
* useful to the regression
* run when necessary
describe row_hi row_lo
describe crra_hi crra_lo
summarize row_hi row_lo risk_attitude
summarize crra_hi crra_lo risk_attitude


* preserve the dohmen dataset from being directly edited
preserve

**# Task 1
intreg row_lo row_hi risk_attitude
estimates store homoskedastic_model

* export into LaTeX
esttab homoskedastic_model using "homoskedastic_model.tex", replace se title ("Interval regression between row switch and risk attitude, homoskedastic") label keep(risk_attitude _cons) stats(ll N, labels("Log-Likelihood" "Observations")) star(* 0.10 ** 0.05 *** 0.01) nonumber

**# Task 2
intreg row_lo row_hi risk_attitude, het(crra_mid)
estimates store heteroskedastic_model

* export into LaTeX
esttab heteroskedastic_model using "heteroskedastic_model.tex", replace se title ("Interval regression between row switch and risk attitude, heteroskedastic") label keep(risk_attitude _cons) stats(ll N, labels("Log-Likelihood" "Observations")) star(* 0.10 ** 0.05 *** 0.01) nonumber

* We can compare the heteroskedastic and homoskedastic model by running an lrtest
lrtest homoskedastic_model heteroskedastic_model

**# Task 3
* repeating the estimation in Task 1 but using CRRA as a dependent variable
intreg crra_lo crra_hi risk_attitude
estimates store crra_homoskedastic_model

* export into LaTeX
esttab crra_homoskedastic_model using "crra_homoskedastic_model.tex", replace se title ("Interval regression between CRRA estimations and risk attitude, homoskedastic") label keep(risk_attitude _cons) stats(ll N, labels("Log-Likelihood" "Observations")) star(* 0.10 ** 0.05 *** 0.01) nonumber

* shows how predicted mean of CRRA varies with the hypothetical survey response level, showing 95% confidence intervals on this prediction from the estimated model
margins, at(risk_attitude=(0(1)10)) predict(xb)


* save the edited dataset in a separate file
save "dohmen_updated.dta", replace

* restore original dohmen
restore

**# Task 4
* preserve again, as this task requires clearing the data
preserve

* interval regression using CRRA intervals, like in Task 3
intreg crra_lo crra_hi risk_attitude

* Store the estimated coefficients and sigma
scalar beta0 = _b[_cons]
scalar beta1 = _b[risk_attitude]
scalar sigma = exp(_b[/lnsigma])

* Create a dataset for simulation
clear
set obs 11
generate risk_attitude = _n - 1

* Calculate predicted means for each risk_attitude level
generate pred_mean = beta0 + beta1 * risk_attitude

* simulate CRRA values for each risk_attitude level
set seed 12345
expand 1000
bysort risk_attitude: generate sim_id = _n
generate sim_crra = pred_mean + sigma * invnorm(uniform())

* calculate mean and 95% confidence intervals
bysort risk_attitude: egen mean_crra = mean(sim_crra)
bysort risk_attitude: egen p2_5 = pctile(sim_crra), p(2.5)
bysort risk_attitude: egen p97_5 = pctile(sim_crra), p(97.5)

* Keep only one observation per risk_attitude level
bysort risk_attitude: keep if _n == 1

* visualize the results
twoway (line mean_crra risk_attitude, sort) ///
       (rcap p97_5 p2_5 risk_attitude, sort), ///
       ytitle("Predicted CRRA") ///
       xtitle("Risk Attitude Score") ///
       title("Predicted Mean CRRA with 95% Confidence Intervals") ///
       legend(off)

list risk_attitude mean_crra p2_5 p97_5, clean noobs
	   
* save the charts
graph export "crra_homoskedastic_model_predicted_graph.png", replace


* restore previous data state
restore

**# Finishing up
* closes log file, translate into PDF
log close
translate homework-victor.smcl homework-victor.log, replace
translate homework-victor.smcl homework-victor.pdf, replace

