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
package com.aljoschability.core.emf.actions;

import org.eclipse.jface.action.Action;

import com.aljoschability.core.ui.util.ViewUtil;

class ShowPropertiesAction extends Action {
	new() {
		super("Show Properties")
	}

	override run() {
		ViewUtil::open(ViewUtil::ID_PROPERTIES)
	}
}
