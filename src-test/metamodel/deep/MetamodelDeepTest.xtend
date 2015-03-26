/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package metamodel.deep

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import property.VaadinProperties

class MetamodelDeepTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(MetaModelDeep)

	@Test def void testObservable() {
		'''
		import metamodel.deep.MetaModelDeep
		import metamodel.Deep
			
		@MetaModelDeep
		class Quote {
			String name
			double price
			@Deep()
			Address address
			
			static class Address{}
		}
		'''.assertCompilesTo(
		'''
			
		''')
	}
}
