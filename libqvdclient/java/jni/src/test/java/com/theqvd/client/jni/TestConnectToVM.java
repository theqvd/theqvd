package com.theqvd.client.jni;

import static org.junit.Assert.*;

import java.io.InputStream;
import java.util.Properties;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestConnectToVM {
	QvdclientWrapper qvd;
	private String user, password, host;
        private int port, connect;
	@Before
	public void setUp() throws Exception {
		// create and load default properties
		Properties testprops = new Properties();
		InputStream in = getClass().getResourceAsStream("/test.properties");
		testprops.load(in);
		in.close();
		host = testprops.getProperty("test.host");
		port = Integer.parseInt(testprops.getProperty("test.port"));
		user = testprops.getProperty("test.user");
		password = testprops.getProperty("test.password");
		connect = Integer.parseInt(testprops.getProperty("test.connect", "0"));
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
		assertNotNull("qvd is not null", qvd);
		try {
			qvd.qvd_connect_to_vm(0);
			fail("You should not be able to connect to vm before vm_list");
		} catch (QvdException e){
			assertTrue("Exception correctly raised invoking connect_to before vm_list:"+e.toString(), true);
		}
		Qvdclient q = qvd.getQvdclient();
		assertNotNull("Qvdclient is not null", q);
		
		qvd.qvd_list_of_vm();
		int l = qvd.getQvdclient().getVmlist().length;
		System.err.println("Number of vms is "+l);
		try {
			qvd.qvd_connect_to_vm(-1);
			fail("You should not be able to connect to vm before vm_list");
		} catch (QvdException e){
			assertTrue("Exception correctly raised invoking connect_to with id < 0:"+e.toString(), true);
		}
		try {
			qvd.qvd_connect_to_vm(l);
			fail("You should not be able to connect to vm before vm_list");
		} catch (QvdException e){
			assertTrue("Exception correctly raised invoking connect_to with id > "+ l +":"+e.toString(), true);
		}
		if (l != 0 && connect != 0) {
			Vm vmlist[] = qvd.getQvdclient().getVmlist();
			qvd.qvd_connect_to_vm(vmlist[0].getId());
		}
	}

}

