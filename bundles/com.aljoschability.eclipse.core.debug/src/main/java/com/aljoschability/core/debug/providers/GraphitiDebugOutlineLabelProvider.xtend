package com.aljoschability.core.debug.providers

import com.aljoschability.core.debug.Activator
import com.aljoschability.core.debug.parts.GraphitiDebugOutlineContainer
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.Property
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Rectangle
import org.eclipse.graphiti.mm.algorithms.styles.Color
import org.eclipse.graphiti.mm.algorithms.styles.Font
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.jface.viewers.IColorProvider
import org.eclipse.jface.viewers.IFontProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.FontData
import org.eclipse.swt.graphics.RGB
import org.eclipse.swt.widgets.Display
import org.eclipse.graphiti.mm.algorithms.styles.Style

class GraphitiDebugOutlineLabelProvider extends LabelProvider implements /*DelegatingStyledCellLabelProvider.IStyledLabelProvider, */ IColorProvider, IFontProvider {
	override getText(Object element) {
		switch element {
			GraphitiDebugOutlineContainer: {
				return element.name
			}
			Property: {
				return '''«element.key» = «element.value»'''
			}
			Polyline: {
				val text = new StringBuilder("Polyline ")
				var index = 0
				for (point : element.points) {
					text.append('''(«point.x», «point.y»)''')
					index++
					if (index < element.points.size) {
						text.append(", ")
					}
				}
				return text.toString
			}
			Point: {
				'''Point («element.x», «element.y»)'''
			}
			Diagram: {
				'''Diagram [«element.diagramTypeId»]'''
			}
			Rectangle: {
				'''Rectangle [«element.x», «element.y», «element.width», «element.height»]'''
			}
			ContainerShape: {
				'''Container Shape [«element.active»]'''
			}
			Color: {
				'''Color [«element.red», «element.green», «element.blue»]'''
			}
			Font: {
				'''Font [«element.name», «element.size», «element.bold», «element.italic»]'''
			}
			Image: {
				'''Image [«element.id»]'''
			}
			Style: '''Style "«element.id»"'''
			EObject: {
				'''«element.eClass.name»'''
			}
			default: {
				return super.getText(element)
			}
		}
	}

	override getImage(Object element) {
		switch element {
			GraphitiDebugOutlineContainer: {
				return element.image
			}
			EObject: {
				Activator::get.getImage(element.eClass.name)
			}
			default: {
				return null
			}
		}
	}

	override getBackground(Object element) {
		if (element instanceof Color) {
			val rgb = new RGB(element.red, element.green, element.blue)
			return new org.eclipse.swt.graphics.Color(Display::getCurrent, rgb)
		}

		return null
	}

	override getForeground(Object element) {
		if (element instanceof Color) {
			if (element.red + element.green + element.blue < 300) {
				return new org.eclipse.swt.graphics.Color(Display::getCurrent, 255, 255, 255)
			}
		}
		return null
	}

	override getFont(Object element) {
		if (element instanceof Font) {
			val fontData = new FontData(element.name, element.size, SWT::NORMAL)
			return new org.eclipse.swt.graphics.Font(Display::getCurrent, fontData)
		}

		return null
	}

/*	override getStyledText(Object element) {
		return new StyledString(getText(element))
	} */
}
