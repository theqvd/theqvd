package com.theqvd.android.client;


import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

public class SelectVmActivity extends ListActivity implements OnItemClickListener {
	String tag;
	public final static String returnedvmname = "returned_vmname";
	public final static String returnedvmorder = "returned_vm_order";
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	tag = getResources().getString(R.string.app_name_qvd) + "-SelectVmActivity-" +java.util.Map.Entry.class.getSimpleName();
    	super.onCreate(savedInstanceState);
//    	setContentView(R.layout.selectvm);
    	// Use Listview see tutorial in Android
    	String vmlist[] = getIntent().getStringArrayExtra(QvdclientActivity.vmlistname);
    	if (vmlist == null) {
    		String error= "vmlist passed is null, this should not happen. ";
    		error("Error in SelectVmActivity", error, error);
    		setResult(RESULT_CANCELED);
    		finish();
    		return;
    	}
    	setListAdapter(new ArrayAdapter<String>(this,R.layout.selectvmitem, vmlist));
    	ListView lv = getListView();
    	lv.setTextFilterEnabled(true);
    	lv.setOnItemClickListener(this);
    }
  	public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {
  		Log.d(tag, "onItemClick(parent="+parent+",view="+view+",pos="+pos+",id="+id);
  		TextView tv = (TextView)view;
		String vmname = tv.getText().toString();
		Log.d(tag, "Vm name selected is " + vmname + " with pos "+pos);
		final Intent returnintent = new Intent(this, this.getClass());
		returnintent.putExtra(returnedvmname, vmname);
		returnintent.putExtra(returnedvmorder, pos);
		setResult(RESULT_OK, returnintent);
		finish();
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
}
