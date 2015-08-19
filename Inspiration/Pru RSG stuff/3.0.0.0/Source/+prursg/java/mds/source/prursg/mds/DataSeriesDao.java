package prursg.mds;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.sql.*;
import javax.sql.*;
import javax.sql.rowset.*;

import oracle.jdbc.*;
import oracle.jdbc.pool.*;
import oracle.jdbc.rowset.OracleCachedRowSet;
import oracle.sql.*;




public class DataSeriesDao extends BaseDao{
	
	private OraclePreparedStatement _pstGetNextId;
	private OraclePreparedStatement _pstInsertDataSeries;
	private OraclePreparedStatement _pstInsertDataSeriesAxis;
	private OraclePreparedStatement _pstInsertDataSeriesProperty;	
	private OraclePreparedStatement _pstInsertDataSeriesValue;
	private OraclePreparedStatement _pstSelectDataSeries;
	private OraclePreparedStatement _pstSelectDataSeriesAxes;
	private OraclePreparedStatement _pstSelectDataSeriesProperties;
	private OraclePreparedStatement _pstSelectDataSeriesValues;
	private OraclePreparedStatement _pstUpdateDataSeriesStatus;
	
	
	public DataSeriesDao(String url, String userName, String password) throws SQLException{
		super(url, userName, password);
	}

	public boolean Insert(DataSeries dataSeries) throws SQLException, ParseException{
//		get next calendar id.
		OraclePreparedStatement pstNextId = GetNextIdStatement();
		ResultSet rs = pstNextId.executeQuery();
		long nextId = 0;
		if (rs.next()){		
			nextId = rs.getLong(1);
			dataSeries.Id = nextId;
		}
			
		SimpleDateFormat df = new SimpleDateFormat("dd/MMM/yyyy");
		
		// insert dataseries
		OraclePreparedStatement pst = GetInsertDataSeriesStatement();        
        pst.setLong(1, nextId);
        pst.setString(2, dataSeries.Name);
        pst.setDate(3, new java.sql.Date(dataSeries.DataDate.getTime()));
        if (dataSeries.EffectiveDate == null){
        	dataSeries.EffectiveDate = df.parse("1/Jan/1900");
        }        	       
        pst.setDate(4, new java.sql.Date(dataSeries.EffectiveDate.getTime()));
        pst.setLong(5, dataSeries.Status);
        if (dataSeries.Purpose == null){
        	dataSeries.Purpose = "";        	
        }
        pst.setString(6, dataSeries.Purpose);
        pst.executeUpdate();
        
        // insert dataseries axes.
        OraclePreparedStatement pstChild = GetInsertDataSeriesAxisStatement();
        int index = 1;
        for(DataSeriesAxis axis : dataSeries.Axes){
	        pstChild.setLong(1, nextId);
	        pstChild.setInt(2, index);
	        index++;	                   
	        pstChild.setString(3, axis.Name);
	        pstChild.addBatch();
        }        
        pstChild.executeBatch();
        
        // insert dataseries properties.
        pstChild = GetInsertDataSeriesPropertyStatement();        
        for(DataSeriesProperty property : dataSeries.Properties){
	        pstChild.setLong(1, nextId);	        	        	                
	        pstChild.setString(2, property.Name);
	        pstChild.setString(3, property.Type);
	        pstChild.setString(4, property.Value);
	        pstChild.addBatch();
        }        
        pstChild.executeBatch();
        
//      insert dataseries values.
        pstChild = GetInsertDataSeriesValueStatement();        
        for(DataSeriesValue value : dataSeries.Values){
	        pstChild.setLong(1, nextId);	        	        	                
	        pstChild.setDouble(2, value.Value);
	        pstChild.setString(3, value.Axis1Value);
	        pstChild.setString(4, value.Axis2Value);
	        pstChild.setString(5, value.Axis3Value);
	        pstChild.setString(6, value.Axis4Value);
	        pstChild.setString(7, value.Axis5Value);
	        pstChild.addBatch();
        }        
        pstChild.executeBatch();
                
		return true;
	}
	
	public ArrayList<DataSeries> Select (String dataSeriesName, java.util.Date fromDate, java.util.Date toDate, java.util.Date effectiveDate, int status, String purpose) throws SQLException{
		ArrayList<DataSeries> dataSeries = new ArrayList<DataSeries>();
		
		OraclePreparedStatement pst = GetSelectDataSeriesStatement();
		pst.setString(1, dataSeriesName);
		if (fromDate != null){
			pst.setDate(2, new java.sql.Date(fromDate.getTime()));
			pst.setDate(3, new java.sql.Date(fromDate.getTime()));
		}
		else{
			pst.setDate(2, null);
			pst.setDate(3, null);
		}
		
		if (toDate != null){
			pst.setDate(4, new java.sql.Date(toDate.getTime()));
			pst.setDate(5, new java.sql.Date(toDate.getTime()));
		}
		else{
			pst.setDate(4, null);
			pst.setDate(5, null);
		}
				
		if (effectiveDate == null){
			pst.setDate(6, null);
			pst.setDate(7, null);
		}
		else{
			pst.setDate(6, new java.sql.Date(effectiveDate.getTime()));
			pst.setDate(7, new java.sql.Date(effectiveDate.getTime()));
		}			
		pst.setInt(8, status);
		pst.setInt(9, status);
		pst.setString(10, purpose);		
		pst.setString(11, purpose);
		ResultSet rs = pst.executeQuery();
		CachedRowSet crs = new OracleCachedRowSet();
		crs.populate(rs);
		rs.close();
		
		OraclePreparedStatement pstAxes = GetSelectDataSeriesAxesStatement();
		OraclePreparedStatement pstProperties = GetSelectDataSeriesPropertiesStatement();
		OraclePreparedStatement pstValues = GetSelectDataSeriesValuesStatement();
		
		while(crs.next()){
			DataSeries d = new DataSeries();
			d.Id = crs.getLong(1);
			d.Name = crs.getString(2);
			d.DataDate = crs.getDate(3);
			d.EffectiveDate = crs.getDate(4);
			d.Status = crs.getInt(5);
			d.Purpose = crs.getString(6);
						
			pstAxes.setLong(1, d.Id);
			ResultSet rsChild = pstAxes.executeQuery();
			CachedRowSet crsChild = new OracleCachedRowSet();
			crsChild.populate(rsChild);
			rsChild.close();			
			while(crsChild.next()){
				d.Axes.add(new DataSeriesAxis(crsChild.getInt(1), crsChild.getString(2)));
			}
			
			pstProperties.setLong(1, d.Id);
			rsChild = pstProperties.executeQuery();
			crsChild = new OracleCachedRowSet();
			crsChild.populate(rsChild);
			rsChild.close();
			while(crsChild.next()){
				d.Properties.add(new DataSeriesProperty(crsChild.getString(1), crsChild.getString(2), crsChild.getString(3)));
			}
			
			pstValues.setLong(1, d.Id);
			rsChild = pstValues.executeQuery();
			crsChild = new OracleCachedRowSet();
			crsChild.populate(rsChild);
			rsChild.close();
			while(crsChild.next()){
				d.Values.add(new DataSeriesValue(crsChild.getDouble(1), crsChild.getString(2), crsChild.getString(3), crsChild.getString(4), crsChild.getString(5), crsChild.getString(6)));
			}
											
			dataSeries.add(d);						
		}			
		
		return dataSeries;
	}
	
	public boolean UpdateStatus(DataSeries dataSeries) throws SQLException{
		OraclePreparedStatement pst = GetUpdateDataSeriesStatusStatement();
		pst.setInt(1, dataSeries.Status);
		pst.setLong(2, dataSeries.Id);
		pst.executeUpdate();							
		return true;
	}
	
	public void Disconnect() throws SQLException{
		if (_pstGetNextId != null){
			_pstGetNextId.close();
			_pstGetNextId = null;
		}
		
		if (_pstInsertDataSeries != null){
			_pstInsertDataSeries.close();
			_pstInsertDataSeries = null;
		}
		
		if (_pstInsertDataSeriesAxis != null){
			_pstInsertDataSeriesAxis.close();
			_pstInsertDataSeriesAxis = null;
		}
		
		if (_pstInsertDataSeriesProperty != null){
			_pstInsertDataSeriesProperty.close();
			_pstInsertDataSeriesProperty = null;
		}
		
		if (_pstInsertDataSeriesValue != null){
			_pstInsertDataSeriesValue.close();
			_pstInsertDataSeriesValue = null;
		}
		
		if (_pstSelectDataSeries != null){
			_pstSelectDataSeries.close();
			_pstSelectDataSeries = null;
		}
		
		if (_pstSelectDataSeriesAxes != null){
			_pstSelectDataSeriesAxes.close();
			_pstSelectDataSeriesAxes = null;
		}
		
		if (_pstSelectDataSeriesProperties != null){
			_pstSelectDataSeriesProperties.close();
			_pstSelectDataSeriesProperties = null;
		}
		
		if (_pstSelectDataSeriesValues != null){
			_pstSelectDataSeriesValues.close();
			_pstSelectDataSeriesValues = null;
		}
		
		if (_pstUpdateDataSeriesStatus != null){
			_pstUpdateDataSeriesStatus.close();
			_pstUpdateDataSeriesStatus = null;
		}
		super.Disconnect();		
	}
	
	private OraclePreparedStatement GetNextIdStatement() throws SQLException{
		if (_pstGetNextId == null){
			String selectSql = "select dataseries_sequence.nextval from dual";
			_pstGetNextId = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		return _pstGetNextId;
	}
	
	private OraclePreparedStatement GetInsertDataSeriesStatement() throws SQLException{
		if (_pstInsertDataSeries == null){
			String insertSql = "insert into DATASERIES(\"ID\",\"NAME\", DATA_DATE, EFFECTIVE_DATE, CREATION_DATE, STATUS_ID, PURPOSE)  values(?, ?, ?, ?, CURRENT_DATE, ?, ?)";
			_pstInsertDataSeries = (OraclePreparedStatement)_connection.prepareStatement(insertSql);
		}
		return _pstInsertDataSeries;
	}
	
	private OraclePreparedStatement GetInsertDataSeriesAxisStatement() throws SQLException{
		if (_pstInsertDataSeriesAxis == null){
			String insertSql = "insert into DATASERIES_AXIS values(?, ?, ?)";
			_pstInsertDataSeriesAxis = (OraclePreparedStatement)_connection.prepareStatement(insertSql);
		}
		return _pstInsertDataSeriesAxis;
	
	}
	
	private OraclePreparedStatement GetInsertDataSeriesPropertyStatement() throws SQLException{
		if (_pstInsertDataSeriesProperty == null){
			String insertSql = "insert into DATASERIES_PROPERTY values(?, ?, ?, ?)";
			_pstInsertDataSeriesProperty = (OraclePreparedStatement)_connection.prepareStatement(insertSql);
		}
		return _pstInsertDataSeriesProperty;
	
	}
	
	private OraclePreparedStatement GetInsertDataSeriesValueStatement() throws SQLException{
		if (_pstInsertDataSeriesValue == null){
			String insertSql = "insert into DATASERIES_VALUE values(?, ?, ?, ?, ?, ?, ?)";
			_pstInsertDataSeriesValue = (OraclePreparedStatement)_connection.prepareStatement(insertSql);
		}
		return _pstInsertDataSeriesValue;
	
	}
	
	private OraclePreparedStatement GetUpdateDataSeriesStatusStatement() throws SQLException{
		if (_pstUpdateDataSeriesStatus== null){
			String updateSql = "update DATASERIES set STATUS_ID = ? WHERE \"ID\" = ?";
			_pstUpdateDataSeriesStatus = (OraclePreparedStatement)_connection.prepareStatement(updateSql);
		}
		return _pstUpdateDataSeriesStatus;
	
	}
	
	private OraclePreparedStatement GetSelectDataSeriesStatement() throws SQLException{
		if (_pstSelectDataSeries == null){
			String selectSql = "select * from  ( " + 
					" select ID, NAME, DATA_DATE, EFFECTIVE_DATE, STATUS_ID, PURPOSE, row_number() over ( partition by DATA_DATE order by EFFECTIVE_DATE ASC, CREATION_DATE DESC) as RN  from dataseries "  + 
					" where Name = ? and " +
					" (NVL(?, TO_DATE('1 Jan 1900', 'dd Mon yyyy')) >=  TO_DATE('1 Jan 1900', 'dd Mon yyyy') OR NVL(DATA_DATE, TO_DATE('1 Jan 1900', 'dd Mon yyyy')) >= ? ) AND " +
					" (NVL(?, TO_DATE('1 Jan 1900', 'dd Mon yyyy')) <=  TO_DATE('1 Jan 1900', 'dd Mon yyyy') OR NVL(DATA_DATE, TO_DATE('1 Jan 1900', 'dd Mon yyyy')) <= ? ) AND " +
					" (NVL(?, TO_DATE('1 Jan 1900', 'dd Mon yyyy')) =  TO_DATE('1 Jan 1900', 'dd Mon yyyy') OR NVL(EFFECTIVE_DATE, TO_DATE('1 Jan 1900', 'dd Mon yyyy')) <= ? ) AND " +
					" (NVL(?, 0) = 0 OR NVL(STATUS_ID, 0) = ?) AND " +
					" (NVL(?, 'NULL') = 'NULL' OR NVL(PURPOSE, 'NULL') = ?) " + 
					" ) " + 
					" where RN = 1 " +
					" order by DATA_DATE";						
			
			_pstSelectDataSeries = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		
		return _pstSelectDataSeries;
	}	
	
	private OraclePreparedStatement GetSelectDataSeriesAxesStatement() throws SQLException{
		if (_pstSelectDataSeriesAxes == null){
			String selectSql = "select ID, NAME from DATASERIES_AXIS where DATASERIES_ID = ? order by \"ID\" ";
			
			_pstSelectDataSeriesAxes = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		
		return _pstSelectDataSeriesAxes;
	}
	
	private OraclePreparedStatement GetSelectDataSeriesPropertiesStatement() throws SQLException{
		if (_pstSelectDataSeriesProperties == null){
			String selectSql = "select NAME, TYPE, VALUE from DATASERIES_PROPERTY where DATASERIES_ID = ? ";
			
			_pstSelectDataSeriesProperties = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		
		return _pstSelectDataSeriesProperties;
	}
	
	private OraclePreparedStatement GetSelectDataSeriesValuesStatement() throws SQLException{
		if (_pstSelectDataSeriesValues == null){
			String selectSql = "select VALUE, AXIS1_VALUE, AXIS2_VALUE, AXIS3_VALUE, AXIS4_VALUE, AXIS5_VALUE from DATASERIES_VALUE where DATASERIES_ID = ? ";
			
			_pstSelectDataSeriesValues = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		
		return _pstSelectDataSeriesValues;
	}

}
