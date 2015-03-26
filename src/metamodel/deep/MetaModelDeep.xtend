package metamodel.deep

import com.vaadin.data.Property
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

import static extension serial.SerialVersionUIDProcessor.addSerialVersionUID
import java.io.ObjectOutputStream.PutField
import metamodel.MetaModelOf
import metamodel.AbstractReference
import metamodel.Deep

@Active(MetaModelDeepProcessor)
annotation MetaModelDeep {
}

class MetaModelDeepProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	def getMetaClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName.replaceFirst(annotatedClass.simpleName, "") + "$$" + annotatedClass.simpleName.toFirstLower
	}

	def getMetaFieldName(MutableFieldDeclaration field) {
		"$$" + field.simpleName.toFirstLower
	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.getMetaClassName)
		for (field : annotatedClass.declaredFields) {
			if(field.annotations.exists[it.annotationTypeDeclaration.simpleName == Deep.simpleName]) {
				registerClass(annotatedClass.getMetaClassName + "." + field.simpleName.toFirstUpper)
				// how to: field.declaredFields()??
			}

		}
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		generateMetaModel(context, annotatedClass)
	}

	def generateMetaModel(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
		val metaClass = context.findClass(annotatedClass.getMetaClassName)
		val referenceType = annotatedClass.newTypeReference

		metaClass.addAnnotation(MetaModelOf.newAnnotationReference[set("value", annotatedClass.qualifiedName)])
		metaClass.addAnnotation(MetaModelDeep.newAnnotationReference)

		metaClass.addField("$",
			[
				type = metaClass.newTypeReference
				initializer = '''new «metaClass.simpleName»()'''
				static = true
				final = true
				visibility = Visibility.PUBLIC
			])

		metaClass.extendedClass = AbstractReference.newTypeReference
		metaClass.addConstructor[body = '''super("«metaClass.qualifiedName»","«metaClass.simpleName»");''']

		addReferences(annotatedClass, context, metaClass)
	}

	def addReferences(MutableClassDeclaration annotatedClass, extension TransformationContext context, MutableClassDeclaration metaClass) {

		for (field : annotatedClass.declaredFields) {

			if(field.annotations.exists[annotation|
				annotation.annotationTypeDeclaration == Deep.newAnnotationReference.annotationTypeDeclaration]) {
			}

			metaClass.addField(field.metaFieldName,
				[
					type = AbstractReference.newTypeReference
					initializer = '''new «AbstractReference.simpleName»("«field.type.name»","«field.simpleName»")'''
					static = true
					final = true
					visibility = Visibility.PUBLIC
				])
		}

	}

}
