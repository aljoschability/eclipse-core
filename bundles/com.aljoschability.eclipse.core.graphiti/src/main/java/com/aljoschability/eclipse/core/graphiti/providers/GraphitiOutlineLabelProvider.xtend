/*
 * Copyright 2013 Aljoschability and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * 	Aljoscha Hark <mail@aljoschability.com> - initial API and implementation
 */
package com.aljoschability.eclipse.core.graphiti.providers

import com.aljoschability.eclipse.core.graphiti.GraphitiImages
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.algorithms.Ellipse
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.MultiText
import org.eclipse.graphiti.mm.algorithms.Polygon
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Rectangle
import org.eclipse.graphiti.mm.algorithms.RoundedRectangle
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.algorithms.styles.Color
import org.eclipse.graphiti.mm.algorithms.styles.Font
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramLink
import org.eclipse.jface.viewers.LabelProvider

class GraphitiOutlineLabelProvider extends LabelProvider {

	//	def dispatch String text(PictogramElement e) '''�e.eClass.name�(�e.active�, �e.visible�)'''
	//	def dispatch String text(Polyline e) '''�e.eClass.name�(�FOR p : e.points��p.x�, �p.y�; �ENDFOR�)'''
	//	def dispatch String text(PictogramLink e) '''�e.eClass.name�(�e.businessObjects.forEach[text(it)]�)'''
	override getText(Object e) {
		switch e {
			Color: '''{«e.red», «e.green», «e.blue»}'''
			Font case e.bold && e.italic: '''«e.name», «e.size», bold, italic'''
			Font case e.bold && !e.italic: '''«e.name», «e.size», bold'''
			Font case !e.bold && e.italic: '''«e.name», «e.size», italic'''
			Font case !e.bold && !e.italic: '''«e.name», «e.size»'''
			Ellipse: '''Ellipse («e.x», «e.y», «e.width», «e.height»)'''
			Image: '''Image («e.x», «e.y», «e.width», «e.height», «e.id»)'''
			MultiText: '''MultiText («e.x», «e.y», «e.width», «e.height»)'''
			Polygon: '''Polygon («FOR p : e.points»«p.x», «p.y»; «ENDFOR»)'''
			Polyline: '''Polyline («FOR p : e.points»«p.x», «p.y»; «ENDFOR»)'''
			Rectangle: '''Rectangle («e.x», «e.y», «e.width», «e.height»)'''
			RoundedRectangle: '''Rounded Rectangle («e.x», «e.y», «e.width», «e.height»)'''
			Point: '''Point («e.x», «e.y»)'''
			EObject: '''«e.eClass.name»'''
			default:
				super.getText(e)
		}
	}

	override getImage(Object element) {
		switch element {
			PictogramLink:
				GraphitiImages::getImage(GraphitiImages::PE_PICTOGRAM_LINK)
			Diagram:
				GraphitiImages::getImage(GraphitiImages::PE_DIAGRAM)
			Ellipse:
				GraphitiImages::getImage(GraphitiImages::GA_ELLIPSE)
			Image:
				GraphitiImages::getImage(GraphitiImages::GA_IMAGE)
			MultiText:
				GraphitiImages::getImage(GraphitiImages::GA_MULTI_TEXT)
			Polygon:
				GraphitiImages::getImage(GraphitiImages::GA_POLYGON)
			Polyline:
				GraphitiImages::getImage(GraphitiImages::GA_POLYLINE)
			Rectangle:
				GraphitiImages::getImage(GraphitiImages::GA_RECTANGLE)
			RoundedRectangle:
				GraphitiImages::getImage(GraphitiImages::GA_ROUNDED_RECTANGLE)
			Text:
				GraphitiImages::getImage(GraphitiImages::GA_TEXT)
			default:
				super.getImage(element)
		}
	}
}
