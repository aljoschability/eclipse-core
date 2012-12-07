package com.aljoschability.eclipse.core.graphiti.outline

import com.aljoschability.eclipse.core.graphiti.outline.thumb.DiagramOutlineThumbnail
import org.eclipse.draw2d.LightweightSystem
import org.eclipse.draw2d.Viewport
import org.eclipse.gef.LayerConstants
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.eclipse.swt.widgets.Canvas
import org.eclipse.swt.widgets.Composite

class GraphitiOutlineThumbnailPart extends GraphitiOutlinePage {
	Canvas canvas
	DiagramOutlineThumbnail thumbnail

	override createControl(Composite parent) {
		canvas = new Canvas(parent, SWT::DOUBLE_BUFFERED)

		var ScalableFreeformRootEditPart rootEditPart = page.getGraphicalViewer().getRootEditPart() as ScalableFreeformRootEditPart;
		thumbnail = new DiagramOutlineThumbnail(rootEditPart.getFigure() as Viewport);
		thumbnail.setSource(rootEditPart.getLayer(LayerConstants.PRINTABLE_LAYERS));

		var LightweightSystem lws = new LightweightSystem(canvas);
		lws.setContents(thumbnail);

		var root = thumbnail.parent

		root.backgroundColor = new Color(canvas.display, new RGB(255, 255, 255))
	}

	override dispose() {
		thumbnail.deactivate()

		super.dispose()
	}

	override getControl() {
		canvas
	}
}
