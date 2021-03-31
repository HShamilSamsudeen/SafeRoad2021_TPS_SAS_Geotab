libname wip "/home/u50039828/TPS - Safe Roads Competition/Work_in_progress";
run;

*Accessing the data;
options validvarname=v7;
proc import datafile="/home/u50039828/TPS - Safe Roads Competition/KSI.csv"
		dbms = csv
		out = wip.ksi
		replace;
		guessingrows=max;
run;

proc contents data= wip.ksi varnum;
run;

proc sort data=wip.ksi 
	out=wip.ksi_nodups
	nodupkey;
	by _all_;
run;

proc print data =wip.ksi_nodups (obs=50);
run;

*Analysing data on Fatal Accidents that caused Major Injuries from 2010 to 2019;
data wip.ksi_fatal_major;
set wip.ksi_nodups; 
where ACCLASS = "Fatal" and INJURY = "Major";
run;

proc freq data=wip.ksi_fatal_major nlevels;
table _char_ /noprint;
table _numeric_ /noprint;
run;

title "Barchart depicting KSI cases from 2010 to 2019 with Fatal Accidents that caused Major Injuries.";
proc freq data=wip.ksi_fatal_major;
	table Acclass*Year /nocum nopercent plots=freqplot;
run;


%Macro Yr(Year);
Title "Details of Fatal Accidents with major injuries caused by aggressing driving in the City of Toronto in &Year";
proc print data=wip.ksi_fatal_major;
where AG_DRIV="Yes" and Year=&Year;
run;

Title "Fatal Accidents with major injuries caused by aggressing driving - locations in the City of Toronto in &Year";
proc sgmap plotdata= wip.ksi_fatal_major (where=(AG_DRIV="Yes" and Year=&Year));
   openstreetmap;
   scatter x=Longitude y=Latitude/ markerattrs=(symbol=Asterisk color=red size=15 px);
run;
title;

%mend Yr;
%Yr(2015);
%Yr(2016);
%Yr(2017);
%Yr(2018);
%Yr(2019);


%Macro yr(Year);
proc sql;
create table wip.accidents_in_&Year as select 
distinct (ACCNUM) as DISTINCT_ACCNUM,
MANOEUVER,
YEAR,
IMPACTYPE
from wip.ksi_nodups 
WHERE ROAD_CLASS = 'Major Arterial' AND YEAR=&Year AND MANOEUVER is not null AND IMPACTYPE ='Cyclist Collisions';
quit;

Title "Frequency of Accidents and their Manoeuvers in &Year";
proc freq data=wip.accidents_in_&Year;
tables MANOEUVER;
run;

%mend yr;
%yr(2015);
%yr(2016);
%yr(2017);
%yr(2018);
%yr(2019);



**************************************************;
*EDA on the Road Impediments Ignition Data Set ;
**************************************************;
/*
SQL USED to query data from Ignition.Geotab:

  SELECT
 *
  FROM
    `geotab-public-intelligence.UrbanInfrastructure.RoadImpediments`
  WHERE
    State LIKE 'Ontario'
    AND City LIKE 'Toronto'
    
    Data Retrieved from: https://data.geotab.com/urban-infrastructure/road-impediments */
   
   
options validvarname=v7;
proc import datafile="/home/u50039828/TPS - Safe Roads Competition/Ignition/ignition_roadimpediments.csv"
		dbms = csv
		out = wip.roadimp
		replace;
		guessingrows=max;
run;

proc contents data= wip.roadimp varnum;
run;

proc sort data=wip.RoadImp 
	out=wip.RoadImp_nodups
	nodupkey;
	by _all_;
run;

proc print data =wip.RoadImp_nodups (obs=50);
run;

proc means data=wip.RoadImp_nodups;
run;

proc univariate data=wip.roadimp_nodups;
   histogram;
run;

/*Creating a road score based on magnitude of the impact and frequency*/
  
proc sql;
CREATE TABLE wip.roadimp_final AS
  SELECT
  *,
  (AvgAcceleration*PercentOfVehicles) AS Score
  FROM
    wip.RoadImp_nodups
  WHERE
    State LIKE 'Ontario'
    AND City LIKE 'Toronto'
    ;
    quit;

proc contents data = wip.roadimp_final varnum;
run;

proc univariate data=wip.roadimp_final;
var Score Latitude Longitude;
   histogram Score;
run;

 proc rank data=wip.roadimp_final out=wip.roadimp_rank groups=5;                               
     var Score;                                                          
     ranks score_rank;                                                      
  run;  
  
proc contents data= wip.roadimp_rank varnum;
run;

proc print data = wip.roadimp_rank (obs=5);
run;

proc freq data=wip.roadimp_rank;                                               
   tables score_rank / nopercent nocum;                                     
run;

proc sort data=wip.roadimp_rank; 
By descending score;
run;

proc univariate data=wip.roadimp_rank;
   histogram score_rank;
run;

*Mapping the road impediments;

Title "Road Impediments: Rank 4";
proc sgmap plotdata=wip.roadimp_rank (where=(score_rank = 4));
   openstreetmap;
   scatter x=Longitude_SW y=Latitude_SW/ 
   markerattrs=(symbol=circlefilled size=3 pt color=red);
   scatter x=Longitude_NE y=Latitude_NE / transparency=1;
run;
title;


Title "Road Impediments: 0.2<=score<=0.79755";
proc sgmap plotdata=wip.roadimp_rank (where=(0.2<=score<=0.79755));
   openstreetmap;
   scatter x=Longitude_SW y=Latitude_SW/ 
   markerattrs=(symbol=circlefilled size=3 pt color=red);
   scatter x=Longitude_NE y=Latitude_NE / transparency=1;
run;
title;




*****************************************;
*			Idling Areas EDA			 ;
*****************************************;
proc import datafile="/home/u50039828/TPS - Safe Roads Competition/Ignition/precipitation_ignition_toronto.csv"
		dbms = csv
		out = wip.idlingareas
		replace;
		guessingrows=max;
run;

proc contents data = wip.idlingareas varnum;
run;

proc sort data=wip.idlingareas
	out=wip.idlingareas_nodups
	nodupkey;
	by _all_;
run;

proc univariate data=wip.idlingareas_nodups;
   histogram ;
run;

*****************************************;
*			Precipitation EDA			 ;
*****************************************;
proc import datafile="/home/u50039828/TPS - Safe Roads Competition/Ignition/precipitation_ignition_toronto.csv"
		dbms = csv
		out = wip.precip
		replace;
		guessingrows=max;
run;

proc contents data = wip.precip varnum;
run;

proc univariate data=wip.precip;
   histogram ;
run;

*****************************************;
*			Hazardous Driving Areas EDA	 ;
*****************************************;

*Accessing the data;
options validvarname=v7;
proc import datafile="/home/u50039828/TPS - Safe Roads Competition/Ignition/ignition_HazardousDrivingAreas.csv"
		dbms = csv
		out = wip.hzdrv_all
		replace;
		guessingrows=max;
run;

data wip.hzdrv;
set wip.hzdrv_all;
where City = 'Toronto';
run;

*Exploring the data;
proc print data=wip.hzdrv (obs=30);
run;

proc contents data=wip.hzdrv varnum;
run;

proc sort data=wip.hzdrv
	out=wip.hzdrv_nodups
	nodupkey;
	by _all_;
run;

proc freq data=wip.hzdrv_nodups nlevels;
table _char_ /noprint;
table _numeric_ /noprint;
run;

proc sort data=wip.hzdrv_nodups;
	by SeverityScore ;
run;

data wip.hzdrv_cleaned;
	set wip.hzdrv_nodups; 
	drop  State ISO_3166_2 Updatedate Version;
run;

/* Analyze Data */
Title "Hazardous driving hot spot regions in the City of Toronto";
proc sgmap plotdata=wip.hzdrv_cleaned;
   openstreetmap;
   scatter x=Longitude_SW y=Latitude_SW/ markerattrs=(symbol=circlefilled color=red size=3 px);
   scatter x=Longitude_NE y=Latitude_NE / transparency=1;
run;
title;

*Calculating and obtaining locations of the top 10 % Severity Scores ;
proc sort data = wip.hzdrv_cleaned; 
By descending SeverityScore;
run;

proc univariate data= wip.hzdrv_cleaned;
run;

*90th percentile starts from 0.095;

data wip.hzdrv_10pcnt;
  set wip.hzdrv_cleaned;
  Where = SeverityScore gt 0.095 ;
  output;
run;


Title "Top 10% of Hazardous driving spot locations in the City of Toronto";
proc sgmap plotdata=wip.hzdrv_10pcnt;
   openstreetmap;
   scatter x=Longitude_SW y=Latitude_SW/ markerattrs=(symbol=circlefilled color=red size=3 px);
   scatter x=Longitude_NE y=Latitude_NE / transparency=1;
run;
title;

*File for further visualization in Tableau;
proc export data=wip.hzdrv_10pcnt dbms=csv
outfile="/home/u50039828/TPS - Safe Roads Competition/Ignition/hzdrv_10pcnt.csv"
replace;
run;




*****************************************;
*		Creating an Analytical File      ;
*****************************************;

/*Renaming the column names in the Precipitation dataset*/
data wip.precip_final (keep= pre_city pre_country pre_latitude pre_longitude pre_localdate pre_localhour pre_utcdate pre_utchour ProbabilityOfPrecipitation ProbabilityOfSnow) ;
set wip.precip (rename =
(Latitude = pre_latitude
Longitude = pre_longitude 
LocalDate = pre_localdate
LocalHour = pre_localhour
UTC_Date = pre_utcdate
UTC_Hour = pre_utchour
City = pre_city
Country = pre_country)); 
;
run;

/*Renaming the column names in the Road Impediments Score dataset*/

data wip.ri_final ;
set WIP.ROADIMP_RANK (rename =
(Latitude = ri_latitude
Longitude = ri_longitude 
City = ri_city
State = ri_state
Score = ri_score
score_rank = ri_rank )); 
;
run;

/*Merging the final Ignition Precipitation & Road Impediments dataset with the KSI dataset.*/
data wip.precip_ri_ksi;
set wip.ri_final wip.precip_final wip.ksi_nodups;
run;


proc export data=wip.precip_ri_ksi dbms=csv
outfile="/home/u50039828/TPS - Safe Roads Competition/Ignition/precip_ri_ksi.csv"
replace;
run;

