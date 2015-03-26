package metamodel.flat

import metamodel.AbstractReference
import metamodel.Deep
import metamodel.MetaModelOf
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.getPackage
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration

@Active(MetaModelProcessor)
annotation MetaModel {
}

class MetaModelProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	val static prefix = "_"
	
	def getMetaClassName(ClassDeclaration annotatedClass) {
		annotatedClass.package + annotatedClass.metaName
	}

	def getQaulifiedMetaName(FieldDeclaration field) {
		field.type.package + field.type.simpleName.metaName
	}

	def getMetaName(String name) {
		prefix + name.toFirstLower
	}

	def getMetaName(NamedElement field) {
		field.simpleName.metaName
	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.getMetaClassName)
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		generateMetaModel(context, annotatedClass)
		context.addWarning(annotatedClass, annotatedClass.getMetaClassName)
	}

	def generateMetaModel(extension TransformationContext context, MutableClassDeclaration annotatedClass) {
		val metaClass = context.findClass(annotatedClass.getMetaClassName)

		metaClass.addAnnotation(MetaModelOf.newAnnotationReference[set("value", annotatedClass.qualifiedName)])
		metaClass.addAnnotation(MetaModel.newAnnotationReference)

		addThisReference(metaClass, context)

		metaClass.extendedClass = AbstractReference.newTypeReference
		metaClass.addConstructor[body = '''super("«metaClass.qualifiedName»","«metaClass.simpleName»");''']

		addReferences(annotatedClass, context, metaClass)
	}

	def addThisReference(MutableClassDeclaration metaClass, extension TransformationContext context) {
		metaClass.addField(prefix,
			[
				type = metaClass.newTypeReference
				initializer = '''new «metaClass.simpleName»()'''
				static = true
				final = true
				visibility = Visibility.PUBLIC
			])
	}

	def addReferences(MutableClassDeclaration annotatedClass, extension TransformationContext context, MutableClassDeclaration metaClass) {

		for (field : annotatedClass.declaredFields) {

			if(field.annotations.exists[it.annotationTypeDeclaration.simpleName == Deep.simpleName]) {
				metaClass.addField(field.metaName) [
					type = field.qaulifiedMetaName.newTypeReference
					initializer = '''«field.qaulifiedMetaName».«prefix»'''
					static = true
					final = true
					visibility = Visibility.PUBLIC
				]

			//					context.addWarning(annotatedClass, "couldn't find: " + qualifiedFieldName)
			} else {
				metaClass.addField(field.metaName,
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

}
