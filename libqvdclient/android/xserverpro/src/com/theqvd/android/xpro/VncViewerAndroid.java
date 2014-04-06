package com.theqvd.android.xpro;
/**
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 * 
 * xvncpro is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * xvncpro is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */
import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

public class VncViewerAndroid implements VncViewer {
	static final String tag = L.xvncbinary + "-VncViewerAndroid-" +java.util.Map.Entry.class.getSimpleName();
	final static String vncpackage = "android.androidVNC";
	private static Activity activity;
	private Config config;
	PendingIntent contentVncIntent;
	Intent vncIntent;
	
	VncViewerAndroid(Activity a) {
		activity = a;
		config = new Config(activity);
		String cmd = Config.vnccmd;
		vncIntent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(cmd));
		vncIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		contentVncIntent = PendingIntent.getActivity(activity, 0, vncIntent, 0);
	}

	@Override
	public void launchVncViewer() throws XvncproException {
		Log.i(tag, "launching vncviewer androidvnc with activity="+activity+"; vncIntent="+vncIntent);
		if (!isInstalled()) {
			throw new XvncproException("Error internal: trying to launch AndroidVnc which is not installed");
		}
		activity.startActivityForResult(vncIntent, Config.vncActivityRequestCode);
	}
	
	@Override
	public void stopVncViewer() {
		Log.i(tag, "Stopping activity with activity code " + Config.vncActivityRequestCode);
		if (!isInstalled()) {
			Log.e(tag, "Error internal: Trying to stop a non installed AndroidVNC");
			return;
		}
		activity.finishActivity(Config.vncActivityRequestCode);
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
		String text = activity.getString(L.r_androidvnc_button_string);
		return text;
	}
	@Override
	public String getDescriptionText() {
		String text = activity.getString(L.r_androidvnc_install_string);
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
