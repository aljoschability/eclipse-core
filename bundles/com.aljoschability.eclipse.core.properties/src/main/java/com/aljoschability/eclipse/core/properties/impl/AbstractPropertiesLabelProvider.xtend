package com.aljoschability.eclipse.core.properties.impl;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import org.eclipse.emf.edit.provider.ComposedAdapterFactory
import org.eclipse.emf.edit.provider.ComposedAdapterFactory.Descriptor.Registry
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.jface.viewers.LabelProvider

abstract class AbstractPropertiesLabelProvider extends LabelProvider {
	ComposedAdapterFactory af
	AdapterFactoryLabelProvider aflp

	new() {
		af = new ComposedAdapterFactory(Registry::INSTANCE)
		aflp = new AdapterFactoryLabelProvider(af)
	}

	override getText(Object element) {
		return aflp.getText(getAdaptor().getElement(element));
	}

	override getImage(Object element) {
		return aflp.getImage(getAdaptor().getElement(element));
	}

	override dispose() {
		if (aflp != null) {
			aflp.dispose();
			aflp = null;
		}

		if (af != null) {
			af.dispose();
			af = null;
		}

		super.dispose();
	}

	protected def ElementAdaptor getAdaptor()
}
