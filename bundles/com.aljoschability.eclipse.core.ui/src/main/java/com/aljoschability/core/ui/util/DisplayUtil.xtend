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
