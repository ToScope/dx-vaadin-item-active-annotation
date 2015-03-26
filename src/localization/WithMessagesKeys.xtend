package localization

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

/**
 * Generates a MessageKeys Enum with all fields out of a Messages.properties.<br/>
 * Properties:<br/>
 * 	• propertyFile: Special Property File, default="Messages.properties"<br/>
 * 	• addJavaDoc: If true, every enum value will get the message value as Java Doc<br/>. Default = true.
 *  • sorted: If true, the enums will be sorted. Default = true.
 */
@Beta
@Target(ElementType.TYPE)
@Active(MessagesKeysProcessor)
annotation WithMessagesKeys {
	String propertyFile = "Messages.properties"
	boolean addJavaDoc = true
	boolean sorted = true
}

class MessagesKeysProcessor extends AbstractClassProcessor {

	final String messageKeyName = "MessageKeys"
	final String enumPath = "messagesEnum.Messages."
	final String defaultPropertyFile = "messagesEnum.Messages."

	override doRegisterGlobals(ClassDeclaration cls, extension RegisterGlobalsContext context) {
		context.registerEnumerationType(enumPath + messageKeyName)
	}

	override doTransform(MutableClassDeclaration muteAbleClass, extension TransformationContext context) {
		super.doTransform(muteAbleClass, context)

		val AnnotationReference withMessagesKeysAnnotation = getWithMessagesKeysAnnotation(muteAbleClass, context);
		val propertyFileName = getPropertyFileName(withMessagesKeysAnnotation, context)

		val propertyFile = muteAbleClass.compilationUnit.filePath.parent.append(propertyFileName)
		if(!propertyFile.exists) {
			muteAbleClass.addError('''Property file «propertyFile» does not exist''')
			return
		}

		val resourceBundle = new PropertyResourceBundle(propertyFile.contentsAsStream)
		addMessageKeyField(context, resourceBundle, muteAbleClass, withMessagesKeysAnnotation)
	}

	def addMessageKeyField(extension TransformationContext context, PropertyResourceBundle resourceBundle, MutableClassDeclaration cls,
		AnnotationReference withMessagesKeysAnnotation) {
		val messageKeysEnum = findEnumerationType(enumPath + messageKeyName)
		var List<String> propertyKeys = newLinkedList(Collections.list(resourceBundle.keys))

		val boolean sorted = withMessagesKeysAnnotation.isSorted
		val boolean addJavaDoc = withMessagesKeysAnnotation.isGenerateJavaDoc
		if(sorted) {
			propertyKeys = propertyKeys.sort()
		}

		propertyKeys.forEach [ key |
			messageKeysEnum.addValue(key,
				[
					if(addJavaDoc) {
						docComment = resourceBundle.getString(key)
					}
				])
		]

		cls.addField(messageKeyName) [
			type = messageKeysEnum.newTypeReference
			visibility = Visibility.PUBLIC
		]
	}

	def AnnotationReference getWithMessagesKeysAnnotation(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		return annotatedClass.findAnnotation(WithMessagesKeys.newTypeReference.type)
	}

	def private String getPropertyFileName(AnnotationReference withMessagesKeysAnnotation, extension TransformationContext context) {
		val value = withMessagesKeysAnnotation.getValue('propertyFile') as String
		if(value.nullOrEmpty) {
			withMessagesKeysAnnotation.addWarning("@WithMessagesKeys using default MessageProperties: " + defaultPropertyFile)
			return defaultPropertyFile
		}
		return value
	}

	def private Boolean isGenerateJavaDoc(extension AnnotationReference withMessagesKeysAnnotation) {
		return getValue('addJavaDoc') as Boolean
	}

	def private Boolean isSorted(extension AnnotationReference withMessagesKeysAnnotation) {
		return getValue('sorted') as Boolean
	}
}
