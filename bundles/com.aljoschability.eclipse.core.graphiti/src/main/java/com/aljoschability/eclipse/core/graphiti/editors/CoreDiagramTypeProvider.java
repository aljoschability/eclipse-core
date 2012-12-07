package com.aljoschability.eclipse.core.graphiti.editors;

import org.eclipse.graphiti.dt.AbstractDiagramTypeProvider;
import org.eclipse.graphiti.tb.IToolBehaviorProvider;

public class CoreDiagramTypeProvider extends AbstractDiagramTypeProvider {
	private IToolBehaviorProvider[] availableToolBehaviorProviders;

	@Override
	public IToolBehaviorProvider[] getAvailableToolBehaviorProviders() {
		if (availableToolBehaviorProviders == null) {
			availableToolBehaviorProviders = new IToolBehaviorProvider[] { createToolBehaviorProvider() };
		}
		return availableToolBehaviorProviders;
	}

	protected IToolBehaviorProvider createToolBehaviorProvider() {
		return null;
	}
}
