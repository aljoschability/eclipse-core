package com.aljoschability.eclipse.core.graphiti.pattern;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.context.IAddContext;
import org.eclipse.graphiti.features.context.IAreaContext;
import org.eclipse.graphiti.features.context.ICreateContext;
import org.eclipse.graphiti.features.context.IUpdateContext;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.Polyline;
import org.eclipse.graphiti.mm.algorithms.Text;
import org.eclipse.graphiti.mm.algorithms.styles.Font;
import org.eclipse.graphiti.mm.algorithms.styles.Point;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.pattern.AbstractPattern;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.services.IGaService;
import org.eclipse.graphiti.services.IPeService;

import com.aljoschability.eclipse.core.graphiti.util.Area;
import com.aljoschability.eclipse.core.graphiti.util.GraphitiUtil;
import com.aljoschability.eclipse.core.graphiti.util.Size;

public abstract class CorePattern extends AbstractPattern {
	protected static final IPeService PE = Graphiti.getPeService();
	protected static final IGaService GA = Graphiti.getGaService();

	protected static final String TEXT_EMPTY = ""; //$NON-NLS-1$

	protected static final String FONT_DEFAULT = "Segoe UI"; //$NON-NLS-1$
	protected static final String FONT_MONO = "Consolas"; //$NON-NLS-1$

	public CorePattern() {
		super(null);
	}

	protected static Area getArea(IAreaContext context, Size size) {
		int x = context.getX();
		int y = context.getY();
		int w = context.getWidth();
		int h = context.getHeight();

		// use middle point as coordinate
		if (w == -1 || h == -1) {
			w = size.getWidth();
			h = size.getHeight();
			x -= w / 2;
			y -= h / 2;
		}

		// use minimum width
		if (w < size.getWidth()) {
			w = size.getWidth();
		}

		// use minimum height
		if (h < size.getHeight()) {
			h = size.getHeight();
		}

		return new Area(x, y, w, h);
	}

	protected Size getSize(Text text) {
		return GraphitiUtil.getSize(text);
	}

	protected Font getFontDefault(int size) {
		return getFontDefault(size, false);
	}

	protected Font getFontDefault(int size, boolean isBold) {
		return getFontDefault(size, isBold, false);
	}

	protected Font getFontDefault(int size, boolean isBold, boolean isItalic) {
		return manageFont(FONT_DEFAULT, size, isItalic, isBold);
	}

	protected Font getFontMonospace(int size) {
		return getFontMonospace(size, false);
	}

	protected Font getFontMonospace(int size, boolean isBold) {
		return getFontMonospace(size, isBold, false);
	}

	protected Font getFontMonospace(int size, boolean isBold, boolean isItalic) {
		return manageFont(FONT_MONO, size, isItalic, isBold);
	}

	protected static boolean differs(Text text, String name) {
		if (text.getValue() != null) {
			return !text.getValue().equals(name);
		}
		if (name != null) {
			return !name.equals(text.getValue());
		}
		return true;
	}

	protected static Size getSize(GraphicsAlgorithm ga) {
		return new Size(ga.getWidth(), ga.getHeight());
	}

	protected static Size getSize(Polyline ga) {
		int minX = Integer.MAX_VALUE;
		int maxX = Integer.MIN_VALUE;
		int minY = Integer.MAX_VALUE;
		int maxY = Integer.MIN_VALUE;
		for (Point point : ga.getPoints()) {
			int x = point.getX();
			if (x > maxX) {
				maxX = x;
			}

			if (x < minX) {
				minX = x;
			}

			int y = point.getY();
			if (y > maxY) {
				maxY = y;
			}

			if (y < minY) {
				minY = y;
			}
		}

		return new Size(maxX - minX, maxY - minY);
	}

	protected abstract EClass getEClass();

	@Override
	public boolean isMainBusinessObjectApplicable(Object bo) {
		return isBO(bo);
	}

	@Override
	public boolean canAdd(IAddContext context) {
		return isBO(context.getNewObject());
	}

	@Override
	public boolean canUpdate(IUpdateContext context) {
		return isPatternControlled(context.getPictogramElement());
	}

	protected EObject createElement(ICreateContext context) {
		return null;
	}

	@Override
	public String getCreateImageId() {
		return getEClass().getInstanceTypeName();
	}

	protected abstract boolean isBO(Object bo);

	protected EObject getBO(PictogramElement pe) {
		return Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
	}

	@Override
	protected boolean isPatternControlled(PictogramElement pe) {
		return isBO(getBO(pe));
	}

	@Override
	protected boolean isPatternRoot(PictogramElement pe) {
		return isPatternControlled(pe);
	}
}
