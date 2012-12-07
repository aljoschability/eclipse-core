package com.aljoschability.eclipse.core.graphiti.util;

import org.eclipse.graphiti.datatypes.IDimension;
import org.eclipse.graphiti.mm.algorithms.styles.Font;
import org.eclipse.graphiti.ui.services.GraphitiUi;

public class CalculatorRunnable implements Runnable {
	private String text;
	private Font font;
	private int width;
	private int height;

	public CalculatorRunnable(String text, Font font) {
		this.text = text;
		this.font = font;
	}

	public int getHeight() {
		return height;
	}

	public int getWidth() {
		return width;
	}

	@Override
	public void run() {
		IDimension dimension = GraphitiUi.getUiLayoutService().calculateTextSize(text, font);

		width = dimension.getWidth();
		height = dimension.getHeight();
	}
}
