package com.aljoschability.eclipse.core.graphiti.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IResizeShapeContext
import org.eclipse.graphiti.features.impl.DefaultResizeShapeFeature

class NoResizeShapeFeature extends DefaultResizeShapeFeature {
	new(IFeatureProvider fp) {
		super(fp)
	}

	override canResizeShape(IResizeShapeContext context) {
		false
	}
}
