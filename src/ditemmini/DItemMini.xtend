package ditemmini

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration

//Remove this line and all works fine


@Active(DItemMiniProcessor)
annotation DItemMini {
}

class DItemMiniProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		registerClass(annotatedClass.qualifiedName + "Item")
	}

}
