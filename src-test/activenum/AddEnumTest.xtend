/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package activenum

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

class VaadinPropertiesTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(AddEnum)

	@Test def void testObservable() {
		'''
			import activenum.AddEnum
			
			package activenum
			@AddEnum
			class EnumTest {}
		'''.assertCompilesTo(
		'''
			
		''')
	}
}
