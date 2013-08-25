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
package com.aljoschability.eclipse.core.properties.ecore;

import com.aljoschability.eclipse.core.properties.impl.AbstractPropertiesLabelProvider

class EcorePropertyLabelProvider extends AbstractPropertiesLabelProvider {
	override getAdaptor() {
		return EcoreElementAdaptor::get()
	}
}
