package com.aljoschability.core.debug.providers

import com.aljoschability.core.debug.Activator
import com.aljoschability.core.debug.parts.GraphitiDebugOutlineContainer
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.algorithms.Rectangle
import org.eclipse.graphiti.mm.algorithms.styles.Color
import org.eclipse.graphiti.mm.algorithms.styles.Font
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.styles.Point

class GraphitiDebugOutlineLabelProvider extends LabelProvider {
	override getText(Object element) {
		switch element {
			GraphitiDebugOutlineContainer: {
				return element.name
			}
			Point: {
				'''Point [«element.x», «element.y»]'''
			}
			Diagram: {
				'''Diagram [«element.diagramTypeId»]'''
			}
			Rectangle: {
				'''Rectangle [«element.x», «element.y», «element.width», «element.height»]'''
			}
			ContainerShape: {
				'''Container Shape [«element.active»]'''
			}
			Color: {
				'''Color [«element.red», «element.green», «element.blue»]'''
			}
			Font: {
				'''Font [«element.name», «element.size», «element.bold», «element.italic»]'''
			}
			Image: {
				'''Image [«element.id»]'''
			}
			EObject: {
				'''«element.eClass.name»'''
			}
			default: {
				return super.getText(element)
			}
		}
	}

	override getImage(Object element) {
		switch element {
			GraphitiDebugOutlineContainer: {
				return element.image
			}
			EObject: {
				Activator::get.getImage(element.eClass.name)
			}
			default: {
				return null
			}
		}
	}
}
