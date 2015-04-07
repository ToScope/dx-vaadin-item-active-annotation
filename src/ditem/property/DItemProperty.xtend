package ditem.property

import com.vaadin.data.util.AbstractProperty
import com.vaadin.data.Property.ReadOnlyException
import ditem.property.BeanItemProperty

class DItemProperty<T> extends AbstractProperty<T> implements BeanItemProperty<T> {

	final val ()=>T getter
	final val (T)=>void setter
	final String id
	boolean notifyOnChange

	/**
     * Data type of the Property's value.
     */
	final Class<T> type

	new(Class<T> type, ()=>T getter, (T)=>void setter, String id) {
		this( type, getter, setter, id, false)
	}

	new( Class<T> type, ()=>T getter, String id) {
		this( type, getter, null, id, false)
		readOnly = true
	}

	new(Class<T> type, ()=>T getter, (T)=>void setter, String id, boolean notifyOnChange) {
		this.getter = getter
		this.setter = setter
		this.type = type
		this.id = id
		this.notifyOnChange = notifyOnChange
	}


	override getType() {
		return type
	}

	override getValue() {
		return getter.apply()
	}

	override setValue(T value) throws ReadOnlyException {
		if(readOnly) {
			throw new IllegalAccessException('''field «id» is readonly''');
		} else {
			setter.apply(value)
			if(notifyOnChange) {
				fireValueChange()
			}
		}
	}

	override toString() {
		return value.toString()
	}

	override getID() {
		return id
	}

	override refresh() {
		fireValueChange()
	}

}
