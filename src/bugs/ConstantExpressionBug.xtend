package bugs

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension ditem.processor.MetaModelClassesProcessor.metaClassName
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration

@Active(ConstantExpressionBugProcessor)
annotation ConstantExpressionBug {
}

class ConstantExpressionBugProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		for (field : annotatedClass.declaredFields) {
			registerClass(annotatedClass.metaClassName(field))
		}

	}

	def static getPackage(Type it) {
		qualifiedName.replace(simpleName, "")
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		for (field : annotatedClass.declaredFields) {
			val metaFieldClass = findClass(annotatedClass.metaClassName(field))
			metaFieldClass.final = true
			metaFieldClass.primarySourceElement = field
			metaFieldClass.addField("name", [
				type = String.newTypeReference
				initializer = '''"«field.simpleName»"'''
				visibility = Visibility.PUBLIC
			//	constantValueAsString = value
			])
		}
	}

	def static String metaClassName(ClassDeclaration it, FieldDeclaration field) {
		return qualifiedName + "._" + field.simpleName
	}
}
