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
package com.aljoschability.core.emf;

import org.eclipse.swt.graphics.Image;

class EmfImages {
	public static val String FILE_ECORE = "icons/files/ecore.png"; //$NON-NLS-1$

	public static val String RESOURCES_PACKAGE = "icons/resources/package.png"; //$NON-NLS-1$

	public static val String RESOURCES_PACKAGES = "icons/resources/packages.png"; //$NON-NLS-1$

	private new() {
	}

	def static final Image get(String key) {
		Activator::get.getImage(key)
	}
}
