package com.aljoschability.eclipse.core.graphiti;

import com.aljoschability.core.ui.runtime.AbstractActivator;
import com.aljoschability.core.ui.runtime.IActivator;

final class Activator extends AbstractActivator {
	static IActivator INSTANCE

	def static IActivator get() {
		Activator::INSTANCE
	}

	override void initialize() {
		Activator::INSTANCE = this

		addImage(GraphitiImages.OUTLINE_OVERVIEW)
		addImage(GraphitiImages.OUTLINE_TREE)
		addImage(GraphitiImages.OUTLINE_MULTI)

		addImage(GraphitiImages.GA_ELLIPSE)
		addImage(GraphitiImages.GA_IMAGE)
		addImage(GraphitiImages.GA_MULTI_TEXT)
		addImage(GraphitiImages.GA_POLYGON)
		addImage(GraphitiImages.GA_POLYLINE)
		addImage(GraphitiImages.GA_RECTANGLE)
		addImage(GraphitiImages.GA_ROUNDED_RECTANGLE)
		addImage(GraphitiImages.GA_TEXT)

		addImage(GraphitiImages.PE_PICTOGRAM_LINK)
		addImage(GraphitiImages.PE_DIAGRAM)
	}

	override void dispose() {
		Activator::INSTANCE = null
	}
}
