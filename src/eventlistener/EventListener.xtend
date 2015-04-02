package eventlistener

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.Collection
import java.util.LinkedList
import javax.lang.model.type.NullType
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.ResolvedMethod
import org.eclipse.xtend.lib.macro.declaration.TypeReference

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addSafeMethod
import static  de.tf.xtend.util.AnnotationProcessorExtensions.registerType

/***
 * Adds remove, add and initializer to listener
 */
@Target(ElementType.FIELD)
@Active(EventListenerProcessor)
annotation EventListener {
	Class<?> event = NullType
}

class EventListenerProcessor extends AbstractFieldProcessor {

	override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
		val mutableClass = field.declaringType
		field.markAsRead

		if (!Collection.newTypeReference.isAssignableFrom(field.type)) {
			context.addError(field, "Listener field have to be a Collection/List.")
			return
		}

		val listener = field.type.actualTypeArguments.head

		if (listener.declaredResolvedMethods.isEmpty) {
			context.addError(field, "Listener Interface has no event method")
		}
		if (listener.declaredResolvedMethods.size > 1) {
			context.addError(field,
				"Listener Interface have to be a SAM type (Interface with, one single abstract method")
		} else {

			var event = field.annotations.findFirst[it == EventListener].getClassValue("event")
			val reventMethod = listener.declaredResolvedMethods.head

			if (event == NullType.newTypeReference) {
				if (reventMethod.resolvedParameters.size != 1) {
					context.addError(field, "Listener event method has to declare one method with one parameter")
				} else {
					event = reventMethod.resolvedParameters.head.resolvedType
				}
			}

			val fieldName = field.simpleName
			val listType = LinkedList.newTypeReference
			registerType(mutableClass, listType, context)

			addAddListenerMethod(mutableClass, listener, fieldName, listType)

			addRemoveListenerMethod(mutableClass, listener, fieldName)

			addFireVentMethod(listener, mutableClass, event, fieldName, reventMethod)

		}
	}



	/***<code><pre>
	 * public void addPropertySetChangeListener(PropertySetChangeListener listener){
	 * 	if(this.listeners == null){
	 * 		this.listeners = new LinkedList<PropertySetChangeListener>();
	 * 	}
	 * 	this.listeners.add(listener);
	 * }
	 * </pre></code>
	 */
	def addAddListenerMethod(MutableTypeDeclaration mutableClass, TypeReference listener, String fieldName,
		TypeReference listType) {
		mutableClass.addSafeMethod("add" + listener.simpleName, [
			addParameter("listener", listener)
			body = [
				'''
					if(this.«fieldName» == null){
						this.«fieldName» = new «listType»<>();
					}
					this.«fieldName».add(listener);
				'''
			]
		])
	}

	/***<code><pre>
	 * 	public void removePropertySetChangeListener(PropertySetChangeListener listener){
	 * 	if(this.listeners != null){
	 * 		this.listeners.remove(listener);
	 * 	}
	 * }
	 * </pre></code>
	 */
	def addRemoveListenerMethod(MutableTypeDeclaration mutableClass, TypeReference listener, String fieldName) {
		mutableClass.addSafeMethod("remove" + listener.simpleName, [
			addParameter("listener", listener)
			body = [
				'''
					if(this.«fieldName» == null){
						this.«fieldName».remove(listener);
					}
				'''
			]
		])
	}

	/***<code><pre>
	 * 	public void firePropertySetChangeEvent(Item.PropertySetChangeEvent event){
	 * 	if(this.listeners == null){
	 * 		for (PropertySetChangeListener listener : this.listeners) {
	 * 			listener.itemPropertySetChange(event);
	 * 		}
	 * 	}
	 * }
	 * </pre></code>
	 */
	def addFireVentMethod(TypeReference listener, MutableTypeDeclaration mutableClass, TypeReference event,
		String fieldName, ResolvedMethod eventMethod) {

		mutableClass.addSafeMethod("fire" + event.simpleName, [
			addParameter("event", event)
			body = [
				'''
					if(this.«fieldName» != null){
						for («listener» listener : this.«fieldName») {
							«fieldName».«eventMethod.declaration.simpleName»(event);
						}
					}
				'''
			]
		])
	}



}
