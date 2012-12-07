package com.aljoschability.eclipse.core.graphiti.editors;

import org.eclipse.graphiti.ui.editor.DefaultPersistencyBehavior;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.IDiagramContainerUI;

public class CoreDiagramBehavior extends DiagramBehavior {
	public CoreDiagramBehavior(IDiagramContainerUI diagramContainer) {
		super(diagramContainer);
	}

	@Override
	protected DefaultPersistencyBehavior createPersistencyBehavior() {
		return new CorePersistencyBehavior(this);
	}
}
