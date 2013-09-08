package com.aljoschability.core.debug

import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage

interface DebugImages {
	val SHAPES = PictogramsPackage::Literals::CONTAINER_SHAPE.name
	val CONNECTIONS = PictogramsPackage::Literals::CONNECTION.name
	val COLORS = StylesPackage::Literals::COLOR.name
	val FONTS = StylesPackage::Literals::FONT.name
	val STYLES = StylesPackage::Literals::STYLE.name
}
