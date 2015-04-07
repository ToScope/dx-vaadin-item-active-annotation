package de.tf.xtend.util

import java.io.PrintWriter
import java.io.StringWriter
import java.lang.annotation.Annotation
import java.util.LinkedHashSet
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
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

	def static getPackage(Type it) {
		qualifiedName.remove(simpleName)
	}

	def static getPackage(TypeReference it) {
		name.remove(simpleName)
	}

	def static boolean operator_notEquals(MutableFieldDeclaration ref, Class<? extends Annotation> annotation) {
		return !operator_equals(ref, annotation)
	}

	def static boolean operator_equals(MutableFieldDeclaration ref, Class<? extends Annotation> annotation) {
		return ref.annotations.exists[it == annotation]
	}

	def static boolean operator_equals(AnnotationReference ref, Class<? extends Annotation> annotation) {
		return ref.annotationTypeDeclaration.simpleName == annotation.simpleName
	}
	
	def static String getStackTraceAsString(Exception e){
		val writer = new StringWriter()
		val printer = new PrintWriter(writer)
		e.printStackTrace(printer)
		return writer.toString
	}
	
    /***
	 * Hack to add an import for a type
	 */
	def static void registerType(MutableTypeDeclaration mutableClass, TypeReference typeReference,
		extension TransformationContext context) {
		mutableClass.addAnnotation(Import.newAnnotationReference[setClassValue("value", typeReference)])
	}
	
		/***
	 * Only adds the method, if there isn't already a method with this name
	 * @See MutableMethodDeclaration#declaredMethods
	 */
	def static  MutableMethodDeclaration addSafeMethod(MutableTypeDeclaration mutableTypeDeclaration, String name,
		(MutableMethodDeclaration)=>void initializer) {
		if (!mutableTypeDeclaration.declaredMethods.exists[it.simpleName == name]) {
			mutableTypeDeclaration.addMethod(name, initializer)
		}
	}
	

}
