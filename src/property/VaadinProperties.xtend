package property

import com.vaadin.data.Property
import com.vaadin.data.util.ObjectProperty
import java.io.Serializable
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(ExternalizedProcessor)
annotation VaadinProperties {
}

class ExternalizedProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	val serialVersionUID = "serialVersionUID"
	boolean calculateSerialVersionUID =false
	val warning ="<h1>Generated Class, Don't Change!</h1><br>For modifying open "

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.docComment = warning +annotatedClass.simpleName+".java <br>"+ annotatedClass.docComment 
		
		addSerialVersionUID(annotatedClass, context)
		for (field : annotatedClass.declaredFields) {
			val objectPropertyType = typeof(ObjectProperty).newTypeReference(field.type)
			val TypeReference propertyType = typeof(Property).newTypeReference(field.type)
			val propertyName = "_" + field.simpleName + "Property"

			addPropertyField(annotatedClass, propertyName, objectPropertyType, field, context)
			addPropertyGetter(field, propertyType, propertyName, context)
		}

	}

	def addPropertyGetter(MutableFieldDeclaration field, TypeReference propertyType, String propertyName,
		extension TransformationContext context) {
		field.declaringType.addMethod('get' + field.simpleName.toFirstUpper + 'Property') [
			field.markAsRead
			returnType = propertyType
			body = ['''return «propertyName»;''']
			primarySourceElement = field
		]
	}

	def addPropertyField(MutableClassDeclaration annotatedClass, String propertyName, TypeReference objectPropertyType,
		MutableFieldDeclaration field, extension TransformationContext context) {
		annotatedClass.addField(propertyName) [
			type = objectPropertyType
			final = true
			visibility = Visibility.PRIVATE
			initializer = ['''new «objectPropertyType»(«field.simpleName»,«field.type».class)''']
			primarySourceElement = annotatedClass
		]
	}

	/***
	 *  Adds a <code>private static final long serialVersionUID = 1L;</code> field and let the class implement the 
	 *  <code>Serializable</code> interface.
	 */
	def addSerialVersionUID(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val TypeReference serialInterface = typeof(Serializable).newTypeReference

		val needsASerialVersionUID = annotatedClass.declaredFields.findFirst[it.simpleName == serialVersionUID] == null
		
		if(calculateSerialVersionUID){
			//TODO: Add class bases serial version generation here. Eg Like javassist.SerialVersionUID.calculateDefault(CtClass)
		}
		
		if (needsASerialVersionUID) {
			annotatedClass.addField(serialVersionUID) [
				type = primitiveLong
				initializer = ["1L"]
			]
		}
		
		annotatedClass.addInterface(serialInterface)
	}

	/***
	 * Adds a Interface to the given classDeclaration. It's no problem to add an interface twice.
	 */
	def static void addInterface(MutableClassDeclaration classDeclaration, TypeReference interfaceType) {
		var implementedInterfaces = newHashSet()
		implementedInterfaces += classDeclaration.implementedInterfaces
		implementedInterfaces += interfaceType
		classDeclaration.implementedInterfaces = implementedInterfaces
	}

}
