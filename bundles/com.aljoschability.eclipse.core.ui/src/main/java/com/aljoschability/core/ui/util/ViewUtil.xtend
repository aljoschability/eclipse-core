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
package com.aljoschability.core.ui.util;

import com.aljoschability.core.ui.Activator
import org.eclipse.ui.IEditorInput
import org.eclipse.ui.PartInitException
import org.eclipse.ui.PlatformUI

final class ViewUtil {
	val public static ID_PROPERTIES = "org.eclipse.ui.views.PropertySheet" //$NON-NLS-1$

	def static void open(String id) {
		try
			PlatformUI::workbench?.activeWorkbenchWindow?.activePage?.showView(id)
		catch(PartInitException e)
			Activator::get.error("Could not open view.", e)
	}

	def static void openEditor(IEditorInput input, String editorId) {
		DisplayUtil.async(
			[ |
				try
					PlatformUI::workbench?.activeWorkbenchWindow?.activePage?.openEditor(input, editorId)
				catch(PartInitException e)
					Activator::get.error("Could not open editor.", e)
			])
	}
}
