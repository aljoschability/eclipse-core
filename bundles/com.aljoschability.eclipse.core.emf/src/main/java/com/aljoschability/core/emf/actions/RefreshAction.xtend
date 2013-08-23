package com.aljoschability.core.emf.actions;

import org.eclipse.emf.common.ui.viewer.IViewerProvider
import org.eclipse.jface.action.Action
import org.eclipse.ui.IWorkbenchPart

class RefreshAction extends Action {
	IViewerProvider provider

	new() {
		super("Refresh@F5")
	}

	override isEnabled() {
		return provider != null
	}

	override public void run() {
		provider.viewer?.refresh()
	}

	def void setActiveWorkbenchPart(IWorkbenchPart part) {
		if (part instanceof IViewerProvider) {
			provider = part
		} else {
			provider = null
		}
	}
}
