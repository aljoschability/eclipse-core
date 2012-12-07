/**
 * Copyright 2012 Aljoschability. All rights reserved. This program and the accompanying materials are made available
 * under the terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *    Aljoscha Hark - initial API and implementation.
 */
package com.aljoschability.eclipse.core.graphiti.wizards;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.model.BaseWorkbenchContentProvider;
import org.eclipse.ui.model.WorkbenchLabelProvider;
import org.eclipse.ui.model.WorkbenchViewerComparator;

public abstract class OLDAbstractCreateModelResourcePage extends WizardPage {
	private IPath resourcePath;
	private String resourceName;

	public OLDAbstractCreateModelResourcePage() {
		super(OLDAbstractCreateModelResourcePage.class.getSimpleName());

		setTitle(getPageTitle());
		setDescription(getPageDescription());
		setImageDescriptor(getImageDescriptor());
	}

	@Override
	public void createControl(Composite parent) {
		Composite mainComposite = new Composite(parent, SWT.NONE);
		GridLayoutFactory.fillDefaults().numColumns(2).margins(6, 6).applyTo(mainComposite);

		Group fileContainerGroup = new Group(mainComposite, SWT.NONE);
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(fileContainerGroup);
		GridDataFactory.fillDefaults().grab(true, true).span(2, 1).applyTo(fileContainerGroup);

		final TreeViewer fileContainerTreeViewer = new TreeViewer(fileContainerGroup, SWT.BORDER);
		fileContainerTreeViewer.setContentProvider(new BaseWorkbenchContentProvider());
		fileContainerTreeViewer.setLabelProvider(new WorkbenchLabelProvider());
		fileContainerTreeViewer.setComparator(new WorkbenchViewerComparator());
		fileContainerTreeViewer.addFilter(new ViewerFilter() {
			@Override
			public boolean select(Viewer viewer, Object parent, Object element) {
				return element instanceof IContainer;
			}
		});

		Tree fileContainerTree = fileContainerTreeViewer.getTree();
		fileContainerTree.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 1, 1));

		Label fileNameLabel = new Label(mainComposite, SWT.NONE);
		fileNameLabel.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));

		final Text fileNameText = new Text(mainComposite, SWT.BORDER);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(fileNameText);

		// hook listeners
		fileNameText.addModifyListener(new ModifyListener() {
			@Override
			public void modifyText(ModifyEvent e) {
				resourceName = fileNameText.getText();
				setPageComplete(isValid());
			}
		});
		fileContainerTreeViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				resourcePath = null;
				ISelection selection = fileContainerTreeViewer.getSelection();
				if (!selection.isEmpty()) {
					Object selected = ((IStructuredSelection) selection).getFirstElement();
					if (selected instanceof IContainer) {
						resourcePath = ((IContainer) selected).getFullPath();
					}
				}
				setPageComplete(isValid());
			}
		});

		// initialize values
		fileContainerGroup.setText("Model Resource Container");
		fileNameLabel.setText("Resource Name:");
		fileContainerTreeViewer.setInput(ResourcesPlugin.getWorkspace().getRoot());
		if (fileContainerTreeViewer.getTree().getItemCount() > 0) {
			Object firstElement = fileContainerTreeViewer.getTree().getItems()[0].getData();
			fileContainerTreeViewer.setSelection(new StructuredSelection(firstElement));
		}
		fileNameText.setText(getDefaultResourceName() + '.' + getFileExtension());

		setControl(mainComposite);
	}

	protected abstract EObject getContent();

	protected String getDefaultResourceName() {
		return "default";
	}

	protected abstract String getFileExtension();

	protected ImageDescriptor getImageDescriptor() {
		return null;
	}

	protected String getPageDescription() {
		return "Select the location for the new model resource.";
	}

	protected String getPageTitle() {
		return "Create Model Resource";
	}

	public IPath getResourcePath() {
		IPath path = resourcePath.append(resourceName);
		if (getFileExtension().equalsIgnoreCase(path.getFileExtension())) {
			return path;
		}
		return path.addFileExtension(getFileExtension());
	}

	protected boolean isValid() {

		setErrorMessage(null);
		setMessage(null);
		return true;
	}
}
