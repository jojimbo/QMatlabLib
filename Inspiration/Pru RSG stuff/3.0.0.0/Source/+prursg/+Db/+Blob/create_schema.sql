create table rsg_job (  
	rsg_job_id integer, 
	job_start date not null,
	job_end date not null,
	basecurrency varchar2(3) not null,
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
	number_of_chunks integer not null,
	CONSTRAINT scenario_set_pk PRIMARY KEY (scenario_set_id),
	CONSTRAINT scenario_set_rsg_job_fk FOREIGN KEY (ss_rsg_job_id) REFERENCES rsg_job(rsg_job_id),
	CONSTRAINT scenario_set_uc UNIQUE (scenario_set_name)
);
		
create table scenario_set_output (
        sso_scenario_set_id number,
        chunk_id number,
        chunk blob,
        CONSTRAINT pk_scenario_set_output PRIMARY KEY (sso_scenario_set_id, chunk_id),
        CONSTRAINT fk_scenario_set_id FOREIGN KEY (sso_scenario_set_id) REFERENCES scenario_set(scenario_set_id) ON DELETE CASCADE
);

create sequence rsg_job_sequence;

create sequence scenario_set_sequence;

create sequence scenario_set_output_sequence;
