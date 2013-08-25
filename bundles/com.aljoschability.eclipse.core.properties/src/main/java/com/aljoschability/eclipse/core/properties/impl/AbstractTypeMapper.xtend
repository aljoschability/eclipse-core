/*
 * Copyright 2013 Aljoschability and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * 	Aljoscha Hark <mail@aljoschability.com> - initial API and implementation
 */
package com.aljoschability.eclipse.core.properties.impl;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import org.eclipse.ui.views.properties.tabbed.ITypeMapper

public abstract class AbstractTypeMapper implements ITypeMapper {
	override final Class<?> mapType(Object element) {
		return getAdaptor().getClass(element)
	}

	protected def ElementAdaptor getAdaptor()
}
