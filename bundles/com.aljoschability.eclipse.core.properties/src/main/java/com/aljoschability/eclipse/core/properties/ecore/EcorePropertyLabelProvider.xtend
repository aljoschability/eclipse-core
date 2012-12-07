package com.aljoschability.eclipse.core.properties.ecore;

import com.aljoschability.eclipse.core.properties.impl.AbstractPropertiesLabelProvider

class EcorePropertyLabelProvider extends AbstractPropertiesLabelProvider {
	override getAdaptor() {
		return EcoreElementAdaptor::get()
	}
}
