package ditem.property

import com.vaadin.data.Property
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

@Data
class IdentablePropertyProxy<T> implements IdentableProperty{
	String ID
	
	@Delegate
	Property porperty

}