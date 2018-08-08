import java.sql.*;
import javax.sql.*;
import java.util.*;
//import sunje.goldilocks.jdbc.GoldilocksDataSource;
//import sunje.sundb.jdbc.SundbDataSource;
//import indep.jdbc.core.JdbcPreparedStatement;

import java.io.*;
import org.json.simple.*;
import org.json.simple.parser.*;

import org.apache.log4j.Logger;

public class MultiThread extends Thread
{
	private static final Logger logger = Logger.getLogger(MultiThread.class.getName());
	char   mode = '\u0000';
	int    num = 0;
	int    tNum = 0;
	int    start = 0;
	int    end = 0;

	static int    avTPS = 0;

	MultiThread(int num, int tNum, char mode, int start, int end){
		this.mode = mode;
		this.num = num;
		this.tNum = tNum;
		this.start = start;
		this.end = end;
	}

	public void run(){
		try{
			CheckJSON cjson = new CheckJSON();
			cjson.check();

			Class.forName(cjson.getDriver());

			Properties prop = new Properties();
			prop.setProperty("user", cjson.getUser()); 
			prop.setProperty("password", cjson.getPassword());
			long commitInterval = cjson.getCommit();
			Connection con = null;
			if(cjson.getMode().equals("D")){
				con = DriverManager.getConnection(cjson.getURL_DA(), prop);
			}
			if(cjson.getMode().equals("T")){
				con = DriverManager.getConnection(cjson.getURL_TCP(), prop);
			}
			if(cjson.getAutoCommit().equals("F")){
				con.setAutoCommit(false);
			}
				

			switch(mode) {
				case 's' :
					Select(con, start);
					break;
				case 'i' :
					Insert(con, start, end, commitInterval, cjson.getAutoCommit());
					break;
				case 'u' :
					Update(con, start, end, commitInterval, cjson.getAutoCommit());
					break;
				case 'd' :
					Delete(con, start, end, commitInterval, cjson.getAutoCommit());
					break;
				default :
					break;
			}
			con.close();

		}catch(Exception e){
			e.printStackTrace();
		}
	}

	public void Information(int num, double spendTime, double count){
		logger.info("  [" + num + "] Thread Information\n" +
					"  Total Time    : " + spendTime + " ms\n" +
					"  Record Count  : " + (int) count + "\n" +
					"  TPS           : " + (int)( count * (double)1000 / spendTime ) + " tps");//\n" +
		setTPS((int)( count * (double)1000 / spendTime ));
	}

	public void SQLExcept(Connection con, SQLException e){
		logger.error("  Error Code    : " + e.getErrorCode() + "\n" +
					 "  SQLState      : " + e.getSQLState() + "\n" +
					 "  Error Message : " + e.getMessage() );

		if(con != null) {
			try{
				con.close();
			}catch(SQLException ee1){
				logger.error("  Error Code    : " + ee1.getErrorCode() + "\n" +
							 "  SQLState      : " + ee1.getSQLState() + "\n" +
							 "  Error Message : " + ee1.getMessage() );
			}
		}
		//System.exit( -1 );
	}


	public void Select(Connection con, int start) throws Exception{
		long startTime = 0;
		long endTime   = 0;
		double spendTime = 0.0;
		long tps       = 0;
		double count     = 0.0;

		String selectQuery = "SELECT C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20 FROM PF_TEST WHERE C1 = ?";
		try{
			PreparedStatement pstmt = con.prepareStatement(selectQuery);
			ResultSet rs = null;

			startTime = System.currentTimeMillis();
			for(int i = 0; i <= start; i++){
				pstmt.setInt(1, i);
				rs = pstmt.executeQuery();
				while(rs.next()){ count ++; }
				rs.close();
			}
			endTime = System.currentTimeMillis();
			spendTime = (endTime - startTime);

			Information(num, spendTime, count);
			pstmt.close();
		}catch(SQLException e){
			SQLExcept(con, e);
		}catch(Exception e1){
			logger.error("  Error Message : " + e1.getMessage() );
			System.exit( -1 );
		}
	}

	public void Insert(Connection con, int start, int end, long commit, String cMode) throws Exception{
		long startTime = 0;
		long endTime   = 0;
		double spendTime = 0.0;
		long tps       = 0;
		double count     = 0.0;
		int cCommit = 0;

		if (end - start + 1 < 0){
			count = 0;
		}else{
			count = end - start + 1;
		}

		String insertQuery = "INSERT INTO PF_TEST (C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try{
		Calendar now = Calendar.getInstance();
		PreparedStatement pstmt = con.prepareStatement(insertQuery);
		java.util.Date uDate = new java.util.Date();
		java.sql.Date  sDate = new java.sql.Date(uDate.getTime());

		startTime = System.currentTimeMillis();
		if(cMode.equals("F")){
			for(int i = start; i <= end; i++){
				pstmt.setInt(1, i);
				pstmt.setInt(2, i);
				pstmt.setInt(3, i);
				pstmt.setInt(4, i);
				pstmt.setInt(5, i);
				pstmt.setInt(6, i);
				pstmt.setInt(7, i);
				pstmt.setInt(8, i);
				pstmt.setInt(9, i);
				pstmt.setInt(10, i);
				pstmt.setString(11, "JDBC Column 4 Performance TEST");
				pstmt.setString(12, "JDBC Column 5 Performance TEST");
				pstmt.setString(13, "JDBC Column 6 Performance TEST");
				pstmt.setString(14, "JDBC Column 7 Performance TEST");
				pstmt.setString(15, "JDBC Column 8 Performance TEST");
				pstmt.setString(16, "JDBC Column 8 Performance TEST");
				pstmt.setString(17, "JDBC Column 8 Performance TEST");
				pstmt.setString(18, "JDBC Column 8 Performance TEST");
				pstmt.setDate(19, sDate);
				pstmt.setTimestamp(20, new Timestamp(now.getTimeInMillis()));
				pstmt.executeUpdate();
				cCommit ++;
				if(cCommit == commit){
					con.commit();
					cCommit = 0;
				}
			}
			con.commit();
		}else{
			for(int i = start; i <= end; i++){
				pstmt.setInt(1, i);
				pstmt.setInt(2, i);
				pstmt.setInt(3, i);
				pstmt.setInt(4, i);
				pstmt.setInt(5, i);
				pstmt.setInt(6, i);
				pstmt.setInt(7, i);
				pstmt.setInt(8, i);
				pstmt.setInt(9, i);
				pstmt.setInt(10, i);
				pstmt.setString(11, "JDBC Column 4 Performance TEST");
				pstmt.setString(12, "JDBC Column 5 Performance TEST");
				pstmt.setString(13, "JDBC Column 6 Performance TEST");
				pstmt.setString(14, "JDBC Column 7 Performance TEST");
				pstmt.setString(15, "JDBC Column 8 Performance TEST");
				pstmt.setString(16, "JDBC Column 8 Performance TEST");
				pstmt.setString(17, "JDBC Column 8 Performance TEST");
				pstmt.setString(18, "JDBC Column 8 Performance TEST");
				pstmt.setDate(19, sDate);
				pstmt.setTimestamp(20, new Timestamp(now.getTimeInMillis()));
				pstmt.executeUpdate();
			}
		}
		endTime = System.currentTimeMillis();
		spendTime = (endTime - startTime);

		Information(num, spendTime, count);
		pstmt.close();
		}catch(SQLException e){
			SQLExcept(con, e);
		}catch(Exception e1){
			logger.error("  Error Message : " + e1.getMessage() );
			System.exit( -1 );
		}
	}
	public void Update(Connection con, int start, int end, long commit, String cMode) throws Exception {
	
		long startTime = 0;
		long endTime   = 0;
		double spendTime = 0.0;
		long tps       = 0;
		int count     = 0;
		int cCommit		= 0;

		if (end - start + 1 < 0){
			count = 0;
		}else{
			count = end - start + 1;
		}

		try{
			PreparedStatement pstmt = con.prepareStatement("UPDATE PF_TEST SET C2 = ? WHERE C1 = ?");
			java.util.Date uDate = new java.util.Date();
			java.sql.Date  sDate = new java.sql.Date(uDate.getTime());

			startTime = System.currentTimeMillis();
			if(cMode.equals("F")){
				for(int i = start; i <= end; i++){
					pstmt.setInt(1, i + 1);
					pstmt.setInt(2, i);
					pstmt.executeUpdate();
					cCommit ++;
					if(cCommit == commit){
						con.commit();
						cCommit = 0;
					}
				}
				con.commit();
			}else{
				for(int i = start; i <= end; i++){
					pstmt.setInt(1, i + 1);
					pstmt.setInt(2, i);
					pstmt.executeUpdate();
				}
			}
			endTime = System.currentTimeMillis();
			spendTime = (endTime - startTime);

			Information(num, spendTime, count);
			pstmt.close();
		}catch(SQLException e){
			SQLExcept(con, e);
		}catch(Exception e1){
			logger.error("  Error Message : " + e1.getMessage() );
			System.exit( -1 );
		}
	}
	public void Delete(Connection con, int start, int end, long commit, String cMode) {

		long startTime = 0;
		long endTime   = 0;
		double spendTime = 0.0;
		long tps       = 0;
		int count     = 0;
		int cCommit	= 0;

		if (end - start + 1 < 0){
			count = 0;
		}else{
			count = end - start + 1;
		}

		try{
			PreparedStatement pstmt = con.prepareStatement("DELETE FROM PF_TEST WHERE C1 = ?");
			java.util.Date uDate = new java.util.Date();
			java.sql.Date  sDate = new java.sql.Date(uDate.getTime());

			startTime = System.currentTimeMillis();
			if(cMode.equals("F")){
				for(int i = start; i <= end; i++){
					pstmt.setInt(1, i);
					pstmt.executeUpdate();
					cCommit ++;
					if(cCommit == commit){
						con.commit();
						cCommit = 0;
					}
				}
				con.commit();
			}else{
				for(int i = start; i <= end; i++){
					pstmt.setInt(1, i);
					pstmt.executeUpdate();
				}
			}
			endTime = System.currentTimeMillis();
			spendTime = (endTime - startTime);

			Information(num, spendTime, count);
			pstmt.close();
		}catch(SQLException e){
			SQLExcept(con, e);
		}catch(Exception e1){
			logger.error("  Error Message : " + e1.getMessage() );
			System.exit( -1 );
		}
	}

	public void setTPS(int i){
		this.avTPS = this.avTPS + i;
	}
	public int getTPS(){
		return this.avTPS;
	}
}
