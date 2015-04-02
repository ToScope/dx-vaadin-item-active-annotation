package ditemmini

import ditem.property.DerivedProperty
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration

import static extension ditemmini.ProcesssorExtensions.addField

//Remove this line and all works fine
@Active(DItemMiniProcessor)
annotation DItemMini {
}

class DItemMiniProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
//		registerClass(annotatedClass.qualifiedName + "Item")
	}



	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
//		addField(annotatedClass, context)
		annotatedClass.addField(context)
	}


}
