package ditem.processor

import ditem.item.AbstractBeanItemBase
import ditem.item.DItemModel
import ditem.property.DItemProperty
import ditem.property.Derived
import ditem.property.DerivedProperty
import ditem.property.PropertyChangeEmitter
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
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static org.eclipse.xtend.lib.macro.declaration.Visibility.*

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addInterface
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.getStackTraceAsString
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_notEquals
import static extension ditem.processor.DItemNamingConventions.*
import static extension serial.SerialVersionUIDProcessor.addSerialVersionUID
import static ditem.processor.MetaModelClassesProcessor.registerMetaClasses
import static ditem.processor.MetaModelClassesProcessor.transformFieldClasses

@Active(DItemProcessor)
annotation DItem {
}

class DItemProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	boolean calculateSerialVersionUID = false
	boolean addDerived = false
	
	val warning = "<h1>Generated Class, Don't Change!</h1><br>For modifying open "

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.getDItemClassName)
			registerMetaClasses(annotatedClass, context)
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		try {
			transformFieldClasses(annotatedClass, context)
			generateDItem(annotatedClass, context)
			generateAccesors(annotatedClass, context)
			generatePropertyChangeSupport(annotatedClass, context)
			annotatedClass.addSerialVersionUID(context, calculateSerialVersionUID)
			annotatedClass.addInterface(DItemModel.newTypeReference)
		} catch(Exception e) {
			annotatedClass.addWarning(e.stackTraceAsString)
		}
	}

	def boolean generateSetter(MutableClassDeclaration clazz, MutableFieldDeclaration it) {
		return !isStatic && !final && !class.declaredMethods.exists[m|m.name == getter]
	}

	def boolean generateGetter(MutableClassDeclaration clazz, MutableFieldDeclaration it) {
		return !isStatic && !class.declaredMethods.exists[m|m.name == getter]
	}

	def boolean generateProperty(MutableFieldDeclaration it) {
		return !isStatic
	}

	def void generateAccesors(MutableClassDeclaration clazz, extension TransformationContext context) {
		generateGetter(clazz, context)
		generateSetter(clazz, context)
	}

	def void generateGetter(MutableClassDeclaration clazz, extension TransformationContext context) {
		for (field : clazz.declaredFields.filter[generateGetter(clazz, it)]) {
			clazz.addMethod(field.getter) [
				returnType = field.type
				body = '''return this.«field.simpleName»;'''
				primarySourceElement = field
			]
			field.markAsRead
		}
	}

	def void addDerivedProperties(MutableClassDeclaration classDeclaration, MutableClassDeclaration dItem,
		extension TransformationContext context) {
		for (direvedMethod : classDeclaration.derivedMethods) {
			val returnType = direvedMethod.returnType
			val propertyType = DerivedProperty.newTypeReference(returnType) 
			addPropertyField(dItem, direvedMethod, propertyType, context)
			addPropertyGetter(dItem, direvedMethod, propertyType, context)
		}
	}

	def getDerivedMethods(MutableClassDeclaration classDeclaration) {
		return classDeclaration.declaredMethods.filter[it.annotations.exists[it == Derived]]
	}

	def void generateSetter(MutableClassDeclaration clazz, extension TransformationContext context) {
		for (fild : clazz.declaredFields.filter[generateSetter(clazz, it)]) {
			clazz.addMethod(fild.setter) [
				addParameter(fild.simpleName, fild.type)
				body = '''
					«fild.type» _oldValue = this.«fild.simpleName»;
					this.«fild.simpleName» = «fild.simpleName»;
					_propertyChangeSupport.firePropertyChange("«fild.simpleName»", _oldValue, «fild.simpleName»);
				'''
				primarySourceElement = fild
			]
		}
	}

	def deligatePropertyChangeListener(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		for (method : annotatedClass.declaredMethods) {
			if(method.simpleName.startsWith("set") && method.visibility == PUBLIC) {
				val setterName = method.simpleName
				val delegateName = "_" + setterName
				method.simpleName = delegateName
				method.visibility = PRIVATE
				// TODO: implement deligates
				annotatedClass.addMethod(setterName, [ m |
					m.body = '''
						System.out.println("lol");
						«»
						«delegateName»;
					'''
					method.parameters.forEach[m.addParameter(it.simpleName, it.type)]
					m.addParameter("", null)
					m.visibility = PUBLIC
				])
			}

		}
	}


	def generateDItem(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val dItem = context.findClass(annotatedClass.getDItemClassName)
		dItem.docComment = warning + annotatedClass.simpleName + ".java <br>" + annotatedClass.docComment
	
		addVaadinProperties(annotatedClass, dItem, context)
		addDerivedProperties(annotatedClass, dItem, context)
		if(addDerived) {
		}
		addConstructor(annotatedClass, dItem, context)

		// addToString(annotatedClass, context, dItem)
		addMarkerAnnotations(dItem, annotatedClass, context)

		dItem.addSerialVersionUID(context, calculateSerialVersionUID)
	}

	def addMarkerAnnotations(MutableClassDeclaration dItem, MutableClassDeclaration annotatedClass,
		extension TransformationContext context) {
		dItem.addAnnotation(DItem.newAnnotationReference)
		dItem.addAnnotation(MetaModelOf.newAnnotationReference[setStringValue("value", annotatedClass.qualifiedName)])
		annotatedClass.addAnnotation(Generated.newAnnotationReference[setStringValue("source", dItem.qualifiedName)])
	}

	def addToString(MutableClassDeclaration annotatedClass, extension TransformationContext context, MutableClassDeclaration dItem) {
		val String toString = annotatedClass.declaredFields.map['''«it.propertyGetterName»()'''].join('+" "+');
		dItem.addMethod("toString", [
			returnType = String.newTypeReference
			body = '''return «toString»;'''
		])
	}

	def addVaadinProperties(MutableClassDeclaration annotatedClass, MutableClassDeclaration dItem,
		extension TransformationContext context) {
		dItem.extendedClass = AbstractBeanItemBase.newTypeReference(annotatedClass.newTypeReference)
		for (field : annotatedClass.declaredFields.filter[generateProperty]) {
			if(field.annotations.exists[it == Deep]) {
				addReferencePropertie(annotatedClass, field, context, dItem)
			} else {
				addVaadinPropertie(field, context, dItem)
			}
		}
	}

	def addConstructor(MutableClassDeclaration annotatedClass, MutableClassDeclaration dItem, extension TransformationContext context) {
		val constructor = '''
			super(«beanName»);
			«createPropertyInitializer(annotatedClass, context)»
			«createDerivedPropertyInitializer(annotatedClass, context)»
			initBeanProperties(«annotatedClass.declaredFields.filter[it != Deep && generateProperty].map[propertyName].join(", ")»);
		''';
		dItem.addConstructor [
			addParameter(beanName, annotatedClass.newTypeReference)
			body = [constructor]
		]
	}

	def String createPropertyInitializer(MutableClassDeclaration annotatedClass, TransformationContext context) {
		var String propertyInitializer = ""
		for (field : annotatedClass.declaredFields.filter[generateProperty]) {
			propertyInitializer += if(field.annotations.exists[it == Deep]) {
				createPropertyReferenceInitializer(context, field)
			} else {
				createPropertyInitializer(context, field)
			}
		}
		return propertyInitializer;
	}

	def String createDerivedPropertyInitializer(MutableClassDeclaration annotatedClass, TransformationContext context) {
		return annotatedClass.derivedMethods.map[method|createDerivedPropertyInitializer(context, method)].join
	}

	/***				
	 * new DerivedProperty<Type>(Type.class,bean::getXX, "popertyName", _fieldRef1, _fieldRef2);
	 */
	static def String createDerivedPropertyInitializer(extension TransformationContext context, MutableMethodDeclaration it) {
		val objectPropertyType = DerivedProperty.newTypeReference
		return '''
			«propertyName» = new «objectPropertyType»(«returnType».class, «beanName»::«simpleName», "«simpleName»"«derivedPropertiesAsString(context)»);
		'''
	}
	
	static def String derivedPropertiesAsString(MutableMethodDeclaration derivedMethod, extension TransformationContext context){
		val derivedAnnotation = derivedMethod.annotations.findFirst[it == Derived]
		val derivedPropetiesRefs = derivedAnnotation?.getClassArrayValue("value")
		if(derivedPropetiesRefs != null && !derivedPropetiesRefs.isEmpty){
			return ","+derivedPropetiesRefs.map[referenceToPropertyName].join(", ")
		}else{
			context.addError(derivedMethod, "A derived method should declare depending field-references")
			return ""
		}
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
		val objectPropertyType = DItemProperty.
			newTypeReference(type)
		return '''
			«propertyName» = new «objectPropertyType»(«type.wrapperIfPrimitive».class, «beanName»::«getter», «beanName»::«setter», "«simpleName»");
		'''
	}
	
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

	def addVaadinPropertie(MutableFieldDeclaration field, extension TransformationContext context, MutableClassDeclaration dItem) {
		val objectPropertyType = DItemProperty.newTypeReference(field.type)

		addPropertyField(dItem, field, objectPropertyType, context)
		addPropertyGetter(dItem, field, objectPropertyType, context)
	}

	def addReferencePropertie(MutableClassDeclaration annotatedClass, MutableFieldDeclaration field,
		extension TransformationContext context, MutableClassDeclaration dItem) {
		val itemType = field.getDItemClassName.newTypeReference

		addPropertyField(dItem, field, itemType, context)
		addPropertyGetter(dItem, field, itemType, context)
	}

	def addPropertyGetter(MutableClassDeclaration dItem, NamedElement field, TypeReference propertyType,
		extension TransformationContext context) {
		dItem.addMethod(field.propertyGetterName) [
			if(field instanceof MutableFieldDeclaration) {
				field.markAsRead
			}
			returnType = propertyType
			body = '''return «field.propertyName»;'''
			primarySourceElement = field
		]
	}

	def addPropertyField(MutableClassDeclaration annotatedClass, NamedElement field, TypeReference objectPropertyType,
		extension TransformationContext context) {
		annotatedClass.addField(field.propertyName) [
			type = objectPropertyType
			final = true
			visibility = Visibility.PRIVATE
			primarySourceElement = field
		]
	}
	

}
