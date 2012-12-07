package com.aljoschability.core.emf.dialogs;

import java.text.MessageFormat;
import java.util.Collection;
import java.util.LinkedHashSet;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerComparator;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;

import com.aljoschability.core.emf.Activator;
import com.aljoschability.core.emf.providers.RegisteredPackageContentProvider;
import com.aljoschability.core.emf.providers.RegisteredPackageLabelProvider;

public class SelectRegisteredPackageDialog extends Dialog {
	private final ResourceSet resourceSet;
	private final Collection<String> uris;
	private final Collection<EPackage> packages;
	private TreeViewer viewer;

	public SelectRegisteredPackageDialog(Shell shell, ResourceSet resourceSet) {
		super(shell);
		this.resourceSet = resourceSet;

		uris = new LinkedHashSet<>();
		packages = new LinkedHashSet<>();
	}

	@Override
	protected Control createDialogArea(Composite parent) {
		Composite composite = (Composite) super.createDialogArea(parent);

		Composite area = new Composite(composite, SWT.NONE);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(area);
		GridLayoutFactory.fillDefaults().applyTo(area);

		createViewer(area);

		return composite;
	}

	private void createViewer(Composite parent) {
		Tree tree = new Tree(parent, SWT.BORDER | SWT.MULTI | SWT.FULL_SELECTION);
		GridDataFactory.fillDefaults().grab(true, true).applyTo(tree);
		tree.setLinesVisible(true);

		viewer = new TreeViewer(tree);
		viewer.setContentProvider(new RegisteredPackageContentProvider());
		viewer.setLabelProvider(new RegisteredPackageLabelProvider());
		viewer.setComparator(new ViewerComparator());
		viewer.addFilter(new ViewerFilter() {
			@Override
			public boolean select(Viewer viewer, Object parent, Object element) {
				return !isAlreadyAdded(element);
			}
		});
		viewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				packages.clear();
				for (Object selected : ((IStructuredSelection) viewer.getSelection()).toArray()) {
					if (selected instanceof EPackage) {
						packages.add((EPackage) selected);
					}
				}
			}
		});

		refresh();
	}

	public Collection<EPackage> getPackages() {
		return packages;
	}

	protected boolean isAlreadyAdded(Object element) {
		if (element instanceof EPackage) {
			return uris.contains(((EPackage) element).getNsURI());
		}
		return false;
	}

	private void refresh() {
		// collect all packages
		Collection<String> keys = new LinkedHashSet<>();
		keys.addAll(EPackage.Registry.INSTANCE.keySet());

		for (String key : keys) {
			try {
				EPackage.Registry.INSTANCE.getEPackage(key);
			} catch (WrappedException e) {
				// package could not be loaded
				Activator.get().warn(MessageFormat.format("The package with URI={0} could not be loaded.", key), e);
			}
		}

		Collection<EPackage> packages = new LinkedHashSet<>();
		for (String key : EPackage.Registry.INSTANCE.keySet()) {
			try {
				packages.add(EPackage.Registry.INSTANCE.getEPackage(key));
			} catch (WrappedException e) {
				// package could not be loaded
				Activator.get().warn(MessageFormat.format("The package with URI={0} could not be loaded.", key), e);
			}
		}

		// collect already contained uris
		TreeIterator<Object> it = EcoreUtil.getAllContents(resourceSet, false);
		while (it.hasNext()) {
			Object object = (Object) it.next();
			if (object instanceof EPackage) {
				uris.add(((EPackage) object).getNsURI());
			}
		}

		viewer.setInput(packages);
	}

	@Override
	protected void configureShell(Shell shell) {
		super.configureShell(shell);

		shell.setText("Select Registered Package");
	}

	@Override
	protected boolean isResizable() {
		return true;
	}
}
