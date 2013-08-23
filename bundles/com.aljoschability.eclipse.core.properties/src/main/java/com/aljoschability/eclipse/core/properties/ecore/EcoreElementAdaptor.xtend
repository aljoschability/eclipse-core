package com.aljoschability.eclipse.core.properties.ecore;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.properties.impl.AbstractElementAdaptor
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.viewers.IStructuredSelection

class EcoreElementAdaptor extends AbstractElementAdaptor {
	static ElementAdaptor INSTANCE

	static def ElementAdaptor get() {
		if (EcoreElementAdaptor::INSTANCE == null) {
			EcoreElementAdaptor::INSTANCE = new EcoreElementAdaptor()
		}
		return EcoreElementAdaptor::INSTANCE
	}

	override getClass(Object element) {
		val adapted = getElement(element);
		if (adapted != null) {
			return adapted.eClass().getInstanceClass();
		}
		return null;
	}

	override getElement(Object element) {
		if (element instanceof IStructuredSelection && (element as IStructuredSelection).size() == 1) {
			return getElement((element as IStructuredSelection).getFirstElement());
		}

		if (element instanceof EObject) {
			return element
		}

		return null;
	}
}
