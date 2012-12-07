package com.aljoschability.eclipse.core.graphiti.util;

import org.eclipse.core.runtime.Assert;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.mm.algorithms.Text;
import org.eclipse.graphiti.mm.algorithms.styles.Font;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;

import com.aljoschability.core.ui.util.DisplayUtil;

public class GraphitiUtil {
	private GraphitiUtil() {
		// hide constructor
	}

	public static EObject getBO(PictogramElement pe) {
		return Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
	}

	public static EObject getSourceBO(ICreateConnectionContext context) {
		return getBO(context.getSourcePictogramElement());
	}

	public static EObject getTargetBO(ICreateConnectionContext context) {
		return getBO(context.getTargetPictogramElement());
	}

	public static boolean unequals(String bo, Text pe) {
		Assert.isNotNull(bo);
		Assert.isNotNull(pe);

		return !bo.equals(pe.getValue());
	}

	public static boolean unequals(int bo, int pe) {
		return bo != pe;
	}

	public static int getHeight(Font font, String text) {
		return getSize(font, text).getHeight();
	}

	public static int getHeight(Text text) {
		return getSize(text).getHeight();
	}

	public static int getWidth(Text text) {
		return getSize(text).getWidth();
	}

	public static Size getSize(Text text) {
		Font font = text.getFont();
		if (font == null && text.getStyle() != null) {
			font = text.getStyle().getFont();
		}

		return getSize(font, text.getValue());
	}

	public static int getWidth(Font font, String text) {
		return getSize(font, text).getWidth();
	}

	public static Size getSize(Font font, String value) {
		return getSize(font, value, 0, 0);
	}

	public static Size getSize(Font font, String value, int paddingWidth, int paddingHeight) {
		if (font == null || value == null || value.isEmpty()) {
			return new Size(0, 0);
		}

		CalculatorRunnable runnable = new CalculatorRunnable(value, font);
		DisplayUtil.sync(runnable);

		return new Size(runnable.getWidth() + paddingWidth * 2, runnable.getHeight() + paddingHeight * 2);
	}
}
