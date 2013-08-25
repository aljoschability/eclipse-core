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
package com.aljoschability.core.emf

import com.aljoschability.core.ui.runtime.AbstractActivator
import com.aljoschability.core.ui.runtime.IActivator

final class Activator extends AbstractActivator {
	var static IActivator INSTANCE;

	def static final IActivator get() {
		Activator::INSTANCE
	}

	override final void initialize() {
		Activator::INSTANCE = this

		addImage(EmfImages::FILE_ECORE)
		addImage(EmfImages::RESOURCES_PACKAGE)
		addImage(EmfImages::RESOURCES_PACKAGES)
	}

	override final void dispose() {
		Activator::INSTANCE = null
	}
}
