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

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

final class DisplayUtil {
	def static void async(Runnable runnable) {
		get().asyncExec(runnable);
	}

	def static void sync(Runnable runnable) {
		get().syncExec(runnable);
	}

	def static Shell getShell() {
		return get().getActiveShell();
	}

	def static Display get() {
		return PlatformUI.getWorkbench().getDisplay();
	}
}
