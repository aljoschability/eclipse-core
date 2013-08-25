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
package com.aljoschability.eclipse.core.graphiti.editors;

import org.eclipse.gef.KeyHandler;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;

import com.aljoschability.eclipse.core.graphiti.outline.GraphitiContentOutlinePage

class CoreDiagramEditor extends DiagramEditor {
	IContentOutlinePage outlinePage

	override getAdapter(Class required) {
		if (IContentOutlinePage == required) {
			if (outlinePage == null) {
				outlinePage = createOutlinePage()
			}
			return outlinePage
		}
		return super.getAdapter(required)
	}

	override DiagramBehavior createDiagramBehavior() {
		new CoreDiagramBehavior(this)
	}

	def protected IContentOutlinePage createOutlinePage() {
		new GraphitiContentOutlinePage(this)
	}

	def KeyHandler getKeyHandler() {
		return getAdapter(KeyHandler) as KeyHandler
	}
}
