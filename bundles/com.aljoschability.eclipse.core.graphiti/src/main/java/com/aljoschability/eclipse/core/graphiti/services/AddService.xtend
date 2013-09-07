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
	AddService INSTANCE = new AddServiceImpl

	/**
	 * Creates an initially <strong>active</strong> container shape on the given container.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def ContainerShape addContainerShape(ContainerShape container, Procedure1<ContainerShape> procedure)

	/**
	 * Creates a free-form connection on the given diagram.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def FreeFormConnection addFreeFormConnection(Diagram container, Procedure1<FreeFormConnection> procedure)

	/**
	 * Creates a chopbox anchor on the given container.
	 * 
	 * @param container The container for the element.
 	 */
	def ChopboxAnchor addChopboxAnchor(AnchorContainer container)

	/**
	 * Creates a new plain rectangle inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def Rectangle addRectangle(GraphicsAlgorithmContainer container, Procedure1<Rectangle> procedure)

	/**
	 * Creates a new plain rounded rectangle with default corner width and height of <code>6</code> inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def RoundedRectangle addRoundedRectangle(GraphicsAlgorithmContainer container,
		Procedure1<RoundedRectangle> procedure)

	/**
	 * Creates a new plain and empty text inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def Text addText(GraphicsAlgorithmContainer container, Procedure1<Text> procedure)

	/**
	 * Creates a new image inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param id The id of the image.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def Image addImage(GraphicsAlgorithmContainer container, String id, Procedure1<Image> procedure)

	/**
	 * Creates a new plain polyline inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def Polyline addPolyline(GraphicsAlgorithmContainer container, Procedure1<Polyline> procedure)

	/**
	 * Creates a new point inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param x The horizontal coordinate for the point.
	 * @param y The vertical coordinate for the point.
 	 */
	def Point addPoint(Polyline container, int x, int y)

	/**
	 * Creates a new style inside the given container.
	 * 
	 * @param container The container for the element.
	 * @param procedure The statements that should be applied to the newly created element.
 	 */
	def Style addStyle(StyleContainer container, Procedure1<Style> procedure)

	def AdaptedGradientColoredAreas newGradient(Procedure1<AdaptedGradientColoredAreas> procedure)
}

package final class AddServiceImpl implements AddService {
	extension IPeService = Graphiti::peService
	extension IGaService = Graphiti::gaService

	override addFreeFormConnection(Diagram c, Procedure1<FreeFormConnection> p) {
		val element = c.createFreeFormConnection
		p?.apply(element)
		return element
	}

	override addText(GraphicsAlgorithmContainer c, Procedure1<Text> p) {
		val element = c.createPlainText
		p?.apply(element)
		return element
	}

	override addContainerShape(ContainerShape c, Procedure1<ContainerShape> p) {
		val element = c.createContainerShape(true)
		p?.apply(element)
		return element
	}

	override addRoundedRectangle(GraphicsAlgorithmContainer c, Procedure1<RoundedRectangle> p) {
		val element = c.createPlainRoundedRectangle(6, 6)
		p?.apply(element)
		return element
	}

	override addRectangle(GraphicsAlgorithmContainer c, Procedure1<Rectangle> p) {
		val element = c.createPlainRectangle
		p?.apply(element)
		return element
	}

	override addImage(GraphicsAlgorithmContainer c, String id, Procedure1<Image> p) {
		val element = c.createImage(id)
		p?.apply(element)
		return element
	}

	override addPolyline(GraphicsAlgorithmContainer container, Procedure1<Polyline> p) {
		val element = container.createPlainPolyline
		p?.apply(element)
		return element
	}

	override addPoint(Polyline container, int x, int y) {
		val element = createPoint(x, y)
		container.points += element
		return element
	}

	override addChopboxAnchor(AnchorContainer c) {
		c.createChopboxAnchor
	}

	override addStyle(StyleContainer c, Procedure1<Style> p) {
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
