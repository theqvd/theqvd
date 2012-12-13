package com.theqvd.client.jni;

/**
 * 
 * Represents a QVD client object
 * 
 * @author nito
 *
 */
public class Qvdclient {
	private String username;
	private String password;
	private String host;
	private int port;
	private Vm vmlist[];
	
	public Qvdclient(String username, String password, String host, int port) {
		this.username = username;
		this.password = password;
		this.host = host;
		this.port = port;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getHost() {
		return host;
	}
	public void setHost(String host) {
		this.host = host;
	}
	public int getPort() {
		return port;
	}
	public void setPort(int port) {
		this.port = port;
	}
	public Vm[] getVmlist() {
		return vmlist;
	}
	public void setVmlist(Vm vmlist[]) {
		this.vmlist = vmlist;
	}
	@Override
	public String toString() {
		String s = "host:"+host+";port="+port+";user="+username+";pass=****;vmlist=";
		int i = 0;
		for(i=0; i < vmlist.length; ++i) {
			s+="["+i+"]="+vmlist[i]+";";
		}
		return s;
	}
}

