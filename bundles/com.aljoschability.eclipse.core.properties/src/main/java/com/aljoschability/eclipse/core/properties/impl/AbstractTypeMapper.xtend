package com.aljoschability.eclipse.core.properties.impl;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import org.eclipse.ui.views.properties.tabbed.ITypeMapper

public abstract class AbstractTypeMapper implements ITypeMapper {
	override final Class<?> mapType(Object element) {
		return getAdaptor().getClass(element)
	}

	protected def ElementAdaptor getAdaptor()
}
