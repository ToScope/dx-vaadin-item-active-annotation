package ditem.property

import com.vaadin.data.Property

class DerivedProperty<T> extends DItemProperty<T>
{

	new(Class<T> type, ()=>T getter, String id, DItemProperty<?>... properties) {
		super(type, getter, id)
		initProperties(properties)
	}

	private def initProperties(DItemProperty<?>... properties) {
		properties.forEach[addValueChangeListener[valueChange]]

	}
	
	def valueChange(Property.ValueChangeEvent event) {
		fireValueChange()
	}

}
