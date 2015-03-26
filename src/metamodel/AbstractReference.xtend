package metamodel

import org.eclipse.xtend.lib.annotations.Data

@Data
class AbstractReference implements metamodel.flat.Reference{
	String type
	String name
	
	override getTypeName() {
		return type
	}
	
}