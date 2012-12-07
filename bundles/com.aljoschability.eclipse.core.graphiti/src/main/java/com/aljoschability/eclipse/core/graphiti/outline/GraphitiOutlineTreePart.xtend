package com.aljoschability.eclipse.core.graphiti.outline

import com.aljoschability.eclipse.core.graphiti.providers.GraphitiOutlineContentProvider
import com.aljoschability.eclipse.core.graphiti.providers.GraphitiOutlineLabelProvider
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Tree

class GraphitiOutlineTreePart extends GraphitiOutlinePage {
	TreeViewer viewer

	override createControl(Composite parent) {
		var tree = new Tree(parent, SWT::MULTI)

		viewer = new TreeViewer(tree)
		viewer.addPostSelectionChangedListener(page)
		viewer.contentProvider = new GraphitiOutlineContentProvider
		viewer.labelProvider = new GraphitiOutlineLabelProvider

		//viewer.comparator = new ViewerComparator
		viewer.input = page.diagram
	}

	override getControl() {
		viewer.control
	}

	override setFocus() {
		viewer.control.setFocus
	}

	def setSelection(ISelection selection) {
		viewer.selection = selection
	}

	def getSelection() {
		viewer.selection
	}
}
