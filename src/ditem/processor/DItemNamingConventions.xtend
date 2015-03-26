package ditem.processor

import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

class DItemNamingConventions {
	public static val prefix = "Prop"
	public static val suffix = ""
	public static val item = "Item"
	public static val beanName = "bean"

	def static String getter(String field) {
		return '''get«field.toFirstUpper»'''
	}

	def static String getter(MutableFieldDeclaration field) {
		return field.simpleName.getter
	}

	def static String setter(String field) {
		return '''set«field.toFirstUpper»'''
	}

	def static String setter(MutableFieldDeclaration field) {
		return field.simpleName.setter
	}

	def static getDItemClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + item
	}

	def static getDItemClassName(MutableFieldDeclaration field) {
		field.type.name + item
	}

	def static String propertyName(MutableFieldDeclaration field) {
		return '''_«field.simpleName»«prefix»'''
	}

	def static String propertyGetterName(MutableFieldDeclaration field) {
		return '''get«suffix»«field.simpleName.toFirstUpper»«prefix»'''
	}

	def static String propertySetterName(MutableFieldDeclaration field) {
		return suffix + field.simpleName.setter + prefix
	}
}
