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
package com.theqvd.android.xpro;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class DummyActivity extends Activity {
	static final String tag = L.xvncbinary + "-DummyActivity-" +java.util.Map.Entry.class.getSimpleName();
	Config config;
	Intent x11Intent;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(L.r_dummylayout);
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
