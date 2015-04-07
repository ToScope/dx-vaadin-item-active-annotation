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

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.registerType
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addInterface
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.getStackTraceAsString
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_notEquals
import static extension ditem.processor.DItemNamingConventions.*
import static extension serial.SerialVersionUIDProcessor.addSerialVersionUID
import static ditem.processor.MetaModelClassesProcessor.registerMetaClasses
import static ditem.processor.MetaModelClassesProcessor.transformFieldClasses
import static extension ditem.processor.MetaModelClassesProcessor.metaClassName
import java.util.Collection
import ditem.item.PropertyList
import ditem.ref.FieldReference

@Active(DItemProcessor)
annotation DItem {
}

class DItemProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	boolean calculateSerialVersionUID = false

	val warning = "<h1>Generated Class, Don't Change!</h1><br>For modifying open "

	extension TransformationContext context
	MutableClassDeclaration dItem
	MutableClassDeclaration annotatedClass
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.getDItemClassName)
		registerMetaClasses(annotatedClass, context)
	}


	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		this.context = context
		this.annotatedClass = annotatedClass
		dItem = context.findClass(annotatedClass.getDItemClassName)

		try {
			transformFieldClasses()
			generateDItem()
			generateAccesors()
			generatePropertyChangeSupport()
			annotatedClass.addSerialVersionUID(context, calculateSerialVersionUID)
			annotatedClass.addInterface(DItemModel.newTypeReference)
		} catch (Exception e) {
			annotatedClass.addWarning(e.stackTraceAsString)
		}
	}

	def boolean generateSetter(MutableFieldDeclaration it) {
		return !isStatic && !final && !annotatedClass.declaredMethods.exists[m|m.simpleName == setter]
	}

	def boolean generateGetter(MutableFieldDeclaration it) {
		return !isStatic && !annotatedClass.declaredMethods.exists[m|m.simpleName == getter]
	}

	def boolean generateProperty(MutableFieldDeclaration it, TransformationContext context) {
		return !isStatic
	}

	def isCollection(MutableFieldDeclaration field) {
		return Collection.newTypeReference.isAssignableFrom(field.type)
	}

	def boolean generateVaadinProperty(MutableFieldDeclaration it, TransformationContext context) {
		return generateProperty(context) && !isCollection
	}

	def void generateAccesors() {
		annotatedClass.generateGetter()
		annotatedClass.generateSetter()
	}

	def transformFieldClasses() {
		for (field : annotatedClass.declaredFields) {
			val metaFieldClass = findClass(annotatedClass.metaClassName(field))
			metaFieldClass.final = true
			metaFieldClass.implementedInterfaces = #[FieldReference.newTypeReference]
			metaFieldClass.primarySourceElement = field
			metaFieldClass.addField("type", [
				type = String.newTypeReference
				static = true
				final = true
				initializer = '''"«field.type.name»"'''
			])
			metaFieldClass.docComment = "FieldReference for declaring DerivedProperties"
		}
	}

	def void generateGetter(MutableClassDeclaration clazz) {
		for (field : clazz.declaredFields.filter[generateGetter(it)]) {
			clazz.addMethod(field.getter) [
				returnType = field.type
				body = '''return this.«field.simpleName»;'''
				primarySourceElement = field
			]
			field.markAsRead
		}
	}

	def void addDerivedProperties() {
		for (direvedMethod : annotatedClass.derivedMethods) {
			val returnType = direvedMethod.returnType
			val propertyType = DerivedProperty.newTypeReference(returnType)
			dItem.addPropertyField(direvedMethod, propertyType)
			dItem.addPropertyGetter(direvedMethod, propertyType)
		}
	}

	def getDerivedMethods(MutableClassDeclaration classDeclaration) {
		return classDeclaration.declaredMethods.filter[it.annotations.exists[it == Derived]]
	}

	def void generateSetter(MutableClassDeclaration clazz) {
		for (fild : clazz.declaredFields.filter[generateSetter(it)]) {
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

	def deligatePropertyChangeListener(MutableClassDeclaration annotatedClass,
		extension TransformationContext context) {
		for (method : annotatedClass.declaredMethods) {
			if (method.simpleName.startsWith("set") && method.visibility == PUBLIC) {
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

	def generateDItem() {
		dItem.docComment = warning + annotatedClass.simpleName + ".java <br>" + annotatedClass.docComment

		addVaadinProperties()
		addDerivedProperties()
		addConstructor()

		// addToString(annotatedClass, context, dItem)
		addMarkerAnnotations()

		dItem.addSerialVersionUID(context, calculateSerialVersionUID)
	}

	def addMarkerAnnotations() {
		dItem.addAnnotation(DItem.newAnnotationReference)
		dItem.addAnnotation(MetaModelOf.newAnnotationReference[setStringValue("value", annotatedClass.qualifiedName)])
		annotatedClass.addAnnotation(Generated.newAnnotationReference[setStringValue("source", dItem.qualifiedName)])
	}

	def addToString() {
		val String toString = annotatedClass.declaredFields.map['''«it.propertyGetterName»()'''].join('+" "+');
		dItem.addMethod("toString", [
			returnType = String.newTypeReference
			body = '''return «toString»;'''
		])
	}

	def addVaadinProperties() {
		dItem.extendedClass = AbstractBeanItemBase.newTypeReference(annotatedClass.newTypeReference)
		for (field : annotatedClass.declaredFields.filter[generateProperty(context)]) {
			if (field.annotations.exists[it == Deep]) {
				addReferencePropertie(field)
			} else if (field.isCollection) {
				addVaadinCollection(field)
			} else {
				addVaadinPropertie(field)
			}
		}
	}

	def addVaadinCollection(MutableFieldDeclaration field) {
		val propertyType = PropertyList.newTypeReference(field.type.actualTypeArguments.head)

		dItem.addPropertyField(field, propertyType)
		dItem.addPropertyGetter(field, propertyType)
	}

	def addConstructor() {
		val constructor = '''
			super(«beanName»);
			«createPropertyInitializer()»
			«createDerivedPropertyInitializer()»
			«createCollectionPropertyInitializer()»
			initBeanProperties(«annotatedClass.declaredFields.filter[it != Deep && generateVaadinProperty(context)].map[propertyName].join(", ")»);
		''';
		dItem.addConstructor [
			addParameter(beanName, annotatedClass.newTypeReference)
			body = [constructor]
		]
	}

	def String createPropertyInitializer() {
		var String propertyInitializer = ""
		for (field : annotatedClass.declaredFields.filter[generateVaadinProperty(context)]) {
			propertyInitializer += if (field.annotations.exists[it == Deep]) {
				createPropertyReferenceInitializer(field)
			} else {
				createPropertyInitializer(field)
			}
		}
		return propertyInitializer;
	}

	def String createCollectionPropertyInitializer() {
		var String propertyInitializer = ""
		for (field : annotatedClass.declaredFields.filter[isCollection]) {
			val propertyType = field.type.actualTypeArguments.head
			var popertyListType = PropertyList.newTypeReference(propertyType)
			dItem.registerType(popertyListType, context)
			propertyInitializer += '''«field.propertyName» = new «popertyListType»(«beanName».«field.getter»());'''
		}
		return propertyInitializer;
	}

	def String createDerivedPropertyInitializer() {
		return annotatedClass.derivedMethods.map[method|createDerivedPropertyInitializer(method)].join
	}

	/***				
	 * new DerivedProperty<Type>(Type.class,bean::getXX, "popertyName", _fieldRef1, _fieldRef2);
	 */
	def String createDerivedPropertyInitializer(MutableMethodDeclaration it) {
		val objectPropertyType = DerivedProperty.
			newTypeReference
		return '''
			«propertyName» = new «objectPropertyType»(«returnType».class, «beanName»::«simpleName», "«simpleName»"«derivedPropertiesAsString»);
		'''
	}

	def String derivedPropertiesAsString(MutableMethodDeclaration derivedMethod) {
		val derivedAnnotation = derivedMethod.annotations.findFirst[it == Derived]
		val derivedPropetiesRefs = derivedAnnotation?.getClassArrayValue("value")
		if (derivedPropetiesRefs != null && !derivedPropetiesRefs.isEmpty) {
			return "," + derivedPropetiesRefs.map[referenceToPropertyName].join(", ")
		} else {
			context.addError(derivedMethod, "A derived method should declare depending field-references")
			return ""
		}
	}

	def String createPropertyReferenceInitializer(MutableFieldDeclaration it) {
		val itemType = getDItemClassName.newTypeReference
		return '''
			«propertyName» = new «itemType.name»(«beanName».«getter»());
		'''
	}

	/***				
	 * // new DItemProperty<Type>(bean.getXX(),Type.class,bean::getXX, bean::setXX, "beanName");
	 */
	def String createPropertyInitializer(MutableFieldDeclaration it) {
		val objectPropertyType = DItemProperty.
			newTypeReference(type)
		return '''
			«propertyName» = new «objectPropertyType»(«type.wrapperIfPrimitive».class, «beanName»::«getter», «beanName»::«setter», "«simpleName»");
		'''
	}

	def void generatePropertyChangeSupport() {
		val clazz = this.annotatedClass
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

	def addVaadinPropertie(MutableFieldDeclaration field) {
		val objectPropertyType = DItemProperty.newTypeReference(field.type)

		dItem.addPropertyField(field, objectPropertyType)
		dItem.addPropertyGetter(field, objectPropertyType)
	}

	def addReferencePropertie(MutableFieldDeclaration field) {
		val itemType = field.getDItemClassName.newTypeReference

		dItem.addPropertyField(field, itemType)
		dItem.addPropertyGetter(field, itemType)
	}

	def addPropertyGetter(MutableClassDeclaration annotatedClass, NamedElement field, TypeReference propertyType) {
		dItem.addMethod(field.propertyGetterName) [
			if (field instanceof MutableFieldDeclaration) {
				field.markAsRead
			}
			returnType = propertyType
			body = '''return «field.propertyName»;'''
			primarySourceElement = field
		]
	}

	def addPropertyField(MutableClassDeclaration annotatedClass, NamedElement field, TypeReference objectPropertyType) {
		annotatedClass.addField(field.propertyName) [
			type = objectPropertyType
			final = true
			visibility = Visibility.PRIVATE
			primarySourceElement = field
		]
	}

}
