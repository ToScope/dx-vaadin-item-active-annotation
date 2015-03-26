package activenum

import com.google.common.annotations.Beta
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.Collections
import java.util.List
import java.util.PropertyResourceBundle
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTarget

@Beta
@Target(ElementType.TYPE)
@Active(AnnotationProcessor)
annotation AddEnum {
}

class AnnotationProcessor extends AbstractClassProcessor {

	final String enumName = "Colors"
	final String enumPath = "activenum."

	override doRegisterGlobals(ClassDeclaration cls, extension RegisterGlobalsContext context) {
										       //activenum.EnumTest.Colors
		context.registerEnumerationType(enumPath + cls.simpleName + "." + enumName) 

	}

	override doTransform(MutableClassDeclaration muteAbleClass, extension TransformationContext context) {
		
																//activenum.EnumTest.Colors
		val messageKeysEnum = findEnumerationType(enumPath + muteAbleClass.simpleName + "." + enumName)
		#['Blue', 'Green', 'Red'].forEach[messageKeysEnum.addValue(it, [])]
//		muteAbleClass.annotations.findFirst[annotationTypeDeclaration == AddEnum.newTypeReference.type].
//		muteAbleClass.removeAnnotation(AddEnum.newAnnotationReference)
//		muteAbleClass.annotations.forEach[muteAbleClass.removeAnnotation(it)]
	val ads=	muteAbleClass.annotations.head.annotationTypeDeclaration
	print(ads)
	//MutableAnnotationReference
//		var annt = muteAbleClass.annotations.head.
//findAnnotationType("s").removeAnnotation(AddEnum.newAnnotationReference)
			//as MutableClassDeclaration).remove
		
 //		muteAbleClass.addField(enumName) [
//			type = messageKeysEnum.newTypeReference
//			visibility = Visibility.PUBLIC
//		]
	}

}
