package prursg.mds;

import java.sql.SQLException;

import oracle.jdbc.pool.OracleDataSource;

import java.sql.Connection;
import java.sql.SQLException;

import oracle.jdbc.*;
import oracle.jdbc.pool.*;
import oracle.sql.*;

public abstract class BaseDao {
	
	private String _url;
	private String _userName;
	private String _password;
	
	protected Connection _connection;
	
	public BaseDao(String url, String userName, String password) throws SQLException{
		_url = url;
		_userName = userName;
		_password = password;
		
		Connect();
	}
	
	public void Connect() throws SQLException
    {
        String msg = "";
               
        OracleDataSource ds = new OracleDataSource();
        ds.setURL(_url);
        ds.setUser(_userName);
        ds.setPassword(_password);

        _connection = ds.getConnection();
    }
	
	public void Disconnect() throws SQLException{
		if (_connection != null){		
			if (!_connection.isClosed()){
				_connection.close();
			}
				
		}
	}

}
