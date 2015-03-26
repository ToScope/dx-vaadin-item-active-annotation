package ditem.processor

import ditem.item.AbstractBeanItemBase
import ditem.property.DItemProperty
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport
import metamodel.Deep
import metamodel.Generated
import metamodel.MetaModelOf
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static org.eclipse.xtend.lib.macro.declaration.Visibility.*

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_notEquals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addInterface
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.getStackTraceAsString
import static extension ditem.processor.DItemNamingConventions.*
import static extension serial.SerialVersionUIDProcessor.addSerialVersionUID
import ditem.property.PropertyChangeEmitter
import ditem.item.DItemModel
import org.eclipse.xtend.lib.macro.declaration.NamedElement

@Active(DItemProcessor)
annotation DItem {
}

class DItemProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	boolean calculateSerialVersionUID = true
	val warning = "<h1>Generated Class, Don't Change!</h1><br>For modifying open "

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.getDItemClassName)
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		try {
			generateDItem(annotatedClass, context)
			generateAccesors(annotatedClass, context)
			generatePropertyChangeSupport(annotatedClass, context)
			annotatedClass.addSerialVersionUID(context, calculateSerialVersionUID)
			annotatedClass.addInterface(DItemModel.newTypeReference)
		} catch(Exception e) {
			annotatedClass.addWarning(e.stackTraceAsString)
		}
	}
	
	
	def boolean generateSetter(MutableClassDeclaration clazz, MutableFieldDeclaration it){
		return !isStatic && !final && !class.declaredMethods.exists[m|m.name == getter]
	}
	
	def boolean generateGetter(MutableClassDeclaration clazz, MutableFieldDeclaration it){
		return !isStatic && !class.declaredMethods.exists[m|m.name == getter]
	}
	
	def boolean generateProperty(MutableFieldDeclaration it){
		return !isStatic
	}
	
	def static getter(NamedElement field){
		"get"+field.simpleName.toFirstUpper
	}
	
	def static setter(NamedElement field){
		"set"+field.simpleName.toFirstUpper
	}
	
	def void generateAccesors(MutableClassDeclaration clazz, extension TransformationContext context){
		generateGetter(clazz, context)
		generateSetter(clazz, context)
	}
	
	def void generateGetter(MutableClassDeclaration clazz, extension TransformationContext context){
			for (f : clazz.declaredFields.filter[generateGetter(clazz, it)]) {
			clazz.addMethod(f.getter) [
				returnType = f.type
				body = '''return this.«f.simpleName»;'''
				primarySourceElement = f
			]
			f.markAsRead
			}
	}
	
	def void generateSetter(MutableClassDeclaration clazz, extension TransformationContext context){
			for (f : clazz.declaredFields.filter[generateSetter(clazz, it)]) {
			clazz.addMethod(f.setter) [
				addParameter(f.simpleName, f.type)
				body = '''
					«f.type» _oldValue = this.«f.simpleName»;
					this.«f.simpleName» = «f.simpleName»;
					_propertyChangeSupport.firePropertyChange("«f.simpleName»", _oldValue, «f.simpleName»);
				'''
				primarySourceElement = f
			]
			}
	}
	
		def void generatePropertyChangeSupport(MutableClassDeclaration clazz, extension TransformationContext context){
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
	
	

	def initPropertyChangeListener(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		for (method : annotatedClass.declaredMethods) {
			if(method.simpleName.startsWith("set") && method.visibility == PUBLIC){
				val setterName = method.simpleName
				val delegateName = "_"+setterName
				method.simpleName = delegateName
				method.visibility =  PRIVATE
				
				annotatedClass.addMethod(setterName,[m|
					m.body = '''
						System.out.println("lol");
						«»
						«delegateName»;
					'''
					method.parameters.forEach[m.addParameter(it.simpleName,it.type)]
					m.addParameter("",null)
					m.visibility = PUBLIC
				])
			}
			
		}
	}

	def generateDItem(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val dItem = context.findClass(annotatedClass.getDItemClassName)
		dItem.docComment = warning + annotatedClass.simpleName + ".java <br>" + annotatedClass.docComment

		addVaadinProperties(annotatedClass, context, dItem)
		addConstructor(annotatedClass, context, dItem)

		//		addToString(annotatedClass, context, dItem)
		addMarkerAnnotations(dItem, context, annotatedClass)

		dItem.addSerialVersionUID(context, calculateSerialVersionUID)
	}

	def addMarkerAnnotations(MutableClassDeclaration dItem, extension TransformationContext context, MutableClassDeclaration annotatedClass) {
		dItem.addAnnotation(DItem.newAnnotationReference)
		dItem.addAnnotation(MetaModelOf.newAnnotationReference[setStringValue("value", annotatedClass.qualifiedName)])
		annotatedClass.addAnnotation(Generated.newAnnotationReference[setStringValue("source", dItem.qualifiedName)])
	}

	def addToString(MutableClassDeclaration annotatedClass, extension TransformationContext context, MutableClassDeclaration dItem) {
		val String toString = annotatedClass.declaredFields.map['''«it.propertyGetterName»()'''].join('+" "+');
		dItem.addMethod("toString",
			[
				returnType = String.newTypeReference
				body = '''return «toString»;'''
			])
	}

	def addVaadinProperties(MutableClassDeclaration annotatedClass, extension TransformationContext context, MutableClassDeclaration dItem) {
		dItem.extendedClass = AbstractBeanItemBase.newTypeReference(annotatedClass.newTypeReference)
		for (field : annotatedClass.declaredFields.filter[generateProperty]) {
			if(field.annotations.exists[it == Deep]) {
				addReferencePropertie(annotatedClass, field, context, dItem)
			} else {
				addVaadinPropertie(field, context, dItem)
			}
		}
	}

	def addConstructor(MutableClassDeclaration annotatedClass, extension TransformationContext context, MutableClassDeclaration dItem) {
		val constructor = '''
			super(«beanName»);
			«createPropertyInitializer(annotatedClass, context)»
			initBeanProperties(«annotatedClass.declaredFields.filter[it != Deep && generateProperty].map[propertyName].join(", ")»);
		''';
		dItem.addConstructor [
			addParameter(beanName, annotatedClass.newTypeReference)
			body = [constructor]
		]
	}

	def String createPropertyInitializer(MutableClassDeclaration annotatedClass, TransformationContext context) {
		var String propertyInitializer = "";
		for (field : annotatedClass.declaredFields.filter[generateProperty]) {
			propertyInitializer += if(field.annotations.exists[it == Deep]){
				createPropertyReferenceInitializer(context, field)}
			else{
				createPropertyInitializer(context, field)
				}
		}
		return propertyInitializer;
	}

	static def String createPropertyReferenceInitializer(extension TransformationContext context, MutableFieldDeclaration it) {
		val itemType = getDItemClassName.newTypeReference
		return '''
			«propertyName» = new «itemType.name»(«beanName».«getter»());
		'''
	}

	/***				
	 * // new DItemProperty<Type>(bean.getXX(),Type.class,bean::getXX, bean::setXX, "beanName");
	 */
	static def String createPropertyInitializer(extension TransformationContext context, MutableFieldDeclaration it) {
		val objectPropertyType = DItemProperty.newTypeReference(type)
		return '''
			«propertyName» = new «objectPropertyType»(«beanName».«getter»(), «type.wrapperIfPrimitive».class, «beanName»::«getter», «beanName»::«setter», "«simpleName»");
		'''
	}

	def addVaadinPropertie(MutableFieldDeclaration field, extension TransformationContext context, MutableClassDeclaration dItem) {
		val objectPropertyType = DItemProperty.newTypeReference(field.type)

		addPropertyField(dItem, field, objectPropertyType, context)
		addPropertyGetter(dItem, field, objectPropertyType, context)
	}

	def addReferencePropertie(MutableClassDeclaration annotatedClass, MutableFieldDeclaration field, extension TransformationContext context,
		MutableClassDeclaration dItem) {
		val itemType = field.getDItemClassName.newTypeReference

		addPropertyField(dItem, field, itemType, context)
		addPropertyGetter(dItem, field, itemType, context)
	}

	def addPropertyGetter(MutableClassDeclaration dItem, MutableFieldDeclaration field, TypeReference propertyType,
		extension TransformationContext context) {
		dItem.addMethod(field.propertyGetterName) [
			field.markAsRead
			returnType = propertyType
			body = '''return «field.propertyName»;'''
			primarySourceElement = field
		]
	}

	def addPropertyField(MutableClassDeclaration annotatedClass, MutableFieldDeclaration field, TypeReference objectPropertyType,
		extension TransformationContext context) {
		annotatedClass.addField(field.propertyName) [
			type = objectPropertyType
			final = true
			visibility = Visibility.PRIVATE
			primarySourceElement = field
		]
	}

}
