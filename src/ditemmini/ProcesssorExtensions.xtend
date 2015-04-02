package ditemmini

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

class ProcesssorExtensions {
		def static addField(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.addField("yoloss", [type = String.newTypeReference])
	}
}