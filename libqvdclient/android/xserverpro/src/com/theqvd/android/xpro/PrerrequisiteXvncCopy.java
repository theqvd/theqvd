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
import java.io.IOException;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.StatFs;
import android.util.Log;
import android.view.View;

public class PrerrequisiteXvncCopy implements Prerrequisite {
	static final String tag = L.xvncbinary + "-PrerrequisiteXvncCopy-" +java.util.Map.Entry.class.getSimpleName();
	private static Context context;
	private Config config;
	private boolean useNotifyUpdates;
	private int mProgressStatus = 0;
	private Handler uiHandler;
	
	PrerrequisiteXvncCopy(Context c) {
		context = c;
		config = new Config(context);
		useNotifyUpdates = false;
	}
	
	private static Long kbytesavailable = -1L;
	private Long getKbytesAvailable() {
		if (kbytesavailable == -1) {
			StatFs fs = new StatFs(config.getTargetdir());
			kbytesavailable = Long.valueOf(fs.getAvailableBlocks()) * Long.valueOf(fs.getBlockSize());
			Log.d(tag,"Blocks available:"+fs.getAvailableBlocks()+"; block size:"+fs.getBlockSize()+
					";kbytes available="+kbytesavailable);
			kbytesavailable = kbytesavailable / 1024;
			Log.d(tag,"Blocks available:"+fs.getAvailableBlocks()+"; block size:"+fs.getBlockSize()+
					";kbytes available="+kbytesavailable);
		}
		return kbytesavailable;
	}
	private Long getMegaBytesAvailable() {
		return getKbytesAvailable()/1024L;
	}

	private boolean enoughSpaceAvailable() {
		long mbytesavailable = getMegaBytesAvailable();
		Log.d(tag, "The MB available are:" + mbytesavailable+" and the MBytes needed are:"+(Integer.valueOf(Config.xvncsizerequired).toString()));
		return mbytesavailable > Config.xvncsizerequired;
	}
	
	@Override
	public boolean isInstalled() {
		return config.is_xvncbinary_copied();
	}

	private void sendErrorAlert(String error) {
		Message m = config.getUiHandler().obtainMessage(Config.SENDALERT);
		Bundle b = new Bundle();
		b.putString(Config.messageTitle, context.getResources().getString(L.r_errorincopytitle));
		b.putString(Config.messageText, context.getResources().getString(L.r_errorincopy)+error);
		m.setData(b);
		config.getUiHandler().sendMessage(m);
	}
	private void copy() {
		AssetManager am = context.getAssets();
		try {
			Log.i(tag, "start copying ");
			AssetTreeCopy.copy(am, Config.assetscopydir, config.getTargetdir());
			config.set_xvncbinary_copied(AssetTreeCopy.isCopied());
			Log.i(tag, "end copying  ");
		} catch (IOException e) {
			Log.e(tag, "Error in copy " + e);
			AssetTreeCopy.setError(true);
			sendErrorAlert(e.toString());
		} catch (InterruptedException e) {
			Log.e(tag, "Error in copy " + e);
			AssetTreeCopy.setError(true);
			sendErrorAlert(e.toString());
		} catch (XvncproException e) {
			Log.e(tag, "Error in copy " + e);
			AssetTreeCopy.setError(true);
			sendErrorAlert(e.toString());
		}
	}
	@Override
	public void install() {
		if (!enoughSpaceAvailable()) {
			sendErrorAlert(context.getString(L.r_xvnccopy_not_enough_space));
			return;
		}
		
		Thread progress = new Thread(new Runnable() {
			private void setProgressBarVisibility(int visibility) {
				Log.d(tag, "message setProgressBarVisibility:"+visibility);
				Message m = config.getUiHandler().obtainMessage(Config.SETPROGRESSVISIBILITY);
				Bundle b = new Bundle();
				b.putInt(Config.progressVisibility, visibility);
				m.setData(b);
				config.getUiHandler().sendMessage(m);
			}
			private void setProgressBarProgress(int progress) {
				Log.d(tag, "message setProgressBarProgress:"+progress);
				Message m = config.getUiHandler().obtainMessage(Config.SETCOPYPROGRESS);
				Bundle b = new Bundle();
				b.putInt(Config.copyProgress, progress);
				m.setData(b);
				config.getUiHandler().sendMessage(m);
			}
			private void updateButtons() {
				Log.d(tag, "message updateButtons");
				Message m = config.getUiHandler().obtainMessage(Config.UPDATEBUTTONS);
				config.getUiHandler().sendMessage(m);
			}
			private void sendCopyFinished() {
				Log.d(tag, "message updateButtons");
				Message m = config.getUiHandler().obtainMessage(Config.PRERREQUISITEINSTALLED);
				config.getUiHandler().sendMessage(m);
			}
			public void run() {
				setProgressBarVisibility(View.VISIBLE);
				mProgressStatus = 0;
				setProgressBarProgress(mProgressStatus);
				while (mProgressStatus < 100) {
					mProgressStatus = AssetTreeCopy.getPercentageOfFilesCopied();
					try { Thread.sleep(200); } catch (InterruptedException e) {	Log.w(tag, "Thread sleep interrupted " + e); }
					// Update the progress bar 
					setProgressBarProgress(mProgressStatus);
				}
				setProgressBarVisibility(View.GONE);
				updateButtons();
				sendCopyFinished();
			}
		});

		Thread worker = new Thread(new Runnable() {
			public void run() {
				copy();
			}
		});
		
		if (getuiHandler() != null) {
			progress.start();
		} else {
			Log.e(tag, "Error, uiHandler or progressbar were not defined, this should not happen");
		}

		worker.start();
	}
	@Override
	public String getButtonText() {
		String text = context.getString(L.r_xvnccopy_button_string);
		return text;
	}
	@Override
	public String getDescriptionText() {
		String text = context.getString(L.r_xvnccopy_install_string);
		return text;
	}

	public boolean isUseNotifyUpdates() {
		return useNotifyUpdates;
	}

	public void setUseNotifyUpdates(boolean useNotifyUpdates) {
		this.useNotifyUpdates = useNotifyUpdates;
	}

	private Handler getuiHandler() {
		return uiHandler;
	}

	public void setuiHandler(Handler mHandler) {
		this.uiHandler = mHandler;
	}

}
