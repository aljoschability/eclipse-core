package com.aljoschability.eclipse.core.graphiti.util

import org.eclipse.graphiti.mm.algorithms.styles.AdaptedGradientColoredAreas
import org.eclipse.graphiti.mm.algorithms.styles.GradientColoredArea
import org.eclipse.graphiti.mm.algorithms.styles.GradientColoredAreas
import org.eclipse.graphiti.mm.algorithms.styles.LocationType
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.util.ColorUtil
import org.eclipse.graphiti.util.IGradientType
import org.eclipse.graphiti.util.IPredefinedRenderingStyle
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

class StylesExtensions {
	val static public INSTANCE = new StylesExtensions

	def setNormal(AdaptedGradientColoredAreas areas, Procedure1<GradientColoredAreas> procedure) {
		val element = createGradientColoredAreas[
			styleAdaption = IPredefinedRenderingStyle::STYLE_ADAPTATION_DEFAULT
			if (procedure != null) {
				procedure.apply(it)
			}
		]
		areas.setArea(IPredefinedRenderingStyle::STYLE_ADAPTATION_DEFAULT, element)
		return element
	}

	def setPrimarySelection(AdaptedGradientColoredAreas areas, Procedure1<GradientColoredAreas> procedure) {
		val element = createGradientColoredAreas[
			styleAdaption = IPredefinedRenderingStyle::STYLE_ADAPTATION_PRIMARY_SELECTED
			if (procedure != null) {
				procedure.apply(it)
			}
		]
		areas.setArea(IPredefinedRenderingStyle::STYLE_ADAPTATION_PRIMARY_SELECTED, element)
		return element
	}

	def setSecondarySelection(AdaptedGradientColoredAreas areas, Procedure1<GradientColoredAreas> procedure) {
		val element = createGradientColoredAreas[
			styleAdaption = IPredefinedRenderingStyle::STYLE_ADAPTATION_SECONDARY_SELECTED
			if (procedure != null) {
				procedure.apply(it)
			}
		]
		areas.setArea(IPredefinedRenderingStyle::STYLE_ADAPTATION_SECONDARY_SELECTED, element)
		return element
	}

	def setAllowedAction(AdaptedGradientColoredAreas areas, Procedure1<GradientColoredAreas> procedure) {
		val element = createGradientColoredAreas[
			styleAdaption = IPredefinedRenderingStyle::STYLE_ADAPTATION_ACTION_ALLOWED
			if (procedure != null) {
				procedure.apply(it)
			}
		]
		areas.setArea(IPredefinedRenderingStyle::STYLE_ADAPTATION_ACTION_ALLOWED, element)
		return element
	}

	def setForbiddenAction(AdaptedGradientColoredAreas areas, Procedure1<GradientColoredAreas> procedure) {
		val element = createGradientColoredAreas[
			styleAdaption = IPredefinedRenderingStyle::STYLE_ADAPTATION_ACTION_FORBIDDEN
			if (procedure != null) {
				procedure.apply(it)
			}
		]
		areas.setArea(IPredefinedRenderingStyle::STYLE_ADAPTATION_ACTION_FORBIDDEN, element)
		return element
	}

	def private void setArea(AdaptedGradientColoredAreas container, int position, GradientColoredAreas content) {
		while (container.adaptedGradientColoredAreas.size <= position) {
			container.adaptedGradientColoredAreas += StylesFactory::eINSTANCE.createGradientColoredAreas
		}
		container.adaptedGradientColoredAreas.set(position, content)
	}

	def createVerticalGradient(Procedure1<AdaptedGradientColoredAreas> procedure) {
		val element = StylesFactory::eINSTANCE.createAdaptedGradientColoredAreas
		element.gradientType = IGradientType::VERTICAL
		if (procedure != null) {
			procedure.apply(element)
		}
		return element
	}

	def setTop(GradientColoredAreas areas, String[] values) {
		areas.addSolidStop(values.get(0), LocationType::LOCATION_TYPE_ABSOLUTE_START, 0, 1)
		areas.addSolidStop(values.get(1), LocationType::LOCATION_TYPE_ABSOLUTE_START, 1, 2)
		areas.addSolidStop(values.get(2), LocationType::LOCATION_TYPE_ABSOLUTE_START, 2, 3)
	}

	def setGradient(GradientColoredAreas areas, String[] values) {
		areas.addGradient(values.get(0), values.get(1), 3, 2)
	}

	def setBottom(GradientColoredAreas areas, String value) {
		areas.addSolidStop(value, LocationType::LOCATION_TYPE_ABSOLUTE_END, 2, 0)
	}

	def addSolidStop(GradientColoredAreas areas, String color, LocationType location, int start, int end) {
		areas.gradientColor += createGradientColoredArea[
			start = createLocation(color, location, start)
			end = createLocation(color, location, end)
		]
	}

	def addGradient(GradientColoredAreas areas, String startColor, String endColor, int start, int end) {
		areas.gradientColor += createGradientColoredArea[
			start = createLocation(startColor, LocationType::LOCATION_TYPE_ABSOLUTE_START, start)
			end = createLocation(endColor, LocationType::LOCATION_TYPE_ABSOLUTE_END, end)
		]
	}

	def createLocation(String color, LocationType type, int value) {
		val element = StylesFactory::eINSTANCE.createGradientColoredLocation
		element.color = color.createColor
		element.locationType = type
		element.locationValue = value
		return element
	}

	def createColor(String hex) {
		val color = StylesFactory::eINSTANCE.createColor
		color.eSet(StylesPackage.Literals::COLOR__RED, ColorUtil::getRedFromHex(hex))
		color.eSet(StylesPackage.Literals::COLOR__GREEN, ColorUtil::getGreenFromHex(hex))
		color.eSet(StylesPackage.Literals::COLOR__BLUE, ColorUtil::getBlueFromHex(hex))
		return color
	}

	def createGradientColoredAreas(Procedure1<GradientColoredAreas> initializer) {
		val element = StylesFactory::eINSTANCE.createGradientColoredAreas
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}

	def createGradientColoredArea(Procedure1<GradientColoredArea> initializer) {
		val element = StylesFactory::eINSTANCE.createGradientColoredArea
		if (initializer != null) {
			initializer.apply(element)
		}
		return element
	}
}
