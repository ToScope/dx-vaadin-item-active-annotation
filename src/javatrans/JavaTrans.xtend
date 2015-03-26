package javatrans

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Active(ActiveProcessor)
annotation JavaTrans {
}

class ActiveProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		val dItem = context.findClass("de.test.xtend.javaclass.Bean")
		dItem.addField("demo", [type = String.newTypeReference])

	}

}
