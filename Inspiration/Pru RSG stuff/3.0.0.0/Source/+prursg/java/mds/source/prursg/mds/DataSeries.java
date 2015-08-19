package prursg.mds;

import java.util.*;
import java.text.*;


public class DataSeries {
	
	public long Id;
	public String Name;
	public Date DataDate;
	public Date EffectiveDate;
	public int Status;
	public String Purpose;
	
	public ArrayList<DataSeriesAxis> Axes;
	public ArrayList<DataSeriesProperty> Properties;
	public ArrayList<DataSeriesValue> Values;
	
	public DataSeries(){
		this.Axes = new ArrayList<DataSeriesAxis>();
		this.Properties = new ArrayList<DataSeriesProperty>();
		this.Values = new ArrayList<DataSeriesValue>();		
	}
	
	public String toString(){
		StringBuilder sb = new StringBuilder();
		sb.append("DataSeries\r\n");
		sb.append(String.format("Id=%s\r\n", this.Id));
		sb.append(String.format("Name=%s\r\n", this.Name));
		sb.append(String.format("DataDate=%s\r\n", this.DataDate));
		sb.append(String.format("EffectiveDate=%s\r\n", this.EffectiveDate));
		sb.append(String.format("Status=%s\r\n", this.Status));
		sb.append(String.format("Purpose=%s\r\n", this.Purpose));
		
		for(DataSeriesAxis axis : this.Axes ){
			sb.append(axis);
		}
		
		for(DataSeriesProperty property : this.Properties ){
			sb.append(property);
		}
		
		for(DataSeriesValue value : this.Values ){
			sb.append(value);
		}
		
		return sb.toString();
	}

}
