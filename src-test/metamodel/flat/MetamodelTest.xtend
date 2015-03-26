/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package metamodel.flat

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import property.VaadinProperties

class MetamodelTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(MetaModel)

	@Test def void testObservable() {
		'''
		import metamodel.flat.MetaModel
			
		@MetaModel
		class Quote {
			String name;
			double price;
			@metamodel.Deep
			java.util.ArrayList arrayList =  new  java.util.ArrayList();
		}
		'''.assertCompilesTo(
		'''
			
		''')
	}
}
