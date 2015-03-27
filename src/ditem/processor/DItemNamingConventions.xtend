package ditem.processor

import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.TypeReference

class DItemNamingConventions {
	public static val prefix = "Prop"
	public static val suffix = ""
	public static val item = "Item"
	public static val beanName = "bean"

	def static String getter(String field) {
		return '''get«field.toFirstUpper»'''
	}

	def static String getter(NamedElement field) {
		return field.simpleName.getter
	}

	def static String setter(String field) {
		return '''set«field.toFirstUpper»'''
	}

	def static String setter(NamedElement field) {
		return field.simpleName.setter
	}

	def static getDItemClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + item
	}

	def static getDItemClassName(MutableFieldDeclaration field) {
		field.type.name + item
	}

	def static String propertyName(NamedElement field) {
		return field.simpleName.propertyName
	}

	def static String referenceToPropertyName(TypeReference fieldRef) {
		return '''«fieldRef»«prefix»'''
	}

	def static String propertyName(String field) {
		return '''_«field»«prefix»'''
	}

	def static String propertyGetterName(NamedElement field) {
		return '''get«suffix»«field.simpleName.toFirstUpper»«prefix»'''
	}

	def static String propertySetterName(NamedElement field) {
		return suffix + field.simpleName.setter + prefix
	}
}
