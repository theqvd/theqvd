package com.theqvd.android.client;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;
import android.app.SearchManager;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDoneException;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteQueryBuilder;
import android.database.sqlite.SQLiteStatement;
import android.provider.BaseColumns;
import android.util.Log;
import android.widget.Toast;

/**
 * 
 * Represents a singleton with a static current Connection and a HashMap of connections
 * 
 * The hashmap will have at least the "new Connection"
 * 
 * this is used to share data between the QvdclientActivity and the EditConnectionActivity
 * 
 * @author nito
 *
 */
public class ConnectionDB extends SQLiteOpenHelper {
	public static Connection currconnection = new Connection();
	private static String tag;
	private static Context context;

    private static final int db_version = 7;
    private static final String db_name = "connectiondb";
    private static final String db_table_name = "connectiondb";
    private static final String c_name = "name";
    private static final String c_host = "host";
    private static final String c_port = "port";
    private static final String c_login = "login";
    private static final String c_password = "password";
    private static final String c_link = "link";
    private static final String c_os = "os";
    private static final String c_keyboard = "keyboard";
    private static final String c_fullscreen = "fullscreen";
    private static final String c_width = "width";
    private static final String c_height = "height";
    private static final String c_debug = "debug";
    private static final String c_localx = "localx";
    private static final String c_useclientcert = "useclientcert";
    private static final String c_client_cert = "clientcert";
    private static final String c_client_key = "clientkey";
    private static final String c_usegoogleauth = "googleauth";
    private static final String[] column_names = {
    	c_name, c_host, c_port, c_login, c_password,
    	c_link, c_os, c_keyboard, c_fullscreen, c_width,
    	c_height, c_debug, c_localx, c_useclientcert,
    	c_client_cert, c_client_key, c_usegoogleauth
    	};
    private static final String db_table_create =
                "CREATE TABLE " + db_table_name + 
                " ( " +
                "rowid INTEGER PRIMARY KEY ASC," +
                c_name + " TEXT," +
                c_host + " TEXT," +
                c_port + " INTEGER," +
                c_login + " TEXT," +
                c_password + " TEXT," +
                c_link + " TEXT," +
                c_os + " TEXT," +
                c_keyboard +" TEXT," +
                c_fullscreen + " BOOLEAN," +
                c_width + " INTEGER," +
                c_height + " INTEGER," +
                c_debug + " BOOLEAN," +
                c_localx + " BOOLEAN," +
                c_useclientcert + " BOOLEAN," +
                c_client_cert + " TEXT," +
                c_client_key + " TEXT," +
                c_usegoogleauth + " BOOLEAN," +
                "UNIQUE (" + c_name +")" +
                ");";
    private static final String db_table_drop =
    		"DROP TABLE IF EXISTS "+db_table_name;
    private static final String db_table_insert =
    		"INSERT INTO " + db_table_name + 
    		" ("+c_name+","+c_host+","+c_port+","+
    	         c_login+","+c_password+","+c_link+","+	
    	         c_os+","+c_keyboard+","+c_fullscreen+","+
    	         c_width+","+c_height+","+c_debug+","+c_localx+","+
    	         c_useclientcert+","+
    	         c_client_cert+","+c_client_key+","+
    	         c_usegoogleauth+
    				") " +
    		" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    private static final String db_table_delete =
    		"DELETE FROM " + db_table_name + 
    		" WHERE (name = ?)";
    private static final String db_table_exists =
    		"SELECT 1 FROM " + db_table_name + 
    		" WHERE (name = ?)";
    private static final String upgrade[] = {
    	"", // oldVersion=0, should never happen
    	"ALTER TABLE "+db_table_name+" ADD COLUMN "+c_debug+" BOOLEAN", // oldVersion=1
    	"ALTER TABLE "+db_table_name+" ADD COLUMN "+c_localx+" BOOLEAN", // oldVersion=2
    	"ALTER TABLE "+db_table_name+" ADD COLUMN "+c_useclientcert+" BOOLEAN", // oldVersion=3
    	"ALTER TABLE "+db_table_name+" ADD COLUMN "+c_client_cert+" TEXT", // oldVersion=4
    	"ALTER TABLE "+db_table_name+" ADD COLUMN "+c_client_key+" TEXT", // oldVersion=5
    	"ALTER TABLE "+db_table_name+" ADD COLUMN "+c_usegoogleauth+" BOOLEAN", // oldVersion=6
    };
    private static SQLiteDatabase db;
    private static SQLiteStatement insertStatement, deleteStatement, existsStatement;
    private static final HashMap<String,String> column_map = buildColumnMap();
    private static ConnectionDB instance = null;

	
    ConnectionDB(Context context) {
        super(context, db_name, null, db_version);
        ConnectionDB.context = context;
    	tag = context.getResources().getString(R.string.app_name_qvd) + "-ConnectionDB-" +java.util.Map.Entry.class.getSimpleName();
        db = getWritableDatabase();
        insertStatement = db.compileStatement(db_table_insert);
        deleteStatement = db.compileStatement(db_table_delete);
        existsStatement = db.compileStatement(db_table_exists);
        setInstance(this);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(db_table_create);
    }

	
    public static boolean existsConnection (Connection c) throws SQLException {
    	return existsConnection(c.getName());
    }
    public static boolean existsConnection (String name) throws SQLException {
    	try {
			existsStatement.bindString(1, name);
			existsStatement.simpleQueryForLong();		// remove sql sentence on error remove entry
		} catch (SQLiteDoneException e) {
			Log.i(tag, "Returned no entries for name: " + name);
			return false;
		} catch (SQLException e) {
			Log.e(tag, "Error in removeConection("+ name + "): " + e);
			throw e;
		}
    	return true;
    }
	public Set<Connection> getConnections() throws SQLException {
		SQLiteQueryBuilder builder = new SQLiteQueryBuilder();
		builder.setTables(db_table_name);
		builder.setProjectionMap(column_map);
		Cursor cursor = builder.query(db, column_names, null, null, null, null, null);
		TreeSet<Connection> c = new TreeSet<Connection>();
		if (cursor.getCount() <= 0) {
			Log.d(tag, "getConnections: No rows found in the database "+ db_name+ " in table " +db_table_name);
			return c;
		}
		Log.d(tag, "getConnections, num of rows is "+cursor.getCount());
		for (cursor.moveToFirst(); ! cursor.isAfterLast(); cursor.moveToNext()) {
			Log.d(tag, "processing cursor "+cursor.getPosition());
			Connection con = new Connection();
			con.setName(cursor.getString(cursor.getColumnIndexOrThrow(c_name)));
			con.setHost(cursor.getString(cursor.getColumnIndexOrThrow(c_host)));
			con.setPort(cursor.getInt(cursor.getColumnIndexOrThrow(c_port)));
			con.setLogin(cursor.getString(cursor.getColumnIndexOrThrow(c_login)));
			// TODO create shared secret
			con.setPassword(cursor.getString(cursor.getColumnIndexOrThrow(c_password)));
			con.setLink(cursor.getString(cursor.getColumnIndexOrThrow(c_link)));
			con.setOs(cursor.getString(cursor.getColumnIndexOrThrow(c_os)));
			con.setKeyboard(cursor.getString(cursor.getColumnIndexOrThrow(c_keyboard)));
			con.setFullscreen(cursor.getInt(cursor.getColumnIndexOrThrow(c_fullscreen)) != 0);
			con.setWidth(cursor.getInt(cursor.getColumnIndexOrThrow(c_width)));
			con.setHeight(cursor.getInt(cursor.getColumnIndexOrThrow(c_height)));
			con.setDebug(cursor.getInt(cursor.getColumnIndexOrThrow(c_debug)) != 0);
			con.setUselocalxserver(cursor.getInt(cursor.getColumnIndexOrThrow(c_localx)) != 0);
			con.setUseclientcert(cursor.getInt(cursor.getColumnIndexOrThrow(c_useclientcert)) != 0);
			con.setClient_cert(cursor.getString(cursor.getColumnIndexOrThrow(c_client_cert)));
			con.setClient_key(cursor.getString(cursor.getColumnIndexOrThrow(c_client_key)));
			con.setGoogleauthentication(cursor.getInt(cursor.getColumnIndexOrThrow(c_usegoogleauth)) != 0);
			c.add(con);
		}
		
		return c;
	}
	public Connection getConnection(String name) throws SQLException {
		SQLiteQueryBuilder builder = new SQLiteQueryBuilder();
		builder.setTables(db_table_name);
		builder.setProjectionMap(column_map);
		Cursor cursor = builder.query(db, column_names, null, null, null, null, null);
		
		if (cursor.getCount() <=0  || cursor.getCount() >= 2) {
			
			Log.d(tag, "getConnections: " + (cursor.getCount() >= 2 ? "Too many rows " : "No rows found ") + 
					cursor.getCount() +" in the database "+ db_name+ " in table " +db_table_name);
			return null;
		}
		cursor.moveToFirst();
		Connection con = new Connection();
		con.setName(cursor.getString(cursor.getColumnIndexOrThrow(c_name)));
		con.setHost(cursor.getString(cursor.getColumnIndexOrThrow(c_host)));
		con.setPort(cursor.getInt(cursor.getColumnIndexOrThrow(c_port)));
		con.setLogin(cursor.getString(cursor.getColumnIndexOrThrow(c_login)));
		// TODO create shared secret
		con.setPassword(cursor.getString(cursor.getColumnIndexOrThrow(c_password)));
		con.setLink(cursor.getString(cursor.getColumnIndexOrThrow(c_link)));
		con.setOs(cursor.getString(cursor.getColumnIndexOrThrow(c_os)));
		con.setKeyboard(cursor.getString(cursor.getColumnIndexOrThrow(c_keyboard)));
		con.setFullscreen(cursor.getInt(cursor.getColumnIndexOrThrow(c_fullscreen)) != 0);
		con.setWidth(cursor.getInt(cursor.getColumnIndexOrThrow(c_width)));
		con.setHeight(cursor.getInt(cursor.getColumnIndexOrThrow(c_height)));
		con.setDebug(cursor.getInt(cursor.getColumnIndexOrThrow(c_debug)) != 0);
		con.setUselocalxserver(cursor.getInt(cursor.getColumnIndexOrThrow(c_localx)) != 0);
		con.setUseclientcert(cursor.getInt(cursor.getColumnIndexOrThrow(c_useclientcert)) != 0);
		con.setClient_cert(cursor.getString(cursor.getColumnIndexOrThrow(c_client_cert)));
		con.setClient_key(cursor.getString(cursor.getColumnIndexOrThrow(c_client_key)));
		con.setGoogleauthentication(cursor.getInt(cursor.getColumnIndexOrThrow(c_usegoogleauth)) != 0);
		return con;
	}
	public void addConnection(Connection c) throws SQLException {
		if (existsConnection(c)) {
			Log.e(tag, "You are trying to add a connection with an existing name:" + c.getName());
			return;
		}
		
		insertStatement.bindString(1, c.getName());
		insertStatement.bindString(2, c.getHost());
		insertStatement.bindLong(3, c.getPort());
		insertStatement.bindString(4, c.getLogin());
		// TODO create shared secret
		insertStatement.bindString(5, c.getPassword());
		insertStatement.bindString(6, c.getLink());
		insertStatement.bindString(7, c.getOs());
		insertStatement.bindString(8, c.getKeyboard());
		insertStatement.bindLong(9, c.isFullscreen() ? 1 : 0);
		insertStatement.bindLong(10, c.getWidth());
		insertStatement.bindLong(11, c.getHeight());
		insertStatement.bindLong(12, c.isDebug() ? 1 : 0);
		insertStatement.bindLong(13, c.isUselocalxserver() ? 1 : 0);
		insertStatement.bindLong(14, c.isUseclientcert() ? 1 : 0);
		insertStatement.bindString(15, c.getClient_cert());
		insertStatement.bindString(16, c.getClient_key());
		insertStatement.bindLong(17, c.isGoogleauthentication() ? 1 : 0);
		Long id = insertStatement.executeInsert();
		Log.i(tag, "inserted entry "+c+" with id " + id+". Debug is:"+c.isDebug());
	}
	public void removeConnection(Connection c) throws SQLException {
		removeConnection(c.getName());
	}
	public void removeConnection(String name) throws SQLException {
		if (!existsConnection(name)) {
			Log.e(tag, "You are trying to remove a non existing connection:" + name +" " + context);
			return;
		}
		deleteStatement.bindString(1, name);
		deleteStatement.execute();		// remove sql sentence on error remove entry
	}
	public void addCurrentConnection() throws SQLException {
		addConnection(currconnection);
	}
	
	public String dump() throws SQLException {
		String r = "curr="+currconnection+";";
		Iterator<Connection> i = getConnections().iterator();
		int index=0;
		while (i.hasNext()) {
			r += "c["+index+"]="+i.next()+";";
			index ++;
		}
		return r;
	}

	/**
     * Builds a map for all columns that may be requested, which will be given to the 
     * SQLiteQueryBuilder. This is a good way to define aliases for column names, but must include 
     * all columns, even if the value is the key. This allows the ContentProvider to request
     * columns w/o the need to know real column names and create the alias itself.
     */
    private static HashMap<String,String> buildColumnMap() {
    	int i;
        HashMap<String,String> map = new HashMap<String,String>();
        for (i= 0; i < column_names.length; ++i ) {
        	map.put(column_names[i], column_names[i]);
        }
        map.put(BaseColumns._ID, "rowid AS " +
                BaseColumns._ID);
        map.put(SearchManager.SUGGEST_COLUMN_INTENT_DATA_ID, "rowid AS " +
                SearchManager.SUGGEST_COLUMN_INTENT_DATA_ID);
        map.put(SearchManager.SUGGEST_COLUMN_SHORTCUT_ID, "rowid AS " +
                SearchManager.SUGGEST_COLUMN_SHORTCUT_ID);
        return map;
    }

	
	public void onDowngrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		Log.i(tag, "Downgrade of database from version " + oldVersion + " to version " + newVersion);
		Toast.makeText(context, "Downgrade. Recreating connection database", Toast.LENGTH_SHORT).show();
		db.execSQL(db_table_drop);
		db.execSQL(db_table_create);
	}
	
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		Log.i(tag, "Upgrade of database from version " + oldVersion + " to version " + newVersion);
		if (upgrade.length < newVersion) {
			Log.e(tag, "Error in the upgrade, upgrade lenght was "+upgrade.length+" but newVersion is bigger "+newVersion + ". Oldversion was "+oldVersion);
			Toast.makeText(context, "Error in the upgrade. Recreating connection database", Toast.LENGTH_SHORT).show();
			db.execSQL(db_table_drop);
			db.execSQL(db_table_create);
			return;
		}
		int i;
		Toast.makeText(context, "Upgrading connection database", Toast.LENGTH_SHORT).show();
		for (i=oldVersion; i < newVersion ; i++) {
			Log.i(tag, "Executing upgrade from version " + i +" to version " + (newVersion - 1) + ". Command: " + upgrade[i]);
			db.execSQL(upgrade[i]);
		}
	}
	protected void finalize() throws Throwable
	{
	  // Better close should be called explicitly
	  super.finalize(); 
	  if (isOpen()) 
		  close();	
	}

	public static ConnectionDB getInstance() {
		return instance;
	}

	public static void setInstance(ConnectionDB instance) {
		ConnectionDB.instance = instance;
	}
	public boolean isOpen() {
		return (db != null && db.isOpen());
	}
}
