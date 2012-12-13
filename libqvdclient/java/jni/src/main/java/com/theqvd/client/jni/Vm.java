package com.theqvd.client.jni;


/**
 * 
 * Represents a Virtual machine in QVD
 * 
 * @author nito
 *
 */
public class Vm {
	private int id;
	private String name;
	private String state;
	private int blocked;
	
	public Vm(int id, String name, String state, int blocked) {
		this.id = id;
		this.name = name;
		this.state = state;
		this.blocked = blocked;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public int getBlocked() {
		return blocked;
	}
	public void setBlocked(int blocked) {
		this.blocked = blocked;
	}
	@Override
	public String toString() {
		return "vm:id="+id+";name="+name+";state="+state+";blocked="+blocked;
	}
}