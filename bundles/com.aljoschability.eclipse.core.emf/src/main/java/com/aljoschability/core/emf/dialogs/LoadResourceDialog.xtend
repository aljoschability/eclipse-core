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
package com.aljoschability.core.emf.dialogs;

import com.aljoschability.core.emf.providers.ResourceNodeContentProvider
import com.aljoschability.core.emf.providers.ResourceNodeLabelProvider
import com.aljoschability.core.emf.resources.ResourceTreeBuilder
import java.util.Collection
import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.jface.dialogs.IDialogConstants
import org.eclipse.jface.dialogs.ProgressMonitorDialog
import org.eclipse.jface.dialogs.TitleAreaDialog
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.operation.IRunnableWithProgress
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.window.Window
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Group
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Tree

class LoadResourceDialog extends TitleAreaDialog {
	EditingDomain editingDomain

	TreeViewer viewer

	new(Shell shell, EditingDomain editingDomain) {
		super(shell)

		this.editingDomain = editingDomain

		helpAvailable = false
	}

	override protected createContents(Composite parent) {
		val contents = super.createContents(parent)

		title = "Manage Resources"
		message = "Manage the resources that should be considered."

		return contents
	}

	override protected createButtonsForButtonBar(Composite parent) {
		createButton(parent, IDialogConstants::OK_ID, IDialogConstants::OK_LABEL, true)
	}

	override protected isResizable() {
		return true
	}

	override protected createDialogArea(Composite parent) {
		val area = super.createDialogArea(parent) as Composite

		val composite = new Composite(area, SWT::NONE)
		composite.layoutData = GridDataFactory.fillDefaults().grab(true, true).create
		composite.layout = GridLayoutFactory.fillDefaults().margins(6, 6).create

		createWidgets(composite)

		return composite
	}

	override protected configureShell(Shell shell) {
		super.configureShell(shell)

		shell.text = "Manage Resources"
	}

	private def void createWidgets(Composite parent) {
		val group = new Group(parent, SWT::NONE)
		group.layoutData = GridDataFactory.fillDefaults().grab(true, true).create
		group.layout = GridLayoutFactory.fillDefaults().numColumns(2).margins(6, 6).create
		group.text = "Resources"

		// tree
		val tree = new Tree(group, SWT::BORDER.bitwiseOr(SWT::SINGLE))
		tree.layoutData = GridDataFactory.fillDefaults().grab(true, true).create

		viewer = new TreeViewer(tree)
		viewer.contentProvider = new ResourceNodeContentProvider()
		viewer.labelProvider = new ResourceNodeLabelProvider()
		viewer.autoExpandLevel = TreeViewer::ALL_LEVELS

		refresh(false)

		// controls
		val controlsComposite = new Composite(group, SWT::NONE)
		controlsComposite.layoutData = GridDataFactory.fillDefaults().grab(false, true).create
		controlsComposite.layout = GridLayoutFactory.fillDefaults().create

		// add from workspace
		val addWorkspaceButton = new Button(controlsComposite, SWT::PUSH)
		addWorkspaceButton.layoutData = GridDataFactory.fillDefaults().grab(true, false).create
		addWorkspaceButton.text = "Add Workspace..."
		addWorkspaceButton.addSelectionListener(
			new SelectionAdapter() {
				override widgetSelected(SelectionEvent e) {
					addWorkspaceResource()
				}
			})

		// add from registry
		val addRegistryButton = new Button(controlsComposite, SWT::PUSH)
		addRegistryButton.layoutData = GridDataFactory.fillDefaults().grab(true, false).create
		addRegistryButton.text = "Add Registry..."
		addRegistryButton.addSelectionListener(
			new SelectionAdapter() {
				override widgetSelected(SelectionEvent e) {
					addRegistryResource()
				}
			})

		// spacer
		val spacerLabel = new Label(controlsComposite, SWT::NONE)
		spacerLabel.layoutData = GridDataFactory.fillDefaults().grab(false, true).create

		// resolve all
		val resolveAllButton = new Button(controlsComposite, SWT::PUSH)
		resolveAllButton.layoutData = GridDataFactory.fillDefaults().grab(true, false).create
		resolveAllButton.text = "Resolve All"
		resolveAllButton.addSelectionListener(
			new SelectionAdapter() {
				override widgetSelected(SelectionEvent e) {
					resolveAll()
				}
			})
	}

	def protected void resolveAll() {
		refresh(true)
	}

	def protected void addRegistryResource() {
		val dialog = new SelectRegisteredPackageDialog(shell, editingDomain.resourceSet)

		if (dialog.open() == Window::OK) {
			for (EPackage ePackage : dialog.packages) {
				editingDomain.resourceSet.resources.add(ePackage.eResource)
			}
			refresh(false)
		}
	}

	def protected void addWorkspaceResource() {
		val dialog = new SelectWorkspaceResourceDialog(shell)

		if (dialog.open() == Window::OK) {
			for (Object object : dialog.files) {
				if (object instanceof IFile) {
					val path = object.fullPath.toPortableString
					val uri = URI.createPlatformResourceURI(path, true)
					editingDomain.resourceSet.getResource(uri, true)
				}
			}
			refresh(false)
		}
	}

	def private void refresh(boolean resolve) {
		val Collection<Object> input = newLinkedHashSet
		val IRunnableWithProgress runnable = [ monitor |
			if (resolve) {
				EcoreUtil::resolveAll(editingDomain.resourceSet)
			}
			val builder = new ResourceTreeBuilder(editingDomain.resourceSet)
			input += builder.build()
		]

		new ProgressMonitorDialog(shell).run(true, false, runnable)

		viewer.setInput(input);
	}
}
