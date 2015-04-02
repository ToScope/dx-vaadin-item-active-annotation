package ditem.item

import com.vaadin.data.Item
import com.vaadin.data.Property
import com.vaadin.data.Item.PropertySetChangeListener
import java.util.List
import java.util.ArrayList
import static extension java.lang.Integer.parseInt

/***
 * Collections of Properties with the same Type
 */
class PropertyList<T> implements Item, Item.PropertySetChangeNotifier{
	final List<Property<T>> properties
	
	new(){
		properties = new ArrayList()
	}
	
	new(Property<T>... properties){
		properties = new ArrayList(properties)
	}
	
	override addItemProperty(Object id, Property property) throws UnsupportedOperationException {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getItemProperty(Object id) {
		return getItemProperty(id.toString.parseInt)
	}
	
	def getItemProperty(int id) {
		return properties.get(id)
	}
	
	override getItemPropertyIds() {
		return (0..properties.size).toList
	}
	
	override removeItemProperty(Object id) throws UnsupportedOperationException {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override addListener(PropertySetChangeListener listener) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override addPropertySetChangeListener(PropertySetChangeListener listener) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override removeListener(PropertySetChangeListener listener) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override removePropertySetChangeListener(PropertySetChangeListener listener) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}