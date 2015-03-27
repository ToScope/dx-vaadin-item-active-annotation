package annotation

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import ditem.property.Derived
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import java.lang.annotation.Annotation

//Remove this line and all works fine


@Active(TestAnnotationProcessor)
annotation TestAnnotationProcessing {
}

class TestAnnotationProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
//		registerClass(annotatedClass.qualifiedName + "Item")
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val derivedMethod = annotatedClass.declaredMethods.head
			val derivedAnnotation = derivedMethod.annotations.findFirst[it == Derived]
		val derivedPropetiesRefs = derivedAnnotation?.getClassArrayValue("value")
		annotatedClass.addWarning(derivedPropetiesRefs.toString)
	}
	
		static def boolean operator_equals(AnnotationReference ref, Class<? extends Annotation> annotation) {
		return ref.annotationTypeDeclaration.simpleName == annotation.simpleName
	}

}
