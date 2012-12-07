package com.aljoschability.core.ui.actions;

import org.eclipse.jface.action.Action;

import com.aljoschability.core.ui.util.ViewUtil;

public class ShowPropertiesAction extends Action {
	public ShowPropertiesAction() {
		super("Show Properties");
	}

	@Override
	public void run() {
		ViewUtil.open(ViewUtil.ID_PROPERTIES);
	}
}
