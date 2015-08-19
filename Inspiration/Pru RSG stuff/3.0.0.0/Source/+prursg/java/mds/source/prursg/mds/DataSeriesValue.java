package prursg.mds;

import java.util.*;
import java.text.*;

public class DataSeriesValue {	
	public double Value;
	public String Axis1Value;
	public String Axis2Value;
	public String Axis3Value;
	public String Axis4Value;
	public String Axis5Value;
	
	public DataSeriesValue(){
		
	}
	
	public DataSeriesValue(double value, String axis1Value, String axis2Value, String axis3Value, String axis4Value, String axis5Value){		
		this.Value = value;
		this.Axis1Value = axis1Value;
		this.Axis2Value = axis2Value;
		this.Axis3Value = axis3Value;
		this.Axis4Value = axis4Value;
		this.Axis5Value = axis5Value;
	}
	
	public String toString(){
				
		StringBuilder sb = new StringBuilder();
		sb.append("DataSeiresValue\r\n");	
		sb.append(String.format("Value=%s\r\n", this.Value));
		sb.append(String.format("Axis1Value=%s\r\n", this.Axis1Value));
		sb.append(String.format("Axis2Value=%s\r\n", this.Axis2Value));
		sb.append(String.format("Axis3Value=%s\r\n", this.Axis3Value));
		sb.append(String.format("Axis4Value=%s\r\n", this.Axis4Value));
		sb.append(String.format("Axis5Value=%s\r\n", this.Axis5Value));		
		return sb.toString();
		
	}
	
}
