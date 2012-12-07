package com.aljoschability.eclipse.core.properties.graphiti;

import com.aljoschability.eclipse.core.properties.impl.AbstractPropertiesLabelProvider

class GraphitiPropertyLabelProvider extends AbstractPropertiesLabelProvider {
	override getAdaptor() {
		return GraphitiElementAdapter::get()
	}
}
