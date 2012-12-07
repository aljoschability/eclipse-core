package com.aljoschability.eclipse.core.graphiti.util;

import java.util.ArrayList;
import java.util.Collection;

import org.eclipse.core.runtime.Assert;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public class Size {
	protected int width;

	protected int height;

	public Size(int width, int height) {
		assert width >= 0;
		assert height >= 0;

		this.width = width;
		this.height = height;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();

		builder.append("Size");
		builder.append(' ');
		builder.append('(');
		builder.append(getWidth());
		builder.append(',');
		builder.append(' ');
		builder.append(getHeight());
		builder.append(')');

		return builder.toString();
	}

	public int getWidth() {
		return width;
	}

	public int getHeight() {
		return height;
	}

	public static Size asRows(Collection<Size> sizes) {
		int width = 0;
		int height = 0;

		for (Size size : sizes) {
			if (size.getWidth() > width) {
				width = size.getWidth();
			}
			height += size.getHeight();
		}

		return new Size(width, height);
	}

	public static Size asRows(Size sizeA, Size sizeB) {
		Collection<Size> sizes = new ArrayList<Size>();
		sizes.add(sizeA);
		sizes.add(sizeB);
		return asRows(sizes);
	}

	public static Size max(Size a, Size b) {
		int width = a.getWidth();
		if (width < b.getWidth()) {
			width = b.getWidth();
		}

		int height = a.getHeight();
		if (height < b.getHeight()) {
			height = b.getHeight();
		}

		return new Size(width, height);
	}

	public Size add(int width, int height) {
		int newWidth = this.width + width;
		int newHeight = this.height + height;
		return new Size(newWidth, newHeight);
	}

	public Size addHeight(int height) {
		this.height += height;
		return this;
	}

	public Size addWidth(int width) {
		this.width += width;
		return this;
	}

	public Size padding(int width, int height) {
		int newWidth = this.width + width * 2;
		int newHeight = this.height + height * 2;
		return new Size(newWidth, newHeight);
	}

	public void setHeight(int height) {
		this.height = height;
	}

	public void setWidth(int width) {
		this.width = width;
	}

	public void applyTo(PictogramElement pe) {
		Assert.isNotNull(pe);

		applyTo(pe.getGraphicsAlgorithm());
	}

	public void applyTo(GraphicsAlgorithm ga) {
		Assert.isNotNull(ga);

		ga.setWidth(width);
		ga.setHeight(height);
	}

	public boolean wider(Size size) {
		return getWidth() > size.getWidth();
	}

	public boolean sameWidth(Size size) {
		return getWidth() == size.getWidth();
	}
}
