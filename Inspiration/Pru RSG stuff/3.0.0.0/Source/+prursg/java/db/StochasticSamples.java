package db;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.*;
import javax.sql.*;

import oracle.jdbc.*;
import oracle.jdbc.pool.*;
import oracle.jdbc.rowset.*;
import oracle.sql.*;


public class StochasticSamples {
    
    private Connection _connection;
    
    public String Connect(String url,String username, String password)
    {
        String msg = "";
        
        try
        {
            OracleDataSource ds = new OracleDataSource();
            ds.setURL(url);
            ds.setUser(username);
            ds.setPassword(password);

            _connection = ds.getConnection();
            
        }
        catch(SQLException se)
        {
           msg = se.toString();
           se.printStackTrace();
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            msg = ex.toString();
            
        }
        
        return msg;
    }
    
    public String Disconnect()
    {
        String msg = "";
        
        try
        {
            if(_connection != null)
            {
                _connection.close();
            }
        }        
        catch(SQLException se)
        {
           msg = se.toString();
           se.printStackTrace();
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            msg = ex.toString();
            
        }
        
        return msg;
        
    }
    
	/**
	 * @param c
	 * @param samples = { SCENARIO_SET_ID, RISK_FACTOR_ID, OUTPUT_NUMBER, MC_NUMBER, SAMPLE }
	 */
	public static void insert(Connection c, String insertSql, double[][] samples) throws SQLException {
		oracle.jdbc.OraclePreparedStatement pst = (oracle.jdbc.OraclePreparedStatement)c.prepareStatement(insertSql);
		for(int i = 0; i < samples.length; ++i) {
			pst.setInt(1, (int)samples[i][0]);
			pst.setInt(2, (int)samples[i][1]);
			pst.setInt(3, (int)samples[i][2]);
			pst.setInt(4, (int)samples[i][3]);
			pst.setBinaryDouble(5, samples[i][4]);
			pst.addBatch();
		}
		pst.executeBatch();
		pst.close();
	}
    
    public String insert(String alterSql, String insertSql, double scenarioSetId, double[][] samples) throws SQLException {     
        oracle.jdbc.OraclePreparedStatement alterPst = (oracle.jdbc.OraclePreparedStatement)_connection.prepareStatement(alterSql);
        alterPst.execute(alterSql);
        alterPst.close();
        
        return insert(insertSql, scenarioSetId, samples);
    }
    
    public String insert(String insertSql, double scenarioSetId, double[][] samples) throws SQLException {
        String msg = "";
        try
        {                                                       
            int length = samples.length;
            int chunkSize = 100000;        
            int startIndex = 0;
            int endIndex = 0;
            while (startIndex < length)
            {            
                endIndex = startIndex + chunkSize;
                if (endIndex > length)
                {
                    endIndex = length;
                }
                
                oracle.jdbc.OraclePreparedStatement pst = (oracle.jdbc.OraclePreparedStatement)_connection.prepareStatement(insertSql);
                for(int i = startIndex; i < endIndex; ++i) {
                    pst.setLong(1, (long)scenarioSetId);
                    pst.setLong(2, (long)samples[i][0]);
                    pst.setLong(3, (long)samples[i][1]);
                    pst.setLong(4, (long)samples[i][2]);
                    pst.setLong(5, (long)samples[i][3]);
                    pst.setBinaryDouble(6, samples[i][4]);
                    pst.addBatch();
                }

                startIndex = endIndex;

                pst.executeBatch();
                pst.close();
            }
		                                  
        }
        catch(SQLException se)
        {
           msg = se.toString();
           se.printStackTrace();
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            msg = ex.toString();
            
        }
        
        return msg;
	}

    public String insert(double[][] data) throws SQLException {
        String msg = "";
        try
        {            
            long[] scenario_ids = new long[data.length];
            long[] risk_factor_ids= new long[data.length];
            long[] output_numbers = new long[data.length];
            long[] monte_carlo_numbers = new long[data.length];
            double[] ssv_values = new double[data.length];
            
            for (int i = 0; i < data.length; i++)
            {
                scenario_ids[i] = (long)data[i][0];
                risk_factor_ids[i] = (long)data[i][1];
                output_numbers[i] = (long)data[i][2];
                monte_carlo_numbers[i] = (long)data[i][3];
                ssv_values[i] = data[i][4];
            }
                                    
            String insertSql = "{call p_insert_SSV(?, ?, ?, ?, ?)}";
            OracleCallableStatement ocs = (OracleCallableStatement)_connection.prepareCall(insertSql);
            ArrayDescriptor int_rows_desc = ArrayDescriptor.createDescriptor("INT_ROWS", _connection);
            ArrayDescriptor double_rows_desc = ArrayDescriptor.createDescriptor("DOUBLE_ROWS", _connection);

            ARRAY array1 = new ARRAY(int_rows_desc, _connection, scenario_ids);
            ARRAY array2 = new ARRAY(int_rows_desc, _connection, risk_factor_ids);
            ARRAY array3 = new ARRAY(int_rows_desc, _connection, output_numbers);
            ARRAY array4 = new ARRAY(int_rows_desc, _connection, monte_carlo_numbers);
            ARRAY array5 = new ARRAY(double_rows_desc, _connection, ssv_values);

            ocs.setARRAY(1, array1);
            ocs.setARRAY(2, array2);
            ocs.setARRAY(3, array3);
            ocs.setARRAY(4, array4);
            ocs.setARRAY(5, array5);

            ocs.execute();
            ocs.close();                                
            		                                 
        }
        catch(SQLException se)
        {
           msg = se.toString();
           se.printStackTrace();
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            msg = ex.toString();
            
        }
        
        return msg;
	}  
    
    public double[][] readStochasticScenarioValues(double stochasticScenarioSetId, double riskId) throws SQLException
    {
        double[][] results = null;
    
        
            
        String sql = " select output_number, ssv_value from stochastic_scenario_value SSV " +
                     " where ssv_scenario_set_id = ? and ssv_risk_factor_id = ?  " +
                     " order by output_number, monte_carlo_number";


        OraclePreparedStatement ps = (OraclePreparedStatement)_connection.prepareStatement(sql, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);            
        ps.setFetchSize(10000);
        ps.setLong(1, (long)stochasticScenarioSetId);
        ps.setLong(2, (long)riskId);
            
        ResultSet rs = ps.executeQuery();
        OracleCachedRowSet ocr = new OracleCachedRowSet();
        ocr.populate(rs);
        results = new double[ocr.size()][2];
        int i = 0;
        while(ocr.next())
        {
            results[i][0] = ocr.getInt(1);
            results[i][1] = ocr.getDouble(2);
            i++;
        }

        ps.close();                                            		                                 
            
        return results;
    }
    
    public String Test()
    {
        String msg = "";
        double[][] data = new double[2][5];
        for(int i = 0; i < data.length; i++)
        {
            for (int j = 0; j < 5; j++)
            {
                data[i][j] = i * j;
            }
        }
        
        try
        {
            insert(data);
        }
        catch(Exception ex)
        {
            
            msg = ex.toString();
        }
        
        return msg;
    }    
    
}
