package com.aljoschability.core.debug.providers

import com.aljoschability.core.debug.parts.GraphitiDebugOutlineContainer
import java.util.Collection
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.mm.algorithms.styles.Color
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.jface.viewers.ArrayContentProvider
import org.eclipse.jface.viewers.ITreeContentProvider

class GraphitiDebugOutlineContentProvider extends ArrayContentProvider implements ITreeContentProvider {
	override getElements(Object element) {
		return element.children
	}

	override getChildren(Object element) {
		switch (element) {
			GraphitiDebugOutlineContainer: {
				return element.children
			}
			Diagram: {
				val Collection<Object> children = newLinkedHashSet

				children += element.children

				children +=
					new GraphitiDebugOutlineContainer("Colors", StylesPackage.Literals::COLOR.name, element.colors)
				children +=
					new GraphitiDebugOutlineContainer("Fonts", StylesPackage.Literals::FONT.name, element.fonts)

				//children += new GraphitiDebugOutlineContainer("Connections", "", element.connections)
				//children += new GraphitiDebugOutlineContainer("Links", "", element.pictogramLinks)
				//children += new GraphitiDebugOutlineContainer("Styles", "", element.styles)
				return children
			}
			Color: {
				val Collection<Object> children = newLinkedHashSet

				val refs = EcoreUtil.UsageCrossReferencer::find(element, element.eResource)
				for (ref : refs) {
					if (ref.EObject == element) {
						println("already contained!!!")
					} else {
						children += ref.EObject
					}
				}
				return children
			}
			EObject: {
				return element.eContents
			}
		}
		if (element instanceof EObject) {
		}
		return newArrayOfSize(0)
	}

	override getParent(Object element) {
		return null
	}

	override hasChildren(Object element) {
		return !element.children.empty
	}
}
