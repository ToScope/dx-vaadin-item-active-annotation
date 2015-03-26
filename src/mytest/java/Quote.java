package mytest.java;

import com.vaadin.data.Property;
import com.vaadin.data.util.ObjectProperty;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.Serializable;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;


public class Quote implements IQuote, Serializable {
	private static final long serialVersionUID = 1L;
	
	private Date created;
	private double totalPrice;
	private String title;
	
	
	
	public Property<String> getTitleProperty(){
		return new ObjectProperty<String>(title,String.class);
	}
	
	private Set<PropertyChangeListener> propertyChangeListeners = new HashSet<PropertyChangeListener>();

	public void add(PropertyChangeListener changeListener){
		propertyChangeListeners.add(changeListener);
	}
	
	protected void firePropertyChange(PropertyChangeEvent evt){
		for (PropertyChangeListener listener : propertyChangeListeners) {
			listener.propertyChange(evt);
		}
	}
	
	public Quote(String title) {
		this.title = title;
	}

	@Override
	public Date getCreated() {
		return created;
	}

	@Override
	public void setCreated(Date created) {
		firePropertyChange(new PropertyChangeEvent(this, "created", this.created, created));
		this.created = created;
	}

	@Override
	public double getTotalPrice() {
		return totalPrice;
	}

	@Override
	public void setTotalPrice(double totalPrice) {
		firePropertyChange(new PropertyChangeEvent(this, "totalPrice", this.totalPrice, totalPrice));
		this.totalPrice = totalPrice;
	}

	@Override
	public String getTitle() {
		return title;
	}

	@Override
	public void setTitle(String title) {
		firePropertyChange(new PropertyChangeEvent(this, "title", this.title, title));
		this.title = title;
	}
	
	

}
