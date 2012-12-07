package com.aljoschability.eclipse.core.graphiti.outline

import org.eclipse.jface.viewers.ISelection
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.SashForm
import org.eclipse.swt.widgets.Composite

class GraphitiOutlineMultiPart extends GraphitiOutlinePage {
	SashForm sash

	GraphitiOutlineThumbnailPart thumbnailPage
	GraphitiOutlineTreePart treePage

	override createControl(Composite parent) {
		sash = new SashForm(parent, SWT::VERTICAL)
		factory.adapt(sash)

		// thumbnail
		thumbnailPage = new GraphitiOutlineThumbnailPart
		thumbnailPage.create(page, factory, sash)

		// tree
		treePage = new GraphitiOutlineTreePart
		treePage.create(page, factory, sash)
	}

	override getControl() {
		sash
	}

	override setFocus() {
		sash.setFocus
	}

	def setSelection(ISelection selection) {
		treePage.selection = selection
	}

	def getSelection() {
		treePage.selection
	}
}
