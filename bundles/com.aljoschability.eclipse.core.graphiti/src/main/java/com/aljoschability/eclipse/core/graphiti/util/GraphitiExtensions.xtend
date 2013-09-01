package com.aljoschability.eclipse.core.graphiti.util

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IPeService
import org.eclipse.graphiti.services.ILinkService

class GraphitiExtensions {
	extension IPeService = Graphiti::peService
	extension ILinkService = Graphiti::linkService

	def EObject getElement(PictogramElement pe) {
		return pe.businessObjectForLinkedPictogramElement
	}
}
