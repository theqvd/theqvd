package com.theqvd.client.jqvdclient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import com.theqvd.client.jni.QvdUnknownCertificateHandler;

/*
 * 
 */
public class AcceptUnknownCertHandler implements QvdUnknownCertificateHandler {

	//@Override
	public boolean certificate_verification(String cert_description,
			String cert_pem_data) {
		String response;
		InputStreamReader inp = new InputStreamReader(System.in);
		BufferedReader br = new BufferedReader(inp);
		System.out.println("Unknown certificate\n"+cert_description+"\nDo you want to accept it?");
		try {
			response = br.readLine();
		} catch (IOException e) {
			System.err.print(e);
			return false;
		}
		if (response.contentEquals("y") || response.contentEquals("Y") || 
				response.contentEquals("Yes") || response.contentEquals("YES")) {
			return true;
		}
		return false;
	}

}
