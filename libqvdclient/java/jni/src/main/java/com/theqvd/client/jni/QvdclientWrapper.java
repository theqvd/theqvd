package com.theqvd.client.jni;

/**
 *
 * Represents a JNI wrapper to the qvdclient library.
 *
 * The wrapper is made up of two components:
 * 1) This class
 * 2) The qvdclientwrapper library which is jni wrapper to the qvdclient library
 *
 * The methods wrapped are the "public" methods for the qvdclient library
 * - qvd_init
 * - qvd_free
 * - qvd_list_of_vm
 * - qvd_connect_to_vm
 *
 * It uses an instance of Qvdclient to store the internal info like username, password, host and port.
 * This instance can be seen as a counterpart of the qvdclient struct defined in qvdclient.h, although
 * the data is not shared between the C library and the java object, it is only copied between both
 * structures.
 *
 * @author Nito@Qindel.ES
 *
 */
public class QvdclientWrapper {
	private Qvdclient qvdclient;

	private long qvd_c_pointer = 0;
	private final static String library = "qvdclientwrapper";
	private final int MAX_SCREEN_SIZE = 32565;
	private native static String qvd_c_get_version_text();
	private native static int qvd_c_get_version();
	private native long qvd_c_init(Qvdclient q);
	private native void qvd_c_free(long qvdclient);
	private native int qvd_c_connect_to_vm(long qvdclient, int i);
	private native Vm[] qvd_c_list_of_vm(long qvdclient);
	private native int qvd_c_stop_vm(long qvdclient, int i);
	private native void qvd_c_set_geometry(long qvdclient, int width, int height);
	private native void qvd_c_set_fullscreen(long qvdclient);
	private native void qvd_c_set_nofullscreen(long qvdclient);
	private native void qvd_c_set_debug();
	private native void qvd_c_set_display(long qvdclient, String display);
	private native void qvd_c_set_home(long qvdclient, String home);
	private native void qvd_c_set_useragent(long qvdclient, String useragent);
	private native void qvd_c_set_os(long qvdclient, String os);
	private native void qvd_c_set_link(long qvdclient, String geometry);
	private native void qvd_c_set_no_cert_check(long qvdclient);
	private native void qvd_c_set_strict_cert_check(long qvdclient);
	private native void qvd_c_set_progress_callback(long qvdclient);
	private native void qvd_c_set_no_progress_callback(long qvdclient);
	private native String qvd_c_get_last_error_message(long qvdclient);
	private native void qvd_c_set_nx_options(long qvdclient, String nx_options);
	private native void qvd_c_set_cert_files(long qvdclient, String client_cert, String client_key);
	private native void qvd_c_end_connection(long qvdclient);
	private native int qvd_c_payment_required(long qvdclient);
	private QvdUnknownCertificateHandler certificateHandler = null;
	private QvdProgressHandler progressHandler = null;

	public static int get_version() {
		return qvd_c_get_version();
	}

	public static String get_version_text() {
		return qvd_c_get_version_text();
	}

	public void qvd_init(String host, int port, String username, String password) throws QvdException {

		if (qvd_c_pointer != 0) {
			throw new QvdException("Unexpected that c pointer is not 0 when running init_qvd");
		}
		qvdclient = new Qvdclient(username, password, host, port);
		qvd_c_pointer = qvd_c_init(qvdclient);
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_init a null pointer was returned");
		}
		certificateHandler = null;
		progressHandler = null;
	}

	public void qvd_list_of_vm() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_list_of_vm. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		Vm v[] = qvd_c_list_of_vm(this.qvd_c_pointer);
		if (v == null) {
			throw new QvdException("Error in qvd_list_of_vm no vm list data has been returned: " + qvd_c_get_last_error_message(qvd_c_pointer));
		}
		qvdclient.setVmlist(v);
		if (v.length == 0)
			throw new QvdException(qvd_c_get_last_error_message(qvd_c_pointer));
	}

	public void qvd_connect_to_vm(int vm_id) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_connect_to_vm. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		if (qvdclient.getVmlist() == null) {
			throw new QvdException("You are trying to connect to a vm but no list of vms is available." +
					"Have you called qvd_list_of_vm, or does the user has any vm?");
		}
		if (vm_id < 0) {
			throw new QvdException("You are trying to connect to a vm not available vm_id="+ vm_id);
		}
		Vm vlist[] = qvdclient.getVmlist();
		Vm v;
		int i;
		boolean found = false;
		String vliststr="";
		for (i = 0; i < vlist.length; i ++)
		{
			v = vlist[i];
			vliststr += v + ";";
			found |= v.getId() == vm_id;
			if (found) {
				break;
			}
		}
		if (!found)
		{
			throw new QvdException("You are trying to connect to a vm not available vm_id="+ vm_id + ". Vmlist="+vliststr);
		}

		if (qvd_c_connect_to_vm(this.qvd_c_pointer, vm_id) != 0) {
			throw new QvdException(qvd_c_get_last_error_message(qvd_c_pointer));
		}
	}


	public void qvd_stop_vm(int vm_id) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_stop_vm. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		if (qvdclient.getVmlist() == null) {
			throw new QvdException("You are trying to stop a vm but no list of vms is available." +
					"Have you called qvd_list_of_vm, or does the user has any vm?");
		}
		if (vm_id < 0) {
			throw new QvdException("You are trying to connect to a vm not available vm_id="+ vm_id);
		}
		Vm vlist[] = qvdclient.getVmlist();
		Vm v;
		int i;
		boolean found = false;
		String vliststr="";
		for (i = 0; i < vlist.length; i ++)
		{
			v = vlist[i];
			vliststr += v + ";";
			found |= v.getId() == vm_id;
			if (found) {
				break;
			}
		}
		if (!found)
		{
			throw new QvdException("You are trying to stop a vm not available vm_id="+ vm_id + ". Vmlist="+vliststr);
		}

		if (qvd_c_stop_vm(this.qvd_c_pointer, vm_id) != 0) {
			throw new QvdException(qvd_c_get_last_error_message(qvd_c_pointer));
		}
	}

	public void qvd_free() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Unexpected that c pointer is not defined when running qvd_free");
		}
		qvd_c_free(qvd_c_pointer);
		qvd_c_pointer = 0;
	}


	public Qvdclient getQvdclient() {
		return qvdclient;
	}

	public void setQvdclient(Qvdclient qvdclient) {
		this.qvdclient = qvdclient;
	}

	public void qvd_set_geometry(int width, int height) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_geometry. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		if (width < 0 || width > MAX_SCREEN_SIZE ||
				height < 0 || height > MAX_SCREEN_SIZE) {
			throw new QvdException("width or height is not between 0-"+MAX_SCREEN_SIZE + ". width="+width+"height="+height);
		}

		qvd_c_set_geometry(qvd_c_pointer, width, height);
	}
	public void qvd_set_fullscreen() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_fullscreen. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_fullscreen(qvd_c_pointer);
	}
	public void qvd_set_nofullscreen() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_nofullscreen. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_nofullscreen(qvd_c_pointer);
	}
	public void qvd_set_debug() {
		qvd_c_set_debug();
	}
	public void qvd_set_display(String display) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_display. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_display(qvd_c_pointer, display);
	}
	public void qvd_set_home(String home) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_home. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_home(qvd_c_pointer, home);
	}
	public void qvd_set_useragent(String useragent) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_useragent. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_useragent(qvd_c_pointer, useragent);
	}
	public void qvd_set_os(String os) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_os. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_os(qvd_c_pointer, os);
	}
	public void qvd_set_link(String link) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_link. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_link(qvd_c_pointer, link);
	}
	public void qvd_set_no_cert_check() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_no_cert_check. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_no_cert_check(qvd_c_pointer);
	}
	public void qvd_strict_cert_check() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_strict_cert_check. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_strict_cert_check(qvd_c_pointer);
	}
	public void qvd_set_certificate_handler_callback(QvdUnknownCertificateHandler certificateHandler) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_certificate_handler_callback. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		this.certificateHandler = certificateHandler;
		if (certificateHandler == null) {
			qvd_c_set_no_progress_callback(qvd_c_pointer);
		} else {
			qvd_c_set_progress_callback(qvd_c_pointer);
		}

	}
	public void qvd_set_progress_handler_callback(QvdProgressHandler progressHandler) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_progress_handler_callback. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		this.progressHandler = progressHandler;

		if (progressHandler == null) {
			qvd_c_set_no_progress_callback(qvd_c_pointer);
		} else {
			qvd_c_set_progress_callback(qvd_c_pointer);
		}
	}
	public void qvd_set_nx_options(String nx_options) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_nx_options. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_nx_options(qvd_c_pointer, nx_options);
	}
	public void qvd_set_cert_files(String client_cert, String client_key) throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_set_cert_files. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_set_cert_files(qvd_c_pointer, client_cert, client_key);
	}
	public void qvd_end_connection() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_end_connection. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		qvd_c_end_connection(qvd_c_pointer);
	}
	public Boolean qvd_payment_required() throws QvdException {
		if (qvd_c_pointer == 0) {
			throw new QvdException("Error in qvd_payment_required. qvd_c_pointer is 0 and it should not be, have you called qvd_init?");
		}
		return (qvd_c_payment_required(qvd_c_pointer) != 0);
	}
	static {
		System.loadLibrary(library);
	}


}
