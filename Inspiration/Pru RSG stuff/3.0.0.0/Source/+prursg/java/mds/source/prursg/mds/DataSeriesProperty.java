package prursg.mds;

import java.util.*;
import java.text.*;

public class DataSeriesProperty {
	public String Name;
	public String Type;
	public String Value;
	
	public DataSeriesProperty(){
	}
	
	public DataSeriesProperty(String name, String type, String value){
		this.Name = name;
		this.Type = type;
		this.Value = value;
	}
	
	public String toString(){
		
		StringBuilder sb = new StringBuilder();
		sb.append("DataSeiresProperty\r\n");
		sb.append(String.format("Name=%s\r\n", this.Name));
		sb.append(String.format("Type=%s\r\n", this.Type));
		sb.append(String.format("Value=%s\r\n", this.Value));
				
		return sb.toString();
		
	}
	
}
