package com.aljoschability.eclipse.core.graphiti.features

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.ICreateFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IContext
import org.eclipse.graphiti.features.context.ICreateContext
import org.eclipse.graphiti.features.impl.AbstractFeature

abstract class CoreCreateFeature extends AbstractFeature implements ICreateFeature {
	String name
	String description
	String imageId
	String largeImageId
	boolean editable = true

	new(IFeatureProvider fp) {
		super(fp)
	}

	override canExecute(IContext context) {
		if (context instanceof ICreateContext) {
			canCreate(context)
		} else {
			false
		}
	}

	override execute(IContext context) {
		if (context instanceof ICreateContext) {
			create(context)
		}
	}

	override create(ICreateContext context) {
		val element = createElement(context)

		addGraphicalRepresentation(context, element)

		featureProvider.directEditingInfo.active = editable

		return #[element]
	}

	def protected EObject createElement(ICreateContext context)

	def protected void setEditable(boolean editable) {
		this.editable = editable
	}

	override getCreateName() {
		return name
	}

	def protected void setName(String name) {
		this.name = name
	}

	override getCreateDescription() {
		return description
	}

	def protected void setDescription(String description) {
		this.description = description
	}

	override getCreateImageId() {
		return imageId
	}

	def protected void setImageId(String imageId) {
		this.imageId = imageId
	}

	override getCreateLargeImageId() {
		return largeImageId
	}

	def protected void setLargeImageId(String largeImageId) {
		this.largeImageId = largeImageId
	}

	override getName() {
		name
	}

	override getDescription() {
		description
	}
}
