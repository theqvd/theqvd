package com.theqvd.android.client;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.accounts.AccountManagerCallback;
import android.accounts.AccountManagerFuture;
import android.accounts.AuthenticatorException;
import android.accounts.OperationCanceledException;
import android.app.AlertDialog;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;	
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.theqvd.android.xpro.Config;
import com.theqvd.android.xpro.DummyActivity;
import com.theqvd.android.xpro.XserverService;
import com.theqvd.client.jni.QvdException;
import com.theqvd.client.jni.QvdclientWrapper;
import com.theqvd.client.jni.Vm;

public class Qvdconnection implements Runnable {
	private String tag;
	private Connection connection;  
	private QvdclientActivity activity;
	private QvdclientWrapper qvd;
	private int vmid = -1;
	private Vm vmlist[] = null;
	public static final int connectnotify = 1;
	public static final int x11intentactivityid = 12;
	private AcceptUnknownCertHandler certhandler;
	private Handler handler;
	private ConnectionProgress connectionprogress;
	private boolean running, connecting, paymentRequired;
	private Account selectedaccount;
	private String googleauthtoken;

	private Exception exception;
	/*
	 *  Implements two interfaces one thread as AsyncTask and other as Runnable interface
	 */

	Qvdconnection(QvdclientActivity context, Connection c, Handler h) {
		this.activity = context;
		setConnection(c);
		tag = this.activity.getResources().getString(R.string.app_name_qvd) + "-Qvdconnection-" +java.util.Map.Entry.class.getSimpleName();
		handler = h;
		certhandler = new AcceptUnknownCertHandler(activity, handler);
		connectionprogress = new ConnectionProgress(activity);
		running = false;
		connecting = false;
	}
	
	public void get_list_of_vm() {
		GetVMList v = new GetVMList();
		v.execute();
	}
	private void vm_list() {
		exception = null;
		vmlist = null;
		vmid = -1;
		setConnecting(true);
		
		qvd = new QvdclientWrapper();
		if (connection.isDebug()) {
			qvd.qvd_set_debug();
		}
		
		try {
			if (connection.isGoogleauthentication()) {
				Log.d(tag, "Use google authentication");
				googleAuth(connection);
				Log.d(tag, "Used google authentication user="+connection.getLogin()+";pass="+connection.getPassword());
				if (connection.getPassword() == "") {
					throw new QvdException("Error in Authenticate against google");
				}
			}
			qvd.qvd_init(connection.getHost(),
					connection.getPort(),
					connection.getLogin(),
					connection.getPassword());
			qvd.qvd_set_home(activity.getFilesDir().getAbsolutePath());
			//		qvd.qvd_set_no_cert_check();
			qvd.qvd_set_certificate_handler_callback(certhandler);
			qvd.qvd_set_display("localhost:0");
			qvd.qvd_set_geometry(connection.getWidth(), connection.getHeight());
			
			qvd.qvd_set_progress_handler_callback(connectionprogress);
			if (connection.isUseclientcert()) {
				Log.d(tag, "Use client cert is true and files are :" + connection.getClient_cert() + " and " + connection.getClient_key());
				qvd.qvd_set_cert_files(connection.getClient_cert(), connection.getClient_key());
			}
			Log.d(tag, "The qvd object is "+qvd.toString());
			qvd.qvd_list_of_vm();
			paymentRequired = false ;// qvd.qvd_payment_required();
			vmlist = qvd.getQvdclient().getVmlist();
			Log.d(tag,"The vm list is "+vmlist);
			if (vmlist == null) {
				setRunning(false);
				setConnecting(false);
				sendAlert(activity.getResources().getString(R.string.vmlisterrortitle), 
				activity.getResources().getString(R.string.vmlistisnull));
			}
		} catch (QvdException e) {
			setRunning(false);
			setConnecting(false);
			exception = e;
			vmlist = null;
			setVmid(-1);
			Message m = handler.obtainMessage(QvdclientActivity.ERROR);
			Bundle b = new Bundle();
			b.putString(QvdclientActivity.messageTitle, activity.getResources().getString(R.string.vmlisterrortitle));
			b.putString(QvdclientActivity.messageText, e.toString());
			m.setData(b);
			Log.e(tag, "Error getting vmlist:" + e.toString());
			handler.sendMessage(m);
		}
	}
	
	public void connect_to_vm() {
		setConnecting(false);
		if (exception != null) {
			Log.e(tag, "Stopping connect_to_vm there was a former exception:" + exception.toString());
			setRunning(false);
			return;
		}
		if (getVmid() == -1) {
			Log.e(tag, "Stopping connect_to_vm there vmid was -1 and exception is null");
			return;
		}
		setRunning(true);
		startX();
		WaitForXAndRunConnect w = new WaitForXAndRunConnect();
		w.execute();
	}
	
    /* 
     * Select the account used to authenticate
     */
    // TODO let the user choose the account
    private void googleAuth(Connection c) throws QvdException {
    	AccountManager am = AccountManager.get(this.activity.getApplicationContext());
    	Account account[] = am.getAccountsByType("com.google");
    	int i;
    	for (i=0; i < account.length; i ++) {
    		Log.d(tag, "Account is <"+account[i].name + "> type <" + account[i].type + "> to string:" + account[i].toString());
    	}
    	if (account.length < 1) {
    		Log.e(tag, "No account found");
    		throw new QvdException("No account found");
    	}
    	selectedaccount = account[0];
    	Log.d(tag, "Selected first account "+selectedaccount);
    	
    	//Toast.makeText(this, "Selected first account "+selectedaccount, Toast.LENGTH_LONG).show();
    	GoogleAuthenticationCallback authcallback = new GoogleAuthenticationCallback(); 

//    	@SuppressWarnings(UNUSED)
		AccountManagerFuture<Bundle> amf = 
    			am.getAuthToken(selectedaccount, "oauth2:https://mail.google.com/", null, this.activity, authcallback, null);
    	try {
			Bundle bundle = amf.getResult();
			c.setLogin(selectedaccount.name);
	    	c.setPassword(bundle.getString(AccountManager.KEY_AUTHTOKEN));
		} catch (OperationCanceledException e) {
			throw new QvdException("Google Auth cancelled" + e.toString());
		} catch (AuthenticatorException e) {
			throw new QvdException("Google Auth exception" + e.toString());
		} catch (IOException e) {
			throw new QvdException("Google Auth io error" + e.toString());
		}
    	
    	
//    	GET https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=ya29.AHES6ZSw0WdfQrZRu7irytsBDA5mvqQztD43y-nVXyA8zg --> 200 OK
//    	{
//    	 "issued_to": "442575845966-mde4be7eingpb5pntfs839jipsetro6s.apps.googleusercontent.com",
//    	 "audience": "442575845966-mde4be7eingpb5pntfs839jipsetro6s.apps.googleusercontent.com",
//    	 "scope": "https://mail.google.com/",
//    	 "expires_in": 3393,
//    	 "access_type": "online"
//    	}
    }

	
	private class GoogleAuthenticationCallback implements AccountManagerCallback<Bundle> {
    	Bundle bundle;
        String connectionError;

    	

    	private boolean authenticate(AccountManagerFuture<Bundle> amf) {
    		connectionError = "";
    		try {
				bundle = amf.getResult();
//				connection.setPassword("");
		    	Log.d(tag, "Obtained bundle with "+bundle +";KEY_ACCOUNT_NAME="+bundle.getString(AccountManager.KEY_ACCOUNT_TYPE)+
		    			";KEY_ACCOUNT_TYPE="+bundle.getString(AccountManager.KEY_ACCOUNT_TYPE)+
		    			";KEY_ACCOUNTS="+bundle.getString(AccountManager.KEY_ACCOUNTS)+
		    			";KEY_AUTHTOKEN="+bundle.getString(AccountManager.KEY_AUTHTOKEN)
		    			);
		    	googleauthtoken = bundle.getString(AccountManager.KEY_AUTHTOKEN);
//		    	connection.setPassword(bundle.getString(AccountManager.KEY_AUTHTOKEN));
//		    	ConnectionDB.currconnection.setLogin(connection.getLogin());
//		    	ConnectionDB.currconnection.setPassword(connection.getPassword());
		    	Log.d(tag, "authenticate. username="+connection.getLogin()+"; pass="+connection.getPassword());
		    	return true;
			} catch (OperationCanceledException e) {
				connectionError = "Authentication cancelled " + e.toString();
			} catch (AuthenticatorException e) {
				connectionError = "Authentication error " + e.toString();
			} catch (IOException e) {
                connectionError = "Authentication I/O error " + e.toString();
			}
			Log.e(tag, connectionError);
    		return false;
    	}
		@Override
		public void run(AccountManagerFuture<Bundle> amf) {
			boolean result;
			Log.d(tag, "AccountManagerFuture " + amf);
			result = authenticate(amf); 
			if (!result) {
				Log.d(tag, "First try of authenticate failed, invalidating cache and trying again");
				AccountManager am = AccountManager.get(activity.getApplicationContext());
				am.invalidateAuthToken(selectedaccount.type, selectedaccount.name);
				result = authenticate(amf);
			}
			Log.d(tag, "result of authentication was "+result);
			// TODO invoke GetList...
//			Toast.makeText(AndroidauthActivity.this, "No account returning", Toast.LENGTH_LONG).show();
			

		}
    }

	
	private class GetVMList extends AsyncTask<Void, Void, Void> {

		// 
		@Override
		protected void onPreExecute() {
			paymentRequired = false;
		}
		// Run the vm_list in a different thread
		@Override
		protected Void doInBackground(Void... arg0) {
			vm_list();
			return null;
		}
		// called when doInBackground finishes
		@Override
		protected void onPostExecute(Void result) {
			if (vmlist == null) {
				// The alert was already issued
				setRunning(false);
				setConnecting(false);
				return;
			}

			switch (vmlist.length) {
			case 0:
				setRunning(false);
				if (paymentRequired) {
					// TODO What do we do if payment is required...
					sendAlert(activity.getResources().getString(R.string.novmsavailabletitle), 
							activity.getResources().getString(R.string.novmsavailable));
				} else {
					sendAlert(activity.getResources().getString(R.string.novmsavailabletitle), 
							activity.getResources().getString(R.string.novmsavailable));
				}
				break;
			case 1:
				setVmid(vmlist[0].getId());
				Log.i(tag, "Vmlist has only one vmid selecting vmid "+getVmid());
				connect_to_vm();
				break;
			default:
				Log.i(tag, "Vmlist has more than one element ("+vmlist.length+"). Choosing a vm from vmid ");
				final Intent selectvmintent = new Intent(activity, SelectVmActivity.class);
				String[] vmmap = new String[vmlist.length];
				
				vmid = vmlist[0].getId();
				int i;
				for (i=0; i < vmlist.length; i ++) {
					vmmap[i] = vmlist[i].getName();
				}

				selectvmintent.putExtra(QvdclientActivity.vmlistname, vmmap);
				activity.startActivityForResult(selectvmintent, QvdclientActivity.selectvmcode);
				;;
			}
			return;
		}

	}
	// runs the connect_to_vm method

	@SuppressWarnings("deprecation")
	@Override
	public void run() {
		boolean hadconnection = false;
		Log.d(tag, "calling qvd_connect_to_vm("+vmid+")");
		Intent qvdclientActivity = new Intent(activity, QvdclientActivity.class);
		PendingIntent qvdclientActivityPI = PendingIntent.getActivity(activity, 0, qvdclientActivity, 0);
		NotificationManager mNotificationManager = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
		try {
			qvd.qvd_connect_to_vm(vmid);
			String connectionfinished = activity.getResources().getString(R.string.connectionfinished);
			Notification notification = new Notification(R.drawable.icon, connectionfinished, System.currentTimeMillis());
			notification.flags |= Notification.FLAG_AUTO_CANCEL;
			notification.setLatestEventInfo(activity, connectionfinished, connectionfinished, qvdclientActivityPI);
			mNotificationManager.notify(connectnotify, notification);
			hadconnection = true;
		} catch (QvdException e) {
			String title = activity.getString(R.string.connectionerrortitle);;
			String text = e.toString();
			Log.i(tag, "Error: Sent notify with title <" +title+"> and text <" + text +">");
			
			Notification notification = new Notification(R.drawable.icon, title, System.currentTimeMillis());
			notification.flags |= Notification.FLAG_AUTO_CANCEL;
			notification.setLatestEventInfo(activity, title, text, qvdclientActivityPI);
			mNotificationManager.notify(connectnotify, notification);
			
			Message m = handler.obtainMessage(QvdclientActivity.ERROR);
			Bundle b = new Bundle();
			b.putString(QvdclientActivity.messageTitle, title);
			b.putString(QvdclientActivity.messageText, text);
			m.setData(b);
			Log.e(tag, "Error connecting to vm:" + e.toString());
			handler.sendMessage(m);
			
		} finally {
			setRunning(false);
			try {
				qvd.qvd_free();
			} catch (QvdException e1) {
				Log.e(tag, "Error in qvd_free, possible memory leak");
			}
		}
		// Needed to cleanup nasty bug in nxcomp lib that doesn't allow to reuse
		// connections. We need to explicitly kill the process (this is against Android's philosophy
		if (hadconnection) {
			stopX();
			activity.finish();
			// Cleanup X11 notifications
			NotificationManager nm = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
			nm.cancel(Config.notifystartx);
			android.os.Process.killProcess(android.os.Process.myPid());
		}
	}
	
	private class WaitForXAndRunConnect extends AsyncTask<Void, Void, Void> {
		private final static int millisecondstowait = 200;
		private final static int timetowaitforXserver = 10000;
		private final static String tag = "WaitForX";
		boolean hasconnected = false;
//		private Socket s;
		
		@Override
		protected Void doInBackground(Void... params) {
			boolean hasexpired = false;
			long startTime = System.currentTimeMillis();
			long expirationTime = startTime + timetowaitforXserver;
			Socket s;
			InetSocketAddress localxserver = new InetSocketAddress("127.0.0.1", 6000);
			while (!hasconnected && !hasexpired) {
				try {
					hasexpired = (System.currentTimeMillis() > expirationTime);
					s = new Socket();
					s.connect(localxserver, millisecondstowait);
					s.close();
					hasconnected = true;
				} catch (IOException e) {
					Log.d(tag, "X server still not up. Waiting for connection to localhost 127.0.0.1:6000 :" + e);
					try {
						Thread.sleep(millisecondstowait);
					} catch (InterruptedException e1) {
					}
				}
			}
			
			long totaltime = System.currentTimeMillis() - startTime;
			if (hasconnected) {
				Log.d(tag, "X server was up after "+ totaltime + " ms");
			} else {
				Log.e(tag, "X server was not up after "+ totaltime + " ms");
			}
			return null;
		}
		protected void onPostExecute(Void result) {
			if (!hasconnected) {
				// Error X server has not started
				sendAlert(activity.getResources().getString(R.string.xservernotstartedtitle), 
						activity.getResources().getString(R.string.xservernotstartedtitle));
				setRunning(false);
				return;
				
			}
			String connecting = activity.getResources().getString(R.string.connectingtovm)+
					connection.getName()+
					"["+vmid+"]";
			Log.d(tag, connecting);
			Toast.makeText(activity, connecting, Toast.LENGTH_LONG).show();
			Thread t = new Thread(Qvdconnection.this);
			t.start();
			return;
		}
	}

	
	private void startX() {
		if (connection.isUselocalxserver()) {
			Log.i(tag, "launching local x server:");
			Intent localxserverIntent = new Intent(activity, DummyActivity.class);
			localxserverIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			activity.startActivity(localxserverIntent);
			return;
		}
		String cmd = "x11://"+connection.getXserverhost()+":" + connection.getXserverport(); // Currently only 6000
		Log.i(tag, "launching intent service:"+cmd);
		Intent x11Intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(cmd));
		x11Intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		activity.startActivityForResult(x11Intent, x11intentactivityid);
	}
	
	public void stopX() {		
		if (connection.isUselocalxserver()) {
			// TODO cancel X11 notification, check if needed, should it stop automatically because the server stopped?
			Log.i(tag, "stopping local x server:");
			Intent localxserverIntent = new Intent(activity, XserverService.class);
			localxserverIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			activity.stopService(localxserverIntent);
			return;
		}
		activity.finishActivity(x11intentactivityid);
		Log.i(tag, "stopX does not stop X servers launched from x11://"+connection.getXserverhost()+":"+connection.getXserverport()+" intent");
	}
	
	private void sendAlert(String title, String text) {
		Log.i(tag, "sendAlert("+title+","+text+")");
    	AlertDialog.Builder builder = new AlertDialog.Builder(activity);
		builder
		.setMessage(text)
		.setTitle(title)
		.setCancelable(true)
		.setNeutralButton(activity.getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int id) {
				dialog.cancel();
			}
		}).show();
		AlertDialog alert = builder.create();
		alert.isShowing();
    }
	public Connection getConnection() {
		return connection;
	}
	public void setConnection(Connection c) {
		connection = c;
	}
	public int getVmid() {
		return vmid;
	}
	public void setVmid(int vmid) {
		this.vmid = vmid;
	}
	public Vm[] getVmlist() {
		return vmlist;
	}

	public synchronized boolean isRunning() {
		return running;
	}

	public synchronized void setRunning(boolean running) {
		this.running = running;
		Log.d(tag, "setRunning:" + running + " calling updatefields");
		Message m = handler.obtainMessage(QvdclientActivity.UPDATEFIELDS);
		handler.sendMessage(m);
	}

	public synchronized boolean isConnecting() {
		return connecting;
	}

	public synchronized void setConnecting(boolean connecting) {
		this.connecting = connecting;
		Log.d(tag, "setConnecting:" + connecting + " calling updatefields");
		Message m = handler.obtainMessage(QvdclientActivity.UPDATEFIELDS);
		handler.sendMessage(m);
	}
}
