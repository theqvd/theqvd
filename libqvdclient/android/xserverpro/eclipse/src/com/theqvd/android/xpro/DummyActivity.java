package com.theqvd.android.xpro;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class DummyActivity extends Activity {
	static final String tag = Config.xvncbinary + "-DummyActivity-" +java.util.Map.Entry.class.getSimpleName();
	Config config;
	Intent x11Intent;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.dummylayout);
		Log.i(tag, "receiving intent:"+this.getIntent());
		config = new Config(this); // side effect sets the activity for config
		x11Intent = new Intent(this, XserverService.class);
		Log.i(tag, "launching intent:"+x11Intent);
		Log.i(tag, "Orientation:"+getRequestedOrientation()+";");
		startService(x11Intent);
		setResult(RESULT_OK);
		finish();
    }
	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	protected void onPause() {
		super.onResume();
	}
	@Override
	protected void onStop() {
		super.onStop();
		setResult(RESULT_OK);
	}
}
