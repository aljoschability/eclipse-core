package com.aljoschability.eclipse.core.graphiti.outline.thumb

import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.graphics.ImageData
import org.eclipse.swt.graphics.RGB
import org.eclipse.draw2d.ColorConstants
import org.eclipse.swt.graphics.PaletteData
import org.eclipse.draw2d.Graphics
import org.eclipse.draw2d.geometry.Dimension

class SelectorFigure extends Figure {
	Rectangle iBounds;

	Image image;

	val Thumb thumb;

	def dispose() {
		image.dispose()
	}

	new(Thumb thumb) {
		this.thumb = thumb;

		iBounds = new Rectangle(0, 0, 1, 1);

		var Display display = Display.getCurrent();
		var PaletteData pData = new PaletteData(0xFF, 0xFF00, 0xFF0000);
		var RGB rgb = ColorConstants.menuBackgroundSelected.getRGB();
		var int fillColor = pData.getPixel(rgb);
		var ImageData iData = new ImageData(1, 1, 24, pData);
		iData.setPixel(0, 0, fillColor);
		iData.setAlpha(0, 0, 55);
		image = new Image(display, iData);
	}

	override paintFigure(Graphics g) {
		var Rectangle bounds = getBounds().getCopy();

		// Avoid drawing images that are 0 in dimension
		if(bounds.width < 5 || bounds.height < 5) {
			return;
		}

		// Don't paint the selector figure if the entire source is visible.
		var Dimension thumbnailSize = new Dimension(thumb.getThumbnailImage());

		// expand to compensate for rounding errors in calculating bounds
		var Dimension size = getSize().getExpanded(1, 1);
		if(size.contains(thumbnailSize)) {
			return;
		}

		bounds.height = bounds.height - 1
		bounds.width = bounds.width - 1

		g.drawImage(image, iBounds, bounds);

		g.setForegroundColor(ColorConstants.menuBackgroundSelected);
		g.drawRectangle(bounds);
	}
}
