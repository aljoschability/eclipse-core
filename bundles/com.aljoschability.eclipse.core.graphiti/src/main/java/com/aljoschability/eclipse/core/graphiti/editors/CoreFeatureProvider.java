package com.aljoschability.eclipse.core.graphiti.editors;

import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.pattern.DefaultFeatureProviderWithPatterns;

public class CoreFeatureProvider extends DefaultFeatureProviderWithPatterns {
	public CoreFeatureProvider(IDiagramTypeProvider dtp) {
		super(dtp);
	}
}
