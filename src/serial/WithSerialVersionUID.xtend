package serial

import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.io.Serializable
import java.math.BigInteger
import java.security.MessageDigest
import java.util.Collection
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.addInterface
import static extension de.tf.xtend.util.AnnotationProcessorExtensions.operator_equals
import static extension java.lang.Math.abs

/***
* Generates a custom Serial Version ID based on the ClassDeclararion. Based on javassist.SerialVersionUID.calculateDefault(CtClass).
* @pram calculateUID default = true. If set to false, the id 1L will be used.
*/
@Active(SerialVersionUIDProcessor)
annotation WithSerialVersionUID {
	boolean calculateUID = true
}

class SerialVersionUIDProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	static val serialVersionUID = "serialVersionUID"

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val calculateUID = annotatedClass.annotations.findFirst[it == WithSerialVersionUID].getBooleanValue('calculateUID')
		addSerialVersionUID(annotatedClass, context, calculateUID)
	}

	/***
	 * Generates a custom Serial Version ID based on the ClassDeclararion. Based on javassist.SerialVersionUID.calculateDefault(CtClass).
	 */
	def static long getSerialVersionID(MutableClassDeclaration it) {
		val bout = new ByteArrayOutputStream()
		val out = new DataOutputStream(bout)
		out += simpleName
		out += #[static, abstract, final, deprecated]

		implementedInterfaces.map[name].sortBy[it].forEach[out += it]
		declaredFields.sortBy[simpleName].forEach[out += it]
		declaredMethods.sortBy[simpleName].forEach[out += it]
		out.flush()
		return hash(bout.toByteArray())
	}

	def static long hash(byte[] bytes) {
		val digest = MessageDigest.getInstance("SHA");
		val byte[] digested = digest.digest(bytes);
		return new BigInteger(1, digested).longValue.abs
	}

	def static void operator_add(DataOutputStream out, MutableFieldDeclaration it) {
		#[deprecated, final, static, transient, volatile].forEach[out += it]
		#[type.simpleName, simpleName].forEach[out += it]
		out += visibility
	}

	def static void operator_add(DataOutputStream out, MutableMethodDeclaration it) {
		#[deprecated, final, static, native, varArgs].forEach[out += it]
		out += simpleName
		out += visibility
	}

	def static void operator_add(DataOutputStream it, String string) {
		writeUTF(string)
	}

	def static void operator_add(DataOutputStream it, Enum<?> enu) {
		writeInt(enu.ordinal)
	}

	def static void operator_add(DataOutputStream it, int integer) {
		writeInt(integer)
	}

	def static void operator_add(DataOutputStream it, boolean bool) {
		writeBoolean(bool)
	}

	def static void operator_add(DataOutputStream out, Collection<Boolean> bools) {
		bools.forEach[out.writeBoolean(it)]
	}
	
	/***
	 *  Adds a <code>private static final long serialVersionUID = 1L;</code> field and let the class implement the 
	 *  <code>Serializable</code> interface.
	 */
	def static addSerialVersionUID(MutableClassDeclaration annotatedClass, extension TransformationContext context, boolean calculateSerialVersionUID) {
		val needsASerialVersionUID = !annotatedClass.declaredFields.exists[it.simpleName == serialVersionUID]
		if(needsASerialVersionUID) {
			val serialUID = if(calculateSerialVersionUID) annotatedClass.serialVersionID + "L" else "1L"
			annotatedClass.addField(serialVersionUID) [
				type = primitiveLong
				initializer = [serialUID]
				static = true
				final = true
			]
		}
		
		val TypeReference serialInterface = Serializable.newTypeReference
		annotatedClass.addInterface(serialInterface)
	}

}
