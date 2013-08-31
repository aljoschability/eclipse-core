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

import com.aljoschability.core.emf.providers.ContainmentContentProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.jface.viewers.ArrayContentProvider
import org.eclipse.jface.viewers.ITreeContentProvider

class GraphitiOutlineContentProvider extends ArrayContentProvider implements ITreeContentProvider {
	ITreeContentProvider modelContentProvider

	new() {
		this(new ContainmentContentProvider)
	}

	new(ITreeContentProvider modelContentProvider) {
		this.modelContentProvider = modelContentProvider
	}

	override getElements(Object element) {
		if (element instanceof Diagram) {
			return element.link.businessObjects
		}
		super.getElements(element)
	}

	override getChildren(Object element) {
		return modelContentProvider.getChildren(element)
	}

	override getParent(Object element) {
		return modelContentProvider.getParent(element)
	}

	override hasChildren(Object element) {
		return modelContentProvider.hasChildren(element)
	}
}

class GraphitiOutlineContentContainer {
	EObject element
	EStructuralFeature feature

	new(EObject element, EStructuralFeature feature) {
		this.element = element
		this.feature = feature
	}

	def getElement() {
		element
	}

	def getFeature() {
		feature
	}
}
