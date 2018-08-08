import java.sql.*;
import javax.sql.*;
import java.util.*;
//import sunje.goldilocks.jdbc.GoldilocksDataSource;
//import sunje.sundb.jdbc.SundbDataSource;

import java.io.*;
import org.json.simple.*;
import org.json.simple.parser.*;

import org.apache.log4j.Logger;

public class Main
{
	private static final Logger logger = Logger.getLogger(Main.class.getName());
	public static void main(String args[]) throws Exception {
		System.out.println();

		// Check Argument
		if(args.length != 3){
			logger.error("  Argument Not Match To Execute Program.\n" +
			             "  Usage(Select(s), Insert(i), Delete(d), Update(u)) : java JdbcSample (Thread_count) (Total Row_count) (Mode)" );
			System.exit(-1);
		}

		// JSON Parsing
		CheckJSON cjson = new CheckJSON();
		cjson.check();
		if(cjson.getMode().equals("D")){
			logger.info("  Driver : " + cjson.getDriver() + "\n" +
					    "  Url    : " + cjson.getURL_DA() + "\n" +
					    "  ID     : " + cjson.getUser() + "\n" +
					    "  PW     : " + cjson.getPassword());
		}
		else if(cjson.getMode().equals("T")){
			logger.info("  Driver : " + cjson.getDriver() + "\n" +
					    "  Url    : " + cjson.getURL_TCP() + "\n" +
					    "  ID     : " + cjson.getUser() + "\n" +
					    "  PW     : " + cjson.getPassword());
		}else{
			logger.error("  Not Proper Mode. Please Input T or D In Mode Value OF JSON File To Execute");
			System.exit(-1);
		}

		int threadCount = 0;
		int rowCount = 0;
		char Mode = '\u0000';

		if(args.length == 2){
			threadCount = Integer.parseInt(args[0]);
			rowCount = Integer.parseInt(args[1]);
			Mode = 's';
			if(threadCount < 1){
				logger.error("  Thread Count Less Than 1");
				System.exit(-1);
			}
			if(rowCount < 1){
				logger.error("  Row Count Less Than 1");
				System.exit(-1);
			}
			logger.info("  Thread Count : " + threadCount + "\n" +
					    "  Mode         : " + Mode);
		}
		else if(args.length == 3){
			threadCount = Integer.parseInt(args[0]);
			rowCount = Integer.parseInt(args[1]);
			Mode = args[2].charAt(0);

			if(threadCount < 1){
				logger.error("  Thread Count Less Than 1");
				System.exit(-1);
			}
			if(rowCount < 1){
				logger.error("  Row Count Less Than 1");
				System.exit(-1);
			}
			if(Mode != 's' && Mode != 'i' && Mode != 'd' && Mode != 'u'){
				logger.error("  Not Proper Mode. Input s, i, d or u");
				System.exit(-1);
			}
			logger.info("  Thread Count : " + threadCount + "\n" +
					    "  Row Count    : " + rowCount + "\n" +
						"  Mode         : " + Mode);
		}

		System.out.println();

		int init = 1;
		int init_div = rowCount / threadCount ;
		int init_mod = rowCount % threadCount ;

		if(Mode == 's'){
			init = rowCount;
			init_div = 0;
		}

		MultiThread[] mt = new MultiThread[threadCount];
		for(int i = 0 ; i < threadCount ; i ++){
			if( i != (threadCount-1) ){
				mt[i] = new MultiThread(i, threadCount, Mode, init, init + init_div - 1);
			}else{
				mt[i] = new MultiThread(i, threadCount, Mode, init, init + init_div + init_mod - 1);
			}
			mt[i].start();
			init = init + init_div;
		}

		for(int i = 0; i < threadCount ; i ++){
            mt[i].sleep(5);
			mt[i].join();
		}

		System.out.println();
		logger.info("  Average TPS is : " + ( mt[0].getTPS() / threadCount ) + "\n" +
				    "  Session TPS is : " + ( mt[0].getTPS()));

		System.out.println();
	}
}

