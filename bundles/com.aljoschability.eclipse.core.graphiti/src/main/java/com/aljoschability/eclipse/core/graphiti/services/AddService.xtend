package com.aljoschability.eclipse.core.graphiti.services

import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.StyleContainer
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Rectangle
import org.eclipse.graphiti.mm.algorithms.RoundedRectangle
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.algorithms.styles.AdaptedGradientColoredAreas
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.algorithms.styles.Style
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.ChopboxAnchor
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import org.eclipse.graphiti.util.IGradientType
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection

interface AddService {
	AddService INSTANCE = new CreateServiceImpl

	def ContainerShape addContainerShape(ContainerShape container, Procedure1<ContainerShape> procedure)

	def ChopboxAnchor addChopboxAnchor(AnchorContainer container)

	def FreeFormConnection addFreeFormConnection(Diagram container, Procedure1<FreeFormConnection> procedure)

	/**
	 * Creates a new plain and empty text inside the given container.
	 * 
	 * @param container The container for the text.
	 * @param procedure The statements that should be applied to the newly create element.
 	 */
	def Text newText(GraphicsAlgorithmContainer container, Procedure1<Text> procedure)

	/**
	 * Creates a new plain rounded rectangle with default corner width and height of <code>6</code> inside the given container.
	 * 
	 * @param container The container for the text.
	 * @param procedure The statements that should be applied to the newly create element.
 	 */
	def RoundedRectangle newRoundedRectangle(GraphicsAlgorithmContainer container,
		Procedure1<RoundedRectangle> procedure)

	/**
	 * Creates a new plain rectangle inside the given container.
	 * 
	 * @param container The container for the text.
	 * @param procedure The statements that should be applied to the newly create element.
 	 */
	def Rectangle newRectangle(GraphicsAlgorithmContainer container, Procedure1<Rectangle> procedure)

	def Image newImage(GraphicsAlgorithmContainer container, Procedure1<Image> procedure)

	def Polyline newPolyline(GraphicsAlgorithmContainer container, Procedure1<Polyline> procedure)

	def Point newPoint(Polyline container, int x, int y)

	def Style newStyle(StyleContainer container, Procedure1<Style> procedure)

	def AdaptedGradientColoredAreas newGradient(Procedure1<AdaptedGradientColoredAreas> procedure)
}

final class CreateServiceImpl implements AddService {
	extension IPeService = Graphiti::peService
	extension IGaService = Graphiti::gaService

	override addFreeFormConnection(Diagram c, Procedure1<FreeFormConnection> p) {
		val element = c.createFreeFormConnection
		p?.apply(element)
		return element
	}

	override newText(GraphicsAlgorithmContainer c, Procedure1<Text> p) {
		val element = c.createPlainText
		p?.apply(element)
		return element
	}

	override addContainerShape(ContainerShape c, Procedure1<ContainerShape> p) {
		val element = c.createContainerShape(true)
		p?.apply(element)
		return element
	}

	override newRoundedRectangle(GraphicsAlgorithmContainer c, Procedure1<RoundedRectangle> p) {
		val element = c.createPlainRoundedRectangle(6, 6)
		p?.apply(element)
		return element
	}

	override newRectangle(GraphicsAlgorithmContainer c, Procedure1<Rectangle> p) {
		val element = c.createPlainRectangle
		p?.apply(element)
		return element
	}

	override newImage(GraphicsAlgorithmContainer c, Procedure1<Image> p) {
		val element = c.createImage(null)
		p?.apply(element)
		return element
	}

	override newPolyline(GraphicsAlgorithmContainer container, Procedure1<Polyline> p) {
		val element = container.createPlainPolyline
		p?.apply(element)
		return element
	}

	override newPoint(Polyline container, int x, int y) {
		val element = createPoint(x, y)
		container.points += element
		return element
	}

	override addChopboxAnchor(AnchorContainer c) {
		c.createChopboxAnchor
	}

	override newStyle(StyleContainer c, Procedure1<Style> p) {
		val element = c.createStyle(null as String)
		p?.apply(element)
		return element
	}

	override newGradient(Procedure1<AdaptedGradientColoredAreas> p) {
		val element = StylesFactory::eINSTANCE.createAdaptedGradientColoredAreas
		element.gradientType = IGradientType::VERTICAL
		p?.apply(element)
		return element
	}
}
