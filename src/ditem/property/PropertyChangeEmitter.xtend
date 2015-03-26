package ditem.property

import java.beans.PropertyChangeListener

interface PropertyChangeEmitter {
	def void addPropertyChangeListener(PropertyChangeListener listener)
	def void removePropertyChangeListener(PropertyChangeListener listener)
}