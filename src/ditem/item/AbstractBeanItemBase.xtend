package ditem.item

import ditem.property.BeanItemProperty
import ditem.property.IdentableProperty
import ditem.property.PropertyChangeEmitter
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.lang.reflect.Type
import java.util.Hashtable
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

import static extension com.google.common.base.Preconditions.checkNotNull

class AbstractBeanItemBase<T> extends AbstractItemBase<T> implements Type, PropertyChangeListener {
	protected Map<String, IdentableProperty<?>> toProperty

	@Accessors
	T bean

	new(T bean) {
		this.bean = bean.checkNotNull
		if(bean instanceof PropertyChangeEmitter) {
			bean.addPropertyChangeListener(this)
		}
	}

	protected def void initBeanProperties(IdentableProperty<?>... properties) {
		toProperty = new Hashtable(properties.size)
		properties.forEach[addBeanProperty]
		firePropertySetChange()
	}

	private def addBeanProperty(IdentableProperty<?> property) {
		toProperty.put(property.getID, property)
		return true
	}

	override getItemProperty(Object id) {
		val item = toProperty?.get(id)
		return item ?: super.getItemProperty(id)
	}

	override getItemPropertyIds() {
		return newHashSet() => [
			addAll(toProperty?.keySet)
			addAll(super.getItemPropertyIds)
		]
	}

	override getTypeName() {
		return bean?.class.name
	}

	override toString() {
		val propertiesAsString = (if(toProperty == null) "" else (toProperty.values.map[ID + ":" + toString].join(", ")))
		val superProperties = if(super.toString.isEmpty) "" else ", " + super.toString
		'''«bean?.class.simpleName»{«propertiesAsString»«superProperties»}'''
	}

	override propertyChange(PropertyChangeEvent changeEvent) {
		val property = getItemProperty(changeEvent.propertyName)
		if(property instanceof BeanItemProperty<?>) {
			property.refresh()
		}
	}

}
