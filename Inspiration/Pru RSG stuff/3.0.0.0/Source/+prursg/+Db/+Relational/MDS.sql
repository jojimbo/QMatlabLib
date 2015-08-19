DROP TABLE HOLIDAY_CALENDAR_DATE;
DROP TABLE HOLIDAY_CALENDAR;
DROP TABLE DATASERIES_VALUE;
DROP TABLE DATASERIES_PROPERTY;
DROP TABLE DATASERIES_AXIS;
DROP TABLE DATASERIES;
DROP TABLE DATASERIES_STATUS;
DROP SEQUENCE DATASERIES_SEQUENCE;
DROP SEQUENCE DATASERIES_VALUE_SEQUENCE;
DROP SEQUENCE HOLIDAY_CALENDAR_SEQUENCE;


--------------------------------------------------------
--  DDL for Sequence DATASERIES_SEQUENCE
--------------------------------------------------------

   CREATE SEQUENCE  DATASERIES_SEQUENCE  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
   
--------------------------------------------------------
--  DDL for Sequence DATASERIES_VALUE_SEQUENCE
--------------------------------------------------------

   CREATE SEQUENCE  DATASERIES_VALUE_SEQUENCE  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
   
--------------------------------------------------------
--  DDL for Sequence HOLIDAY_CALENDAR_SEQUENCE
--------------------------------------------------------

   CREATE SEQUENCE  HOLIDAY_CALENDAR_SEQUENCE  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

--------------------------------------------------------
--  DDL for Table HOLIDAY_CALENDAR
--------------------------------------------------------

  CREATE TABLE HOLIDAY_CALENDAR
   (	"ID" NUMBER, 
	"NAME" VARCHAR2(255 BYTE), 
	"CREATION_DATE" DATE
   );
--------------------------------------------------------
--  DDL for Index HOLIDAY_CALENDAR_PK
--------------------------------------------------------
  CREATE UNIQUE INDEX HOLIDAY_CALENDAR_PK ON HOLIDAY_CALENDAR ("ID");
--------------------------------------------------------
--  DDL for Index HOLIDAY_CALENDAR_NAME_INDEX
--------------------------------------------------------

  CREATE INDEX HOLIDAY_CALENDAR_NAME_INDEX ON HOLIDAY_CALENDAR ("NAME");
--------------------------------------------------------
--  Constraints for Table HOLIDAY_CALENDAR
--------------------------------------------------------

  ALTER TABLE HOLIDAY_CALENDAR ADD CONSTRAINT "HOLIDAY_CALENDAR_PK" PRIMARY KEY ("ID") ENABLE;
 
  ALTER TABLE HOLIDAY_CALENDAR MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE HOLIDAY_CALENDAR MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE HOLIDAY_CALENDAR MODIFY ("CREATION_DATE" NOT NULL ENABLE);
  
  
  --------------------------------------------------------
--  DDL for Table HOLIDAY_CALENDAR_DATE
--------------------------------------------------------

  CREATE TABLE HOLIDAY_CALENDAR_DATE 
   (	"HOLIDAY_CALENDAR_ID" NUMBER, 
	"HOLIDAY_DATE" DATE, 
	"DESCRIPTION" VARCHAR2(255 BYTE)
   )  ;
--------------------------------------------------------
--  DDL for Index HOLIDAY_CALENDAR_DATE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX HOLIDAY_CALENDAR_DATE_PK ON HOLIDAY_CALENDAR_DATE ("HOLIDAY_CALENDAR_ID", "HOLIDAY_DATE") ;
  
--------------------------------------------------------
--  Constraints for Table HOLIDAY_CALENDAR_DATE
--------------------------------------------------------

  ALTER TABLE HOLIDAY_CALENDAR_DATE ADD CONSTRAINT "HOLIDAY_CALENDAR_DATE_PK" PRIMARY KEY ("HOLIDAY_CALENDAR_ID", "HOLIDAY_DATE") ENABLE;  
 
  ALTER TABLE HOLIDAY_CALENDAR_DATE MODIFY ("HOLIDAY_CALENDAR_ID" NOT NULL ENABLE);
 
  ALTER TABLE HOLIDAY_CALENDAR_DATE MODIFY ("HOLIDAY_DATE" NOT NULL ENABLE);


--------------------------------------------------------
--  DDL for Table DATASERIES
--------------------------------------------------------

  CREATE TABLE DATASERIES
   (	"ID" NUMBER, 
	"NAME" VARCHAR2(255 BYTE), 
	"DATA_DATE" DATE, 
	"EFFECTIVE_DATE" DATE, 
	"CREATION_DATE" DATE, 
	"STATUS_ID" NUMBER, 
	"PURPOSE" VARCHAR2(255 BYTE)
   );
--------------------------------------------------------
--  DDL for Index DATASERIES_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX DATASERIES_PK ON DATASERIES ("ID") ;
  
--------------------------------------------------------
--  DDL for Index DATASERIES_DATA_DATE_INDEX
--------------------------------------------------------

  CREATE INDEX DATASERIES_DATA_DATE_INDEX ON DATASERIES ("DATA_DATE"); 
  
--------------------------------------------------------
--  DDL for Index DATASERIES_NAME_INDEX
--------------------------------------------------------

  CREATE INDEX DATASERIES_NAME_INDEX ON DATASERIES ("NAME");  
--------------------------------------------------------
--  Constraints for Table DATASERIES
--------------------------------------------------------

  ALTER TABLE DATASERIES ADD CONSTRAINT "DATASERIES_PK" PRIMARY KEY ("ID") ENABLE;
  
 
  ALTER TABLE DATASERIES MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE DATASERIES MODIFY ("NAME" NOT NULL ENABLE);
 
  ALTER TABLE DATASERIES MODIFY ("DATA_DATE" NOT NULL ENABLE);


--------------------------------------------------------
--  DDL for Table DATASERIES_AXIS
--------------------------------------------------------

  CREATE TABLE DATASERIES_AXIS
   (	"DATASERIES_ID" NUMBER, 
	"ID" NUMBER, 
	"NAME" VARCHAR2(255 BYTE)
   );
--------------------------------------------------------
--  DDL for Index DATASERIES_AXIS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX DATASERIES_AXIS_PK ON DATASERIES_AXIS ("DATASERIES_ID", "ID");
  
--------------------------------------------------------
--  Constraints for Table DATASERIES_AXIS
--------------------------------------------------------

  ALTER TABLE DATASERIES_AXIS ADD CONSTRAINT "DATASERIES_AXIS_PK" PRIMARY KEY ("DATASERIES_ID", "ID") ENABLE;
  
  ALTER TABLE DATASERIES_AXIS MODIFY ("DATASERIES_ID" NOT NULL ENABLE);
 
  ALTER TABLE DATASERIES_AXIS MODIFY ("ID" NOT NULL ENABLE);
 
  ALTER TABLE DATASERIES_AXIS MODIFY ("NAME" NOT NULL ENABLE);


CREATE TABLE DATASERIES_PROPERTY
  (
    "DATASERIES_ID" NUMBER NOT NULL ENABLE,
    "NAME"          VARCHAR2(255 BYTE) NOT NULL ENABLE,
    "TYPE"          VARCHAR2(255 BYTE),
    "VALUE"         VARCHAR2(255 BYTE),
    CONSTRAINT "DATASERIES_PROPERTY_PK" PRIMARY KEY ("DATASERIES_ID", "NAME") ENABLE
  );
  
  
  CREATE TABLE DATASERIES_VALUE
  (
    "DATASERIES_ID" NUMBER NOT NULL ENABLE,    
    "VALUE"         NUMBER,
    "AXIS1_VALUE"   VARCHAR2(255 BYTE),
    "AXIS2_VALUE"   VARCHAR2(255 BYTE),
    "AXIS3_VALUE"   VARCHAR2(255 BYTE),
    "AXIS4_VALUE"   VARCHAR2(255 BYTE),
    "AXIS5_VALUE"   VARCHAR2(255 BYTE)
  );
  
  CREATE TABLE DATASERIES_STATUS
  (
    "ID"   NUMBER NOT NULL ENABLE,
    "NAME" VARCHAR2(255 BYTE) NOT NULL ENABLE,
    CONSTRAINT "DATASERIES_STATUS_PK" PRIMARY KEY ("ID") ENABLE
  );
  