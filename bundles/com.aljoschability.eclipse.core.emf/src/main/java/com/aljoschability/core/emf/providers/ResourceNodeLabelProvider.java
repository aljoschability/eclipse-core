package com.aljoschability.core.emf.providers;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;
import org.eclipse.ui.model.WorkbenchLabelProvider;

import com.aljoschability.core.emf.EmfImages;
import com.aljoschability.core.emf.resources.ResourceTreeNode;
import com.aljoschability.core.emf.resources.ResourceType;
import com.aljoschability.core.ui.CoreImages;

public class ResourceNodeLabelProvider extends LabelProvider {
	private WorkbenchLabelProvider workbenchLabelProvider;
	private RegisteredPackageLabelProvider registeredPackageLabelProvider;

	@Override
	public Image getImage(Object element) {
		// node
		if (element instanceof ResourceTreeNode) {
			ResourceTreeNode node = (ResourceTreeNode) element;

			switch (node.getType()) {
			case PLUGIN:
				return CoreImages.get(CoreImages.RESOURCES_PLUGIN);

			case FOLDER:
				return CoreImages.get(CoreImages.RESOURCES_FOLDER_OPEN);

			case PROJECT:
				return CoreImages.get(CoreImages.RESOURCES_PROJECT_OPEN);

			case REGISTRY:
				if (ResourceType.REGISTRY.equals(node.getElement())) {
					return EmfImages.get(EmfImages.RESOURCES_PACKAGES);
				}
				return EmfImages.get(EmfImages.RESOURCES_PACKAGE);

			default:
				if (node.getElement() instanceof IFile) {
					return getWorkbenchLabelProvider().getImage(node.getElement());
				} else {
					return EmfImages.get(EmfImages.FILE_ECORE);
				}
			}
		}

		return super.getImage(element);
	}

	@Override
	public String getText(Object element) {
		// node
		if (element instanceof ResourceTreeNode) {
			return getText(((ResourceTreeNode) element).getElement());
		}

		// workspace
		if (element instanceof IResource) {
			// workspace root
			if (ResourcesPlugin.getWorkspace().getRoot().equals(element)) {
				return "Workspace";
			}

			// resource
			return getText((IResource) element);
		}

		// TODO: plug-in resource
		if (ResourceType.REGISTRY.equals(element)) {
			return "Registry";
		}
		if (element instanceof EPackage) {
			return getText((EPackage) element);
		}

		return super.getText(element);
	}

	private String getText(EPackage element) {
		return getRegisteredPackageLabelProvider().getText(element);
	}

	private String getText(IResource resource) {
		return getWorkbenchLabelProvider().getText(resource);
	}

	private WorkbenchLabelProvider getWorkbenchLabelProvider() {
		if (workbenchLabelProvider == null) {
			workbenchLabelProvider = new WorkbenchLabelProvider();
		}
		return workbenchLabelProvider;
	}

	private RegisteredPackageLabelProvider getRegisteredPackageLabelProvider() {
		if (registeredPackageLabelProvider == null) {
			registeredPackageLabelProvider = new RegisteredPackageLabelProvider();
		}
		return registeredPackageLabelProvider;
	}

	@Override
	public void dispose() {
		if (workbenchLabelProvider != null) {
			workbenchLabelProvider.dispose();
			workbenchLabelProvider = null;
		}

		if (registeredPackageLabelProvider != null) {
			registeredPackageLabelProvider.dispose();
			registeredPackageLabelProvider = null;
		}

		super.dispose();
	}
}
