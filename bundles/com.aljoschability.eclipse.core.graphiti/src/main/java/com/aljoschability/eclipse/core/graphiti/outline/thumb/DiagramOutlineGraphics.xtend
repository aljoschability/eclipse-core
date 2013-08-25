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
package com.aljoschability.eclipse.core.graphiti.outline.thumb

import org.eclipse.draw2d.Graphics
import org.eclipse.draw2d.ScaledGraphics
import org.eclipse.swt.graphics.Path

class DiagramOutlineGraphics extends ScaledGraphics {
	Graphics graphics

	new(Graphics graphics) {
		super(graphics)
		this.graphics = graphics
	}

	override clipPath(Path path) {
		graphics.clipPath(path)
	}

	override drawPath(Path path) {
		graphics.drawPath(path)
	}

	override fillGradient(int x, int y, int w, int h, boolean v) {
		graphics.fillGradient(x, y, w, h, v)
	}

	override fillPath(Path path) {
		graphics.fillPath(path)
	}

	override rotate(float degrees) {
		graphics.rotate(degrees)
	}

	override setClip(Path path) {
		graphics.setClip(path)
	}

	override translate(float dx, float dy) {
		graphics.translate(Math::round(dx), Math::round(dy))
	}
}
