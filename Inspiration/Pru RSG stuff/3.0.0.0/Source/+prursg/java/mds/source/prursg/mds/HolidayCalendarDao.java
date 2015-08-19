package prursg.mds;


import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import oracle.jdbc.*;
import oracle.jdbc.pool.*;
import oracle.sql.*;



public class HolidayCalendarDao extends BaseDao {
	
	private OraclePreparedStatement _pstGetNextId;
	private OraclePreparedStatement _pstInsertCalendar;
	private OraclePreparedStatement _pstInsertCalendarDate;
	private OraclePreparedStatement _pstSelectCalendar;	
	
	public HolidayCalendarDao(String url, String userName, String password) throws SQLException {
		super(url, userName, password);		
	}

	public boolean Insert(HolidayCalendar cal) throws SQLException{
			
		//get next calendar id.
		OraclePreparedStatement pstNextId = GetNextIdStatement();
		ResultSet rs = pstNextId.executeQuery();
		long nextId = 0;
		if (rs.next()){		
			nextId = rs.getLong(1);
			cal.Id = nextId;
		}
				
		// insert calendar.
		OraclePreparedStatement pst = GetInsertCalendarStatement();        
        pst.setLong(1, nextId);
        pst.setString(2, cal.Name);                            
        pst.executeUpdate();
        
        // insert calendar dates.
        OraclePreparedStatement pstChild = GetInsertCalendarDateStatement();
        for(HolidayCalendarDate d : cal.Dates){
	        pstChild.setLong(1, nextId);	     
	        pstChild.setDate(2, new java.sql.Date(d.CalendarDate.getTime()));            
	        pstChild.setString(3, d.Desc);
	        pstChild.addBatch();
        }
        
        pstChild.executeBatch();
                
		return true;
	}
	
	public HolidayCalendar Select(String calendarName) throws SQLException{
		OraclePreparedStatement pst = GetSelectCalendarStatement();
		pst.setString(1, calendarName);
		ResultSet rs = pst.executeQuery();		
		HolidayCalendar calendar = null;
		while(rs.next()){
			if (rs.isFirst()){
				calendar = new HolidayCalendar(rs.getLong(1), rs.getString(2));				
			}			
			if (rs.getDate(3) != null){
				calendar.Dates.add(new HolidayCalendarDate(rs.getDate(3), rs.getString(4)));	
			}
						
		}			
		return calendar;
	}
	
	public void Disconnet() throws SQLException {
		if (_pstGetNextId != null){
			_pstGetNextId.close();
			_pstGetNextId = null;
		}
		
		if (_pstInsertCalendar != null){
			_pstInsertCalendar.close();
			_pstInsertCalendar = null;
		}
		
		if (_pstInsertCalendar != null){
			_pstInsertCalendar.close();
			_pstInsertCalendar = null;
		}
		
		if (_pstSelectCalendar != null){
			_pstSelectCalendar.close();
			_pstSelectCalendar = null;
		}
		
		super.Disconnect();		
	}
	
	private OraclePreparedStatement GetNextIdStatement() throws SQLException{
		if (_pstGetNextId == null){
			String selectSql = "select holiday_calendar_sequence.nextval from dual";
			_pstGetNextId = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		return _pstGetNextId;
	}
	
	private OraclePreparedStatement GetInsertCalendarStatement() throws SQLException{
		if (_pstInsertCalendar == null){
			String insertSql = "insert into HOLIDAY_CALENDAR values(?, ?, CURRENT_DATE)";
			_pstInsertCalendar = (OraclePreparedStatement)_connection.prepareStatement(insertSql);
		}
		return _pstInsertCalendar;
	}
	
	private OraclePreparedStatement GetInsertCalendarDateStatement() throws SQLException{
		if (_pstInsertCalendarDate == null){
			String insertSql = "insert into HOLIDAY_CALENDAR_DATE values(?, ?, ?)";
			_pstInsertCalendarDate = (OraclePreparedStatement)_connection.prepareStatement(insertSql);
		}
		return _pstInsertCalendarDate;
	
	}
	
	private OraclePreparedStatement GetSelectCalendarStatement() throws SQLException{
		if (_pstSelectCalendar == null){
			String selectSql = "select Cal.ID, Cal.NAME, d.HOLIDAY_DATE, d.DESCRIPTION " + 
								"from " + 
								"(" + 
								"select * from ( select * from holiday_calendar where NAME = ? order by creation_date desc ) where rownum = 1 " + 
								") Cal left outer join Holiday_calendar_date d on Cal.id = d.holiday_calendar_id " + 
								" ORDER BY D.HOLIDAY_DATE";
			
			_pstSelectCalendar = (OraclePreparedStatement)_connection.prepareStatement(selectSql);
		}
		
		return _pstSelectCalendar;
	}	
}
