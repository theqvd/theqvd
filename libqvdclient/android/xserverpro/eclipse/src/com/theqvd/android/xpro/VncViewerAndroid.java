package com.theqvd.android.xpro;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

public class VncViewerAndroid implements VncViewer {
	static final String tag = Config.xvncbinary + "-VncViewerAndroid-" +java.util.Map.Entry.class.getSimpleName();
	final static String vncpackage = "android.androidVNC";
//	private final int vncActivityRequestCode = 11;
	private static Activity activity;
	private Config config;
	PendingIntent contentVncIntent;
	
	VncViewerAndroid(Activity a) {
		activity = a;
		config = new Config(activity);
	}

	@Override
	public void launchVncViewer() {
		Log.i(tag, "launching vncviewer androidvnc");
		String cmd = Config.vnccmd;
		Intent vncIntent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(cmd));
		vncIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		contentVncIntent = PendingIntent.getActivity(activity, 0, vncIntent, 0);
		activity.startActivityForResult(vncIntent, vncActivityRequestCode);
	}
	
	@Override
	public void stopVncViewer() {
		Log.i(tag, "Stopping activity with activity code " + vncActivityRequestCode);
		activity.finishActivity(vncActivityRequestCode);
	}
	@Override
	public boolean isInstalled() {
		return config.packageInstalled(vncpackage);
	}

	@Override
	public void install() {
		config.installPackage(vncpackage);
	}
	@Override
	public String getButtonText() {
		String text = activity.getString(R.string.androidvnc_button_string);
		return text;
	}
	@Override
	public String getDescriptionText() {
		String text = activity.getString(R.string.androidvnc_install_string);
		return text;
	}
	@Override
	public PendingIntent getContentVncIntent() {
		return contentVncIntent;
	}

	@Override
	public Activity getActivity() {
		return activity;
	}

}
