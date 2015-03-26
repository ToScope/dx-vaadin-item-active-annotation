package metamodel.flat

import java.lang.reflect.Type

interface Reference extends Type{
//	def Class<?> getOrgin()
	def String getType()
	def String getName();
	
	
}