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
