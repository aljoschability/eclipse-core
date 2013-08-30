package com.aljoschability.eclipse.core.graphiti.patterns

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.pattern.AbstractPattern
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.util.IColorConstant
import org.eclipse.graphiti.mm.PropertyContainer

abstract class CorePattern extends AbstractPattern {
	def boolean isElement(EObject element)

	override isMainBusinessObjectApplicable(Object element) {
		if (element instanceof EObject) {
			return element.isElement
		}

		return false
	}

	override protected isPatternControlled(PictogramElement pe) {
		return getBusinessObject(pe).isElement
	}

	override protected isPatternRoot(PictogramElement pe) {
		return getBusinessObject(pe).isElement
	}

	def private getBusinessObject(PictogramElement pe) {
		return Graphiti.linkService.getBusinessObjectForLinkedPictogramElement(pe)
	}

	override canAdd(IAddContext context) {
		return isMainBusinessObjectApplicable(context.newObject)
	}

	def void setLink(PictogramElement pe, Object bo) {
		link(pe, bo)
	}

	def void setBackground(GraphicsAlgorithm ga, IColorConstant color) {
		ga.background = manageColor(color)
	}

	def void setForeground(GraphicsAlgorithm ga, IColorConstant color) {
		ga.foreground = manageColor(color)
	}

	def void setName(PropertyContainer element, String name) {
		Graphiti::getPeService.setPropertyValue(element, "name", name)
	}
}
