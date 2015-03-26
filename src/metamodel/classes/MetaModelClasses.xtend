package metamodel.classes

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
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import metamodel.flat.MetaModel
import java.util.List

@Active(MetaModelClassesProcessor)
annotation MetaModelClasses {
}

class MetaModelClassesProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	val static prefix = "_8"

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

	//	override doRegisterGlobals(List<? extends ClassDeclaration> annotatedClasses, extension RegisterGlobalsContext context) {
	//		super.doRegisterGlobals(annotatedClasses, context)
	//		for (clazz : annotatedClasses) {
	//			if(clazz.simpleName == "Quote") {
	//			}
	//		}
	//	}
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext context) {
		registerClass(clazz.getMetaClassName)
		for (field : clazz.declaredFields) {
			registerClass(clazz.getMetaClassName + "." + field.metaName)

			if(field.annotations.exists[it == Deep]) {
				val fieldSource = findSourceClass(field.type.name)
				val upType = findUpstreamType(field.type.name)

				//						val reflClazz = Class.forName(field.type.name)
				//						val fields = reflClazz.fields
				if(fieldSource != null) {
					for (f : fieldSource?.declaredFields) {
						registerClass(clazz.getMetaClassName + "." + field.metaName + "." + f.metaName)

					}
				}

			}
		}
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		//		generateMetaModel(context, annotatedClass)
		//		context.addWarning(annotatedClass, annotatedClass.getMetaClassName)
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
