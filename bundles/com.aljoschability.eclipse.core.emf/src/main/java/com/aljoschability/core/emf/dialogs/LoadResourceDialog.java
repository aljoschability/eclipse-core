package com.aljoschability.core.emf.dialogs;

import java.lang.reflect.InvocationTargetException;
import java.util.Collection;
import java.util.LinkedHashSet;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.dialogs.ProgressMonitorDialog;
import org.eclipse.jface.dialogs.TitleAreaDialog;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.window.Window;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;

import com.aljoschability.core.emf.providers.ResourceNodeContentProvider;
import com.aljoschability.core.emf.providers.ResourceNodeLabelProvider;
import com.aljoschability.core.emf.resources.ResourceTreeBuilder;

public class LoadResourceDialog extends TitleAreaDialog {
	private EditingDomain editingDomain;

	private TreeViewer viewer;

	public LoadResourceDialog(Shell shell, EditingDomain editingDomain) {
		super(shell);

		setHelpAvailable(false);

		this.editingDomain = editingDomain;
	}

	@Override
	protected Control createContents(Composite parent) {
		Control contents = super.createContents(parent);

		// TODO Auto-generated method stub
		setTitle("Manage Resources");
		setMessage("Manage the resources that should be considered.");

		return contents;
	}

	@Override
	protected void createButtonsForButtonBar(Composite parent) {
		createButton(parent, IDialogConstants.OK_ID, IDialogConstants.OK_LABEL, true);
	}

	@Override
	protected boolean isResizable() {
		return true;
	}

	@Override
	protected Control createDialogArea(Composite parent) {
		Composite area = (Composite) super.createDialogArea(parent);

		Composite composite = new Composite(area, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(composite);
		GridLayoutFactory.fillDefaults().margins(6, 6).applyTo(composite);

		createWidgets(composite);

		return composite;
	}

	@Override
	protected void configureShell(Shell shell) {
		super.configureShell(shell);

		shell.setText("Manage Resources");
	}

	private void createWidgets(Composite parent) {
		Group group = new Group(parent, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(group);
		GridLayoutFactory.fillDefaults().numColumns(2).margins(6, 6).applyTo(group);
		group.setText("Resources");

		// tree
		Tree tree = new Tree(group, SWT.BORDER | SWT.SINGLE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(tree);

		viewer = new TreeViewer(tree);
		viewer.setContentProvider(new ResourceNodeContentProvider());
		viewer.setLabelProvider(new ResourceNodeLabelProvider());
		viewer.setAutoExpandLevel(TreeViewer.ALL_LEVELS);

		refresh(false);

		// controls
		Composite controlsComposite = new Composite(group, SWT.NONE);
		GridDataFactory.fillDefaults().grab(false, true).applyTo(controlsComposite);
		GridLayoutFactory.fillDefaults().applyTo(controlsComposite);

		// add from workspace
		Button addWorkspaceButton = new Button(controlsComposite, SWT.PUSH);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(addWorkspaceButton);
		addWorkspaceButton.setText("Add Workspace...");
		addWorkspaceButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				addWorkspaceResource();
			}
		});

		// add from registry
		Button addRegistryButton = new Button(controlsComposite, SWT.PUSH);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(addRegistryButton);
		addRegistryButton.setText("Add Registry...");
		addRegistryButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				addRegistryResource();
			}
		});

		// spacer
		Label spacerLabel = new Label(controlsComposite, SWT.NONE);
		GridDataFactory.fillDefaults().grab(false, true).applyTo(spacerLabel);

		// resolve all
		Button resolveAllButton = new Button(controlsComposite, SWT.PUSH);
		GridDataFactory.fillDefaults().grab(true, false).applyTo(resolveAllButton);
		resolveAllButton.setText("Resolve All");
		resolveAllButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				resolveAll();
			}
		});
	}

	protected void resolveAll() {
		refresh(true);
	}

	protected void addRegistryResource() {
		SelectRegisteredPackageDialog dialog = new SelectRegisteredPackageDialog(getShell(),
				editingDomain.getResourceSet());

		if (dialog.open() == Window.OK) {
			for (EPackage ePackage : dialog.getPackages()) {
				editingDomain.getResourceSet().getResources().add(ePackage.eResource());
			}
			refresh(false);
		}
	}

	protected void addWorkspaceResource() {
		SelectWorkspaceResourceDialog dialog = new SelectWorkspaceResourceDialog(getShell());

		if (dialog.open() == Window.OK) {
			for (Object object : dialog.getFiles()) {
				String path = ((IFile) object).getFullPath().toPortableString();
				URI uri = URI.createPlatformResourceURI(path, true);
				editingDomain.getResourceSet().getResource(uri, true);
			}
			refresh(false);
		}
	}

	private void refresh(final boolean resolve) {
		final Collection<Object> input = new LinkedHashSet<>();
		IRunnableWithProgress runnable = new IRunnableWithProgress() {
			@Override
			public void run(IProgressMonitor monitor) throws InvocationTargetException, InterruptedException {
				if (resolve) {
					EcoreUtil.resolveAll(editingDomain.getResourceSet());
				}

				ResourceTreeBuilder builder = new ResourceTreeBuilder(editingDomain.getResourceSet());
				input.addAll(builder.build());
			}
		};

		try {
			new ProgressMonitorDialog(getShell()).run(true, false, runnable);
		} catch (InvocationTargetException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		viewer.setInput(input);
	}
}
