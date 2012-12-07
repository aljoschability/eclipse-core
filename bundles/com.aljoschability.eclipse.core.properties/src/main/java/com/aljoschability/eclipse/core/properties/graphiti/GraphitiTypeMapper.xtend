package com.aljoschability.eclipse.core.properties.graphiti;

import com.aljoschability.eclipse.core.properties.impl.AbstractTypeMapper

public class GraphitiTypeMapper extends AbstractTypeMapper {
	override getAdaptor() {
		return GraphitiElementAdapter::get()
	}
}
