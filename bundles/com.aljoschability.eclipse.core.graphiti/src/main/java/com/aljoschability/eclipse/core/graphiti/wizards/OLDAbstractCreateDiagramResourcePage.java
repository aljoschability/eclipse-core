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
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.model.BaseWorkbenchContentProvider;
import org.eclipse.ui.model.WorkbenchLabelProvider;
import org.eclipse.ui.model.WorkbenchViewerComparator;

public abstract class OLDAbstractCreateDiagramResourcePage extends WizardPage {
	private IPath fileContainerPath;
	private String fileName;
	private boolean createNewModel;

	protected OLDAbstractCreateDiagramResourcePage() {
		super(OLDAbstractCreateDiagramResourcePage.class.getSimpleName());

		setTitle(getPageTitle());
		setDescription(getPageDescription());
		setImageDescriptor(getImageDescriptor());
	}

	@Override
	public void createControl(Composite parent) {
		Composite mainComposite = new Composite(parent, SWT.NONE);
		GridLayoutFactory.fillDefaults().numColumns(2).margins(6, 6).applyTo(mainComposite);

		// container group
		Group resourceContainerGroup = new Group(mainComposite, SWT.NONE);
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(resourceContainerGroup);
		GridDataFactory.fillDefaults().grab(true, true).span(2, 1).applyTo(resourceContainerGroup);

		// container tree
		final TreeViewer resourceContainerTreeViewer = new TreeViewer(resourceContainerGroup, SWT.BORDER | SWT.SINGLE);
		resourceContainerTreeViewer.setContentProvider(new BaseWorkbenchContentProvider());
		resourceContainerTreeViewer.setLabelProvider(new WorkbenchLabelProvider());
		resourceContainerTreeViewer.setComparator(new WorkbenchViewerComparator());
		resourceContainerTreeViewer.addFilter(new ViewerFilter() {
			@Override
			public boolean select(Viewer viewer, Object parent, Object element) {
				return element instanceof IContainer;
			}
		});
		Tree fileContainerTree = resourceContainerTreeViewer.getTree();
		GridDataFactory.fillDefaults().grab(true, true);
		fileContainerTree.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 1, 1));

		// file name
		Label resourceNameLabel = new Label(mainComposite, SWT.TRAIL);
		GridDataFactory.fillDefaults().align(SWT.TRAIL, SWT.CENTER).applyTo(resourceNameLabel);

		final Text resourceNameText = new Text(mainComposite, SWT.BORDER);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(resourceNameText);

		// diagram name
		Label diagramNameLabel = new Label(mainComposite, SWT.TRAIL);
		GridDataFactory.fillDefaults().align(SWT.TRAIL, SWT.CENTER).applyTo(diagramNameLabel);

		final Text diagramNameText = new Text(mainComposite, SWT.BORDER);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(diagramNameText);

		// model
		Label modelLabel = new Label(mainComposite, SWT.NONE);
		GridDataFactory.fillDefaults().align(SWT.TRAIL, SWT.CENTER).applyTo(modelLabel);

		Composite modelComposite = new Composite(mainComposite, SWT.NONE);
		GridLayoutFactory.fillDefaults().numColumns(2).margins(0, 0).applyTo(modelComposite);

		final Button radioModelCreateNew = new Button(modelComposite, SWT.RADIO);
		final Button radioModelUseExisting = new Button(modelComposite, SWT.RADIO);

		// hook listeners
		resourceContainerTreeViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				ISelection selection = resourceContainerTreeViewer.getSelection();
				if (!selection.isEmpty()) {
					Object selected = ((IStructuredSelection) selection).getFirstElement();
					if (selected instanceof IContainer) {
						fileContainerPath = ((IContainer) selected).getFullPath();
					}
				}
				setPageComplete(isValid());
			}
		});
		resourceNameText.addModifyListener(new ModifyListener() {
			@Override
			public void modifyText(ModifyEvent e) {
				fileName = resourceNameText.getText();
				setPageComplete(isValid());
			}
		});
		SelectionAdapter modelCreateNewAdapter = new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				createNewModel = e.getSource().equals(radioModelCreateNew);
				setPageComplete(isValid());
			}
		};
		radioModelCreateNew.addSelectionListener(modelCreateNewAdapter);
		radioModelUseExisting.addSelectionListener(modelCreateNewAdapter);

		// set values
		resourceContainerTreeViewer.setInput(ResourcesPlugin.getWorkspace().getRoot());
		resourceContainerGroup.setText("Diagram Resource Container");
		resourceNameLabel.setText("Resource Name:");
		resourceNameText.setText(getDefaultResourceName() + '.' + getFileExtension());
		diagramNameLabel.setText("Diagram Name:");
		diagramNameText.setText(getDefaultDiagramName());
		modelLabel.setText("Model:");
		radioModelCreateNew.setText("Create New Model Resource");
		radioModelCreateNew.setSelection(true);
		radioModelUseExisting.setText("Use Existing Model");

		setControl(mainComposite);
	}

	protected String getDefaultDiagramName() {
		return getDefaultResourceName();
	}

	protected String getDefaultResourceName() {
		return "default";
	}

	public String getDiagramName() {
		int lastDot = fileName.lastIndexOf('.');
		if (lastDot == -1) {
			return fileName;
		}
		return fileName.substring(0, lastDot);
	}

	public IPath getDiagramPath() {
		IPath path = fileContainerPath.append(fileName);
		if (getFileExtension().equalsIgnoreCase(path.getFileExtension())) {
			return path;
		}
		return path.addFileExtension(getFileExtension());
	}

	public abstract String getDiagramTypeId();

	public abstract String getDiagramTypeProviderId();

	protected abstract String getFileExtension();

	protected ImageDescriptor getImageDescriptor() {
		return null;
		// return ModelingImages.getImageDescriptor(ModelingImages.WIZBAN_NEWDIAGRAM);
	}

	protected String getPageDescription() {
		return "Select the location for the new diagram resource.";
	}

	protected String getPageTitle() {
		return "Create Diagram Resource";
	}

	public boolean isCreateNewModel() {
		return createNewModel;
	}

	protected boolean isValid() {
		if (fileContainerPath == null) {
			setErrorMessage("Select a valid resource container!");
			return false;
		}

		if (fileName == null || fileName.isEmpty()) {
			setErrorMessage("Provide a resource file name!");
			return false;
		}

		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		if (root.findMember(getDiagramPath()) instanceof IFile) {
			setMessage("The file already exists and will be overwritten!", WARNING);
			return true;
		}

		setErrorMessage(null);
		setMessage(null);
		return true;
	}
}
