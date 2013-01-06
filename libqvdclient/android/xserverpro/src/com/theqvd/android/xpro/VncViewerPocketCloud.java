package com.theqvd.android.xpro;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetManager;
import android.net.Uri;
import android.util.Log;

public class VncViewerPocketCloud implements VncViewer {
	static final String tag = L.xvncbinary + "-VncViewerPocketCloud-" +java.util.Map.Entry.class.getSimpleName();
	static final String vncpackage = "com.wyse.pocketcloudfull";
	private static Activity activity;
	private Config config;
	PendingIntent contentVncIntent;
	boolean configcopied;
	Intent vncIntent;

	VncViewerPocketCloud(Activity c) {
		activity = c;
		config = new Config(activity);
		setConfigcopied(false);
		Uri uri = Uri.parse("pocketcloud://file://"+Config.pocketvncconfigfullpath);
		Log.i(tag, "pocketcloud uri when connect is" + uri );
	    vncIntent = new Intent(Intent.ACTION_VIEW, uri);
		vncIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		contentVncIntent = PendingIntent.getActivity(activity, 0, vncIntent, 0);
	}
	@Override
	public void launchVncViewer() throws XvncproException {
		Log.i(tag, "launching vncviewer PocketCloud");
		if (!isInstalled()) {
			throw new XvncproException("Error internal: trying to launch PocketCloud which is not installed");
		}
		activity.startActivityForResult(vncIntent, Config.vncActivityRequestCode);
	}

	@Override
	public void stopVncViewer() {
		Log.i(tag, "Stopping activity with activity code " + Config.vncActivityRequestCode);
		if (!isInstalled()) {
			Log.e(tag, "Error internal: Trying to stop a non installed PocketCloud");
			return;
		}
		activity.finishActivity(Config.vncActivityRequestCode);
	}
	@Override
	public boolean isInstalled() {
		return isConfigcopied() && config.packageInstalled(vncpackage);
	}

	private void copyXvncConfig(AssetManager am, String srcFile)
			throws IOException
	{
		String destFile = srcFile;
		InputStream oInStream;
		OutputStream oOutStream;
		BufferedInputStream oBuffInputStream;
		oInStream = am.open(srcFile);
		Log.d(tag, "copying file from assets " + srcFile + " to outputstream");
		oOutStream = activity.openFileOutput(destFile, Activity.MODE_WORLD_READABLE);
		oBuffInputStream = new BufferedInputStream( oInStream, 8192 );
		byte[] oBytes = new byte[8192];
		int nLength;
		while ((nLength = oBuffInputStream.read(oBytes)) > 0)
		{
			oOutStream.write(oBytes, 0, nLength);
		}
		oInStream.close();
		oOutStream.close();
	}

	@Override
	public void install() {
		if (!config.packageInstalled(vncpackage))
			config.installPackage(vncpackage);
		if (isConfigcopied())
			return;
		AssetManager am = activity.getAssets();
		try {
			Log.i(tag, "start copying " + Config.pocketvncconfig);
			copyXvncConfig(am, Config.pocketvncconfig);
			setConfigcopied(true);
			Log.i(tag, "end copying " + Config.pocketvncconfig);	
		} catch (IOException e) {
			Log.e(tag, "Error in copy " + e);
			AlertDialog.Builder builder = new AlertDialog.Builder(activity);
    		builder
    		.setMessage(activity.getResources().getString(L.r_errorincopytitle))
    		.setTitle(activity.getResources().getString(L.r_errorincopy)+e.toString())
    		.setCancelable(true)
    		.setNeutralButton(activity.getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
    			public void onClick(DialogInterface dialog, int id) {
    				dialog.cancel();
    			}
    		}).show();
    		AlertDialog alert = builder.create();
    		alert.isShowing();
		}
	}
	@Override
	public String getButtonText() {
		String text = activity.getString(L.r_pocketvnc_button_string);
		return text;
	}
	@Override
	public String getDescriptionText() {
		String text = activity.getString(L.r_pocketvnc_install_string);
		return text;
	}
	@Override
	public PendingIntent getContentVncIntent() {
		return contentVncIntent;
	}
	private boolean isConfigcopied() {
		if (configcopied)
			return configcopied;
		File pocketvncconfig = new File(Config.pocketvncconfigfullpath);
		setConfigcopied(pocketvncconfig.exists()); 
		Log.d(tag, "Config for vnc "+Config.pocketvncconfigfullpath+" was copied:"+configcopied);
		return configcopied;
	}
	private void setConfigcopied(boolean configcopied) {
		this.configcopied = configcopied;
	}
	@Override
	public Activity getActivity() {
		return activity;
	}


}
