package ditem.processor

import metamodel.classes.FieldReference
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement

import static extension de.tf.xtend.util.AnnotationProcessorExtensions.getPackage

class MetaModelClassesProcessor  {

	val static prefix = "_"

	def static getMetaClassName(ClassDeclaration annotatedClass) {
		annotatedClass.package + annotatedClass.metaName
	}

	def static getQaulifiedMetaName(FieldDeclaration field) {
		field.type.package + field.type.simpleName.metaName
	}

	def static getMetaName(String name) {
		prefix + name.toFirstLower
	}

	def static getMetaName(NamedElement field) {
		field.simpleName.metaName
	}

	def static registerMetaClasses(ClassDeclaration clazz, extension RegisterGlobalsContext context) {
		registerClass(clazz.getMetaClassName)
		for (field : clazz.declaredFields) {
			registerClass(clazz.getMetaClassName + "." + field.metaName)
		}
	}
	
	
	def static transformFieldClasses(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
			for (field : annotatedClass.declaredFields) {
			val metaFieldClass = findClass(annotatedClass.getMetaClassName + "." + field.metaName)
			metaFieldClass.implementedInterfaces = #[FieldReference.newTypeReference]
			metaFieldClass.primarySourceElement = field
			metaFieldClass.addField("type",[
				type = String.newTypeReference
				static  = true
				final = true
				initializer = '''"«field.type.name»"'''
			])
		}
	}

}