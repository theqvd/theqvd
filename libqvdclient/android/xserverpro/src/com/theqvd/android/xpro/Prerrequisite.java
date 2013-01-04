package com.theqvd.android.xpro;

public interface Prerrequisite {
	public boolean isInstalled();
	public void install();
	public String getButtonText();
	public String getDescriptionText();
}
