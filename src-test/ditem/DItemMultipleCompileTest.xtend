/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package ditem

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import property.VaadinProperties
import ditem.processor.DItem

class DItemMultipleCompileTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(DItem)

	@Test def void testObservable() {
		'''
			import ditem.processor.DItem
			
			@DItem
			class Quote {
				String name
				static String tom
			}
		'''.assertCompilesTo(
		'''
			
			}
		''')
	}
}
