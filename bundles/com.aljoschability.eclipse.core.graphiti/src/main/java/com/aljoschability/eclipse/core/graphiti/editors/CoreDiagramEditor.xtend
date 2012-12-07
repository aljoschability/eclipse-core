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
