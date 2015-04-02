package eventlistener;

import java.util.LinkedList;
import java.util.List;

import com.vaadin.data.Item;
import com.vaadin.data.Item.PropertySetChangeListener;

public class EventListenerExample {
	
	
	private List<PropertySetChangeListener> listeners;
	
	public void addPropertySetChangeListener(PropertySetChangeListener listener){
		if(this.listeners == null){
			this.listeners = new LinkedList<PropertySetChangeListener>();
		}
		this.listeners.add(listener);
	}
	
	public void removePropertySetChangeListener(PropertySetChangeListener listener){
		if(this.listeners != null){
			this.listeners.remove(listener);
		}
	}
	
	public void firePropertySetChangeEvent(Item.PropertySetChangeEvent event){
		if(this.listeners == null){
			for (PropertySetChangeListener listener : this.listeners) {
				listener.itemPropertySetChange(event);
			}
		}
	}
	
	
}
