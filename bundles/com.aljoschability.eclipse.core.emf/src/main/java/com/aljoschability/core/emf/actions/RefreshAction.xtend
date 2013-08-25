/*
 * Copyright 2013 Aljoschability and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * 	Aljoscha Hark <mail@aljoschability.com> - initial API and implementation
 */
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
