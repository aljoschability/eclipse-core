package com.aljoschability.core.emf.providers;

import org.eclipse.emf.ecore.EPackage;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.graphics.Image;

public class RegisteredPackageLabelProvider extends LabelProvider {
	private ComposedAdapterFactoryLabelProvider adapterFactoryLabelProvider;

	@Override
	public String getText(Object element) {
		if (element instanceof EPackage) {
			return ((EPackage) element).getNsURI();
		}
		return super.getText(element);
	}

	@Override
	public Image getImage(Object element) {
		return getLabelProvider().getImage(element);
	}

	@Override
	public void dispose() {
		if (adapterFactoryLabelProvider != null) {
			adapterFactoryLabelProvider.dispose();
			adapterFactoryLabelProvider = null;
		}

		super.dispose();
	}

	private LabelProvider getLabelProvider() {
		if (adapterFactoryLabelProvider == null) {
			adapterFactoryLabelProvider = new ComposedAdapterFactoryLabelProvider();
		}
		return adapterFactoryLabelProvider;
	}
}
