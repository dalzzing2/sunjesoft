import java.util.*;

import java.io.*;
import org.json.simple.*;
import org.json.simple.parser.*;

public class CheckJSON
{
	String driver = null;
	String url_da = null;
	String url_tcp = null;
	String user = null;
	String password = null;
	String mode = null;
	String auto_commit = null;
	long commit = 0;

	public class checkJSON{}
	
	public void check() throws Exception{
		JSONParser parser = new JSONParser();
		Object obj = parser.parse(new FileReader("./conf/sunje.json"));
		JSONObject jo = (JSONObject) obj;

		
		setDriver((String) jo.get("JDBCDriver"));
		setURL_DA((String) jo.get("JDBCUrl_DA"));
		setURL_TCP((String) jo.get("JDBCUrl_TCP"));
		setUser((String) jo.get("User"));
		setPassword((String) jo.get("Password"));
		setMode((String) jo.get("Mode"));
		setAutoCommit((String) jo.get("AutoCommit"));
		setCommit(Long.parseLong((String)jo.get("Commit")));

		/*
		System.out.println(getDriver());
		System.out.println(getURL_DA());
		System.out.println(getURL_TCP());
		System.out.println(getUser());
		System.out.println(getPassword());
		System.out.println(getMode());
		System.out.println(getCommit());
		*/
	}

	public void setDriver(String driver){
		this.driver = driver;
	}
	public String getDriver(){
		return driver;
	}

	public void setURL_DA(String url_da){
		this.url_da = url_da;
	}
	public String getURL_DA(){
		return url_da;
	}

	public void setURL_TCP(String url_tcp){
		this.url_tcp = url_tcp;
	}
	public String getURL_TCP(){
		return url_tcp;
	}

	public void setUser(String user){
		this.user = user;
	}
	public String getUser(){
		return user;
	}

	public void setPassword(String password){
		this.password = password;
	}
	public String getPassword(){
		return password;
	}

	public void setMode(String mode){
		this.mode = mode;
	}
	public String getMode(){
		return mode;
	}

	public void setCommit(long commit){
		this.commit = commit;
	}
	public long getCommit(){
		return commit;
	}

	public void setAutoCommit(String auto_commit){
		this.auto_commit = auto_commit;
	}
	public String getAutoCommit(){
		return auto_commit;
	}
}
