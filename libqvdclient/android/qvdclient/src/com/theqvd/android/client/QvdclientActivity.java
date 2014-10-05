package com.theqvd.android.client;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import com.theqvd.android.xpro.Config;
import com.theqvd.android.xpro.XvncproActivity;
import com.theqvd.android.xpro.XvncproException;
import com.theqvd.client.jni.Vm;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

public class QvdclientActivity extends Activity
                               implements OnItemSelectedListener
	{
	String tag;
	private Spinner spinner;
	private ArrayAdapter<Connection> adapter;
	private Button editconnection, connect, delete;
	private EditText login, password, host;
	private ConnectionDB connectiondb;
	private static String conntodelete;
	private final static int editconnectioncode = 1;
	public final static int selectvmcode = 2;
	// TODO unify these in one class
	public final static int xvncproactivityid = 13;
	private final static String lastconnectionprop = "last_connection";
	private Config config;
	public final static String vmlistname = "vmlistname";
	private Handler handler;
	public final static int CERTIFICATEEXCEPTION=0;
	public final static int VMLISTSELECTION=1;
	public final static int ERROR=2;
	public final static int UPDATEFIELDS=3;
	public final static int[] messageType = {
		CERTIFICATEEXCEPTION, // uses messageTitle and messageText in the setData
		VMLISTSELECTION, // used to call the SelectVmActivity and return the vmid
		ERROR, // General QvdException processing (normally via Notify)
		UPDATEFIELDS, // Call updateFields
	};
	public final static String certDetails = "certDetails";
	public final static String messageTitle = "title";
	public final static String messageText = "text";
	private Qvdconnection qvdconnection;
	

	/*
	 * Initial creation method
	 * Database connection is opined (new ConnectionDB)
	 * Last connection is restored (if it exists)
	 * Buttons are set up
	 * @see android.app.Activity#onCreate(android.os.Bundle)
	 */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        tag = getResources().getString(R.string.app_name_qvd) + "-QvdclientActivity-" +java.util.Map.Entry.class.getSimpleName();
        connectiondb = new ConnectionDB(this.getBaseContext());
        Connection c = getLastConnection();
        ConnectionDB.currconnection = c != null ? c : ConnectionDB.currconnection;
        setContentView(R.layout.main);
        login = (EditText) findViewById(R.id.mainlogin);
        password = (EditText) findViewById(R.id.mainpassword);
        host = (EditText) findViewById(R.id.mainhost);
        config = new Config(this);
        handler = new AsyncMessageHandler();
        setDefaultResolution();
        setEditConnection();
        setDeleteConnection();    
        setConnect();
        setSpinner();
        updateFields();
    }
   


	/*
     * The database connection is closed
     * @see android.app.Activity#onPause()
     */
    @Override
    protected void onPause() {
    	super.onPause();
    	if (connectiondb.isOpen())
    		connectiondb.close();
    }
    
    /*
     * The database connection is reestablished
     * And the fields are loaded crom the current connection into
     * the text fields (ConnectionDB.currconnection)
     * @see android.app.Activity#onResume()
     */
    @Override
    protected void onResume() {
    	super.onResume();
    	Log.d(tag, "onResume");
    	if (connectiondb == null || !connectiondb.isOpen())
    		connectiondb = new ConnectionDB(this.getBaseContext());
    	updateFields();
    	setSpinner();
    }
    /*
     * Closes the database connection
     * @see android.app.Activity#onStop()
     */
    @Override
    protected void onStop() {
		super.onStop();
		connectiondb.close();
	}

    /*
     * Method invoked after requesting either:
     * * Edit connection -> see EditConnectionActivity.java and the setResult method there
     * * Select the VM in case more than one vm is returned -> See SelectVmActivy and the setResult method there 
     * @see android.app.Activity#onActivityResult(int, int, android.content.Intent)
     */
    protected void onActivityResult(int requestCode, int resultCode,
    		Intent data) {
    	connectiondb = new ConnectionDB(this.getBaseContext());
    	switch (requestCode) {
		case Config.vncActivityRequestCode:
			Log.i(tag, "Response for vncActivityRequestCode. This is a response of starting the vnc client");
			return;
    	case editconnectioncode:
    		switch (resultCode)
    			{
    			case RESULT_OK:
    				Log.i(tag, "Returned ok for requestCode " + requestCode);
    				updateFields();
    				setSpinner();
    				break;
    			case RESULT_CANCELED:
    				Log.i(tag, "Returned canceled for requestCode "+requestCode);
    				updateFields();
    				setSpinner();
    				break;
    			default:
    				Log.e(tag, "Returned different from ok or cancel:"+resultCode + ". RequestCode "+requestCode);
    				Toast.makeText(this, getResources().getString(R.string.erroreditnoresult_toast), Toast.LENGTH_LONG).show();
    			}
    		break;
		case selectvmcode:
			switch (resultCode)
			{
    			case RESULT_OK:
    				Log.i(tag, "Returned ok for requestCode " + requestCode);
    				if (qvdconnection == null || qvdconnection.getVmid() == -1) {
    					error(getResources().getString(R.string.connectionerrortitle),
    							getResources().getString(R.string.connectionerror) + "OnActivityResult returned null qvdconnection or vmid == -1???: qvdconnection"
    									+ qvdconnection + ";vmid"+qvdconnection.getVmid(),
    						    "OnActivityResult returned null qvdconnection or vmid == -1???: qvdconnection"
    						    		+ qvdconnection + ";vmid"+qvdconnection.getVmid());
    					qvdconnection.setConnecting(false);
    					break;
    				}
    				
    				String vmname = data.getStringExtra(SelectVmActivity.returnedvmname);
    				int vmindex = data.getIntExtra(SelectVmActivity.returnedvmorder, -1);
    				Log.d(tag, "Returned vmname="+vmname+"; vmindex="+vmindex);
    				if (vmindex == -1) {
    					error(getResources().getString(R.string.connectionerrortitle),
    							getResources().getString(R.string.connectionerror) + "Returned vmindex does not exist:" +vmindex,
    							"vmindex is -1");
    					qvdconnection.setConnecting(false);
    					return;
    				}
    				Vm vmlist[] = qvdconnection.getVmlist();
    				if (vmlist == null) {
    					error(getResources().getString(R.string.connectionerrortitle),
    							getResources().getString(R.string.connectionerror) + "Returned vmlist is null",
    							"vmlist is null");
    					qvdconnection.setConnecting(false);
    					return;
    				}
    				int vmid = vmlist[vmindex].getId();
    				qvdconnection.setVmid(vmid);
    				qvdconnection.connect_to_vm();
    				break;
    			case RESULT_CANCELED:
    				Log.i(tag, "Returned canceled for requestCode "+requestCode);
    				Toast.makeText(this, getResources().getString(R.string.selectvmcanceltext), Toast.LENGTH_LONG).show();
    				qvdconnection.setConnecting(false);
    				break;
    			default:
    				Log.e(tag, "Returned different from ok or cancel:"+resultCode + ". RequestCode "+requestCode);
    				qvdconnection.setConnecting(false);
    				Toast.makeText(this, getResources().getString(R.string.erroreditnoresult_toast), Toast.LENGTH_LONG).show();
    			}
			updateFields();
			break;
		case Qvdconnection.x11intentactivityid:
			Log.i(tag, "Return of x11 intent activity with code: "+Qvdconnection.x11intentactivityid);
			break;
		default:
			error(getResources().getString(R.string.unexpectedresulttitle),
					getResources().getString(R.string.unexpectedresult)+" requestcode " + requestCode,
					"Unexpected result onActivityResult with requestCode "+requestCode+" resultCode "+resultCode+" data "+data);
    	}    	
    }
    /*
     * Create options menu
     * @see android.app.Activity#onCreateOptionsMenu(android.view.Menu)
     */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.qvdclient, menu);
        return true;
    }
    /*
     * Obtain the default resolution from the system display
     */
    private void setDefaultResolution() {
    	DisplayMetrics metrics = new DisplayMetrics();
		((WindowManager) getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(metrics);
		Connection.setDefaultHeight(metrics.heightPixels);
		Connection.setDefaultWidth(metrics.widthPixels);
    }
    
    /*
     * Handle menu options
     * @see android.app.Activity#onOptionsItemSelected(android.view.MenuItem)
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle item selection
        switch (item.getItemId()) {
        case R.id.xvncproitem:
        	Log.i(tag, "Clicked on xvncpro");
        	// TODO see why it doesn't start
    		Intent xvncproIntent = new Intent(this, XvncproActivity.class);
			startActivity(xvncproIntent);
            return true;
        case R.id.helpitem:
            	Log.i(tag, "Clicked on help");
        		Intent helpIntent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(getResources().getString(R.string.help_url)));
    			startActivity(helpIntent);
                return true;
            case R.id.aboutitem:
        		String version = getResources().getString(R.string.version); 
        		Log.d(tag, "version is "+version);
        		Toast.makeText(getApplication().getApplicationContext(), getAbout(), Toast.LENGTH_LONG).show();
                return true;
            case R.id.changelogitem:
        		Log.i(tag, "Clicked on changelog");
        		AlertDialog.Builder builder = new AlertDialog.Builder(this);
        		builder
        		.setMessage(getResources().getString(R.string.changelog))
        		.setTitle(getResources().getString(R.string.changelogtitle))
        		.setCancelable(true)
        		.setNeutralButton(getResources().getString(R.string.ok), new DialogInterface.OnClickListener() {
        			public void onClick(DialogInterface dialog, int id) {
        				dialog.cancel();
        			}
        		}).show();
        		AlertDialog alert = builder.create();
        		alert.isShowing();
                return true;
            case R.id.exititem:
        		Log.i(tag, "Clicked on exit");
        		if (qvdconnection != null) {
        			Log.i(tag, "qvdconnection is not null, stopping X server");
        			qvdconnection.stopX();
        		} else {
        			Log.i(tag, "qvdconnection is null, not stopping X server");
        		}
        		finish();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
    /*
     * Updates the login, password and host fields from the connection
     */
    private void updateConnection() {
    	ConnectionDB.currconnection.setLogin(login.getText().toString());
    	ConnectionDB.currconnection.setPassword(password.getText().toString());
    	ConnectionDB.currconnection.setHost(host.getText().toString());
    	Log.i(tag, "saved current connection:"+ConnectionDB.currconnection.dump());
    }
    
    /*
     * Define the action when you click in the edit button
     * That is call the EditConnectionActivity, and wait for result (see onActivityResult)
     */
    private void setEditConnection() {
    	editconnection = (Button) findViewById(R.id.editConnectionButton);
    	final Intent editconnectionIntent = new Intent(this, EditConnectionActivity.class);
    	editconnection.setOnClickListener(new Button.OnClickListener() {
        	public void onClick(View view) {
        		Log.d(tag, "launching activity: EditConnectionActivity");
        		updateConnection();
        		startActivityForResult(editconnectionIntent, editconnectioncode);
        	}
        });
    }
    
    /*
     * Method called when you click on connect.
     * Save the last connection used to be the default for next invocation
     * Gets the list of VMs
     * And if not empty connects to the vm
     */
    private void setConnect() {
    	connect = (Button) findViewById(R.id.connectionButton);
    	
    	if (qvdconnection != null && qvdconnection.isRunning()) {
    		Log.d(tag, "setConnect: qvdconnection non null and is running");
    		connect.setText(getResources().getString(R.string.connect_to_x));
    		connect.setClickable(true);
    		connect.setOnClickListener(new Button.OnClickListener() {
            	public void onClick(View view) {
            		try {
						config.getVncViewer().launchVncViewer();
					} catch (XvncproException e) {
						sendAlert(getString(R.string.error_handler_message), e.toString());
					}
            	}
            });
    		return;
    	}
    	
    	if (qvdconnection != null && qvdconnection.isConnecting()) {
    		Log.d(tag, "setConnect: qvdconnection non null and is connecting");
    		connect.setText(getResources().getString(R.string.connecting));
    		connect.setClickable(false);
    		return;
    	}
    	Log.d(tag, "setConnect: qvdconnection either null or non connecting and not running");
    	connect.setText(getResources().getString(R.string.connect));
    	connect.setClickable(true);
    	connect.setOnClickListener(new Button.OnClickListener() {
        	public void onClick(View view) {
        		saveLastConnection(ConnectionDB.currconnection);
        		updateConnection();
        		Log.i(tag, "Clicked on connect");
        		qvdconnection = new Qvdconnection(QvdclientActivity.this, ConnectionDB.currconnection, handler);
        		qvdconnection.setConnection(ConnectionDB.currconnection);
        		qvdconnection.get_list_of_vm();
        	}
        });
    }
  
    /*
     * Deletes the selected connection
     * Send an alert dialog to confirm the deletion
     */
    private void deleteConnection() {
    	
    	Log.d(tag, "deleteConnection: currentConnection is "+ConnectionDB.currconnection.toString());
    	conntodelete = ConnectionDB.currconnection.getName();
    	if (conntodelete == getResources().getString(R.string.newconnection)
    			|| conntodelete == "" || !ConnectionDB.existsConnection(conntodelete)) {
    		error(getResources().getString(R.string.unabletodelete_alerttitle), 
    				getResources().getString(R.string.unabletodelete_alert),
    				"Cannot delete a the new connection with name \""+ConnectionDB.currconnection.getName()+"\"");
    		return;
    	}
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle(getResources().getString(R.string.confirmdelete_alerttitle)).
		setMessage(getResources().getString(R.string.deleteconnectionquestion_alert)+conntodelete)
		.setPositiveButton(getResources().getString(R.string.yes), new DialogInterface.OnClickListener() 
		{
			public void onClick(DialogInterface dialog, int id) {
				Log.i(tag, "Deleting entry "+conntodelete);
				connectiondb.removeConnection(conntodelete);
		    	setSpinner();
				Toast.makeText(QvdclientActivity.this, getResources().getString(R.string.deletedconnection_toast)+conntodelete, Toast.LENGTH_LONG).show();
			}
		})
		.setNegativeButton(getResources().getString(R.string.no), new DialogInterface.OnClickListener()
		{
			public void onClick(DialogInterface dialog, int id) {
				
				Log.d(tag, "Cancelled deletion");
				dialog.cancel();
			}
		})
		.show();
		AlertDialog alert = builder.create();
		alert.isShowing();
    }
    /*
     * Sets up the delete button, and calls deleteConnection if clicked
     */
    private void setDeleteConnection() {
    	delete = (Button) findViewById(R.id.deleteConnectionButton);
    	delete.setOnClickListener(new Button.OnClickListener() {
        	public void onClick(View view) {
        		Log.i(tag, "Clicked on delete Connection");
        		deleteConnection();
        	}
        });
    }
    /*
     * Sets the login, password and host field from the current connection
     * Also updates the clickable buttons
     */
    private void updateFields() {
    	login.setText(ConnectionDB.currconnection.getLogin());
    	password.setText(ConnectionDB.currconnection.getPassword());
    	host.setText(ConnectionDB.currconnection.getHost());
    	try {
			if (config.prerrequisitesInstalled()) {
				setConnect();
				return;
			}
		} catch (XvncproException e) {
			sendAlert(getString(R.string.error_handler_message), e.toString());
		}
    	connect.setText(getResources().getString(R.string.installvnc));
    	connect.setOnClickListener(new Button.OnClickListener() {
    		public void onClick(View view) {
    			// TODO review how to invoke the progress without
    			// Perhaps send a message which states that this is the starting activity
    			// and then invoke the XvncproActivity
    			connect.setText(getResources().getString(R.string.installingprerrequisites));
    			//					config.installPrerrequisites();
    			Intent xvncproIntent = new Intent(QvdclientActivity.this, XvncproActivity.class);
       			Config.setInstallPrerrequisitesOnStart(true);
    			startActivity(xvncproIntent);
    		}
    	});
    	
    }
    
    /*
     * Returns the list of all the connections in the database
     */
    private List<Connection> getArrayOfConnections() {
    	ArrayList<Connection> a = new ArrayList<Connection>();
		Connection newconnection = new Connection();
		newconnection.setName(getResources().getString(R.string.newconnection));
		a.add(newconnection);
    	Iterator<Connection> p = connectiondb.getConnections().iterator();
		while (p.hasNext()) {
			a.add(p.next());
		}
		return a;
    }
    /*
     * Creates the spinner (dropdown),
     * Gets the list of connection from the database (getArrayOfConnections)
     * Selects the current connection if it exists, if not it selects New Connection
     */
    private void setSpinner() {
    	spinner = (Spinner) findViewById(R.id.connections_spinner);
    	List<Connection> arrayOfConnections = getArrayOfConnections();
    	adapter = new ArrayAdapter<Connection>(this, android.R.layout.simple_spinner_item, arrayOfConnections);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
        spinner.setOnItemSelectedListener(this);
        // Select current connection if defined
        Log.d(tag, "setSpinner currconnection is "+ConnectionDB.currconnection.dump() + ". And connection list is " +arrayOfConnections);
        int position = arrayOfConnections.indexOf(ConnectionDB.currconnection);
        Log.d(tag, "setSpinner position of "+ConnectionDB.currconnection+" is " + arrayOfConnections.indexOf(ConnectionDB.currconnection) + ". position="+position);
        position = (position == -1) ? 0 : position;
        Log.d(tag, "setSpinner position of "+ConnectionDB.currconnection+" is " + arrayOfConnections.indexOf(ConnectionDB.currconnection) + ". position="+position);

        spinner.setSelection(position,true);
        }

    /*
     * Action to do when you select an item
     * @see android.widget.AdapterView.OnItemSelectedListener#onItemSelected(android.widget.AdapterView, android.view.View, int, long)
     */
    public void onItemSelected(AdapterView<?> parent,
    		View view, int pos, long id) {
    	Log.d(tag, "in onItemSelected with pos "+pos);
//    	if (pos != 0) {
//    		Log.d(tag, "in onItemSelected with pos "+pos + " different from 0, updating connection");
    		ConnectionDB.currconnection = new Connection((Connection) parent.getSelectedItem());
//    	}
    	Log.d(tag, "in onItemSelected with pos "+pos+" and selection "+ ConnectionDB.currconnection.dump());
    	Log.d(tag, "onItemSelected item selected is "+pos);
    	updateFields();
    }

    public void onNothingSelected(AdapterView<?> parent) {
    }
    /*
     * Display alert and send log
     */
    private void error(String title, String error, String logerror) {
    	Log.e(tag, logerror);
    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage(error)
		.setTitle(title)
		.setCancelable(true)
		.setNeutralButton(getResources().getString(R.string.ok), new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int id) {
				dialog.cancel();
			}
		}).show();
		AlertDialog alert = builder.create();
		alert.isShowing();
    }
    /*
     * Save the specified connection as a user property
     */
    private void saveLastConnection(Connection c) {
    	SharedPreferences prefsPrivate;
		prefsPrivate = getSharedPreferences("PREFS_PRIVATE", Context.MODE_PRIVATE);
		Editor prefsPrivateEditor = prefsPrivate.edit();
		prefsPrivateEditor.putString(lastconnectionprop, c.getName());
		prefsPrivateEditor.commit();
    }
    /*
     * Return the last saved property
     */
    private Connection getLastConnection() {
    	SharedPreferences prefsPrivate;
		prefsPrivate = getSharedPreferences("PREFS_PRIVATE", Context.MODE_PRIVATE);
		String lastconnectionname = prefsPrivate.getString(lastconnectionprop, getResources().getString(R.string.newconnection));
		return connectiondb.getConnection(lastconnectionname);
    }
    
    public String getAbout() {
		return "qvdclient\n" +
				"License: Licensed under the GPLv3.\n" +
				"Author: info@theqvd.com\n" +
				"Sponsored: http://theqvd.com\n" +
				"Version: "+getResources().getString(R.string.version)+"\n" +
						"Revision: $Revision$\n" +
						"Date: $Date$";
	}
    private class AsyncMessageHandler extends Handler {
    	// handleMessage should handle, yes/no cert question and update the result
    	// should handle the return of vmlist and call the SelectVmActivity
    	// should handle errors
    	@Override
    	public void handleMessage(Message msg) {
    		Log.d(tag, "handleMessage: got message"+msg.what);
    		if (msg.what >= QvdclientActivity.messageType.length) {
				Log.e(tag, "Error this should not happen, you have sent a message with key greater than Config.MessageTypes");
				sendAlert(getString(R.string.error_handler_message), getString(R.string.error_handler_message) + ": " + msg.what);
				return;
			}
			Bundle b;
			
			switch (msg.what) {
			// TODO add updateFields
			case QvdclientActivity.CERTIFICATEEXCEPTION:
				Log.d(tag, "handleMessage: certifiateexception");
				b = msg.getData();
				String cert_description = b.getString(QvdclientActivity.certDetails);
				Log.d(tag, "handleMessage: certifiateexception " + cert_description);
				AlertDialog.Builder builder = new AlertDialog.Builder(QvdclientActivity.this);
				builder
				.setMessage(QvdclientActivity.this.getResources().getString(R.string.unknown_certificate) + cert_description)
				.setTitle(QvdclientActivity.this.getResources().getString(R.string.unknown_certificate_title))
				.setCancelable(false)
				.setPositiveButton(QvdclientActivity.this.getResources().getString(android.R.string.yes), new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						AcceptUnknownCertHandler.setValidcertificate(true);
						dialog.cancel();
					}
				}).
				setNegativeButton(QvdclientActivity.this.getResources().getString(android.R.string.no), new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						AcceptUnknownCertHandler.setValidcertificate(false);
						dialog.cancel();
					}
				}).show();
				AlertDialog alert = builder.create();
				alert.isShowing();
//				String text = b.getString(Config.messageText);
//				String title = b.getString(Config.messageTitle);
//				Log.i(tag, "Received message alert with title <"+title+"> and text <"+text+">");
//				sendAlert(title, text);
				return;
			case QvdclientActivity.VMLISTSELECTION:
				b = msg.getData();
				return;
			case QvdclientActivity.ERROR:
				b = msg.getData();
				String text = b.getString(messageText);
				String title = b.getString(messageTitle);
				Log.i(tag, "Received message to updateButtons");
				sendAlert(title, text);
				return;
			case QvdclientActivity.UPDATEFIELDS:
				updateFields();
				return;
			default:
				Log.i(tag, "Received message not defined??? :" + msg.what);
				sendAlert(getString(R.string.error_handler_message), getString(R.string.error_handler_message) + ": " + msg.what + "[default]");
				return;
			}
		}
    	
//    	private void sendAlert(String title, String text) {
//        	if (QvdclientActivity.this.isFinishing()) {
//        		Log.i(tag, "sending toast instead of alert because application is finishing");
//        		Toast.makeText(getApplication().getApplicationContext(), title + "\n" + text, 30).show();
//        		return;
//        	}
//        	AlertDialog.Builder builder = new AlertDialog.Builder(QvdclientActivity.this);
//    		builder
//    		.setMessage(text)
//    		.setTitle(title)
//    		.setCancelable(true)
//    		.setNeutralButton(getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
//    			public void onClick(DialogInterface dialog, int id) {
//    				dialog.cancel();
//    			}
//    		}).show();
//    		AlertDialog alert = builder.create();
//    		alert.isShowing();
//        }
    }
    private void sendAlert(String title, String text) {
    	if (this.isFinishing()) {
    		Log.i(tag, "sending toast instead of alert because application is finishing");
    		Toast.makeText(getApplication().getApplicationContext(), title + "\n" + text, 30).show();
    		return;
    	}
    	AlertDialog.Builder builder = new AlertDialog.Builder(QvdclientActivity.this);
		builder
		.setMessage(text)
		.setTitle(title)
		.setCancelable(true)
		.setNeutralButton(getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int id) {
				dialog.cancel();
			}
		}).show();
		AlertDialog alert = builder.create();
		alert.isShowing();
    }
}