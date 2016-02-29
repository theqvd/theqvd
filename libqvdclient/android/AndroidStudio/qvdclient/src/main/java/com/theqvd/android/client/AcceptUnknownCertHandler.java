package com.theqvd.android.client;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.theqvd.client.jni.QvdUnknownCertificateHandler;

public class AcceptUnknownCertHandler implements QvdUnknownCertificateHandler {
	private static String tag;
	private static BlockingQueue<Boolean> queue;
	private final static int millisecondstowait = 200;
	private Handler handler;
	private static Activity activity = null;
	AcceptUnknownCertHandler(Activity a, Handler h) {
		tag = "AcceptUnknownCertHandler-" +java.util.Map.Entry.class.getSimpleName();
		handler = h;
		activity = a;
		queue = new ArrayBlockingQueue<Boolean>(1);
	}
	@Override
	public boolean certificate_verification(String cert_description, String cert_pem_data) {
		Log.d(tag, "certificate_verification" + cert_description + System.getProperties());
		Message m = handler.obtainMessage(QvdclientActivity.CERTIFICATEEXCEPTION);
		Bundle b = new Bundle();
		b.putString(QvdclientActivity.certDetails, cert_description);
		m.setData(b);
		Log.d(tag, "certificate_verification send message");
		handler.sendMessage(m);
		// wait on setValidCertificate
        return getValidcertificate();
	}
	public static Boolean getValidcertificate() {
		Boolean result = null;
		try {
			Log.d(tag, "getValidcertificate: Wait for queue.poll");
			// Utilizar poll en vez de take
			while (result == null) {			
				result = queue.poll(millisecondstowait, TimeUnit.MILLISECONDS);
			}
		} catch (InterruptedException e) {
			Log.e(tag, "Error waiting for queue, returning false "+e.toString());
			sendNotify(e.toString());
		}
		return result;
	}
	
	public static void setValidcertificate(Boolean vc) {
		try {
			queue.put(vc);
		} catch (InterruptedException e) {
			Log.e(tag, "Error waiting for queue "+e.toString());
			sendNotify(e.toString());
		}
	}
	
	@SuppressWarnings("deprecation")
	private static void sendNotify(String text) {
		if (activity == null) {
			Log.e(tag, "Notifiation not sent because activity is null. Message:"+text);
		}
		String title = activity.getString(com.theqvd.android.client.R.string.connectionerrortitle);
		String message = activity.getString(com.theqvd.android.client.R.string.connectionerrortitle)+text;
		Intent qvdclientActivity = new Intent(activity, QvdclientActivity.class);
		PendingIntent qvdclientActivityPI = PendingIntent.getActivity(activity, 0, qvdclientActivity, 0);
		NotificationManager mNotificationManager = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
		Notification notification = new Notification(com.theqvd.android.client.R.drawable.icon, title, System.currentTimeMillis());
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.setLatestEventInfo(activity, title, message, qvdclientActivityPI);
		mNotificationManager.notify(Qvdconnection.connectnotify, notification);
	}
}
