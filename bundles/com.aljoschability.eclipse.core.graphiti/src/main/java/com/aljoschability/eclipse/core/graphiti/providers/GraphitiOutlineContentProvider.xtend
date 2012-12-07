package com.aljoschability.eclipse.core.graphiti.providers

import com.aljoschability.core.emf.providers.ContainmentContentProvider
import java.util.Collection
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage
import org.eclipse.jface.viewers.ArrayContentProvider
import org.eclipse.jface.viewers.ITreeContentProvider

class GraphitiOutlineContentProvider extends ArrayContentProvider implements ITreeContentProvider {
	ITreeContentProvider modelContentProvider

	new() {
		this(new ContainmentContentProvider)
	}

	new(ITreeContentProvider modelContentProvider) {
		this.modelContentProvider = modelContentProvider
	}

	override getElements(Object e) {
		println("getElements: " + e)
		if (e instanceof Diagram) {
			var d = e

			var elements = newArrayList

			// add diagram model
			elements.addAll(d.link?.businessObjects)

			// add all diagrams
			elements.addAll(d.eResource.contents)

			return elements
		}
		super.getElements(e)
	}

	override getChildren(Object e) {
		println("getChildren: " + e)

		var contents = newArrayList

		switch e {
			Diagram: {

				// shapes
				contents.addAll(e.children)

				// colors
				contents.add(new GraphitiOutlineContentContainer(e, PictogramsPackage.Literals.DIAGRAM__COLORS))

				// fonts
				contents.add(new GraphitiOutlineContentContainer(e, PictogramsPackage.Literals.DIAGRAM__FONTS))
			}
			EObject: {
				contents.addAll(e.eContents)
			}
			GraphitiOutlineContentContainer: {
				contents.addAll(e.element.eGet(e.feature) as Collection<?>)
			}
		}

		return contents.toArray
	}

	override getParent(Object e) {
	}

	override hasChildren(Object e) {
		getChildren(e).length > 0
	}
}

class GraphitiOutlineContentContainer {
	EObject element
	EStructuralFeature feature

	new(EObject element, EStructuralFeature feature) {
		this.element = element
		this.feature = feature
	}

	def getElement() {
		element
	}

	def getFeature() {
		feature
	}
}
