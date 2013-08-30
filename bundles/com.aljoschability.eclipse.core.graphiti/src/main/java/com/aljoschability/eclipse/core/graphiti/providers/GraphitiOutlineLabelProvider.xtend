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

import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.algorithms.Ellipse
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.MultiText
import org.eclipse.graphiti.mm.algorithms.Polygon
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Rectangle
import org.eclipse.graphiti.mm.algorithms.RoundedRectangle
import org.eclipse.graphiti.mm.algorithms.styles.Color
import org.eclipse.graphiti.mm.algorithms.styles.Font
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.jface.viewers.LabelProvider

class GraphitiOutlineLabelProvider extends LabelProvider {
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
}
