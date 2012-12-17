package com.theqvd.client.jni;

import static org.junit.Assert.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestVmList {
	QvdclientWrapper qvd;
	private String user, password, host;
	private int port;
	@Before
	public void setUp() throws Exception {
		Properties testprops = new Properties();
		InputStream in = getClass().getResourceAsStream("/testlocal.properties");
		try {
			testprops.load(in);
		} catch (IOException e) {
			in = getClass().getResourceAsStream("/test.properties");
			testprops.load(in);
		}
		in.close();
		host = testprops.getProperty("test.host");
		port = Integer.parseInt(testprops.getProperty("test.port"));
		user = testprops.getProperty("test.user");
		password = testprops.getProperty("test.password");
		qvd = new QvdclientWrapper();
		qvd.qvd_init(host, port, user, password);
		qvd.qvd_set_no_cert_check();
	}
	
	@After
	public void tearDown() throws Exception {
		qvd.qvd_free();
	}
	@Test
	public void test() throws QvdException {
		assertNotNull("Library loaded", qvd);
		Qvdclient q = qvd.getQvdclient();
		assertNotNull("Qvdclient is not null", q);
		qvd.qvd_list_of_vm();
		System.err.println("q:"+q);
//		assertTrue("The list of vms is 0", q.getVmlist().length == 0);
	}

}

