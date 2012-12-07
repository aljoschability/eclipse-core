package com.aljoschability.core.ui;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;

final class CoreColors {
	public static val String ERROR = CoreColors.canonicalName + ".ERROR" //$NON-NLS-1$
	public static val String WARNING = CoreColors.canonicalName + ".WARNING" //$NON-NLS-1$

	protected static val RGB VALUE_ERROR = new RGB(222, 164, 164)
	protected static val RGB VALUE_WARNING = new RGB(241, 240, 186)

	def static Color get(String key) {
		Activator.get.getColor(key)
	}
}
