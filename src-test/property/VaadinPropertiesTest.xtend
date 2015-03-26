/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package property

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import property.VaadinProperties

class VaadinPropertiesTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(VaadinProperties)

	@Test def void testObservable() {
		'''
			import property.VaadinProperties
			
			@VaadinProperties
			class Quote {
				String name;
			}
		'''.assertCompilesTo(
		'''
			import com.vaadin.data.Property;
			import com.vaadin.data.util.ObjectProperty;
			import java.io.Serializable;
			import property.VaadinProperties;
			
			@VaadinProperties
			@SuppressWarnings("all")
			public class Quote implements Serializable {
			  private String name;
			  
			  private long serialVersionUID = 1L;
			  
			  private final ObjectProperty<String> _nameProperty = new ObjectProperty<String>(name,String.class);
			  
			  public Property<String> getNameProperty() {
			    return _nameProperty;
			  }
			  
			  private final ObjectProperty<Long> _serialVersionUIDProperty = new ObjectProperty<Long>(serialVersionUID,long.class);
			  
			  public Property<Long> getSerialVersionUIDProperty() {
			    return _serialVersionUIDProperty;
			  }
			}
		''')
	}
}
