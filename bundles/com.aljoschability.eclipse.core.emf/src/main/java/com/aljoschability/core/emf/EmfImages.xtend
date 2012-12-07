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
