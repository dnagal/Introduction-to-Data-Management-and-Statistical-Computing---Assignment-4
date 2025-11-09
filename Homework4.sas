/* exercise 1a */
libname xptfile0 XPORT "/home/u64352307/HomeworkAssignments/XPT/TR.xpt";
libname xptfile1 XPORT "/home/u64352307/HomeworkAssignments/XPT/TU.xpt";
libname xptfile2 XPORT "/home/u64352307/HomeworkAssignments/XPT/IC.xpt";
libname xptfile3 XPORT "/home/u64352307/HomeworkAssignments/XPT/RS.xpt";
libname ino "/home/u64352307/HomeworkAssignments/XPTread";

proc copy in=xptfile0 out=ino memtype=data;
run;
proc copy in=xptfile1 out=ino memtype=data;
run;
proc copy in=xptfile2 out=ino memtype=data;
run;
proc copy in=xptfile3 out=ino memtype=data;
run;

proc contents data=ino.IC order=varnum;
proc contents data=ino.RS order=varnum;
proc contents data=ino.TR order=varnum;
proc contents data=ino.TU order=varnum;
run;

proc print data=ino.IC (firstobs=1 obs=5);
run;

/* exercise 1b*/ 
proc sort data=ino.TR out=ino.TRsort ;
	by SUBJIDN TRDTC VISIT TREVALID;
run;

proc sort data=ino.RS out=ino.RSsort ;
	by SUBJIDN RSDTC VISIT RSEVALID;
run;

data ino.TRRS;
merge ino.TR (rename = (TRDTC = date TREVALID = readerID))
	  ino.RS (rename = (RSDTC = date RSEVALID = readerID));
	  by SUBJIDN date VISIT readerID;
run;

data TRRS2;
set ino.TRRS;
if TRSEQ~=. & RSSEQ~=. then merge=3;
if TRSEQ=. & RSSEQ~=. then merge=2;
if TRSEQ~=. & RSSEQ=. then merge=1;
run;

proc freq data=ino.TRRS;
table SUBJIDN*VISITNUM;
run;

proc freq data=TRRS2;
table merge*VISITNUM;
run;

proc freq data=TRRS2;
where merge=3;
    tables SUBJIDN * VISITNUM / nocol nocum;
run; 

proc freq data=TRRS2;
where merge=1;
	table VISITNUM;
run; 

proc freq data=TRRS2;
where merge=2;
	tables SUBJIDN * RSORRES;
run;

/* exercise 1c */
data unique_subjects_and_visits ; 
	Set TRRS2; 
	by SUBJIDN VISITNUM; 
	if (first.SUBJIDN=1 or first.VISITNUM=1)  then output ;
run; 

proc freq data=unique_subjects_and_visits;
	table SUBJIDN*VISITNUM;
	where merge=3;
run;

proc freq data=unique_subjects_and_visits;
	table SUBJIDN*VISITNUM;
	where merge=1;
run;	

proc freq data=unique_subjects_and_visits;
	table SUBJIDN*VISITNUM;
	where merge=2;
run;

proc freq data=unique_subjects_and_visits;
	table SUBJIDN*VISITNUM;
	where merge=2 or merge=1;
run;

/* exercise 1d */
proc contents data=ino.TR;
run;

proc print data=ino.TR;
run;

ods listing close;
ods rtf file="/home/u64352307/HomeworkAssignments/XPT/TR.xpt.rtf";
title1 "Baseline Target Disease Burden";
proc means data=ino.TR n mean stddev; 
where TRTEST = "Sum of Diameter" and TRACPTFL = "Y" and VISIT = "Screening";
var TRSTRESN;
run;
ods rtf close;
ods listing;
   
/* exercise 2 */
libname newdata "/home/u64352307/HomeworkAssignments/XPTread";
Data best_countries;
 set newdata.best_countries;
run;

proc format;
 value hifmt 0-<50    = "< 50"
             50-75    = "50-75"
             75<-high = "> 75";
run;

proc contents data=newdata.best_countries;
run;

proc freq data=newdata.best_countries order=freq;
where incGroup = "High";
tables region/nocum;
run; 

/* exercise 3 */ 
proc freq data=newdata.best_countries;
tables region*incGroup / norow nocol;
run; 

/* exercise 3-1 */
proc freq data=newdata.best_countries;
tables region*incGroup / chisq norow nocol;
run; 
/* processing time is in the log */

/* exercise 3-2 */
proc freq data=newdata.best_countries;
tables region*incGroup / chisq fisher norow nocol;
run; 

/* exercise 3-3 */
proc freq data = newdata.best_countries;
tables popGroup*region*HI / list nocum nopercent;
format HI hifmt.;
run;
/* population group, region, categorization 
of health index, in this order */