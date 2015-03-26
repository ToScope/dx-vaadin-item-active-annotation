package metamodel.flat

import com.vaadin.data.util.AbstractProperty
import com.vaadin.data.Property.ReadOnlyException

class DItemProperty<T> extends AbstractProperty<T> {

	final val ()=>T getter
	final val (T)=>void setter

	/**
     * Data type of the Property's value.
     */
	final Class<T> type

	new(T value, Class<T> type, ()=>T getter, (T)=>void setter) {
		this.getter = getter
		this.setter = setter
		this.value = value
		this.type = type
	}

	new(T value, ()=>T getter, (T)=>void setter) {
		this(value, value.class as Class<T>, getter, setter)
	}

	override getType() {
		return type
	}

	override getValue() {
		return getter.apply()
	}

	override setValue(T value) throws ReadOnlyException {
		setter.apply(value)
		fireValueChange()
	}

}
