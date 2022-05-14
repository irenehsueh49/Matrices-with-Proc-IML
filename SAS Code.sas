/******************** Homework 2 - Matricies ********************/
libname homework "C:/Irene Hsueh's Documents\MS Applied Biostatistics/BS 803 - Statistical Programming for Biostatisticians/Class 2 - Matrices/Homework 2";
data naac;
	set homework.exercise2;
	rename naccageb=age_baseline nacczmms=mmse_score nacczlmi=immediate_score nacczlmd=delayed_score nacczdft=digit_forward;  
run;


title "Homework 2";
proc print data=naac (obs=50)
	style(header) = {just=center verticalalign=middle};
run;
title;


title "Replacing Missing Values using Array";
data naac_missing;
	set naac;
		array miss(4) mmse_score immediate_score delayed_score digit_forward;
			do i=1 to 4;
				if miss(i) in (-99,99) then miss(i)=.;
			end;
		cognition = mean(mmse_score, immediate_score, delayed_score, digit_forward);
		if cognition=. then delete;
	drop i;
run;

proc sort data=naac_missing;
	by cognition;
run;

proc print data=naac_missing (obs=50)
	style(header) = {just=center verticalalign=middle};
run;
title;


title "Impaired Subjects";
data impaired;
	set naac_missing;
	where cognition < -1.5;
run;
proc print data=impaired;
run;
title;




ODS HTML close;
ODS HTML;




title "Patients with Cognitive Scores < -1.5";
proc iml;
	varnames = {"age_baseline" "mmse_score" "immediate_score" "delayed_score" "digit_forward"};
	use naac;
		read all var varnames into cg;
	close naac;

	do j=1 to ncol(cg);
		do i=1 to nrow(cg);
			if cg[i,j]=-99 | cg[i,j]=99 then cg[i,j] = .;
		end;
	end;

	psych_scores = cg[,2:5];
	cognition = psych_scores[,:];
	nacc = cg || cognition;

	impaired_id = loc(nacc[,6]<-1.5 & nacc[,6]^= .);

	finalvarnames = {"age_baseline" "mmse_score" "immediate_score" "delayed_score" "digit_forward" "cognition"};
	print (impaired_id`)[label="Row"] (nacc[impaired_id,])[colname=finalvarnames];

	create impaired from impaired_id;
	append from impaired_id;
	close impaired;

	create nacc_dataset from nacc[colname = finalvarnames];
	append from nacc;
	close nacc_dataset;

	submit;
		proc reg data=nacc_dataset;
			model cognition = age_baseline;
		run;
		quit;
	endsubmit;
quit;
title;

