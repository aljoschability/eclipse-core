package com.aljoschability.core.ui.wizards

import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.viewers.DoubleClickEvent
import org.eclipse.jface.viewers.IDoubleClickListener
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.viewers.ViewerFilter
import org.eclipse.jface.wizard.WizardPage
import org.eclipse.swt.SWT
import org.eclipse.swt.events.ModifyEvent
import org.eclipse.swt.events.ModifyListener
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Group
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.swt.widgets.Tree
import org.eclipse.ui.model.WorkbenchContentProvider
import org.eclipse.ui.model.WorkbenchLabelProvider

class NewFileCreationPage extends WizardPage {
	String fileExtension

	IContainer container
	String name

	new(String name, String initialName, String fileExtension, IStructuredSelection selection) {
		super(name)

		this.fileExtension = fileExtension

		initializeContainer(selection)
		initializeName(initialName)
	}

	def private void initializeContainer(IStructuredSelection selection) {

		// select first found container
		for (Object selected : selection.toArray) {
			if (selected instanceof IContainer) {
				container = selected
			} else if (selected instanceof IFile) {
				container = selected.getParent()
			}
		}

		// select first project otherwise
		if (container == null) {
			val root = ResourcesPlugin::workspace.root
			if (!root.projects.empty) {
				container = root.projects.head
			}
		}
	}

	def private void initializeName(String initialName) {
		name = initialName + '.' + fileExtension
		var i = 1
		val root = ResourcesPlugin::workspace.root
		while (root.findMember(getPath()) instanceof IFile) {
			name = initialName + i + '.' + fileExtension
			i++
		}
	}

	override createControl(Composite parent) {
		val composite = new Composite(parent, SWT::NONE)
		composite.layoutData = GridDataFactory.fillDefaults().grab(true, true).create
		composite.layout = GridLayoutFactory.fillDefaults().margins(6, 6).create

		createContainerWidgets(composite)

		createNameWidgets(composite)

		setControl(composite)

		setPageComplete(isValid())
	}

	def private void createContainerWidgets(Composite parent) {
		val group = new Group(parent, SWT.NONE)
		group.layoutData = GridDataFactory.fillDefaults().grab(true, true).create
		group.layout = GridLayoutFactory.fillDefaults().margins(6, 6).create
		group.setText("Container")

		val tree = new Tree(group, SWT.SINGLE.bitwiseOr(SWT.BORDER))
		GridDataFactory.fillDefaults().grab(true, true).applyTo(tree)

		val viewer = new TreeViewer(tree)
		viewer.setContentProvider(new WorkbenchContentProvider())
		viewer.setLabelProvider(WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider())
		viewer.setInput(ResourcesPlugin.getWorkspace())

		viewer.setSelection(new StructuredSelection(container))

		viewer.addFilter(
			new ViewerFilter() {
				override select(Viewer viewer, Object parent, Object element) {
					return element instanceof IContainer
				}
			})

		viewer.addDoubleClickListener(
			new IDoubleClickListener() {
				override doubleClick(DoubleClickEvent event) {
					val selected = (viewer.selection as IStructuredSelection).firstElement
					if (viewer.getExpandedState(selected)) {
						viewer.collapseToLevel(selected, 1)
					} else {
						viewer.expandToLevel(selected, 1)
					}
				}
			})

		viewer.addSelectionChangedListener(
			new ISelectionChangedListener() {
				override selectionChanged(SelectionChangedEvent event) {
					val selected = (viewer.selection as IStructuredSelection).firstElement
					if (selected instanceof IContainer) {
						container = selected
					} else {
						container = null
					}
					setPageComplete(isValid())
				}
			})
	}

	def private void createNameWidgets(Composite parent) {
		val composite = new Composite(parent, SWT.NONE)
		composite.layoutData = GridDataFactory.fillDefaults().grab(true, false).create
		composite.layout = GridLayoutFactory.fillDefaults().margins(6, 6).numColumns(2).create

		val label = new Label(composite, SWT.TRAIL)
		GridDataFactory.fillDefaults().align(SWT.FILL, SWT.CENTER)
		label.setText("File Name:")

		val text = new Text(composite, SWT.BORDER.bitwiseOr(SWT.LEAD))
		GridDataFactory.fillDefaults().grab(true, false).applyTo(text)
		text.setText(name)
		text.addModifyListener(
			new ModifyListener() {
				override modifyText(ModifyEvent e) {
					val newName = text.getText()

					if (newName.endsWith('.' + fileExtension)) {
						name = newName
					} else {
						name = newName + '.' + fileExtension
					}

					setPageComplete(isValid())
				}
			})
	}

	def private boolean isValid() {
		if (container == null) {
			errorMessage = "Provide the container for the new file."
			return false
		}

		if (name == null) {
			errorMessage = "Provide a name for the new file."
			return false
		}

		if (ResourcesPlugin::workspace.root.findMember(getPath()) instanceof IFile) {
			errorMessage = "The file already exists."
			return false
		}

		errorMessage = null
		return true
	}

	def String getPath() {
		return container.fullPath.append(name).toPortableString
	}
}
