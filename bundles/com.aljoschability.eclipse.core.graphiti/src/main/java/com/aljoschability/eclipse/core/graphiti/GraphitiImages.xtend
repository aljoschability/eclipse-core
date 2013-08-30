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
package com.aljoschability.eclipse.core.graphiti;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;

final class GraphitiImages {
	public static val OUTLINE_OVERVIEW = "icons/outline/thumbnail.png"; //$NON-NLS-1$
	public static val OUTLINE_TREE = "icons/outline/tree.png"; //$NON-NLS-1$
	public static val OUTLINE_MULTI = "icons/outline/multi.png"; //$NON-NLS-1$

	def static Image getImage(String key) {
		Activator::get.getImage(key)
	}

	def static ImageDescriptor getImageDescriptor(String key) {
		Activator::get.getImageDescriptor(key)
	}

	private new() {
		// hide constructor
	}
}
