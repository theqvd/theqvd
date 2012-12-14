package com.theqvd.android.client;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.theqvd.android.xpro.Config;
import com.theqvd.client.jni.QvdProgressHandler;

public class ConnectionProgress implements QvdProgressHandler {
	static final String tag = Config.xvncbinary + "-ConnectionProgress-" +java.util.Map.Entry.class.getSimpleName();
	Activity activity;
	ConnectionProgress(Activity activity) {
		this.activity = activity;
	}

	@SuppressWarnings("deprecation")
	@Override
	public void print_progress(String message) {
		Intent qvdclientActivity = new Intent(activity, QvdclientActivity.class);
		PendingIntent qvdclientActivityPI = PendingIntent.getActivity(activity, 0, qvdclientActivity, 0);

		NotificationManager mNotificationManager = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
		Notification notification = new Notification(R.drawable.icon, "QVD connection", System.currentTimeMillis());
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.setLatestEventInfo(activity, message, message, qvdclientActivityPI);
		mNotificationManager.notify(Qvdconnection.connectnotify, notification);
		
	}

}
