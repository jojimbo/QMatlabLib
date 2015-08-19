package prursg.mds;

import java.util.*;
import java.text.*;

public class HolidayCalendar {
	
	public long Id;
	public String Name;
	public ArrayList<HolidayCalendarDate> Dates;
	
	public HolidayCalendar(){
		this(0, null);
	}
	
	public HolidayCalendar(long id, String name){
		this(id, name, new ArrayList<HolidayCalendarDate>());		
	}
	
	public HolidayCalendar(long id, String name, ArrayList<HolidayCalendarDate> dates){
		this.Id = id;
		this.Name = name;
		this.Dates = dates;
	}
	
	public String toString(){
		StringBuilder sb = new StringBuilder();
		sb.append("HolidayCalendar\r\n");
		sb.append(String.format("ID=%s\r\n", this.Id));
		sb.append(String.format("Name=%s\r\n", this.Name));
		for(HolidayCalendarDate date : this.Dates ){
			sb.append(date);
		}		
		return sb.toString();
	}
}
