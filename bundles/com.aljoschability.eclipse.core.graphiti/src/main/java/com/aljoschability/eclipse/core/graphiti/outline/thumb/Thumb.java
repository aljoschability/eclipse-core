package com.aljoschability.eclipse.core.graphiti.outline.thumb;

import org.eclipse.draw2d.geometry.Point;
import org.eclipse.swt.graphics.Image;

public interface Thumb {

	double getViewportScaleX();

	double getViewportScaleY();

	void setViewLocation(Point p);

	Point getViewLocation();

	Image getThumbnailImage();
}
