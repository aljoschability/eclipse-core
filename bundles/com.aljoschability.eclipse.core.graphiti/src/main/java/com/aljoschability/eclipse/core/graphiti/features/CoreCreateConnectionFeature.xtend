package com.aljoschability.eclipse.core.graphiti.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature

abstract class CoreCreateConnectionFeature extends AbstractCreateConnectionFeature {
	String name
	String description
	String imageId
	String largeImageId

	boolean editable

	new(IFeatureProvider fp) {
		super(fp, null, null)
	}

	def protected void setName(String name) {
		this.name = name
	}

	override getCreateDescription() {
		description
	}

	override getCreateImageId() {
		imageId
	}

	override getCreateLargeImageId() {
		largeImageId
	}

	override getCreateName() {
		name
	}

	def protected void setDescription(String description) {
		this.description = description
	}

	def protected void setImageId(String imageId) {
		this.imageId = imageId
	}

	def protected void setLargeImageId(String largeImageId) {
		this.largeImageId = largeImageId
	}

	def protected void setEditable(boolean editable) {
		this.editable = editable
	}
}
