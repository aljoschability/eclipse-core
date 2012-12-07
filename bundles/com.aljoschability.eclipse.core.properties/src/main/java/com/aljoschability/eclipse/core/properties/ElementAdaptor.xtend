package com.aljoschability.eclipse.core.properties

import org.eclipse.emf.ecore.EObject;

interface ElementAdaptor {
	def Class<?> getClass(Object element)

	def EObject getElement(Object element)
}
