create table rsg_job (  
	rsg_job_id integer, 
	job_start date not null,
	job_end date not null,
	basecurrency varchar2(3) not null,
    num_simulations integer not null,
	xml_model_file blob,
	retain_flag varchar2(1) default 'N',
	persist_until date,	
	CONSTRAINT rsj_job_pk PRIMARY KEY (rsg_job_id)
);
	
create table scenario_set (
	scenario_set_id integer,	
	ss_rsg_job_id integer,
	scenario_set_name varchar2(255) not null,
	scenario_set_type varchar2(255) not null,
	scenario_type_key integer  not null,
	sess_date date not null,
	number_of_chunks integer not null,
	CONSTRAINT scenario_set_pk PRIMARY KEY (scenario_set_id),
	CONSTRAINT scenario_set_rsg_job_fk FOREIGN KEY (ss_rsg_job_id) REFERENCES rsg_job(rsg_job_id) ON DELETE CASCADE,
	CONSTRAINT scenario_set_uc UNIQUE (scenario_set_name)
);

create table scenario (
	scenario_id integer,
	s_scenario_set_id integer,
	scen_name varchar2(255),
	scen_step integer not null,
	scen_date date not null,
	scen_number integer not null,
	is_stochastic varchar2(1) not null,
    is_shockedBase integer default 0,
	CONSTRAINT scenario_pk PRIMARY KEY (scenario_id),
	CONSTRAINT scenario_scenario_set_fk FOREIGN KEY (s_scenario_set_id) REFERENCES scenario_set(scenario_set_id) ON DELETE CASCADE
);

                    
create table risk_factor ( 
	risk_factor_id integer, 
	risk_factor_name varchar2(255) not null, 
	risk_factor_currency varchar2(3) not null,
	risk_family varchar2(255) not null,
	pru_type varchar2(255) not null,
	algo_type varchar2(255) not null,
	pru_group varchar2(255) not null,
	CONSTRAINT risk_factor_pk PRIMARY KEY (risk_factor_id),
	CONSTRAINT risk_factor_uc UNIQUE (risk_factor_name)
);
		
CREATE TABLE "STOCHASTIC_SCENARIO_VALUE"
  (
    "SSV_SCENARIO_SET_ID"    NUMBER(*,0),
    "SSV_SCENARIO_ID"    NUMBER(*,0),
    "SSV_RISK_FACTOR_ID" NUMBER(*,0),
    "OUTPUT_NUMBER"      NUMBER(*,0) ,
    "MONTE_CARLO_NUMBER" NUMBER(*,0) ,
    "SSV_VALUE" BINARY_DOUBLE    
  )
  PCTFREE 0 NOLOGGING 
  
  PARTITION BY RANGE
  (
    "SSV_SCENARIO_SET_ID"
  )  
  subpartition  by hash(SSV_RISK_FACTOR_ID) subpartitions 1000
  (
    PARTITION "P1" VALUES LESS THAN (2) PCTFREE 0 
  );


create table deterministic_scenario_value (
	dsv_scenario_id integer, 
	dsv_risk_factor_id integer, 
	output_number integer not null, 
	dsv_value binary_double not null, 	
	CONSTRAINT dscen_val_pk PRIMARY KEY (dsv_scenario_id, dsv_risk_factor_id, output_number), 
	CONSTRAINT dscen_val_scenario_fk FOREIGN KEY (dsv_scenario_id) REFERENCES scenario(scenario_id) ON DELETE CASCADE, 
	CONSTRAINT dscen_val_risk_factor_fk FOREIGN KEY (dsv_risk_factor_id) REFERENCES risk_factor(risk_factor_id) ON DELETE CASCADE
);


create table norisk_scenario_value (
	nsv_scenario_id integer, 
	nsv_risk_factor_id integer, 
	output_number integer not null, 
	nsv_value binary_double not null, 	
	CONSTRAINT nscen_val_pk PRIMARY KEY (nsv_scenario_id, nsv_risk_factor_id, output_number), 
	CONSTRAINT nscen_val_scenario_fk FOREIGN KEY (nsv_scenario_id) REFERENCES scenario(scenario_id) ON DELETE CASCADE, 
	CONSTRAINT nscen_val_risk_factor_fk FOREIGN KEY (nsv_risk_factor_id) REFERENCES risk_factor(risk_factor_id) ON DELETE CASCADE
);


create table axis (
	axis_id integer,
	axis_scenario_set_id integer, 
	axis_risk_factor_id integer, 
	axis_number integer,
	axis_name varchar2(255) not null,		
	CONSTRAINT axis_pk PRIMARY KEY (axis_id),
	CONSTRAINT axis_uc1 UNIQUE (axis_scenario_set_id, axis_risk_factor_id, axis_name), 
	CONSTRAINT axis_uc2 UNIQUE (axis_scenario_set_id, axis_risk_factor_id, axis_number), 	
	CONSTRAINT axis_scenario_set_fk FOREIGN KEY (axis_scenario_set_id) REFERENCES scenario_set(scenario_set_id) ON DELETE CASCADE, 
	CONSTRAINT axis_risk_factor_fk FOREIGN KEY (axis_risk_factor_id) REFERENCES risk_factor(risk_factor_id) ON DELETE CASCADE
);

create table axis_value (
	av_axis_id integer, 
	av_number integer, 
	av_value binary_double not null,		
	CONSTRAINT axis_value_pk PRIMARY KEY (av_axis_id, av_number), 
	CONSTRAINT axis_value_axis_fk FOREIGN KEY (av_axis_id) REFERENCES axis(axis_id) ON DELETE CASCADE
);

create table validation_schedule (
	vs_scenario_set_id integer, 
	line_number integer,
	ruleset_name varchar2(255),
	validation_item varchar2(255),
	validation_measure varchar2(255),
	validation_value binary_double,	
	CONSTRAINT validation_schedule_pk PRIMARY KEY (vs_scenario_set_id, line_number), 
	CONSTRAINT vs_scenario_set_id_fk FOREIGN KEY (vs_scenario_set_id) REFERENCES scenario_set(scenario_set_id) ON DELETE CASCADE
);

create sequence rsg_job_sequence;

create sequence scenario_set_sequence;

create sequence scenario_sequence;	                

create sequence risk_factor_sequence;

create sequence stochastic_scenario_value_sequ;

create sequence deterministic_scenario_value_s;

create sequence norisk_scenario_value_s;

create sequence axis_sequence;

create sequence axis_value_sequence;

create sequence validation_schedule_sequence;

