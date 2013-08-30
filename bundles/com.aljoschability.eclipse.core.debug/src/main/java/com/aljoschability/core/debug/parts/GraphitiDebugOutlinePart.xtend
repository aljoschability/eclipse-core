package com.aljoschability.core.debug.parts

import com.aljoschability.core.debug.Activator
import com.aljoschability.core.debug.providers.GraphitiDebugOutlineContentProvider
import com.aljoschability.core.debug.providers.GraphitiDebugOutlineLabelProvider
import java.util.Collection
import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import javax.inject.Inject
import javax.inject.Named
import org.eclipse.e4.core.di.annotations.Optional
import org.eclipse.e4.ui.services.IServiceConstants
import org.eclipse.gef.EditPart
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Tree

class GraphitiDebugOutlinePart {
	Diagram diagram

	TreeViewer viewer

	@PostConstruct def postConstruct(Composite parent) {
		val tree = new Tree(parent, SWT::SINGLE)
		tree.layoutData = GridDataFactory::fillDefaults.grab(true, true).create

		viewer = new TreeViewer(tree)

		//viewer.autoExpandLevel = TreeViewer::ALL_LEVELS
		viewer.contentProvider = new GraphitiDebugOutlineContentProvider
		viewer.labelProvider = new GraphitiDebugOutlineLabelProvider
		viewer.input = diagram
	}

	@PreDestroy def preDestroy() {
	}

	@Inject
	def void handleSelection(@Optional @Named(IServiceConstants.ACTIVE_SELECTION) IStructuredSelection selection) {
		val oldDiagram = diagram
		diagram = null

		if (selection != null && !selection.empty) {
			for (element : selection.toArray) {
				if (element instanceof EditPart) {
					val model = element.model
					if (model instanceof PictogramElement) {
						val newDiagram = Graphiti::getPeService.getDiagramForPictogramElement(model)
						if (newDiagram != null) {
							diagram = newDiagram
						}
					}
				}
			}
		}

		if (oldDiagram != diagram) {
			if (viewer != null && !viewer.control.disposed) {
				viewer.input = diagram
			}
		}
	}
}

class GraphitiDebugOutlineContainer {
	val String name
	val String imageId
	val Collection<?> children

	new(String name, String imageId, Collection<?> children) {
		this.name = name
		this.imageId = imageId
		this.children = children
	}

	def getName() {
		return name
	}

	def getImage() {
		return Activator.get.getImage(imageId)
	}

	def getChildren() {
		return children
	}
}
