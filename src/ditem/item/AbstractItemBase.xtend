package ditem.item

import com.vaadin.data.Item
import com.vaadin.data.Property
import ditem.property.IdentableProperty
import ditem.property.IdentablePropertyProxy
import java.util.HashMap
import java.util.LinkedList
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Data

import static java.util.Collections.EMPTY_MAP
import static java.util.Collections.EMPTY_SET

import static extension com.google.common.base.Preconditions.checkNotNull

class AbstractItemBase<T> implements Item, Item.PropertySetChangeNotifier {
	protected List<PropertySetChangeListener> changeListener
	protected Map<String, IdentableProperty<?>> toProperty

	def addItemProperty(IdentableProperty<?> property) {
		property.checkNotNull
		toProperty = toProperty ?: new HashMap()

		if(toProperty.containsKey(property.getID)) {
			return false
		} else {
			toProperty.put(property.getID, property)
			firePropertySetChange()
			return true
		}
	}

	override addItemProperty(Object id, Property property) {
		return addItemProperty(new IdentablePropertyProxy(id.toString, property.checkNotNull))
	}

	override IdentableProperty<?> getItemProperty(Object id) {
		return toProperty?.get(id)
	}

	override getItemPropertyIds() {
		return toProperty?.keySet ?: EMPTY_SET
	}

	override removeItemProperty(Object id) throws UnsupportedOperationException {
		return toProperty?.remove(id) != null
	}

	override addListener(PropertySetChangeListener listener) {
		addPropertySetChangeListener(listener)
	}

	override addPropertySetChangeListener(PropertySetChangeListener listener) {
		changeListener = changeListener ?: new LinkedList()
		changeListener += listener
	}

	override removeListener(PropertySetChangeListener listener) {
		removePropertySetChangeListener(listener)
	}

	override removePropertySetChangeListener(PropertySetChangeListener listener) {
		if(changeListener != null) {
			changeListener -= listener
		}
	}

	protected def firePropertySetChange() {
		val changeEvent = new PropertySetChangeEvent(this);
		changeListener?.forEach[it.itemPropertySetChange(changeEvent)]
	}

	@Data
	static class PropertySetChangeEvent implements Item.PropertySetChangeEvent {
		Item item
	}

	override toString() {
		return (toProperty ?: EMPTY_MAP).values.map[toString].join(" ")
	}

}
