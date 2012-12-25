package com.theqvd.android.xpro;

import com.theqvd.android.client.R;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

public class XvncproActivity extends Activity {
	static final String tag = Config.xvncbinary + "-XvncproActivity-" +java.util.Map.Entry.class.getSimpleName();

	VncViewerAndroid androidvncviewer;
	VncViewerPocketCloud pocketcloudvncviewer;
	PrerrequisiteXvncCopy xvnccopy;
	Config config;
	private Button connectionStartButton, buttonStopX;
	private ToggleButton forceXresolutionToggleButton, androidVncToggleButton, keepXRunningToggleButton, allowRemoteVncToogleButton, renderButton;
	private ProgressBar progressbar;
	TextView consoleTextview;
	private EditText xResolution, yResolution;
	
	private static Handler mainHandler;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.xvncpromain);
        config = new Config(this);
        setupHandler();
        config.setUiHandler(mainHandler);
        connectionStartButton = (Button) findViewById(R.id.connectionStartButton);
        buttonStopX = (Button) findViewById(R.id.stopButton);
		xResolution = (EditText) findViewById(R.id.editText1);
		yResolution = (EditText) findViewById(R.id.editText2);
		consoleTextview = (TextView) findViewById(R.id.consoletext);
		forceXresolutionToggleButton = (ToggleButton) findViewById(R.id.toggleForceResolutionButton);
		keepXRunningToggleButton = (ToggleButton) findViewById(R.id.stopOnVncDisconnectButton);
		androidVncToggleButton = (ToggleButton) findViewById(R.id.vncChoiceButton);
		allowRemoteVncToogleButton = (ToggleButton) findViewById(R.id.allowRemoteVNCButton);
		renderButton = (ToggleButton) findViewById(R.id.renderButton);
		progressbar = (ProgressBar) findViewById(R.id.progressbar1);
		
		setConnectionStartButton();
        setStopButton();
        setResolution();
        setVncToggleButton();
        setRenderButton();
        setStopOnExit();
        setAllowRemoteVncButton();
        
        Log.d(tag, "InstallPrerrequisites is "+Config.isInstallPrerrequisitesOnStart());
        if (Config.isInstallPrerrequisitesOnStart()) {
        	Log.i(tag, "InstallPrerrequisitesOnStart is true invoking installprerrequisites");
        	try {
				config.installPrerrequisites();
				if (config.prerrequisitesInstalled()) {
					// Might reach this sentence here and not beeing installed because
					// the copy happens in background
					Log.i(tag, "prerrequisites are installed, calling finish");
					Config.setInstallPrerrequisitesOnStart(false);
					finish();
				}
			} catch (XvncproException e) {
				sendAlert(getString(R.string.x11_error), e.toString());
			}
        }
        updateButtons();	
    }
    
	@Override
	protected void onResume() {
		super.onResume();
		Log.d(tag, "onResume");
		updateButtons();
	}
	@Override
	protected void onPause() {
		super.onPause();
	}
	@Override
	protected void onStop() {
		super.onStop();
	}
	
    private void setupHandler() {
    	mainHandler = new Handler() {
    		public void handleMessage(Message msg) {
    			if (msg.what >= Config.messageType.length) {
    				Log.e(tag, "Error this should not happen, you have sent a message with key greater than Config.MessageTypes");
    				sendAlert(getString(R.string.error_handler_message), getString(R.string.error_handler_message) + ": " + msg.what);
    				return;
    			}
    			Bundle b;
    			switch (msg.what) {
    			case Config.SENDALERT:
    				b = msg.getData();
    				String text = b.getString(Config.messageText);
    				String title = b.getString(Config.messageTitle);
    				Log.i(tag, "Received message alert with title <"+title+"> and text <"+text+">");
    				sendAlert(title, text);
    				return;
    			case Config.SETCOPYPROGRESS:
    				b = msg.getData();
    				int progress = b.getInt(Config.copyProgress);
    				Log.i(tag, "Received message progress update with value <"+progress+">");
    				progressbar.setProgress(progress);
    				connectionStartButton.setText(getResources().getString(R.string.copying) + " " +
    						progress+ "%" + (progress == 0 ? 
    								getResources().getString(R.string.checkingfiles) : 
    								""));
    				return;
    			case Config.SETPROGRESSVISIBILITY:
    				b = msg.getData();
    				int visibility = b.getInt(Config.progressVisibility);
    				Log.i(tag, "Received message progress visibility with value <"+visibility+">");
    				progressbar.setVisibility(visibility);
    				return;
    			case Config.UPDATEBUTTONS:
    				Log.i(tag, "Received message to updateButtons");
    				updateButtons();
    				return;
    			case Config.PRERREQUISITEINSTALLED:
    				Log.i(tag, "Received message that copy has finished");
    				try {
    					Log.d(tag, "message copy finished prerrequisitesinstalled="+config.prerrequisitesInstalled());
						if (config.prerrequisitesInstalled()) {
							Log.d(tag, "Calling XvncproActivity finish");
							XvncproActivity.this.finish();
						}
					} catch (XvncproException e) {
						sendAlert(getString(R.string.x11_error), e.toString());
					}
    				return;
    			default:
    				Log.i(tag, "Received message not defined??? :" + msg.what);
    				sendAlert(getString(R.string.error_handler_message), getString(R.string.error_handler_message) + ": " + msg.what + "[default]");
    				return;
    			}
    		}
    	};
    }
    void setConnectionStartButton() {
    	connectionStartButton.setOnClickListener(new ConnectionStartButtonActivity());
    }
    private class ConnectionStartButtonActivity implements View.OnClickListener {
		@Override
		public void onClick(View v) {
			try {
				if (config.prerrequisitesInstalled()) {
					Intent x11Intent = new Intent(XvncproActivity.this, DummyActivity.class);
					startActivity(x11Intent);
					updateButtons();
					return;
				}
				Log.d(tag, "InstallPrerrequisites is false invoking installprerrequisites inside ConnectionStartButtonActivity");
				config.installPrerrequisites();
				// This is usually true when invoked from QvdclientActivity
				if (Config.isInstallPrerrequisitesOnStart()) {
					Log.d(tag, "InstallPrerrequisites is true after installing installPrerrequisites:" +config.prerrequisitesInstalled());
					XvncproActivity.this.finish();
				}
			} catch (XvncproException e) {
				sendAlert(getString(R.string.x11_error), e.toString());
			}
			updateButtons();
		}
    	
    }
    
    void setStopButton() {
    	
    	buttonStopX.setOnClickListener(new Button.OnClickListener() {
    		public void onClick(View view) {	
    			Intent xserverService = new Intent(XvncproActivity.this, XserverService.class);
    			stopService(xserverService);
    			updateButtons();
    		}
    	});
    }
    
    void setResolution() {
    	String width = Integer.valueOf(config.get_width_pixels()).toString(); 
        String height = Integer.valueOf(config.get_height_pixels()).toString();
        xResolution.setText(width);
        xResolution.addTextChangedListener(new TextWatcher() {
			@Override
			public void afterTextChanged(Editable s) {
				if (config.is_force_x_geometry()) {
					String xres = xResolution.getText().toString();
					int x;
					try {
						x = Integer.parseInt(xres);
					} catch (java.lang.NumberFormatException e) {
						x = config.getAppconfig_defaultWidthPixels();
						Log.e(tag, "Error parsing x resolution" + e.toString());
					}
                	config.set_width_pixels(x);
				}
			}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// Do nothing
			}
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// Do nothing
			}
        });
        yResolution.setText(height);
        yResolution.addTextChangedListener(new TextWatcher() {
			@Override
			public void afterTextChanged(Editable s) {
				if (config.is_force_x_geometry()) {
					String yres = yResolution.getText().toString();
					int y;
					try {
						y= Integer.parseInt(yres);
					} catch (java.lang.NumberFormatException e) {
						y = config.getAppConfig_defaultHeightPixels();
						Log.e(tag, "Error parsing y resolution" + e.toString());
					}
                	config.set_height_pixels(y);
				}
			}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// Do nothing
			}
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// Do nothing
			}
        });
        forceXresolutionToggleButton.setChecked(config.is_force_x_geometry());
        forceXresolutionToggleButton.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
                // Perform action on clicks
                if (forceXresolutionToggleButton.isChecked()) {
                	String yres = yResolution.getText().toString();
                	String xres = xResolution.getText().toString();
                	int y;
					try {
						y= Integer.parseInt(yres);
					} catch (java.lang.NumberFormatException e) {
						y = config.getAppConfig_defaultHeightPixels();
						Log.e(tag, "Error parsing y resolution" + e.toString());
					}
                	int x;
					try {
						x = Integer.parseInt(xres);
					} catch (java.lang.NumberFormatException e) {
						x = config.getAppconfig_defaultWidthPixels();
						Log.e(tag, "Error parsing x resolution" + e.toString());
					}
                    config.set_height_pixels(y);
                	config.set_width_pixels(x);
                	config.set_force_x_geometry(true);
                } else {
                    config.set_height_pixels(config.getAppConfig_defaultHeightPixels());
                    config.set_width_pixels(config.getAppconfig_defaultWidthPixels());
                    config.set_force_x_geometry(false);
                    String width = Integer.valueOf(config.get_width_pixels()).toString(); 
                    String height = Integer.valueOf(config.get_height_pixels()).toString();
                    xResolution.setText(width);
                    yResolution.setText(height);
                }
                updateButtons();
            }
        });
    }
    void setVncToggleButton() {
    	androidVncToggleButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.d(tag, "Clicked on Android VNC toggle. The toggle button is "+androidVncToggleButton.isChecked());
				config.set_run_androidvnc_client(androidVncToggleButton.isChecked());
				updateButtons();
			}
    	});
    }
    void setRenderButton() {
    	renderButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.d(tag, "Clicked on render toggle. The toggle button is "+renderButton.isChecked());
				config.set_run_androidvnc_client(renderButton.isChecked());
				updateButtons();
			}
    	});
    }
    void setStopOnExit() {
    	keepXRunningToggleButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.d(tag, "Clicked on keep X running togle. The togle button is "+androidVncToggleButton.isChecked());
				config.set_keep_x_running(keepXRunningToggleButton.isChecked());
				updateButtons();
			}
    	});
    }
    void setAllowRemoteVncButton() {
    	allowRemoteVncToogleButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.d(tag, "Clicked on allow Remote VNC toogle. The togle button is "+allowRemoteVncToogleButton.isChecked());
				config.setAppConfig_remote_vnc_allowed(allowRemoteVncToogleButton.isChecked());
				updateButtons();
			}
    	});
    }
    void updateButtons() {
    	// Installed usual case
    	//forceXresolutionToggleButton, androidVncToggleButton, keepXRunningToggleButton
    	forceXresolutionToggleButton.setChecked(config.is_force_x_geometry());
    	androidVncToggleButton.setChecked(config.is_run_androidvnc_client());
     	renderButton.setChecked(config.isAppConfig_render());
       	keepXRunningToggleButton.setChecked(config.is_keep_x_running());
    	try {
    		if (config.prerrequisitesInstalled())
    		{
    			// No text console and no visibility
    			consoleTextview.setVisibility(View.GONE);    		
    			progressbar.setVisibility(View.GONE);

    			// Installed and running. Show pid in button, and say connect to X
    			if (XserverService.getInstance() != null && XserverService.getInstance().isRunning()) {
    				Log.d(tag, "updateButtons: getInstance is non null and isRunning");
    				connectionStartButton.setText(getString(R.string.connect_to_x)+" pid="+XserverService.getInstance().getPid());
    				buttonStopX.setText(getString(R.string.stopx));
    				buttonStopX.setEnabled(true);
    				return;
    			}
    			// Installed and not running
    			// Show start X message
    			connectionStartButton.setText(getString(R.string.launchx));
    			buttonStopX.setEnabled(false);
    			buttonStopX.setText(getString(R.string.stopdisabled_not_running));
    			return;
    		}
    		// Not installed
    		connectionStartButton.setText(getString(R.string.installprereqs));
    		consoleTextview.setVisibility(View.VISIBLE);
    		consoleTextview.setText(config.getPrerrequisitesText());
    		buttonStopX.setEnabled(false);
    		// The updates are handled via the handler
    	} catch (XvncproException e) {
    		sendAlert(getString(R.string.x11_error), e.toString());
		}
    }
    /*
     * Create options menu
     * @see android.app.Activity#onCreateOptionsMenu(android.view.Menu)
     */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.xvncmenu, menu);
        return true;
    }
    
    /*
     * Update buttons when detached from main app
     * @see android.app.Activity#onDetachedFromWindow()
     */
	@Override
	public void onDetachedFromWindow() {
		super.onDetachedFromWindow();
		Log.d(tag, "onDetachedFromWindow");
		updateButtons();
	}
	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		Log.d(tag, "onWindowFocusChanged"+hasFocus);
		updateButtons();
	}
    /*
     * Handle menu options
     * @see android.app.Activity#onOptionsItemSelected(android.view.MenuItem)
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle item selection
        switch (item.getItemId()) {
            
            case R.id.helpitem:
            	Log.i(tag, "Clicked on help");
        		Intent helpIntent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(getResources().getString(R.string.xncpro_helpurl)));
    			startActivity(helpIntent);
                return true;
            case R.id.aboutitem:
            	String version = getResources().getString(R.string.xvncpro_versionName); 
        		Log.i(tag, "Clicked on about. version is "+version);
        		Toast.makeText(getApplication().getApplicationContext(), Config.getAbout(version), Toast.LENGTH_LONG).show();
                return true;
            case R.id.changelogitem:
        		Log.i(tag, "Clicked on changelog");
        		sendAlert(getString(R.string.xvncpro_changelogtitle), getString(R.string.xvncpro_changelog));
                return true;
            case R.id.exititem:
        		Log.i(tag, "Clicked on exit");
        		Intent x11Intent = new Intent(this, XserverService.class);
        		stopService(x11Intent);
        		finish();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
    
    private void sendAlert(String title, String text) {
    	if (this.isFinishing()) {
    		Log.i(tag, "sending toast instead of alert because application is finishing");
    		Toast.makeText(getApplication().getApplicationContext(), title + "\n" + text, Toast.LENGTH_LONG).show();
    		return;
    	}
    	AlertDialog.Builder builder = new AlertDialog.Builder(XvncproActivity.this);
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