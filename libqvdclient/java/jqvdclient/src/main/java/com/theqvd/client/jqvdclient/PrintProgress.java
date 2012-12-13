package com.theqvd.client.jqvdclient;

import com.theqvd.client.jni.QvdProgressHandler;

public class PrintProgress implements QvdProgressHandler {

	@Override
	public void print_progress(String message) {
		System.out.println(message);
		System.out.flush();
	}

}
