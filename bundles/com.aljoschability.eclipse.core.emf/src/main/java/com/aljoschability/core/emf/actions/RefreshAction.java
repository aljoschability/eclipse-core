package com.aljoschability.core.emf.actions;

import org.eclipse.emf.common.ui.viewer.IViewerProvider;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.ui.IWorkbenchPart;

public class RefreshAction extends Action {
	private IViewerProvider provider;

	public RefreshAction() {
		super("Refresh@F5");
	}

	@Override
	public boolean isEnabled() {
		return provider != null;
	}

	@Override
	public void run() {
		Viewer viewer = provider.getViewer();
		if (viewer != null) {
			viewer.refresh();
		}
	}

	public void setActiveWorkbenchPart(IWorkbenchPart part) {
		if (part instanceof IViewerProvider) {
			provider = (IViewerProvider) part;
		} else {
			provider = null;
		}
	}
}