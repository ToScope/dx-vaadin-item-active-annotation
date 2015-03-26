/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package localization

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import org.junit.Ignore

class WithMessagesKeysTest {
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(WithMessagesKeys)

//	@Ignore
	@Test def void testMessagesKeys() {
		'''
			import localization.WithMessagesKeys
			@WithMessagesKeys
			class Messages {}
		'''.assertCompilesTo(
		'''''')
	}
}