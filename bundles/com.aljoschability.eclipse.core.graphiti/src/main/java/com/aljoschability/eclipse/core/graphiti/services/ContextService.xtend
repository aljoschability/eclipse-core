package com.aljoschability.eclipse.core.graphiti.services

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.context.IPictogramElementContext
import org.eclipse.graphiti.features.context.IReconnectionContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.ILinkService

interface ContextService {
	val ContextService INSTANCE = new ContextServiceImpl

	def EObject getModel(IPictogramElementContext context)

	def EObject getModel(IReconnectionContext context)

	def EObject getStartModel(IReconnectionContext context)

	def EObject getEndModel(IReconnectionContext context)

	def EObject getNewModel(IReconnectionContext context)

	def EObject getModel(PictogramElement pe)

}

class ContextServiceImpl implements ContextService {
	extension ILinkService = Graphiti::linkService

	override getModel(IPictogramElementContext context) {
		context.pictogramElement.model
	}

	override getModel(PictogramElement pe) {
		pe.businessObjectForLinkedPictogramElement
	}

	override getModel(IReconnectionContext context) {
		context.connection.model
	}

	override getStartModel(IReconnectionContext context) {
		context.connection.start?.parent?.model
	}

	override getEndModel(IReconnectionContext context) {
		context.connection.end?.parent?.model
	}

	override getNewModel(IReconnectionContext context) {
		context.newAnchor?.parent?.model
	}
}
