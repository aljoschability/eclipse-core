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
package com.aljoschability.core.ui;

import com.aljoschability.core.ui.runtime.AbstractActivator;
import com.aljoschability.core.ui.runtime.IActivator;

final class Activator extends AbstractActivator {
	static IActivator INSTANCE

	def static IActivator get() {
		Activator::INSTANCE
	}

	override void initialize() {
		Activator::INSTANCE = this

		// add colors
		addColor(CoreColors.ERROR, CoreColors.VALUE_ERROR)
		addColor(CoreColors.WARNING, CoreColors.VALUE_WARNING)

		// add images
		addImage(CoreImages.CONTROL_START)
		addImage(CoreImages.CONTROL_SUSPEND)
		addImage(CoreImages.CONTROL_RESUME)
		addImage(CoreImages.CONTROL_STOP)
		addImage(CoreImages.CONTROL_REFRESH)
		addImage(CoreImages.CONTROL_VALIDATE)
		addImage(CoreImages.STATE_INFORMATION)
		addImage(CoreImages.STATE_QUESTION)
		addImage(CoreImages.STATE_WARNING)
		addImage(CoreImages.STATE_ERROR)
		addImage(CoreImages.RESOURCES_FOLDER_OPEN)
		addImage(CoreImages.RESOURCES_PLUGIN)
		addImage(CoreImages.RESOURCES_PROJECT_OPEN)
		addImage(CoreImages.VIEW_PROPERTIES)
		addImage(CoreImages.FIND)
		addImage(CoreImages.ADD)
		addImage(CoreImages.REMOVE)
		addImage(CoreImages.EDIT)
		addImage(CoreImages.UP)
		addImage(CoreImages.DOWN)
		addImage(CoreImages.COLLAPSE)
		addImage(CoreImages.COLLAPSEALL)
		addImage(CoreImages.EXPAND)
		addImage(CoreImages.EXPANDALL)
	}

	override void dispose() {
		Activator::INSTANCE = null
	}
}
