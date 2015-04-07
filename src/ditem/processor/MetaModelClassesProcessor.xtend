package ditem.processor

import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
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
	
	def static String metaClassName(ClassDeclaration it, FieldDeclaration field ){
		return qualifiedName + "." + field.metaName
	}

	def static registerMetaClasses(ClassDeclaration it, extension RegisterGlobalsContext context) {
		registerClass(getMetaClassName)
		for (field : declaredFields) {
			registerClass(metaClassName(field))
		}
	}
	
	


}
