package com.aljoschability.core.ui.wizards;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.model.WorkbenchContentProvider;
import org.eclipse.ui.model.WorkbenchLabelProvider;
import org.eclipse.ui.part.DrillDownComposite;

public class ExistingFileSelectionPage extends WizardPage {
	private IStructuredSelection selection;

	private IFile file;

	private TreeViewer viewer;

	private String fileExtension;

	public ExistingFileSelectionPage(String pageName, String fileExtension, IStructuredSelection selection) {
		super(pageName);

		this.fileExtension = fileExtension;
		this.selection = selection;
	}

	@Override
	public void createControl(Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(composite);
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(composite);

		createViewerWidgets(composite);

		setControl(composite);
	}

	private void createViewerWidgets(Composite parent) {
		DrillDownComposite composite = new DrillDownComposite(parent, SWT.BORDER);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(composite);

		Tree tree = new Tree(composite, SWT.SINGLE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(tree);

		viewer = new TreeViewer(tree);
		viewer.setContentProvider(new WorkbenchContentProvider());
		viewer.setLabelProvider(WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider());
		viewer.setInput(ResourcesPlugin.getWorkspace());
		viewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				Object selected = ((IStructuredSelection) viewer.getSelection()).getFirstElement();
				if (selected instanceof IFile) {
					file = (IFile) selected;
				} else {
					file = null;
				}
				setPageComplete(isValid());
			}
		});
		viewer.addFilter(new ViewerFilter() {
			@Override
			public boolean select(Viewer viewer, Object parent, Object element) {
				if (element instanceof IFile) {
					return getModelFileExtension().equals(((IFile) element).getFileExtension());
				}
				return true;
			}
		});
		viewer.addDoubleClickListener(new IDoubleClickListener() {
			@Override
			public void doubleClick(DoubleClickEvent event) {
				Object selected = ((IStructuredSelection) viewer.getSelection()).getFirstElement();
				if (selected instanceof IFile) {
					getContainer().showPage(getNextPage());
				} else {
					if (viewer.getExpandedState(selected)) {
						viewer.collapseToLevel(selected, 1);
					} else {
						viewer.expandToLevel(selected, 1);
					}
				}
			}
		});

		viewer.setSelection(selection);

		composite.setChildTree(viewer);
	}

	private boolean isValid() {
		if (file == null) {
			setErrorMessage("Select an existing file.");
			return false;
		}

		if (!getModelFileExtension().equals(file.getFileExtension())) {
			setErrorMessage("The selected file is not valid.");
			return false;
		}

		setErrorMessage(null);
		return true;
	}

	private String getModelFileExtension() {
		return fileExtension;
	}

	public IFile getFile() {
		return file;
	}
}
