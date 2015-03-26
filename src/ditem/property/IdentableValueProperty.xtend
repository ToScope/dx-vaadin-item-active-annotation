package ditem.property

import org.eclipse.xtend.lib.annotations.Data

/***
 * Vaadin com.vaadin.data.Property with Type and value and id. 
 */
@Data
class IdentableValueProperty<T> extends ValueProperty<T> implements IdentableProperty<T> {

	final String id

	new(T value, String id) {
		super(value)
		this.id = id
	}

	override getID() {
		return id
	}

	override toString() {
		id + ":" + super.toString
	}

}
