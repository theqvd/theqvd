package com.theqvd.client.jni;

/*
 * This interface is invoked by the certificate callback from the JNI interface
 * 
 * See accept_unknown_cert_callback in com_theqvd_client_jni_QvdclientWrapper.c
 * and qvd_set_unknown_cert_callback in qvdclient.h and qvdclientcore.c
 * 
 */
public interface QvdUnknownCertificateHandler {
	/*
	 * This method receives as the first string a description that should be shown 
	 * to the user and as second argument a string with the certificate
	 * it returns true if the certificate is validated by the user or
	 * false if the certificate is not accepted by the user.
	 * 
	 * Usually this is method implements something like:
	 * 
	 * print cert_description
	 * 
	 * ask if user accepts the string and in that case return true, otherwise it returns false
	 * 
	 * This method is invoked from the JNI interface as a callback for certificate verification.
	 */
	boolean certificate_verification(String cert_description, String cert_pem_data);
}
