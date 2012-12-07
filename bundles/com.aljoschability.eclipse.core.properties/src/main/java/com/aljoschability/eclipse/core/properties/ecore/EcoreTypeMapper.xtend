package com.aljoschability.eclipse.core.properties.ecore;

import com.aljoschability.eclipse.core.properties.impl.AbstractTypeMapper

class EcoreTypeMapper extends AbstractTypeMapper {
	override getAdaptor() {
		return EcoreElementAdaptor::get()
	}
}
