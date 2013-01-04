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
	static final String tag = Config.xvncbinary + "-VncViewerPocketCloud-" +java.util.Map.Entry.class.getSimpleName();
	static final String vncpackage = "com.wyse.pocketcloudfull";
	private static Activity activity;
//	private final int vncActivityRequestCode = 11;
	private Config config;
	PendingIntent contentVncIntent;
	boolean configcopied;

	VncViewerPocketCloud(Activity c) {
		activity = c;
		config = new Config(activity);
		setConfigcopied(false);
	}
	@Override
	public void launchVncViewer() {
		Log.i(tag, "launching vncviewer androidvnc");
		Uri uri = Uri.parse("pocketcloud://file://"+Config.pocketvncconfigfullpath);
		Log.i(tag, "Clicked on connect" + uri );
		Intent vncIntent = new Intent();
		vncIntent.setAction(Intent.ACTION_VIEW);
		vncIntent.setData(uri);
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
    		.setMessage(activity.getResources().getString(R.string.errorincopytitle))
    		.setTitle(activity.getResources().getString(R.string.errorincopy)+e.toString())
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
		String text = activity.getString(R.string.pocketvnc_button_string);
		return text;
	}
	@Override
	public String getDescriptionText() {
		String text = activity.getString(R.string.pocketvnc_install_string);
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
