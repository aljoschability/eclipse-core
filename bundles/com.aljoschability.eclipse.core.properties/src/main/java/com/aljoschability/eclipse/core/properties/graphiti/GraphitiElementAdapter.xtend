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
package com.aljoschability.eclipse.core.properties.graphiti;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.properties.ecore.EcoreElementAdaptor
import org.eclipse.gef.EditPart
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.PictogramLink
import org.eclipse.jface.viewers.IStructuredSelection

class GraphitiElementAdapter extends EcoreElementAdaptor {
	static GraphitiElementAdapter INSTANCE

	static def ElementAdaptor get() {
		if (GraphitiElementAdapter::INSTANCE == null) {
			GraphitiElementAdapter::INSTANCE = new GraphitiElementAdapter()
		}
		return GraphitiElementAdapter::INSTANCE
	}

	override getElement(Object element) {
		if (element instanceof IStructuredSelection) {
			if (element.size() == 1) {
				return getElement(element.getFirstElement())
			}
		}

		if (element instanceof EditPart) {
			return getElement(element.getModel())
		}

		if (element instanceof PictogramElement) {
			return getElement(element.getLink())
		}

		if (element instanceof PictogramLink) {
			val bos = element.getBusinessObjects()
			if (bos.size() == 1) {
				return getElement(bos.get(0))
			}
		}

		return super.getElement(element)
	}
}
