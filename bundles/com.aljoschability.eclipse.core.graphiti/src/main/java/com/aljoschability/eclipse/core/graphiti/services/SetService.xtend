package com.aljoschability.eclipse.core.graphiti.services

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.algorithms.styles.AbstractStyle
import org.eclipse.graphiti.mm.algorithms.styles.AdaptedGradientColoredAreas
import org.eclipse.graphiti.mm.algorithms.styles.Color
import org.eclipse.graphiti.mm.algorithms.styles.GradientColoredArea
import org.eclipse.graphiti.mm.algorithms.styles.GradientColoredAreas
import org.eclipse.graphiti.mm.algorithms.styles.LocationType
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import org.eclipse.graphiti.util.ColorUtil
import org.eclipse.graphiti.util.IColorConstant
import org.eclipse.graphiti.util.IPredefinedRenderingStyle
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

interface SetService {
	SetService INSTANCE = new SetServiceImpl

	def void setBackground(AbstractStyle element, IColorConstant color)

	def void setBackground(AbstractStyle element, String color)

	def void setBackground(AbstractStyle element, AdaptedGradientColoredAreas background)

	def void setForeground(AbstractStyle element, IColorConstant color)

	def void setForeground(AbstractStyle element, String color)

	def void setNormal(AdaptedGradientColoredAreas element, String[] colors)

	def void setPrimarySelection(AdaptedGradientColoredAreas element, String[] colors)

	def void setSecondarySelection(AdaptedGradientColoredAreas element, String[] colors)

	def void setForbiddenAction(AdaptedGradientColoredAreas element, String[] colors)

	def void setAllowedAction(AdaptedGradientColoredAreas areas, String[] colors)
}

class SetServiceImpl implements SetService {
	extension IGaService = Graphiti::gaService
	extension IPeService = Graphiti::peService

	override setBackground(AbstractStyle element, IColorConstant value) {
		element.background = element.diagram.manageColor(value)
	}

	override setBackground(AbstractStyle element, String value) {
		element.background = element.diagram.manageColor(value)
	}

	override setBackground(AbstractStyle element, AdaptedGradientColoredAreas value) {
		element.renderingStyle = value
	}

	override setForeground(AbstractStyle element, IColorConstant value) {
		element.foreground = element.diagram.manageColor(value)
	}

	override setForeground(AbstractStyle element, String value) {
		element.foreground = element.diagram.manageColor(value)
	}

	override setNormal(AdaptedGradientColoredAreas areas, String[] values) {
		areas.setArea(values, IPredefinedRenderingStyle::STYLE_ADAPTATION_DEFAULT)
	}

	override setPrimarySelection(AdaptedGradientColoredAreas areas, String[] values) {
		areas.setArea(values, IPredefinedRenderingStyle::STYLE_ADAPTATION_PRIMARY_SELECTED)
	}

	override setSecondarySelection(AdaptedGradientColoredAreas areas, String[] values) {
		areas.setArea(values, IPredefinedRenderingStyle::STYLE_ADAPTATION_SECONDARY_SELECTED)
	}

	override setForbiddenAction(AdaptedGradientColoredAreas areas, String[] values) {
		areas.setArea(values, IPredefinedRenderingStyle::STYLE_ADAPTATION_ACTION_FORBIDDEN)
	}

	override setAllowedAction(AdaptedGradientColoredAreas areas, String[] values) {
		areas.setArea(values, IPredefinedRenderingStyle::STYLE_ADAPTATION_ACTION_ALLOWED)
	}

	def private createGradientColoredAreas(Procedure1<GradientColoredAreas> initializer) {
		val element = StylesFactory::eINSTANCE.createGradientColoredAreas
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def private createColor(String hex) {
		val color = StylesFactory::eINSTANCE.createColor
		color.eSet(StylesPackage.Literals::COLOR__RED, ColorUtil::getRedFromHex(hex))
		color.eSet(StylesPackage.Literals::COLOR__GREEN, ColorUtil::getGreenFromHex(hex))
		color.eSet(StylesPackage.Literals::COLOR__BLUE, ColorUtil::getBlueFromHex(hex))
		return color
	}

	def private createGradientColoredArea(Procedure1<GradientColoredArea> initializer) {
		val element = StylesFactory::eINSTANCE.createGradientColoredArea
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def private void setArea(AdaptedGradientColoredAreas container, String[] values, int style) {
		val element = createGradientColoredAreas[
			styleAdaption = style
			addGradient(values)
		]
		container.setArea(style, element)
	}

	def private addGradient(GradientColoredAreas areas, String[] values) {
		areas.gradientColor += createGradientColoredArea[
			start = createLocation(values.get(0), LocationType::LOCATION_TYPE_ABSOLUTE_START, 0)
			end = createLocation(values.get(1), LocationType::LOCATION_TYPE_ABSOLUTE_END, 0)
		]
	}

	def private createLocation(String color, LocationType type, int value) {
		val element = StylesFactory::eINSTANCE.createGradientColoredLocation
		element.color = color.createColor
		element.locationType = type
		element.locationValue = value
		return element
	}

	def private void setArea(AdaptedGradientColoredAreas container, int position, GradientColoredAreas content) {
		while (container.adaptedGradientColoredAreas.size <= position) {
			container.adaptedGradientColoredAreas += StylesFactory::eINSTANCE.createGradientColoredAreas
		}
		container.adaptedGradientColoredAreas.set(position, content)
	}

	def private Color manageColor(Diagram diagram, String hex) {
		val r = ColorUtil::getRedFromHex(hex)
		val g = ColorUtil::getGreenFromHex(hex)
		val b = ColorUtil::getBlueFromHex(hex)

		return diagram.manageColor(r, g, b)
	}

	def private Diagram getDiagram(EObject element) {
		var diagram = element
		while (diagram != null) {
			if (diagram instanceof Diagram) {
				return diagram
			}
			diagram = diagram.eContainer
		}
		throw new UnsupportedOperationException
	}

}
