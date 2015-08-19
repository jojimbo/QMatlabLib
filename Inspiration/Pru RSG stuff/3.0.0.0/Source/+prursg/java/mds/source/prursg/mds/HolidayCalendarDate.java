package prursg.mds;

import java.util.*;
import java.text.*;

public class HolidayCalendarDate {
	
	public Date CalendarDate;
	public String Desc;
	
	public HolidayCalendarDate(){
	}
	
	public HolidayCalendarDate(Date date, String desc){
		this.CalendarDate = date;
		this.Desc = desc;
	}
	
	public String toString(){
		StringBuffer sb = new StringBuffer();
		sb.append("HolidayCalendarDate\r\n");
		sb.append(String.format("Date=%s\r\n", this.CalendarDate));
		sb.append(String.format("Desc=%s\r\n", this.Desc));		
		return sb.toString();
	}
}
