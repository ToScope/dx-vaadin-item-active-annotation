/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package ditem

import ditem.processor.DItem
import metamodel.Deep
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static extension testutil.CompilerTestestExtensions.*
import ditem.property.Derived

class DItemCompileDerivedTest {

	val classpath = #[DItem, Derived]

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(classpath)

	@Test def void testObservable() {
		'''
		«imports(classpath)»
		
		«DItem.asAnnotation»
		class Quotes {
			String name = "Alo"
			Double price = 42
			//val a = "sd"
			
			def String nameWithPrice(){
				return name + price 
			}
		}
		'''.assertCompilesTo(
			'''
				''')
	}
}
