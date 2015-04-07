/**
 * FolderTreeCopy
 * Copies all the files from the source folder to the target folder
 * 
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
 */
package com.theqvd.android.xpro;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import android.content.res.AssetManager;
import android.util.Log;

/**
 * 
 * Copies files or folders.
 * 
 * Be aware that for files in Android 2.2 errors with more than 1MB files
 * might arise. See 
 * http://android.git.kernel.org/?p=platform/frameworks/base.git;a=commit;h=b100cbf178e91d6652ebbad3ed36684cacb9d10e
 * 
 * We use the .ogg extension, and if a file with that extension appears in 
 * the asset directory we copy it without that extension.
 * 
 * @author Nito@Qindel.ES
 *
 */
public class AssetTreeCopy {
	static final private String tag = L.xvncbinary + "-AssetTreeCopy-" +java.util.Map.Entry.class.getSimpleName();
	static final private String srcDirInAsset = Config.assetscopydir;
	static private String specialExtension = Config.specialAndroid22Extension;
	static private Integer filesCopied = 0;
	static private Integer filesToCopy = 0;
	static private boolean copied = false;
	static private boolean error = false;
	private static boolean copying = false;
	
	public static synchronized Integer getFilesCopied() {
		return filesCopied;
	}

	public static synchronized void setFilesCopied(Integer filesCopied) {
		AssetTreeCopy.filesCopied = filesCopied;
	}
	public static synchronized void incrementFilesCopied() {
		filesCopied ++;
	}

	public static synchronized Integer getFilesToCopy() {
		return filesToCopy;
	}

	public static synchronized void setFilesToCopy(Integer filesToCopy) {
		AssetTreeCopy.filesToCopy = filesToCopy;
	}
	public static Integer getPercentageOfFilesCopied() {
		
		Integer percentage;
		filesToCopy = getFilesToCopy();
		filesCopied = getFilesCopied();
		percentage = filesToCopy == 0 ? 0 : filesCopied * 100 / filesToCopy;
		percentage = isError() ? 100 : percentage;
		return percentage;
	}

	/**
	 * 
	 * @param am The Asset manager
	 * @param assetSrc The directory inside the asset where the MANIFEST file with all the files
	 *                 to copy exist
	 * @param target where to copy the files located in the MANIFEST file
	 * @throws IOException 
	 * @throws InterruptedException 
	 * @throws XvncproException 
	 */

	public static void copy (AssetManager am, String assetSrc, String target) throws IOException, InterruptedException, XvncproException {
		if (checkAndSetCopying()) {
			Log.w(tag, "Already copying");
			return;
		}
		List<String> files = getFileListToCopy(am, assetSrc+"/index");
		setFilesToCopy(files.size());
		setFilesCopied(0);
		Log.i(tag, "Files to copy from index are: " + files);
		copyFiles(am, files, target);
		
    	String cmd = "chmod 755 " + Config.xvnc;
    	Log.i(tag, "launching:"+cmd);
    	Process process = Runtime.getRuntime().exec(cmd);
    	Log.i(tag, "after launch:"+cmd);
    	process.waitFor();
    	setCopying(false);
		setCopied(true);	
	}
	
	private static List<String> getFileListToCopy(AssetManager assetManager, String src) throws IOException {
		InputStream inputStream;
		List<String> files = new ArrayList<String>();
		inputStream = assetManager.open(src);
		InputStreamReader isr = new InputStreamReader(inputStream);
		BufferedReader b = new BufferedReader(isr);
		String line;
		while ((line = b.readLine()) != null) {
			if (Config.debug) { Log.i("AssetTreeCopy", "Found line <"+line+">"); }
			files.add(line);
		}
		inputStream.close();
		   
		//} catch (IOException e) {
		//	Log.e("tag", e.getMessage());
        //}
		return files;
	}
	private static void copyFiles(AssetManager am, List<String> files, String destFolder) throws IOException, XvncproException
	{
		Pattern pattern = Pattern.compile("^(.*?)"+specialExtension+"$");
		for (String file: files) {
			Matcher m = pattern.matcher(file);
			if (m.find()) 
			{
				if (Config.debug) { Log.d(tag, "Pattern <"+pattern+"> found in string " + file + " with matching part "+m.group(1)); }
				copyFile(am, srcDirInAsset + "/" + file, destFolder + "/" + m.group(1));	
			} else
			{
				if (Config.debug) { Log.d(tag, "Pattern <"+pattern+"> not found in string " + file); }
				copyFile(am, srcDirInAsset + "/" + file, destFolder + "/" + file);	
			}
			incrementFilesCopied();
		}
	}
	
	private static final String rootDir = "/";
	private static final File rootDirFile = new File(rootDir);
	private static void createParentDir(File file) throws XvncproException
	{
		File parentDir = file.getParentFile();
		
		if (parentDir.exists()) {
			if (Config.debug) { Log.d(tag, "parentDir is <"+parentDir + "> and exists. Returning"); }
			return;
		} else {
			if (parentDir == rootDirFile) {
				throw new XvncproException("mkdirs of <" + rootDir + "> Should never happen with parentDir: " + parentDir);
			}
			File grandpa = parentDir.getParentFile();
			if (!grandpa.exists()) {
				if (Config.debug) { Log.d(tag, "parentDir is <"+parentDir + "> and parent does not exists <"+grandpa+">. Recursive call"); }
				createParentDir(parentDir);
			}
			if (Config.debug) { Log.d(tag, "parentDir is <"+parentDir + "> and parent exists <"+grandpa+">. Creating dir"); }
			parentDir.mkdir();
			if (parentDir.exists()) {
				if (Config.debug) { Log.d(tag, "parentDir is <"+parentDir + "> and was successfully created"); }
				return;
			} else {
				throw new XvncproException("After mkdirs the directory does not exists:" + parentDir);					
			}
		}
	}
	
	public static void copyFile(AssetManager am, String srcFile, String destFile) throws XvncproException
	 //throws IOException
	{
		
	        InputStream oInStream;
	        OutputStream oOutStream;
	        BufferedInputStream oBuffInputStream;
			try {
				oInStream = am.open(srcFile);
				File destFileFile = new File(destFile);
				Log.i(tag, "destfile is <" + destFileFile + ">");
				createParentDir(destFileFile);
				oOutStream = new FileOutputStream(destFileFile);
				oBuffInputStream = new BufferedInputStream( oInStream, 8192 );
		        // Transfer bytes from in to out
		        byte[] oBytes = new byte[8192];
		        int nLength;

		        while ((nLength = oBuffInputStream.read(oBytes)) > 0)
		        {
		        	oOutStream.write(oBytes, 0, nLength);
		        }
		        oInStream.close();
		        oOutStream.close();
			} catch (FileNotFoundException e) {
				Log.e(tag, "Error writing to file " + destFile + e.toString());
				throw new XvncproException(e.toString());
			} catch (IOException e) {
				Log.e(tag, "Error opening file " + srcFile + ":" + e.toString());
				throw new XvncproException(e.toString());
			}
	 

	}
	
	public static synchronized void setCopied(boolean mycopied) {
		copied = mycopied;
//		Log.d(tag, "AssetTreeCopy.copied = " + mycopied);
	}

	public static synchronized boolean isCopied() {
		boolean result;
		result = copied;
		return result;
	}
	public static synchronized void setError(boolean error) {
		AssetTreeCopy.error = error;
		if (error) {
			copying = false;
			copied = false;
		}
	}
	public static synchronized boolean isError() {
		boolean result;
		result = error;
		return result;
	}
	public static synchronized boolean isCopying() {
		return copying;
	}

	public static synchronized void setCopying(boolean copying) {
		AssetTreeCopy.copying = copying;
	}
	public static synchronized boolean checkAndSetCopying() {
		if (AssetTreeCopy.copying) {
			return true;
		}
		AssetTreeCopy.copying = true;
		return false;
		
	}
}
