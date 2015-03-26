package mytest

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.io.Serializable
import java.util.Date
import java.util.HashSet
import java.util.Set
import mytest.java.IQuote

class XQuote implements IQuote, Serializable {
	private static final long serialVersionUID = 1L;

	private Date created;
	private double totalPrice;
	private String title;

	private Set<PropertyChangeListener> propertyChangeListeners = new HashSet<PropertyChangeListener>();

	def void add(PropertyChangeListener changeListener) {
		propertyChangeListeners.add(changeListener);
	}

	def protected void firePropertyChange(PropertyChangeEvent evt) {
		for (PropertyChangeListener listener : propertyChangeListeners) {
			listener.propertyChange(evt);
		}
	}

	new(String title) {
		this.title = title;
	}

	override Date getCreated() {
		return created;
	}

	override void setCreated(Date created) {
		firePropertyChange(new PropertyChangeEvent(this, "created", this.created, created));
		this.created = created;
	}

	override double getTotalPrice() {
		return totalPrice;
	}

	override void setTotalPrice(double totalPrice) {
		firePropertyChange(new PropertyChangeEvent(this, "totalPrice", this.totalPrice, totalPrice));
		this.totalPrice = totalPrice;
	}

	override String getTitle() {
		return title;
	}

	override void setTitle(String title) {
		firePropertyChange(new PropertyChangeEvent(this, "title", this.title, title));
		this.title = title;
	}
}
