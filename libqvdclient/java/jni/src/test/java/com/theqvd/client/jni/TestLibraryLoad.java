package com.theqvd.client.jni;

import static org.junit.Assert.*;

import java.io.InputStream;
import java.util.Properties;

import org.junit.Before;
import org.junit.Test;

public class TestLibraryLoad {
	private String user, password, host;
	private int port;
	@Before
	public void setUp() throws Exception {
		Properties testprops = new Properties();
		InputStream in = getClass().getResourceAsStream("/test2.properties");
		testprops.load(in);
		in.close();
		host = testprops.getProperty("test.host");
		port = Integer.parseInt(testprops.getProperty("test.port"));
		user = testprops.getProperty("test.user");
		password = testprops.getProperty("test.password");
	}

	@Test
	public void testLibraryLoad() {
		QvdclientWrapper qvd = new QvdclientWrapper();
		assertNotNull("Library load test", qvd);
	}

	@Test
	public void testinitfree() throws QvdException {
		QvdclientWrapper qvd = new QvdclientWrapper();
		qvd.qvd_init(host, port, user, password);
		try {
			qvd.qvd_init(host, port, user, password);
			fail("two consecutive calls to qvd_init fail");
		} catch (QvdException e) {
			assertTrue("Two consecutive qvd_init should fail", true);

		}
		assertNotNull("qvd init worked", qvd.getQvdclient());
		qvd.qvd_free();
		try {
			qvd.qvd_free();
			fail("two consecutive calls to qvd_free fail");
		} catch (QvdException e) {
			assertTrue("Two consecutive qvd_free should fail", true);

		}
		// Run another load
		qvd.qvd_init(host, port, user, password);
		assertNotNull("qvd init worked", qvd.getQvdclient());
		qvd.qvd_set_useragent("QVD/3.1 test useragent");
		qvd.qvd_set_home("/tmp");
		qvd.qvd_set_display(":0");
		qvd.qvd_set_os("Linux");
		qvd.qvd_set_geometry(1024,768);
		qvd.qvd_set_link("adsl");
		qvd.qvd_free();

	}
}
