package com.aljoschability.eclipse.core.graphiti.editors

import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.ICreateConnectionFeature
import org.eclipse.graphiti.features.ICreateFeature
import org.eclipse.graphiti.palette.impl.ConnectionCreationToolEntry
import org.eclipse.graphiti.palette.impl.ObjectCreationToolEntry
import org.eclipse.graphiti.tb.DefaultToolBehaviorProvider

class CoreToolBehaviorProvider extends DefaultToolBehaviorProvider {
	new(IDiagramTypeProvider dtp) {
		super(dtp)
	}

	override getPalette() {
		emptyList
	}

	def static protected creationTool(ICreateConnectionFeature feature) {
		val label = feature.createName
		val description = feature.createDescription
		val iconId = feature.createImageId
		val largeIconId = feature.createLargeImageId

		val entry = new ConnectionCreationToolEntry(label, description, iconId, largeIconId)
		entry.addCreateConnectionFeature(feature)

		return entry
	}

	def static protected creationTool(ICreateFeature feature) {
		val label = feature.createName
		val description = feature.createDescription
		val iconId = feature.createImageId
		val largeIconId = feature.createLargeImageId

		return new ObjectCreationToolEntry(label, description, iconId, largeIconId, feature)
	}
}
