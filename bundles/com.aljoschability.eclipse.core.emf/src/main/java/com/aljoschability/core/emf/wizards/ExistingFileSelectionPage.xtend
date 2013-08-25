package com.aljoschability.core.emf.wizards

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.viewers.ViewerFilter
import org.eclipse.jface.wizard.WizardPage
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Tree
import org.eclipse.ui.model.WorkbenchContentProvider
import org.eclipse.ui.model.WorkbenchLabelProvider
import org.eclipse.ui.part.DrillDownComposite

class ExistingFileSelectionPage extends WizardPage {
	IStructuredSelection selection

	IFile file

	TreeViewer viewer

	String fileExtension

	new(String pageName, String fileExtension, IStructuredSelection selection) {
		super(pageName)

		this.fileExtension = fileExtension
		this.selection = selection
	}

	override createControl(Composite parent) {
		val composite = new Composite(parent, SWT.NONE)
		GridDataFactory::fillDefaults().grab(true, true).applyTo(composite)
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(composite)

		createViewerWidgets(composite)

		setControl(composite)
	}

	def private void createViewerWidgets(Composite parent) {
		val composite = new DrillDownComposite(parent, SWT.BORDER)
		composite.layoutData = GridDataFactory::fillDefaults().grab(true, true).create

		val tree = new Tree(composite, SWT.SINGLE)
		tree.layoutData = GridDataFactory::fillDefaults().grab(true, true).create

		viewer = new TreeViewer(tree)
		viewer.contentProvider = new WorkbenchContentProvider()
		viewer.labelProvider = WorkbenchLabelProvider::getDecoratingWorkbenchLabelProvider()
		viewer.input = ResourcesPlugin::getWorkspace()
		viewer.addSelectionChangedListener(
			[ event |
				val selected = (viewer.getSelection() as IStructuredSelection).getFirstElement()
				if (selected instanceof IFile) {
					file = selected
				} else {
					file = null
				}
				setPageComplete(isValid())
			])
		viewer.addFilter(
			new ViewerFilter() {
				override select(Viewer viewer, Object parent, Object element) {
					if (element instanceof IFile) {
						return fileExtension == element.fileExtension
					}
					return true
				}
			})
		viewer.addDoubleClickListener(
			[ event |
				val selected = (viewer.getSelection() as IStructuredSelection).getFirstElement()
				if (selected instanceof IFile) {
					container.showPage(nextPage)
				} else {
					if (viewer.getExpandedState(selected)) {
						viewer.collapseToLevel(selected, 1)
					} else {
						viewer.expandToLevel(selected, 1)
					}
				}
			])

		viewer.selection = selection

		composite.childTree = viewer
	}

	def private boolean isValid() {
		if (file == null) {
			errorMessage = "Select an existing file."
			return false
		}

		if (fileExtension != file.fileExtension) {
			errorMessage = "The selected file is not valid."
			return false
		}

		errorMessage = null
		return true
	}

	def IFile getFile() {
		return file
	}
}
