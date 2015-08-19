package prursg.mds;

public class DataSeriesAxis {
	public int Id;
	public String Name;
	
	public DataSeriesAxis(){
		
	}
	
	public DataSeriesAxis(int id, String name){
		this.Id = id;
		this.Name = name;
	}
	
public String toString(){
		
		StringBuilder sb = new StringBuilder();
		sb.append("DataSeiresAxis\r\n");
		sb.append(String.format("Id=%s\r\n", this.Id));
		sb.append(String.format("Name=%s\r\n", this.Name));
				
		return sb.toString();
		
	}

}
