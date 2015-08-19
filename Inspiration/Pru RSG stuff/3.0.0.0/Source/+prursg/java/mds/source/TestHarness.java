import prursg.mds.*;
import java.util.*;
import java.text.*;

public class TestHarness {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		try{
			TestHarness tester = new TestHarness();
			//tester.TestHolidayCalendarDao();
			tester.TestDataSeriesDao();
		}
		catch(Exception ex){
			ex.printStackTrace();
		}
	}

	
	private void TestHolidayCalendarDao() throws Exception{
		
		HolidayCalendarDao dao = new HolidayCalendarDao("jdbc:oracle:thin:@axoradev03.hs.pru.com:1521:RSG01A", "mds1_rsg", "mds1_rsg");
		
		//test insert
		HolidayCalendar cal = new HolidayCalendar();		
		cal.Name = "HOL_UK";
		DateFormat df = new SimpleDateFormat("dd MMM yyyy");
		
				
		cal.Dates.add(new HolidayCalendarDate(df.parse("1 Jan 2011"), "Desc1"));
		cal.Dates.add(new HolidayCalendarDate(df.parse("2 Jan 2011"), "Desc2"));
		cal.Dates.add(new HolidayCalendarDate(df.parse("25 Dec 2011"), "Desc3"));
		System.out.println(cal);
		
		
		boolean result = dao.Insert(cal);
		System.out.println(result);
		
		//test select
		HolidayCalendar calendar = dao.Select("HOL_UK");
		System.out.println(calendar);
		
		dao.Disconnect();		
		
	}
	
	private void TestDataSeriesDao() throws Exception{
		
		DataSeriesDao dao = new DataSeriesDao("jdbc:oracle:thin:@axoradev03.hs.pru.com:1521:RSG01A", "mds1_rsg", "mds1_rsg");
		
		DateFormat df = new SimpleDateFormat("dd MMM yyyy");
		
		DataSeries dataSeries = new DataSeries();
		dataSeries.Id = 1;
		dataSeries.Name = "GBP_VOL";
		dataSeries.DataDate = df.parse("1 Jan 2011");
		dataSeries.Axes.add(new DataSeriesAxis(1, "Maturity"));
		dataSeries.Axes.add(new DataSeriesAxis(2, "Strike"));
		dataSeries.Properties.add(new DataSeriesProperty("Currency", "string", "GBP"));
		dataSeries.Properties.add(new DataSeriesProperty("TestProp", "number", "34.333"));
		dataSeries.Values.add(new DataSeriesValue(0.023, "1", "0.5", null, null, null));
		dataSeries.Values.add(new DataSeriesValue(0.021, "1", "0.75", null, null, null));
		dataSeries.Values.add(new DataSeriesValue(0.0351, "1", "1", null, null, null));
		dataSeries.Values.add(new DataSeriesValue(0.021, "2", "0.5", null, null, null));
		dataSeries.Values.add(new DataSeriesValue(0.0641, "2", "0.75", null, null, null));
		dataSeries.Values.add(new DataSeriesValue(0.03221, "2", "1", null, null, null));
		
		
		//System.out.println(dataSeries);
		
		dataSeries.Status = 1;
		dao.Insert(dataSeries, status);
		
		dataSeries.Status = 2;
		dao.UpdateStatus(dataSeries, status);
		
		
		try{
			Date fromDate = df.parse("1 Jan 2011");
			Date toDate = df.parse("1 Mar 2011");
			ArrayList<DataSeries> newSeriesList = dao.Select("GBP_VOL", fromDate, toDate, null, 0, null);
			if(newSeriesList != null){			
				for(DataSeries series : newSeriesList){				
					System.out.println(series);
				}
			}
		}
		catch(Exception ex){
			ex.printStackTrace();
		}
				
	}
}
