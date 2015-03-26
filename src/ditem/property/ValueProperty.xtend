package ditem.property

import com.vaadin.data.util.AbstractProperty
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import com.vaadin.data.Property.ReadOnlyException

/***
 * Vaadin com.vaadin.data.Property with Type and value. 
 */
class ValueProperty<T> extends AbstractProperty<T>{
	final Class<T> type
	@Accessors
	T value
	
	new(Class<T> type, T value){
		this.type = type
		this.value = value
	}
	
	new(T value){
		this(value.class as Class<T>, value)
	}

	override getType() {
		type
	}
	
	override toString() {
		value.toString()
	}
		
}