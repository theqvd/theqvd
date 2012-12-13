package com.theqvd.client.jni;

/*
 * This interface is invoked by the progress callback from the JNI interface
 * 
 */

public interface QvdProgressHandler {
	/*
	 * Message that will be printed or otherwise shown to the user
	 */
	public void print_progress(String message);
}
