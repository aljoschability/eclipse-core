package com.aljoschability.eclipse.core.graphiti.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature

abstract class CoreCreateConnectionFeature extends AbstractCreateConnectionFeature {
	new(IFeatureProvider fp) {
		super(fp, null, null)
	}
}
