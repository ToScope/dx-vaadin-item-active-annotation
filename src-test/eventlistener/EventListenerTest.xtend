/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package eventlistener

import ditem.processor.DItem
import metamodel.Deep
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static extension testutil.CompilerTestestExtensions.*
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeEvent
import java.util.List

class EventListenerTest {

	val classpath = #[EventListener, PropertyChangeListener, PropertyChangeEvent, List]

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(classpath)

	@Test def void testObservable() {
		'''
		«imports(classpath)»
		class EventListenerTest {
			@EventListener
			List<PropertyChangeListener> listener;
		}
		'''.assertCompilesTo(
			'''
			import de.tf.xtend.util.Import;
			import eventlistener.EventListener;
			import java.beans.PropertyChangeEvent;
			import java.beans.PropertyChangeListener;
			import java.util.LinkedList;
			import java.util.List;
			
			@Import(value = LinkedList.class)
			@SuppressWarnings("all")
			public class EventListenerTest {
			  @EventListener
			  private List<PropertyChangeListener> listener;
			  
			  public void addPropertyChangeListener(final PropertyChangeListener listener) {
			    if(this.listener == null){
			    	this.listener = new LinkedList<>();
			    }
			    this.listener.add(listener);
			  }
			  
			  public void removePropertyChangeListener(final PropertyChangeListener listener) {
			    if(this.listener == null){
			    	this.listener.remove(listener);
			    }
			  }
			  
			  public void firePropertyChangeEvent(final PropertyChangeEvent event) {
			    if(this.listener != null){
			    	for (PropertyChangeListener listener : this.listener) {
			    		listener.propertyChange(event);
			    	}
			    }
			  }
			}
			''')
	}
}
