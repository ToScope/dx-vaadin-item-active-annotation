package ditem.processor

import ditem.item.AbstractBeanItemBase
import ditem.item.DItemModel
import ditem.item.PropertyList
import ditem.property.DItemProperty
import ditem.property.Derived
import ditem.property.DerivedProperty
import ditem.property.PropertyChangeEmitter
import ditem.ref.FieldReference
import java.beans.PropertyChangeListener
import java.util.Collection
import metamodel.Deep
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

import static ditem.processor.MetaModelClassesProcessor.registerMetaClasses
import static org.eclipse.xtend.lib.macro.declaration.Visibility.*
import static de.tf.xtend.util.EnumUtils.value

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addInterface
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.getStackTraceAsString
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_notEquals
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.isPrimitiveOrString
import static extension ditem.processor.DItemNamingConventions.*
import static extension ditem.processor.MetaModelClassesProcessor.metaClassName
import static extension serial.SerialVersionUIDProcessor.addSerialVersionUID
import ditem.ref.FieldType
import java.util.stream.Collectors
import java.util.List
import ditem.container.DItemContainer
import de.tf.xtend.util.AnnotationProcessorExtensions
import metamodel.SkipInToString

/***
 * Generates an additional DItem which helps to access and bind this model with a Vaadin UI. For every field a appropriate Vaadin Property 
 * will be created. Property changes will be passed to the model and inversly, model changes will be passed to the Properties. In addition 
 * its possible to mark methods as direved. Then a property with listeners to the dependent fields will be created.   
 */
@Active(DItemProcessor)
annotation DItem {
}

class DItemProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	boolean calculateSerialVersionUID = false

	val warning = "<h1>Generated Class, Don't Change!</h1><br>For modifying open "

	extension TransformationContext context
	extension AnnotationProcessorExtensions processorExtensions
	MutableClassDeclaration dItem
	MutableClassDeclaration annotatedClass

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.getDItemQualifiedName)
		registerMetaClasses(annotatedClass, context)
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		this.context = context
		this.annotatedClass = annotatedClass
		this.processorExtensions = new AnnotationProcessorExtensions(context)
		dItem = context.findClass(annotatedClass.getDItemQualifiedName)

		try {
			transformFieldClasses()
			generateDItem()
			generateAccesors()
			generatePropertyChangeSupport()
			annotatedClass.addSerialVersionUID(context, calculateSerialVersionUID)
			annotatedClass.addInterface(DItemModel.newTypeReference)
		} catch(Exception e) {
			annotatedClass.addWarning(e.stackTraceAsString)
		}
	}

	def private boolean generateSetter(MutableFieldDeclaration it) {
		return !isStatic && !final && !annotatedClass.declaredMethods.exists[m|m.simpleName == setter]
	}

	def private boolean generateGetter(MutableFieldDeclaration it) {
		return !isStatic && !annotatedClass.declaredMethods.exists[m|m.simpleName == getter]
	}

	def private boolean generateProperty(MutableFieldDeclaration it) {
		return !isStatic
	}

	def private boolean generateVaadinProperty(MutableFieldDeclaration it) {
		return generateProperty() && !isCollection
	}

	def private void generateAccesors() {
		annotatedClass.generateGetter()
		annotatedClass.generateSetter()
	}

	/***
	 * Adds a unique class for every field. Useful to reference fields for DerivedProperties. Example:
	 * <code><pre>
	 *  String name
	 *  
	 *  @FieldType(value = String.class)
	 *  public static final class _name implements FieldReference {}
	 * </pre></code>
	 */
	def private transformFieldClasses() {
		for (field : annotatedClass.declaredFields) {
			val metaFieldClass = findClass(annotatedClass.metaClassName(field))
			metaFieldClass.final = true
			metaFieldClass.implementedInterfaces = #[FieldReference.newTypeReference]
			metaFieldClass.primarySourceElement = field
			metaFieldClass.addAnnotation(FieldType.newAnnotationReference[setClassValue(value, field.type)])
			metaFieldClass.docComment = "FieldReference for declaring DerivedProperties"
			metaFieldClass.addField("fieldName", [
				type = String.newTypeReference
				visibility = Visibility.PUBLIC

				constantValueAsString = field.simpleName
//				initializer = '''"«field.simpleName»"'''
//				static = true
//				final = true
			])
		}
	}

	/***
	 * <pre>
	 *   public String getLastName() {
	 *   	return this.lastName;
	 *   }
	 * </pre>
	 */
	def private void generateGetter(MutableClassDeclaration clazz) {
		for (field : clazz.declaredFields.filter[generateGetter(it)]) {
			clazz.addMethod(field.getter) [
				returnType = field.type
				body = '''return this.«field.simpleName»;'''
				primarySourceElement = field
			]
			field.markAsRead
		}
	}

	def private void addDerivedProperties() {
		for (direvedMethod : annotatedClass.derivedMethods) {
			val returnType = direvedMethod.returnType
			val propertyType = DerivedProperty.newTypeReference(returnType)
			dItem.addPropertyFieldAndGetter(direvedMethod, propertyType)
		}
	}

	/***
	 * List all methods which are annotated with Derived
	 */
	def private getDerivedMethods(MutableClassDeclaration classDeclaration) {
		return classDeclaration.declaredMethods.filter[it.annotations.exists[it == Derived]]
	}

	/***
	 * <pre>
	 *   public void setLastName(final String lastName) {
	 *      String _oldValue = this.lastName;
	 *      this.lastName = lastName;
	 *      _propertyChangeSupport.firePropertyChange("lastName", _oldValue, lastName);
	 * }
	 * </pre>
	 */
	def private void generateSetter(MutableClassDeclaration clazz) {
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

	def private deligatePropertyChangeListener(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
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

	def private generateDItem() {
		dItem.docComment = warning + annotatedClass.simpleName + ".java <br>" + annotatedClass.docComment

//		dItem.addToString([propertyGetterName])
		addVaadinProperties()
		addDerivedProperties()
		addConstructor()

		addMarkerAnnotations()

		dItem.addSerialVersionUID(context, calculateSerialVersionUID)
	}

	/***
	 * Adds annotations with additional information to the generated Classes:
	 * @DItem
	 * @MetaModelOf(value = "ditem.Person")
	 * @Generated(value = "ditem.processor.DItem")
	 */
	def private addMarkerAnnotations() {
		dItem.addAnnotation(DItem.newAnnotationReference)
		dItem.addAnnotation(MetaModelOf.newAnnotationReference[setStringValue(value, annotatedClass.qualifiedName)])
		dItem.addGeneratedAnnotation()
		annotatedClass.addGeneratedAnnotation()
	}

	def private addGeneratedAnnotation(MutableClassDeclaration it) {
		addAnnotation(javax.annotation.Generated.newAnnotationReference[setStringValue(value, DItem.typeName)])
	}

	def private addMissingTostring(MutableClassDeclaration mutableClass) {
		if(!mutableClass.declaredMethods.exists[it.simpleName == "toString"]) {
			addToString(mutableClass, [it.getter])
		}
	}

	def private addToString(MutableClassDeclaration mutableClass, (MutableFieldDeclaration)=>String getter) {
		val String fieldAsString = annotatedClass.propertyFields.filter[it != SkipInToString].map['''"«it.simpleName»:" + «getter.apply(it)»()'''].join(' +", "+ ');
		mutableClass.addMethod("toString", [
			returnType = String.newTypeReference
			body = '''return "«mutableClass.simpleName»" + "{«IF !fieldAsString.isEmpty»" + «fieldAsString» + "«ENDIF»}";'''
		])
	}

	/***
	 * Adds Vaadin propeties for every field. Based on the type a DItemProperty, a ReferenceProperty or a ProertyList will be uesed.
	 */
	def private addVaadinProperties() {
		dItem.extendedClass = AbstractBeanItemBase.newTypeReference(annotatedClass.newTypeReference)
		for (field : annotatedClass.propertyFields) {
			if(field.annotations.exists[it == Deep]) {
				addReferencePropertie(field)
			} else if(field.isCollection) {
				addVaadinCollection(field)
			} else {
				addVaadinPropertie(field)
			}
		}
	}

	/***
	 * @Return all fields which needs a generated Property
	 */
	def private propertyFields(MutableClassDeclaration mutableClassDeclaration) {
		return annotatedClass.declaredFields.filter[generateProperty()]
	}

	def private addConstructor() {
		val constructor = '''
			super(«beanName»);
			«createPropertyInitializer()»
			«createDerivedPropertyInitializer()»
			«createCollectionPropertyInitializer()»
			initBeanProperties(«annotatedClass.declaredFields.filter[it != Deep && generateVaadinProperty].map[propertyName].join(", ")»);
		''';
		dItem.addConstructor [
			addParameter(beanName, annotatedClass.newTypeReference)
			body = [constructor]
		]
	}

	/***
	 *   Creates a PropertyInitializer or a PropertyReferenceInitializer depending on the field type.
	 */
	def private String createPropertyInitializer() {
		var String propertyInitializer = ""
		for (field : annotatedClass.declaredFields.filter[generateVaadinProperty()]) {
			propertyInitializer += if(field.annotations.exists[it == Deep]) {
				createPropertyReferenceInitializer(field)
			} else {
				createPropertyInitializer(field)
			}
		}
		return propertyInitializer;
	}

	/***
	 *  _addresseProp = new PropertyList(bean.getAddresse());
	 */
	def private String createCollectionPropertyInitializer() {
		var String propertyInitializer = ""
		for (field : annotatedClass.declaredFields.filter[isCollection]) {
			val propertyType = field.listValueType
			var popertyListType = PropertyList.newTypeReference(propertyType)

			var dListItemName = propertyType.getDItemName
			if(propertyType.isPrimitiveOrString) {
				propertyInitializer += '''
					«field.propertyName» = new «popertyListType.type.simpleName»(«field.getterOverBean»());
				'''
			} else {
				propertyInitializer +=
					'''
						if(«field.getterOverBean»() != null){
							«List.name»<«dListItemName»> «field.propertyName»List = «field.getterOverBean»().stream().map((p) -> new «dListItemName»(p)).collect(«Collectors.name».toList());
							«field.propertyName» = new «DItemContainer.simpleName»<«propertyType»,«propertyType.DItemName»>(«propertyType.DItemName».class, «field.propertyName»List);
						}
					'''
			}
		}
		return propertyInitializer;
	}

	/***<pre>
	 * for(method: mericedMethods){				
	 *   _derivedPropN = new DItemProperty<String>(String.class, bean::getLastName, bean::setLastName, "atrributeName");
	 * }</pre>
	 */
	def private String createDerivedPropertyInitializer() {
		return annotatedClass.derivedMethods.map[method|createDerivedPropertyInitializer(method)].join
	}

	/***				
	 *   _lastNameProp = new DItemProperty<String>(String.class, bean::getLastName, bean::setLastName, "lastName");
	 */
	def private String createDerivedPropertyInitializer(MutableMethodDeclaration it) {
		val objectPropertyType = DerivedProperty.newTypeReference
		return '''
			«propertyName» = new «objectPropertyType»(«returnType».class, «beanName»::«simpleName», "«simpleName»"«derivedPropertiesAsString»);
		'''
	}

	/***
	 * @return the csv list of fieldReferences of a DerivedProperty annotation
	 */
	def private String derivedPropertiesAsString(MutableMethodDeclaration derivedMethod) {
		val derivedAnnotation = derivedMethod.annotations.findFirst[it == Derived]
		val derivedPropetiesRefs = derivedAnnotation?.getClassArrayValue(value)
		val boolean doubleRef = derivedPropetiesRefs.toSet.size != derivedPropetiesRefs.size
		if(doubleRef) {
			context.addWarning(derivedAnnotation, "Declared fieldRerences with the same name on derived Method")
		}
		if(derivedPropetiesRefs != null && !derivedPropetiesRefs.isEmpty) {
			return ", " + derivedPropetiesRefs.map[referenceToPropertyName].join(", ")
		} else {
			context.addError(derivedMethod, "A derived method should declare depending field-references")
			return ""
		}
	}

	/***
	 * _addressProp = new ditem.AddressItem(bean.getAddress());
	 */
	def private String createPropertyReferenceInitializer(MutableFieldDeclaration it) {
		val itemType = getDItemQualifiedName.newTypeReference
		return '''
			if(«beanName».«getter»() != null){
				«propertyName» = new «itemType.name»(«beanName».«getter»());
			}
		'''
	}

	/***				
	 * new DItemProperty<Type>(bean.getXX(),Type.class,bean::getXX, bean::setXX, "beanName");
	 */
	def private String createPropertyInitializer(MutableFieldDeclaration it) {
		val objectPropertyType = DItemProperty.newTypeReference(type)
		return '''
			«propertyName» = new «objectPropertyType»(«type.wrapperIfPrimitive».class, «beanName»::«getter», «beanName»::«setter», "«simpleName»");
		'''
	}

	/***
	 * Adds Property-Change-Support: Generated field to hold listeners, addPropertyChangeListener() and removePropertyChangeListener()
	 */
	def private void generatePropertyChangeSupport() {
		val changeSupportType = java.beans.PropertyChangeSupport.newTypeReference
		annotatedClass.addField("_propertyChangeSupport") [
			type = changeSupportType
			initializer = '''new «changeSupportType»(this)'''
			primarySourceElement = annotatedClass
		]

		val propertyChangeListener = PropertyChangeListener.newTypeReference
		annotatedClass.addMethod("addPropertyChangeListener") [
			addParameter("listener", propertyChangeListener)
			body = '''this._propertyChangeSupport.addPropertyChangeListener(listener);'''
			primarySourceElement = annotatedClass
		]
		annotatedClass.addMethod("removePropertyChangeListener") [
			addParameter("listener", propertyChangeListener)
			body = '''this._propertyChangeSupport.removePropertyChangeListener(listener);'''
			primarySourceElement = annotatedClass
		]
		annotatedClass.addInterface(PropertyChangeEmitter.newTypeReference)
	}

	/***
	 *  private final DItemProperty<String> _firstNameProp;
	 */
	def private addVaadinPropertie(MutableFieldDeclaration field) {
		val objectPropertyType = DItemProperty.newTypeReference(field.type)
		dItem.addPropertyFieldAndGetter(field, objectPropertyType)
	}

	/***
	 *  private final AddressItem _addressProp;
	 */
	def private addReferencePropertie(MutableFieldDeclaration field) {
		val itemType = field.getDItemQualifiedName.newTypeReference
		dItem.addPropertyFieldAndGetter(field, itemType)
	}

	/***
	 *  private final PropertyList<Address> _addresseProp;
	 */
	def private addVaadinCollection(MutableFieldDeclaration list) {
		val fieldType = list.listValueType
		if(list.listValueType.primitiveOrString) {
			val propertyType = PropertyList.newTypeReference(fieldType)
			dItem.addPropertyFieldAndGetter(list, propertyType)
		} else {
			val propertyType = DItemContainer.newTypeReference(fieldType, fieldType.getDItemQualifiedName.newTypeReference)
			dItem.addPropertyFieldAndGetter(list, propertyType)
		}
	}

	/***
	 * Returns the value type of a generic list.
	 * @Param list: field with the type <b>List&lt;Integer&gt;</b>
	 * @Returns List&lt;Integer&gt; &rArr; Integer 
	 */
	def private static listValueType(MutableFieldDeclaration list) {
		list.type.actualTypeArguments.head
	}

	def private addPropertyFieldAndGetter(MutableClassDeclaration annotatedClass, NamedElement field, TypeReference objectPropertyType) {
		annotatedClass.addPropertyField(field, objectPropertyType)
		annotatedClass.addPropertyGetter(field, objectPropertyType)
	}

	/***
	 * Creates a getter for the given field with the given type
	 */
	def private addPropertyGetter(MutableClassDeclaration annotatedClass, NamedElement field, TypeReference propertyType) {
		dItem.addMethod(field.propertyGetterName) [
			if(field instanceof MutableFieldDeclaration) {
				field.markAsRead
			}
			returnType = propertyType
			body = '''return «field.propertyName»;'''
			primarySourceElement = field
		]
	}

	/***
	 *  private final DItemProperty<String> _firstNameProp;
	 */
	def private addPropertyField(MutableClassDeclaration annotatedClass, NamedElement field, TypeReference objectPropertyType) {
		annotatedClass.addField(field.propertyName) [
			type = objectPropertyType
			final = false
			visibility = Visibility.PRIVATE
			primarySourceElement = field
		]
	}

}
