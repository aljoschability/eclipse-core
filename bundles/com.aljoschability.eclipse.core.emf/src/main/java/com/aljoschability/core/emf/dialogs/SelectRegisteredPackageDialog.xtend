package com.aljoschability.core.emf.dialogs

import com.aljoschability.core.emf.Activator
import com.aljoschability.core.emf.providers.RegisteredPackageContentProvider
import com.aljoschability.core.emf.providers.RegisteredPackageLabelProvider
import java.text.MessageFormat
import java.util.Collection
import org.eclipse.emf.common.util.WrappedException
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.jface.dialogs.Dialog
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.ViewerComparator
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Tree

class SelectRegisteredPackageDialog extends Dialog {
	final ResourceSet resourceSet
	final Collection<String> uris
	final Collection<EPackage> packages
	TreeViewer viewer

	new(Shell shell, ResourceSet resourceSet) {
		super(shell)
		this.resourceSet = resourceSet

		uris = newLinkedHashSet
		packages = newLinkedHashSet
	}

	override protected createDialogArea(Composite parent) {
		val composite = super.createDialogArea(parent) as Composite

		val area = new Composite(composite, SWT::NONE)
		GridDataFactory.fillDefaults().grab(true, true).applyTo(area)
		GridLayoutFactory.fillDefaults().applyTo(area)

		createViewer(area)

		return composite
	}

	def private void createViewer(Composite parent) {
		val tree = new Tree(parent, SWT::BORDER.bitwiseOr(SWT::MULTI).bitwiseOr(SWT::FULL_SELECTION))
		GridDataFactory.fillDefaults().grab(true, true).applyTo(tree)
		tree.setLinesVisible(true)

		viewer = new TreeViewer(tree)
		viewer.contentProvider = new RegisteredPackageContentProvider()
		viewer.labelProvider = new RegisteredPackageLabelProvider()
		viewer.comparator = new ViewerComparator()
		viewer.addFilter([v, p, e|return !isAlreadyAdded(e)])

		viewer.addSelectionChangedListener(
			[ e |
				packages.clear()
				for (Object selected : (viewer.getSelection() as IStructuredSelection).toArray()) {
					if (selected instanceof EPackage) {
						packages.add(selected)
					}
				}
			])

		refresh()
	}

	def Collection<EPackage> getPackages() {
		return packages
	}

	def protected boolean isAlreadyAdded(Object element) {
		if (element instanceof EPackage) {
			return uris.contains(element.nsURI)
		}
		return false
	}

	def private void refresh() {

		// collect all packages
		val Collection<String> keys = newLinkedHashSet
		keys.addAll(EPackage.Registry::INSTANCE.keySet())

		for (String key : keys) {
			try {
				EPackage.Registry::INSTANCE.getEPackage(key)
			} catch (WrappedException e) {

				// package could not be loaded
				Activator::get().warn(MessageFormat::format("The package with URI={0} could not be loaded.", key), e)
			}
		}

		val Collection<EPackage> packages = newLinkedHashSet
		for (String key : EPackage.Registry::INSTANCE.keySet()) {
			try {
				packages.add(EPackage.Registry::INSTANCE.getEPackage(key))
			} catch (WrappedException e) {

				// package could not be loaded
				Activator::get().warn(MessageFormat.format("The package with URI={0} could not be loaded.", key), e)
			}
		}

		// collect already contained uris
		val iter = EcoreUtil::getAllContents(resourceSet, false)
		while (iter.hasNext) {
			val object = iter.next
			if (object instanceof EPackage) {
				uris.add(object.nsURI)
			}
		}

		viewer.input = packages
	}

	override protected configureShell(Shell shell) {
		super.configureShell(shell)

		shell.text = "Select Registered Package"
	}

	override protected isResizable() {
		return true
	}
}
