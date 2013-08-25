package com.aljoschability.core.ui.actions;

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
