package com.theqvd.android.client;


/**
 * 
 * Represents a QVD currconnection
 * 
 * @author nito
 *
 */
public class Connection implements Comparable<Connection> {
	private String name, host, link, login, password, keyboard, os, xserverhost, client_cert, client_key;
	private int port, height, width, xserverport;
	private static int defaultHeight=600, defaultWidth=800;
	private boolean fullscreen, debug, uselocalxserver, useclientcert;
	
	public Connection() {
		name = "";
		host = "";
		link = "adsl";
		login = "";
		password = "";
		keyboard = "pc/105";
		os = "linux";
		
		port = 8443;

		height = Connection.getDefaultHeight();
		width = Connection.getDefaultWidth();
		
		fullscreen = true;
		uselocalxserver = true;
		setDebug(false);
		xserverhost = "127.0.0.1";
		xserverport = 6000;
		useclientcert = false;
		client_cert = "";
		client_key = "";
	}
	public Connection(Connection c) {
		name = new String(c.name);
		host = new String(c.host);
		link = new String(c.link);
		login = new String(c.login);
		password = new String(c.password);
		keyboard = new String(c.keyboard);
		os = new String(c.os);
		port = c.port;
		height = c.height;
		width = c.width;
		fullscreen = c.fullscreen;
		uselocalxserver = c.uselocalxserver;
		debug = c.debug;
		xserverport = c.xserverport;
		xserverhost = c.xserverhost;
		useclientcert = c.useclientcert;
		client_cert = c.client_cert;
		client_key = c.client_key;
	}
	@Override
	public String toString() {
		return name;
	}
	public String dump() {
		return "name:"+name+";host:"+host+";port:"+port+";link=:"+link+
				";login:"+login+";password:****;keyboard:"+keyboard+
				";width="+width+";height:"+height+";fullscreen:"+fullscreen+
				";os:"+os+";debug:"+debug+";xserverport="+xserverport+
				";uselocalx:"+uselocalxserver+";usecert:"+useclientcert+
				";certfile:"+client_cert+";keyfile:"+client_key;
	}
	// We consider two objects equal if the name is equal
	@Override
	public boolean equals(Object obj) {
		if(this == obj)
			return true;

		if((obj == null) || (obj.getClass() != this.getClass())) 
			return false;

		Connection c = (Connection) obj;

		return c.name.equals(this.name);
	}
	
	@Override
	public int hashCode() {
		return this.name.hashCode();
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getHost() {
		return host;
	}

	public void setHost(String host) {
		this.host = host;
	}

	public String getLink() {
		return link;
	}

	public void setLink(String link) {
		this.link = link;
	}

	public String getLogin() {
		return login;
	}

	public void setLogin(String login) {
		this.login = login;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getKeyboard() {
		return keyboard;
	}

	public void setKeyboard(String keyboard) {
		this.keyboard = keyboard;
	}

	public String getOs() {
		return os;
	}

	public void setOs(String os) {
		this.os = os;
	}

	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public int getHeight() {
		return height;
	}

	public void setHeight(int height) {
		this.height = height;
	}

	public int getWidth() {
		return width;
	}

	public void setWidth(int width) {
		this.width = width;
	}

	public boolean isFullscreen() {
		return fullscreen;
	}

	public void setFullscreen(boolean fullscreen) {
		this.fullscreen = fullscreen;
	}

	public static int getDefaultHeight() {
		return defaultHeight;
	}

	public static void setDefaultHeight(int defaultHeight) {
		Connection.defaultHeight = defaultHeight;
	}

	public static int getDefaultWidth() {
		return defaultWidth;
	}

	public static void setDefaultWidth(int defaultWidth) {
		Connection.defaultWidth = defaultWidth;
	}
	@Override
	public int compareTo(Connection another) {
		return name.compareTo(another.name);
	}
	public boolean isDebug() {
		return debug;
	}
	public void setDebug(boolean debug) {
		this.debug = debug;
	}
	public boolean isUselocalxserver() {
		return uselocalxserver;
	}
	public void setUselocalxserver(boolean uselocalxserver) {
		this.uselocalxserver = uselocalxserver;
	}
	public int getXserverport() {
		return xserverport;
	}
	public void setXserverport(int xserverport) {
		this.xserverport = xserverport;
	}
	public String getXserverhost() {
		return xserverhost;
	}
	public void setXserverhost(String xserverhost) {
		this.xserverhost = xserverhost;
	}
	public String getClient_cert() {
		return client_cert;
	}
	public void setClient_cert(String client_cert) {
		this.client_cert = client_cert;
	}
	public String getClient_key() {
		return client_key;
	}
	public void setClient_key(String client_key) {
		this.client_key = client_key;
	}
	public boolean isUseclientcert() {
		return useclientcert;
	}
	public void setUseclientcert(boolean useclientcert) {
		this.useclientcert = useclientcert;
	}


}
