package com.theqvd.android.client;

import java.io.File;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ToggleButton;

public class EditConnectionActivity extends Activity implements OnItemSelectedListener {
	private String tag;
	private Spinner spinner;
	private ArrayAdapter<CharSequence> adapter;
	private Button save, cancel, help, clientcert, clientkey;
	private EditText name, login, password, host, port, width, height, keyboard, certfile, keyfile;
	private ToggleButton nofullscreen, debug, nolocalx, useclientcert;
	
	private final static int PICKFILE_REQUEST_CODE_CERT = 21;
	private final static int PICKFILE_REQUEST_CODE_KEY = 22;
	private static final int INSTALLPACKAGE = 23;
	private final static String OIFILEMGR = "org.openintents.filemanager";
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
    	tag = getResources().getString(R.string.app_name_qvd) + "-EditConnectionActivity-" +java.util.Map.Entry.class.getSimpleName();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.editconnection);
        Log.i(tag, "launched activity: EditConnectionActivity with currconnection:"+ConnectionDB.currconnection.dump());
        new ConnectionDB(this.getBaseContext());
        setName();
        setLogin();
        setPassword();
        setHost();
        setPort();
        setWidthAndHeight();
        setKeyboard();
        setNofullscreen();
        setSave();
        setCancel();
        setHelp();
        setSpinner();
        setDebug();
        setLocalX();
        setUseClientCerts();
        setCerts();
    }
    /*
     * The database connection is closed
     * @see android.app.Activity#onPause()
     */
    @Override
    protected void onPause() {
    	super.onPause();
    	// TODO see where to close the database connection
//    	connectiondb.close();
    }

    // Returns true if the cert and Key file exists
    private boolean verifycertfiles() {
    	String certfile = ConnectionDB.currconnection.getClient_cert();
    	String keyfile =  ConnectionDB.currconnection.getClient_key();
    	File c = new File(certfile);
    	File k = new File(keyfile);
    	
    	if (c.canRead() && k.canRead()) {
    		Log.d(tag, "File "+certfile+" and file " + keyfile + " seem to be readable");
    		return true;
    	}
    	
    	if (!c.canRead()) {
    		Log.d(tag, "File "+certfile+" seems to be not readable");
    	}
    	
    	if (!k.canRead()) {
    		Log.d(tag, "File "+keyfile+" seems to be not readable");
    	}
		return false;
    }

	private boolean saveConnection() {
    	Log.d(tag, "before updateConnection DB"+ConnectionDB.getInstance().dump());
    	ConnectionDB.currconnection.setName(name.getText().toString());
    	ConnectionDB.currconnection.setLogin(login.getText().toString());
    	ConnectionDB.currconnection.setPassword(password.getText().toString());
    	ConnectionDB.currconnection.setHost(host.getText().toString());
    	try {
			int p = Integer.parseInt(port.getText().toString());
			ConnectionDB.currconnection.setPort(p);
		} catch (java.lang.NumberFormatException e) {
			Log.e(tag, "Error parsing port number:" + e.toString());
			Toast.makeText(this, getResources().getString(R.string.errorparsingport_toast), Toast.LENGTH_LONG).show();
		}
    	try {
			int w = Integer.parseInt(width.getText().toString());
			int h = Integer.parseInt(height.getText().toString());
			ConnectionDB.currconnection.setWidth(w);
			ConnectionDB.currconnection.setHeight(h);
		} catch (java.lang.NumberFormatException e) {
			Log.e(tag, "Error parsing width or height resolution:" + e.toString());
			Toast.makeText(this, getResources().getString(R.string.errorparsinggeometry_toast), Toast.LENGTH_LONG).show();
		}
    	ConnectionDB.currconnection.setKeyboard(keyboard.getText().toString());
    	ConnectionDB.currconnection.setFullscreen(nofullscreen.isChecked());
    	ConnectionDB.currconnection.setDebug(debug.isChecked());
    	ConnectionDB.currconnection.setUselocalxserver(!nolocalx.isChecked());
    	
    	ConnectionDB.currconnection.setClient_cert(certfile.getText().toString());
    	ConnectionDB.currconnection.setClient_key(keyfile.getText().toString());
    	ConnectionDB.currconnection.setUseclientcert(useclientcert.isChecked());
    	if (useclientcert.isChecked() && !verifycertfiles()) {
    		ConnectionDB.currconnection.setUseclientcert(false);
    		useclientcert.setChecked(false);
    		Toast.makeText(EditConnectionActivity.this, getResources().getString(R.string.certorkeynotreadable), Toast.LENGTH_LONG).show();
    	}
    	
    	Log.d(tag, "before check DB"+ConnectionDB.getInstance().dump());
    	if (ConnectionDB.existsConnection(ConnectionDB.currconnection)) {
    		Log.i(tag, "Connection already exists launching alertdialog:"+ConnectionDB.currconnection.dump());
    		Log.i(tag, "DB:"+ConnectionDB.getInstance().dump());
    		AlertDialog.Builder builder = new AlertDialog.Builder(EditConnectionActivity.this);
    		builder.setTitle(getResources().getString(R.string.duplicateconnectionoverwrite_alerttitle)).
    		setMessage(getResources().getString(R.string.duplicateconnectionoverwrite_alert1)+ConnectionDB.currconnection.toString()+getResources().getString(R.string.duplicateconnectionoverwrite_alert2))
    		.setPositiveButton(getResources().getString(R.string.yes), new DialogInterface.OnClickListener() 
    		{
    			public void onClick(DialogInterface dialog, int id) {
    				Log.d(tag, "before adding duplicate DB"+ConnectionDB.getInstance().dump());
    				Connection c = new Connection(ConnectionDB.currconnection);
    				ConnectionDB.getInstance().removeConnection(c);
    				ConnectionDB.getInstance().addConnection(c);
    				Intent i = new Intent(getResources().getString(R.string.overwrittenconnection_toast)+c);
        			EditConnectionActivity.this.setResult(RESULT_OK, i);
        			Toast.makeText(EditConnectionActivity.this, getResources().getString(R.string.editvm_toast)+ConnectionDB.currconnection.getName(), Toast.LENGTH_LONG).show();
        			EditConnectionActivity.this.finish();
        			return;
    			}
    		})
    		.setNegativeButton(getResources().getString(R.string.no), new DialogInterface.OnClickListener()
    		{
    			public void onClick(DialogInterface dialog, int id) {
    				Toast.makeText(EditConnectionActivity.this, getResources().getString(R.string.changeconnectionname_toast)+ConnectionDB.currconnection, Toast.LENGTH_LONG).show();
    				Log.d(tag, "Continue editing");
    				dialog.cancel();
    			}
    		})
    		.show();
    		AlertDialog alert = builder.create();
    		alert.isShowing();
    		
    		return false;
    	}    	
    	Connection c = new Connection(ConnectionDB.currconnection);
    	ConnectionDB.getInstance().addConnection(c);
    	Log.i(tag, "saved current connection:"+ConnectionDB.currconnection.dump());
    	Intent i = new Intent(getResources().getString(R.string.savedconnection_toast)+c);
    	setResult(RESULT_OK, i);
    	Toast.makeText(EditConnectionActivity.this, getResources().getString(R.string.editvm_toast)+ConnectionDB.currconnection.getName(), Toast.LENGTH_LONG).show();
		finish();
    	return true;
    }
    // OnCreate methods
    private void setName() {
    	name = (EditText) findViewById(R.id.editconnectionname);
    	name.setText(ConnectionDB.currconnection.getLogin() + "@" +
    			ConnectionDB.currconnection.getHost());
    }
    private void setLogin() {
    	login = (EditText) findViewById(R.id.editlogin);
    	login.setText(ConnectionDB.currconnection.getLogin());
    }
    private void setPassword() {
    	password = (EditText) findViewById(R.id.editpassword);
    	password.setText(ConnectionDB.currconnection.getPassword());
    }
    private void setHost() {
    	host = (EditText) findViewById(R.id.edithost);
    	host.setText(ConnectionDB.currconnection.getHost());
    }
    private void setPort() {
    	port = (EditText) findViewById(R.id.port);
    	port.setText(Integer.toString(ConnectionDB.currconnection.getPort()));
    }
    private void setWidthAndHeight() {
    	width = (EditText) findViewById(R.id.width);
    	height = (EditText) findViewById(R.id.height);
    	width.setText(Integer.toString(ConnectionDB.currconnection.getWidth()));
    	height.setText(Integer.toString(ConnectionDB.currconnection.getHeight()));
    }
    private void setKeyboard() {
    	keyboard = (EditText) findViewById(R.id.keyboard);
    	keyboard.setText(ConnectionDB.currconnection.getKeyboard());
    }
    
    /*
     * Certificate handling
     * private class to install the open intents file manager if not installed
     * call the installation and return on OnActivityResult.
     * The file selection will also call OnActivityResult
     * 
     */
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode,
    		Intent data) {
    	Log.d(tag, "onActivityResult, requestCode:"+ requestCode + ", resultCode:" + resultCode);
    	updateCertFilesButtons();
    	switch(requestCode){
    	case PICKFILE_REQUEST_CODE_CERT:
    		if(resultCode==RESULT_OK){
    			String filepath = data.getData().getPath();
    			certfile.setText(filepath);
    			Log.d(tag, "onActivityResult cert file is " + filepath + " certfile:" + certfile.getText().toString());
    		} else { 
    			Log.e(tag, "resultcode for request " + requestCode +  			   		
    					"is not ok " + resultCode);
    			//Toast.makeText(this, getResources().getString((R.string.nofilechosen)), Toast.LENGTH_SHORT);
    		}
    		break;
    	case PICKFILE_REQUEST_CODE_KEY:
    		if(resultCode==RESULT_OK){
    			String filepath = data.getData().getPath();
    			keyfile.setText(filepath);
    			Log.d(tag, "onActivityResult key file is " + filepath + " keyfile:" + keyfile.getText().toString());
    		} else { 
    			Log.e(tag, "resultcode for request " + requestCode +  			   		
    					"is not ok " + resultCode);
    			//Toast.makeText(this, getResources().getString((R.string.nofilechosen)), Toast.LENGTH_SHORT);
    		}
    		break;
    	case INSTALLPACKAGE:
    		if(resultCode==RESULT_OK){
    			Log.d(tag, "OnActivityResult: package was succesfully installed");
    			break;
    		} else { 
    			Log.e(tag, "resultcode for request " + requestCode +  			   		
    					"is not ok " + resultCode);
    			//Toast.makeText(this, getResources().getString((R.string.errorinstallfilemgr_alert)), Toast.LENGTH_LONG);
    		}
    		break;
    	default:
    		Log.e(tag, "Unknown requestCode " + requestCode);
    		//Toast.makeText(this, "Unknown requestCode " + requestCode, Toast.LENGTH_LONG);
    	}
    }
    private void setCerts() {
    	certfile = (EditText) findViewById(R.id.certfile);
    	certfile.setText(ConnectionDB.currconnection.getClient_cert());
    	keyfile = (EditText) findViewById(R.id.keyfile);
    	keyfile.setText(ConnectionDB.currconnection.getClient_key());
    	clientcert = (Button) findViewById(R.id.pickclientcert);
    	clientkey = (Button) findViewById(R.id.pickclientkey);
    	updateCertFilesButtons();
    	clientcert.setOnClickListener(new Choosefile(PICKFILE_REQUEST_CODE_CERT));
    	clientkey.setOnClickListener(new Choosefile(PICKFILE_REQUEST_CODE_KEY));
    }
    
    private void updateCertFilesButtons() {
    	if (packageInstalled(OIFILEMGR)) {
			Log.d(tag, "package is installed:"+OIFILEMGR);
			clientcert.setText(this.getText(R.string.pickfile));
			clientkey.setText(this.getText(R.string.pickfile));
		} else {
			Log.d(tag, "package is not installed:"+OIFILEMGR);
			clientcert.setText(this.getText(R.string.installfilemgr));
			clientkey.setText(this.getText(R.string.installfilemgr));
		}
    }

    private boolean packageInstalled(String packagename) {
		ApplicationInfo info;
		try{
			
			info = this.getPackageManager().getApplicationInfo(packagename, 0);
		} catch( PackageManager.NameNotFoundException e ){
			Log.i(tag, packagename + " is not installed");
			return false;
		}
		Log.i(tag, packagename+" is already installed" + info);
		return true;
	}
    private void installPackage(String packagename) {
    	Log.i(tag, "Requesting installation of "+packagename);
    	Intent goToMarket = new Intent(Intent.ACTION_VIEW).setData(Uri.parse("market://details?id="+packagename));
//    	goToMarket.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    	Log.d(tag, "Calling installPackage with startActivityForResult because activity is non null");
    	this.startActivityForResult(goToMarket, INSTALLPACKAGE);
    }
    
    private class Choosefile implements View.OnClickListener {

        int requesttype = -1;
    	Choosefile(int requesttype) {
    		this.requesttype = requesttype;
    	}
		@Override
		public void onClick(View v) {
			if (!packageInstalled(OIFILEMGR)) {
				Log.i(tag, "package is not installed: " + OIFILEMGR);
				installPackage(OIFILEMGR);
			} else {
				Log.i(tag, "package installed: " + OIFILEMGR + ". Intent is called with requesttype: " + requesttype);
				Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
	            intent.setType("file/*");
	            startActivityForResult(intent, requesttype);
			}
			
		}
    }
    
    private void setNofullscreen() {
    	nofullscreen = (ToggleButton) findViewById(R.id.nofullscreenButton);
    	nofullscreen.setChecked(ConnectionDB.currconnection.isFullscreen());
    	nofullscreen.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ConnectionDB.currconnection.setFullscreen(nofullscreen.isChecked());  	
        	}
        });
    }
    private void setSave() {
    	save = (Button) findViewById(R.id.saveButton);
    	save.setOnClickListener(new Button.OnClickListener() {
        	public void onClick(View view) {
        		Log.i(tag, "Clicked on save");
        		saveConnection();
        	}
        });
    }
    private void setCancel() {
    	cancel = (Button) findViewById(R.id.editCancelButton);
    	
    	cancel.setOnClickListener(new Button.OnClickListener() {
        	public void onClick(View view) {
        		Log.i(tag, "Clicked on cancel");
        		Intent i = new Intent("Cancelled edit");
        		setResult(RESULT_CANCELED, i);
        		Toast.makeText(EditConnectionActivity.this, getResources().getString(R.string.editvmcancelled_toast), Toast.LENGTH_LONG).show();
        		finish();
        	}
        });
    }
    
    private void setHelp() {
    	help = (Button) findViewById(R.id.editHelpButton);
    	
    	help.setOnClickListener(new Button.OnClickListener() {
        	public void onClick(View view) {
        		Log.i(tag, "Clicked on help");
        		Intent helpIntent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(getResources().getString(R.string.help_url)));
    			startActivity(helpIntent);
        	}
        });
    }
    private void setDebug() {
    	debug = (ToggleButton) findViewById(R.id.toggleDebugButton);
    	debug.setChecked(ConnectionDB.currconnection.isDebug());
        debug.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ConnectionDB.currconnection.setDebug(debug.isChecked());  	
        	}
        });
	}
    private void setLocalX() {
    	nolocalx = (ToggleButton) findViewById(R.id.nolocalxButton);
    	nolocalx.setChecked(!ConnectionDB.currconnection.isUselocalxserver());
    	nolocalx.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		Log.d(tag, "Clicked on use local server nolocalx is " + nolocalx.isChecked());
        		ConnectionDB.currconnection.setUselocalxserver(!nolocalx.isChecked());  	
        	}
        });
	}
    
    private void setUseClientCerts() {
    	useclientcert = (ToggleButton) findViewById(R.id.useClientCertButton);
    	useclientcert.setChecked(ConnectionDB.currconnection.isUseclientcert());
    	useclientcert.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		Log.d(tag, "Clicked on use client cert now value is "+useclientcert.isChecked());
        		ConnectionDB.currconnection.setUseclientcert(useclientcert.isChecked());  	
        	}
        });
    	
    }
    private void setSpinner() {
    	spinner = (Spinner) findViewById(R.id.link_spinner);
        adapter = ArrayAdapter.createFromResource(this, R.array.link_array, android.R.layout.simple_spinner_item);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
        int pos = adapter.getPosition(ConnectionDB.currconnection.getLink());
        Log.d(tag, "The position of link "+ConnectionDB.currconnection.getLink()+" is "+pos);
        spinner.setSelection(pos);
        spinner.setOnItemSelectedListener(this);
    }

    public void onItemSelected(AdapterView<?> parent,
    		View view, int pos, long id) {

    	ConnectionDB.currconnection.setLink(parent.getItemAtPosition(pos).toString());
    }

    public void onNothingSelected(AdapterView<?> parent) {
    }
//    private void sendAlert(String title, String text) {
//    	if (this.isFinishing()) {
//    		Log.i(tag, "sending toast instead of alert because application is finishing");
//    		Toast.makeText(getApplication().getApplicationContext(), title + "\n" + text, 30).show();
//    		return;
//    	}
//    	AlertDialog.Builder builder = new AlertDialog.Builder(this);
//		builder
//		.setMessage(text)
//		.setTitle(title)
//		.setCancelable(true)
//		.setNeutralButton(getResources().getString(android.R.string.ok), new DialogInterface.OnClickListener() {
//			public void onClick(DialogInterface dialog, int id) {
//				dialog.cancel();
//			}
//		}).show();
//		AlertDialog alert = builder.create();
//		alert.isShowing();
//    }
}
