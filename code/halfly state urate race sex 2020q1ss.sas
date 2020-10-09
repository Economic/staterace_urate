**state run for unemployment rate and unwgted LF level , CPS basic 16 of age +;
*Using race5 now because of data update;
*Limited to state/race categories with sample size of at least 700;

***Jin runs this for EARN during the lockdown, the original pgm was provided by Julia W;

libname d 'Y:\cpsmon\cpsquarter\newvar2';
%let outf="R:\new_R_drive_structure\EARN\State_Race Unemployment\2020 Q1\urate_race q1_2020.xlsx";
options obs=max symbolgen;
       

%macro state(yyyy);
      /*plug in 4-digit year period you want to study*/
%if &yyyy<=2014 %then %do;
proc format;     /*by 4 regions in short form*/
value states 
      11=me 12=nh 13=vt 14=ma 15=ri 16=ct 21=ny 22=nj 23=pa 
      31=oh 32=in 33=il 34=mi 35=wi 41=mn 42=ia 43=mo 44=nd 45=sd 46=ne 47=ks 
      51=de 52=md 53=dc 54=va 55=wv 56=nc 57=sc 58=ga 59=fl 61=ky 62=tn 63=al 64=ms 71=ar 72=la 73=ok 74=tx 
      81=mt 82=id 83=wy 84=co 85=nm 86=az 87=ut 88=nv 91=wa 92=or 93=ca 94=ak 95=hi;

proc format;     /*by 9 divisions in full name*/
value statel 
      11=Maine 12=New Hampshire 13=Vermont 14=Massachusetts 15=Rhode Island 16=Connecticut 
      21=New York 22=New Jersey 23=Pennsylvania 
      31=Ohio 32=Indiana 33=Illinois 34=Michigan 35=Wisconsin  
      41=Minnesota 42=Iowa 43=Missouri 44=North Dakota 45=South Dakota 46=Nebraska 47=Kansas 
      51=Delaware 52=Maryland 53=District Of Columbia 54=Virginia 55=West Virginia 56=North Carolina 57=South Carolina 58=Georgia 59=Florida 
      61=Kentucky 62=Tennessee 63=Alabama 64=Mississippi 
      71=Arkansas 72=Louisiana 73=Oklahoma 74=Texas 
      81=Montana 82=Idaho 83=Wyoming 84=Colorado 85=New Mexico 86=Arizona 87=Utah 88=Nevada 
      91=Washington 92=Oregon 93=California 94=Alaska 95=Hawaii;
%end;
%else %do;      /*thus, starting 2015*/
proc format;   
value states 
      23=me 33=nh 50=vt 25=ma 44=ri 09=ct 36=ny 34=nj 42=pa 
      39=oh 18=in 17=il 26=mi 55=wi 27=mn 19=ia 29=mo 38=nd 46=sd 31=ne 20=ks 
      10=de 24=md 11=dc 51=va 54=wv 37=nc 45=sc 13=ga 12=fl 21=ky 47=tn 01=al 28=ms 05=ar 22=la 40=ok 48=tx 
      30=mt 16=id 56=wy 08=co 35=nm 04=az 49=ut 32=nv 53=wa 41=or 06=ca 02=ak 15=hi;

proc format;
value statel 
      23=Maine 33=New Hampshire 50=Vermont 25=Massachusetts 44=Rhode Island 09=Connecticut 
      36=New York 34=New Jersey 42=Pennsylvania 
      39=Ohio 18=Indiana 17=Illinois 26=Michigan 55=Wisconsin  
      27=Minnesota 19=Iowa 29=Missouri 38=North Dakota 46=South Dakota 31=Nebraska 20=Kansas 
      10=Delaware 24=Maryland 11=District Of Columbia 51=Virginia 54=West Virginia 37=North Carolina 45=South Carolina 13=Georgia 12=Florida 
      21=Kentucky 47=Tennessee 01=Alabama 28=Mississippi 
      05=Arkansas 22=Louisiana 40=Oklahoma 48=Texas 
      30=Montana 16=Idaho 56=Wyoming 08=Colorado 35=New Mexico 04=Arizona 49=Utah 32=Nevada 
      53=Washington 41=Oregon 06=California 02=Alaska 15=Hawaii;
%end;
%mend;

*For just a quarterly update change this to current and previous quarter;
%state(2020);
data P0;
set d.cps20q1 (keep=cmpwgt empstat state age sex race5 month where=(age>=16));
       
cmpwgt=cmpwgt/3;          /*The denominator was 6, Jin edits it to 3 since this is qtly data. The change only affects in counts, NOT rates*/  
         
if race5=1 then rc='white          ';
  else if race5=2 then rc='black';
  else if race5=3 then rc='hispanic';
  else if race5=4 then rc='oAsian';
  else rc='Other';

if sex=1 then sexc=' male            ';
  else sexc='female';

if 1<=empstat<=2 then do;
  lbfce=1;
  if empstat=2 then unemp=1;
    else unemp=0;
end;

statec=put(state, states.);
statename=put(state, statel.);
run;

%state(2019);

data P1;
set d.cps19q4 (keep=cmpwgt empstat state age sex race5 month where=(age>=16));
       
cmpwgt=cmpwgt/3;          /*The denominator was 6, Jin edits it to 3 since this is qtly data. The change only affects in counts, NOT rates*/             
         
if race5=1 then rc='white          ';
  else if race5=2 then rc='black';
  else if race5=3 then rc='hispanic';
  else if race5=4 then rc='oAsian';
  else rc='Other';

if sex=1 then sexc=' male            ';
  else sexc='female';

if 1<=empstat<=2 then do;
  lbfce=1;
  if empstat=2 then unemp=1;
    else unemp=0;
end;

statec=put(state, states.);
statename=put(state, statel.);
run;

data P2;
set P0 P1;
run;

*urates;
proc means data=P2 noprint;
var unemp;
class statec sexc rc;
weight cmpwgt;
output out=uneP2 mean=urtP;

proc sort data=P2;
by statec sexc rc;
proc sort data=uneP2;
by statec sexc rc;
run;


*This dataset is in same format and order as excel spreadsheet;
data unemp2 (keep=statec sexc rc urtP _freq_);
set uneP2;
if _freq_<=700 then urtP=.;
if statec=' ' then statec='USA  ';
if sexc=' ' then sexc=' All sexes  ';
if rc=' ' then rc=' All races  ';
if rc="Other  " then delete;
run;

proc export data=unemp2
	outfile =&outf
  	DBMS=XLSX replace;
    sheet='2019Q4 2020Q1 CPS w700obs';
run;


**Not needed for updates ***************;


*unweighted sample sizes;
proc means data=P2 noprint;
var lbfce;
class statec sexc rc;
output out=lbfcP2 (drop=_freq_ _type_) sum=lbfcP;

proc sort data=lbfcP2;
by statec sexc rc;

proc print;
title 'avg unemployment rate by sex, race state, pooled 2019qt4-2020qt1';

run;
/*
data unemp_LF700;
set unemp2;
if lbfcP>=700;
run;
proc contents data=unemp2;
run;

data unemp2 (keep=statec sexc rc urtP);
set uneP2;

if statec=' ' then statec=' USA';
if sexc=' ' then sexc=' All sexes';
if rc=' ' then rc=' All races';
if rc="Other" then delete;
run;

data unemp2;
set unemp2;
rename urtP=urtP2;
run;
*/
/*
proc export data=lbfcP2
	outfile =&outf
  	DBMS=excel replace;
    sheet='2014 Q4 LF SS';
run;
/*
proc sort data=unemp2 ;
by statec sexc rc;
proc sort data=lbfcP2 ;
by statec sexc rc;
run;


data combined;
merge unemp2 lbfcP2;
by statec sexc rc;
*Find average margin of error for last 4 quarters
 I decided to use labor force sample size instead (avgss);

moe1 = 1.96*((urtp1*(1-urtp1))/lbfcp1)**0.5;
moe2 = 1.96*((urtp3*(1-urtp3))/lbfcp3)**0.5;
moe3 = 1.96*((urtp5*(1-urtp5))/lbfcp5)**0.5;
moe4 = 1.96*((urtp6*(1-urtp6))/lbfcp6)**0.5;
*make sure at least 1 person is reporting unemployed
otherwise moes get skewed;
if (moe1>0 and moe2>0 and moe3>0 and moe4>0) then 
  avgmoe = (moe1+moe2+moe3+moe4)/4;
  else avgmoe=1;
avgss = (lbfcp1+lbfcp3+lbfcp5+lbfcp6)/4;
run;

data combined;
 set combined;
 by statec;
 if (first.statec) then do; 
   stateratep1=urtp1;
   stateratep4=urtp4;
   end;
 retain stateratep1 stateratep4;
run;

data combined_under2;
set combined;
if avgss<700 then do;
    urtp1=.;
    urtp2=.;
	urtp3=.;
	urtp4=.;
	urtp5=.;
	urtp6=.;
	end;
if rc="Other" then delete;
run; 

proc export data=combined_under2 (keep=statec sexc rc urtp1 urtp2 urtp3 urtp4 
                                  urtp5 urtp6 stateratep1 stateratep4)
            outfile=&outf          
            DBMS=excel replace;
            sheet='cps 6m est LF700';
run;
     
proc export data=combined
	outfile =&outf
  	DBMS=excel replace;
    sheet='6 month all data ';
run;

** testing;
