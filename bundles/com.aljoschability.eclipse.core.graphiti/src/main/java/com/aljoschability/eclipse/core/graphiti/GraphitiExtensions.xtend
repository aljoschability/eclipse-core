package com.aljoschability.eclipse.core.graphiti

import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.RoundedRectangle
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.mm.algorithms.Rectangle

interface GraphitiExtensionsInitializer<T> {
	def void apply(T t)
}

class GraphitiExtensions {
	def ContainerShape addContainerShape(GraphitiExtensionsInitializer<ContainerShape> initializer) {
		return addContainerShape(null, initializer)
	}

	def ContainerShape addContainerShape(ContainerShape parent,
		GraphitiExtensionsInitializer<ContainerShape> initializer) {
		val element = Graphiti::peService.createContainerShape(parent, false)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Text addText(GraphicsAlgorithmContainer parent, GraphitiExtensionsInitializer<Text> initializer) {
		val element = Graphiti::gaService.createText(parent)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Polyline addPolyline(GraphicsAlgorithmContainer parent, GraphitiExtensionsInitializer<Polyline> initializer) {
		val element = Graphiti::gaService.createPlainPolyline(parent)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Image addImage(GraphicsAlgorithmContainer parent, GraphitiExtensionsInitializer<Image> initializer) {
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
		GraphitiExtensionsInitializer<RoundedRectangle> initializer) {
		val element = Graphiti::gaService.createPlainRoundedRectangle(parent, 0, 0)
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def Rectangle addRectangle(GraphicsAlgorithmContainer parent,
		GraphitiExtensionsInitializer<Rectangle> initializer) {
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
