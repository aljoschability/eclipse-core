package com.aljoschability.core.ui.wizards;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
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
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.model.WorkbenchContentProvider;
import org.eclipse.ui.model.WorkbenchLabelProvider;

public class NewFileCreationPage extends WizardPage {
	private String extension;

	private IContainer container;
	private String name;

	public NewFileCreationPage(String name, String initialName, String extension, IStructuredSelection selection) {
		super(name);

		this.extension = extension;

		initializeContainer(selection);
		initializeName(initialName);
	}

	private void initializeContainer(IStructuredSelection selection) {
		// select first found container
		for (Object selected : selection.toArray()) {
			if (selected instanceof IContainer) {
				container = (IContainer) selected;
				break;
			} else if (selected instanceof IFile) {
				container = ((IFile) selected).getParent();
				break;
			}
		}

		// select first project otherwise
		if (container == null) {
			IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
			if (root.getProjects().length > 0) {
				container = root.getProjects()[0];
			}
		}
	}

	private void initializeName(String initialName) {
		name = initialName + '.' + extension;
		int i = 1;
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		while (root.findMember(getPath()) instanceof IFile) {
			name = initialName + i + '.' + extension;
			i++;
		}
	}

	@Override
	public void createControl(Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(composite);
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(composite);

		createContainerWidgets(composite);

		createNameWidgets(composite);

		setControl(composite);

		setPageComplete(isValid());
	}

	private void createContainerWidgets(Composite parent) {
		Group group = new Group(parent, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(group);
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(group);
		group.setText("Container");

		Tree tree = new Tree(group, SWT.SINGLE | SWT.BORDER);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(tree);

		final TreeViewer viewer = new TreeViewer(tree);
		viewer.setContentProvider(new WorkbenchContentProvider());
		viewer.setLabelProvider(WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider());
		viewer.setInput(ResourcesPlugin.getWorkspace());

		viewer.setSelection(new StructuredSelection(container));

		viewer.addFilter(new ViewerFilter() {
			@Override
			public boolean select(Viewer viewer, Object parent, Object element) {
				return element instanceof IContainer;
			}
		});

		viewer.addDoubleClickListener(new IDoubleClickListener() {
			@Override
			public void doubleClick(DoubleClickEvent event) {
				Object selected = ((IStructuredSelection) viewer.getSelection()).getFirstElement();
				if (viewer.getExpandedState(selected)) {
					viewer.collapseToLevel(selected, 1);
				} else {
					viewer.expandToLevel(selected, 1);
				}
			}
		});

		viewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				Object selected = ((IStructuredSelection) viewer.getSelection()).getFirstElement();
				if (selected instanceof IContainer) {
					container = (IContainer) selected;
				} else {
					container = null;
				}
				setPageComplete(isValid());
			}
		});
	}

	private void createNameWidgets(Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(composite);
		GridLayoutFactory.fillDefaults().margins(6, 6).numColumns(2).applyTo(composite);

		Label label = new Label(composite, SWT.TRAIL);
		GridDataFactory.fillDefaults().align(SWT.FILL, SWT.CENTER);
		label.setText("File Name:");

		final Text text = new Text(composite, SWT.BORDER | SWT.LEAD);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(text);
		text.setText(name);
		text.addModifyListener(new ModifyListener() {
			@Override
			public void modifyText(ModifyEvent e) {
				String newName = text.getText();

				if (newName.endsWith('.' + extension)) {
					name = newName;
				} else {
					name = newName + '.' + extension;
				}

				setPageComplete(isValid());
			}
		});
	}

	private boolean isValid() {
		if (container == null) {
			setErrorMessage("Provide the container for the new file.");
			return false;
		}

		if (name == null) {
			setErrorMessage("Provide a name for the new file.");
			return false;
		}

		if (ResourcesPlugin.getWorkspace().getRoot().findMember(getPath()) instanceof IFile) {
			setErrorMessage("The file already exists.");
			return false;
		}

		setErrorMessage(null);
		return true;
	}

	public String getPath() {
		return container.getFullPath().append(name).toPortableString();
	}
}
