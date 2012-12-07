package com.aljoschability.core.emf.dialogs

import java.util.List
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.dialogs.Dialog
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.viewers.DoubleClickEvent
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.window.Window
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Tree
import org.eclipse.ui.model.WorkbenchContentProvider
import org.eclipse.ui.model.WorkbenchLabelProvider
import org.eclipse.ui.views.navigator.ResourceComparator

class SelectWorkspaceResourceDialog extends Dialog {
	List<Object> selectedFiles

	TreeViewer viewer

	new(Shell shell) {
		super(shell)
	}

	override protected configureShell(Shell shell) {
		super.configureShell(shell)

		shell.text = "Select Workspace Resource"
	}

	override protected createDialogArea(Composite parent) {
		var control = super.createDialogArea(parent) as Composite
		control.layoutData = GridDataFactory::fillDefaults.grab(true, true).create
		control.layout = GridLayoutFactory::fillDefaults.margins(6, 6).create

		createViewer(control)

		control
	}

	override protected createContents(Composite parent) {
		var control = super.createContents(parent)

		getButton(Window::OK).enabled = false

		control
	}

	def private createViewer(Composite parent) {
		var tree = new Tree(
			parent,
			SWT::BORDER.bitwiseOr(SWT::MULTI)
		)
		tree.layoutData = GridDataFactory::fillDefaults.grab(true, true).create

		viewer = new TreeViewer(tree)

		// providers
		viewer.contentProvider = new WorkbenchContentProvider
		viewer.labelProvider = new WorkbenchLabelProvider

		// comparator
		viewer.comparator = new ResourceComparator(ResourceComparator::NAME)

		// filter
		viewer.addFilter [ Viewer v, Object p, Object e |
			if (e instanceof IResource) {
				return !e?.name.startsWith(".")
			} else {
				return false
			}
		]

		// selection change
		viewer.addSelectionChangedListener [ SelectionChangedEvent e |
			selectedFiles = (viewer.selection as IStructuredSelection).toArray.filter[it instanceof IFile].toList
			// set button state
			getButton(Window::OK).enabled = !files.empty
		]

		// double click
		viewer.addDoubleClickListener [ DoubleClickEvent e |
			if (getButton(Window::OK).isEnabled) {
				close
			} else {
				var element = (viewer.selection as IStructuredSelection).firstElement
				if (element instanceof IContainer) {
					viewer.setExpandedState(element, !viewer.getExpandedState(element))
				}
			}
		]

		// input
		viewer.input = ResourcesPlugin::workspace.root
	}

	override protected isResizable() {
		true
	}

	def List<Object> getFiles() {
		selectedFiles
	}
}
