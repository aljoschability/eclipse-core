package com.aljoschability.eclipse.core.graphiti.util

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.context.IAreaContext
import org.eclipse.graphiti.features.context.IPictogramElementContext
import org.eclipse.graphiti.features.context.ITargetContext
import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Rectangle
import org.eclipse.graphiti.mm.algorithms.RoundedRectangle
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.ILinkService
import org.eclipse.graphiti.services.IPeService
import org.eclipse.graphiti.util.IColorConstant
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.IAddConnectionContext

class GraphitiExtensions {
	val public static INSTANCE = new GraphitiExtensions

	extension IPeService = Graphiti::peService
	extension IGaService = Graphiti::gaService
	extension ILinkService = Graphiti::linkService

	protected new() {
	}

	def Anchor getSourceAnchor(IAddContext context) {
		if (context instanceof IAddConnectionContext) {
			return context.sourceAnchor
		}
	}

	def Anchor getTargetAnchor(IAddContext context) {
		if (context instanceof IAddConnectionContext) {
			return context.targetAnchor
		}
	}

	@Deprecated
	def EObject getElement(PictogramElement pe) {
		return pe.bo
	}

	def void setBackground(GraphicsAlgorithm ga, IColorConstant color) {
		ga.background = ga.diagram.manageColor(color)
	}

	def void setForeground(GraphicsAlgorithm ga, IColorConstant color) {
		ga.foreground = ga.diagram.manageColor(color)
	}

	def Diagram getDiagram(GraphicsAlgorithm ga) {
		ga.activeContainerPe.diagramForPictogramElement
	}

	def int[] position(IAreaContext context) {
		return #[context.x, context.y]
	}

	def int[] size(IAreaContext context, int minWidth, int minHeight) {
		var width = minWidth
		if (width < context.width) {
			width = context.width
		}

		var height = minHeight
		if (height < context.height) {
			height = context.height
		}

		return #[width, height]
	}

	def ContainerShape getContainer(ITargetContext context) {
		return context.targetContainer
	}

	def EObject getBo(PictogramElement pe) {
		pe.businessObjectForLinkedPictogramElement
	}

	def EObject getBo(IPictogramElementContext context) {
		context.pictogramElement.bo
	}

	def ContainerShape addContainerShape(Procedure1<ContainerShape> initializer) {
		return addContainerShape(null, initializer)
	}

	def ContainerShape addContainerShape(ContainerShape parent, Procedure1<ContainerShape> initializer) {
		val element = Graphiti::peService.createContainerShape(parent, false)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Text addText(GraphicsAlgorithmContainer parent, Procedure1<Text> initializer) {
		val element = Graphiti::gaService.createText(parent)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Polyline addPolyline(GraphicsAlgorithmContainer parent, Procedure1<Polyline> initializer) {
		val element = Graphiti::gaService.createPlainPolyline(parent)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Image addImage(GraphicsAlgorithmContainer parent, Procedure1<Image> initializer) {
		val element = Graphiti::gaService.createImage(parent, null)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def void addPoint(Polyline ga, int x, int y) {
		ga.points += Graphiti.gaService.createPoint(x, y)
	}

	def RoundedRectangle addRoundedRectangle(GraphicsAlgorithmContainer parent,
		Procedure1<RoundedRectangle> initializer) {
		val element = Graphiti::gaService.createPlainRoundedRectangle(parent, 0, 0)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Rectangle addRectangle(GraphicsAlgorithmContainer parent, Procedure1<Rectangle> initializer) {
		val element = Graphiti::gaService.createPlainRectangle(parent)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def void setParent(Shape shape, ContainerShape container) {
		shape.container = container
	}

	def void setPosition(GraphicsAlgorithm ga, int[] position) {
		ga.x = position.get(0)
		ga.y = position.get(1)
	}

	def void setSize(GraphicsAlgorithm ga, int[] size) {
		ga.width = size.get(0)
		ga.height = size.get(1)
	}

	def void setRadius(RoundedRectangle ga, int[] radius) {
		ga.cornerWidth = radius.get(0)
		ga.cornerHeight = radius.get(1)
	}

	def void setRadius(RoundedRectangle ga, int radius) {
		ga.radius = #[radius, radius]
	}
}
