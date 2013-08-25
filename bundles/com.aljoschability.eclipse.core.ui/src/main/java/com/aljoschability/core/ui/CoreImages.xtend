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

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;

final class CoreImages {
	public static val String CONTROL_START = "icons/control/start.png" //$NON-NLS-1$
	public static val String CONTROL_SUSPEND = "icons/control/suspend.png" //$NON-NLS-1$
	public static val String CONTROL_RESUME = "icons/control/resume.png" //$NON-NLS-1$
	public static val String CONTROL_STOP = "icons/control/stop.png" //$NON-NLS-1$
	public static val String CONTROL_REFRESH = "icons/control/refresh.png" //$NON-NLS-1$
	public static val String CONTROL_VALIDATE = "icons/control/validate.png" //$NON-NLS-1$

	public static val String STATE_INFORMATION = "icons/state/information.png" //$NON-NLS-1$
	public static val String STATE_QUESTION = "icons/state/question.png" //$NON-NLS-1$
	public static val String STATE_WARNING = "icons/state/warning.png" //$NON-NLS-1$
	public static val String STATE_ERROR = "icons/state/error.png" //$NON-NLS-1$

	public static val String RESOURCES_FOLDER_OPEN = "icons/resources/folder_open.png" //$NON-NLS-1$
	public static val String RESOURCES_PLUGIN = "icons/resources/plugin.png" //$NON-NLS-1$
	public static val String RESOURCES_PROJECT_OPEN = "icons/resources/project_open.png" //$NON-NLS-1$

	public static val String VIEW_PROPERTIES = "icons/views/properties.png" //$NON-NLS-1$

	public static val String FIND = "icons/find.png" //$NON-NLS-1$

	public static val String ADD = "icons/add.png" //$NON-NLS-1$
	public static val String REMOVE = "icons/remove.png" //$NON-NLS-1$
	public static val String EDIT = "icons/edit.png" //$NON-NLS-1$

	public static val String UP = "icons/up.png" //$NON-NLS-1$
	public static val String DOWN = "icons/down.png" //$NON-NLS-1$

	public static val String COLLAPSE = "icons/collapse.png" //$NON-NLS-1$
	public static val String COLLAPSEALL = "icons/collapseall.png" //$NON-NLS-1$

	public static val String EXPAND = "icons/expand.png" //$NON-NLS-1$
	public static val String EXPANDALL = "icons/expandall.png" //$NON-NLS-1$

	def static Image get(String key) {
		Activator::get.getImage(key)
	}

	def static ImageDescriptor getDescriptor(String key) {
		Activator::get.getImageDescriptor(key)
	}
}
