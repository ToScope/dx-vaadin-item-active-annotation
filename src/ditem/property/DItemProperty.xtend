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

	new(T value, Class<T> type, ()=>T getter, (T)=>void setter, String id) {
		this(value, type, getter, setter, id, false)
	}

	new(T value, Class<T> type, ()=>T getter, String id) {
		this(value, type, getter, null, id, false)
		readOnly = true
	}

	new(T value, Class<T> type, ()=>T getter, (T)=>void setter, String id, boolean notifyOnChange) {
		this.getter = getter
		this.setter = setter
		this.value = value
		this.type = type
		this.id = id
		this.notifyOnChange = notifyOnChange
	}

	new(T value, ()=>T getter, (T)=>void setter, String id, boolean notifyOnChange) {
		this(value, value.class as Class<T>, getter, setter, id, notifyOnChange)
	}

	new(T value, ()=>T getter, (T)=>void setter, String id) {
		this(value, value.class as Class<T>, getter, setter, id, false)
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
