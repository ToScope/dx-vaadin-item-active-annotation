package testutil

import java.lang.annotation.Annotation

class CompilerTestestExtensions {
		def static imports(Class<?>... classes){
		return '''
		«FOR imp : classes»
		«imp.asImport»
		«ENDFOR»
		'''
	}
	
	def static String asImport(Class<?> clazz){
		"import "+clazz.name
	}
	
	def static String asAnnotation(Class<? extends Annotation> clazz){
		"@"+clazz.simpleName
	}
}