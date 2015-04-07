package ditem.processor

import ditem.property.PropertyChangeEmitter
import java.beans.PropertyChangeListener
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addInterface

class PropertyChangeSupport {
	def static void generatePropertyChangeSupport(MutableClassDeclaration clazz, extension TransformationContext context) {
		// generated field to hold listeners, addPropertyChangeListener() and removePropertyChangeListener() 
		val changeSupportType = PropertyChangeSupport.newTypeReference
		clazz.addField("_propertyChangeSupport") [
			type = changeSupportType
			initializer = '''new «changeSupportType»(this)'''
			primarySourceElement = clazz
		]

		val propertyChangeListener = PropertyChangeListener.newTypeReference
		clazz.addMethod("addPropertyChangeListener") [
			addParameter("listener", propertyChangeListener)
			body = '''this._propertyChangeSupport.addPropertyChangeListener(listener);'''
			primarySourceElement = clazz
		]
		clazz.addMethod("removePropertyChangeListener") [
			addParameter("listener", propertyChangeListener)
			body = '''this._propertyChangeSupport.removePropertyChangeListener(listener);'''
			primarySourceElement = clazz
		]
		clazz.addInterface(PropertyChangeEmitter.newTypeReference)
	}
}