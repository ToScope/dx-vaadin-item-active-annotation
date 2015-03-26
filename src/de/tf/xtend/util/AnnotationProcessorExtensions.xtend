package de.tf.xtend.util

import java.io.PrintWriter
import java.io.StringWriter
import java.lang.annotation.Annotation
import java.util.LinkedHashSet
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeReference

import static extension de.tf.xtend.util.StringUtils.remove

class AnnotationProcessorExtensions {

	/***
	 * Adds a Interface to the given classDeclaration. It's no problem to add an interface twice. Interface order will be preserved.
	 */
	def static void addInterface(MutableClassDeclaration classDeclaration, TypeReference interfaceType) {
		var implementedInterfaces = new LinkedHashSet()
		implementedInterfaces += interfaceType
		implementedInterfaces += classDeclaration.implementedInterfaces
		classDeclaration.implementedInterfaces = implementedInterfaces
	}

	static def getPackage(Type it) {
		qualifiedName.remove(simpleName)
	}

	static def getPackage(TypeReference it) {
		name.remove(simpleName)
	}

	static def boolean operator_notEquals(MutableFieldDeclaration ref, Class<? extends Annotation> annotation) {
		return !operator_equals(ref, annotation)
	}

	static def boolean operator_equals(MutableFieldDeclaration ref, Class<? extends Annotation> annotation) {
		return ref.annotations.exists[it == annotation]
	}

	static def boolean operator_equals(AnnotationReference ref, Class<? extends Annotation> annotation) {
		return ref.annotationTypeDeclaration.simpleName == annotation.simpleName
	}
	
	static def String getStackTraceAsString(Exception e){
		val writer = new StringWriter()
		val printer = new PrintWriter(writer)
		e.printStackTrace(printer)
		return writer.toString
	}

}
