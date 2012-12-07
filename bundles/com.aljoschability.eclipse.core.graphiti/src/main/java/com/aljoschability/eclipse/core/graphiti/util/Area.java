package com.aljoschability.eclipse.core.graphiti.util;

import org.eclipse.core.runtime.Assert;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public class Area extends Location {
	public static enum Position {
		LEFT, TOP, RIGHT, BOTTOM, SAME;
	}

	protected int height;

	protected int width;

	public Area(int x, int y, int width, int height) {
		super(x, y);

		assert width >= 0;
		assert height >= 0;

		this.width = width;
		this.height = height;
	}

	public static Area fromPE(PictogramElement pe) {
		assert pe != null;
		return fromGA(pe.getGraphicsAlgorithm());
	}

	public static Area fromGA(GraphicsAlgorithm ga) {
		assert ga != null;
		return new Area(ga.getX(), ga.getY(), ga.getWidth(), ga.getHeight());
	}

	public void applyTo(PictogramElement pe) {
		Assert.isNotNull(pe);

		applyTo(pe.getGraphicsAlgorithm());
	}

	public void applyTo(GraphicsAlgorithm ga) {
		Assert.isNotNull(ga);

		ga.setX(x);
		ga.setY(y);
		ga.setWidth(width);
		ga.setHeight(height);
	}

	/**
	 * Checks whether the first Area contains the second.
	 * 
	 * @param a The outer area.
	 * @param b The inner area.
	 * @return Returns <code>true</code> when the outer area contains the inner.
	 */
	public static boolean contains(Area outer, Area inner) {
		Assert.isNotNull(outer);
		Assert.isNotNull(inner);
		return outer.x <= inner.x && outer.y <= inner.y && outer.x + outer.width >= inner.x + inner.width
				&& outer.y + outer.height >= inner.y + inner.height;
	}

	public static boolean intersects(Area a, Area b) {
		// TODO: implement
		throw new RuntimeException();
	}

	public static Area merge(Area a, Area b) {
		if (a == null) {
			return b;
		}

		if (b == null) {
			return a;
		}

		int x = Math.min(a.x, b.x);
		int y = Math.min(a.y, b.y);

		int width = Math.max(a.x + a.width, b.x + b.width) - x;
		int height = Math.max(a.y + a.height, b.y + b.height) - y;

		return new Area(x, y, width, height);
	}

	public boolean contains(Area other) {
		return Area.contains(this, other);
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = super.hashCode();
		result = prime * result + x;
		result = prime * result + y;
		result = prime * result + width;
		result = prime * result + height;
		return result;
	}

	@Override
	public boolean equals(Object object) {
		if (object instanceof Area) {
			Area other = (Area) object;
			return x == other.x && y == other.y && width == other.width && height == other.height;
		}
		return super.equals(object);
	}

	public int getHeight() {
		return height;
	}

	public int getWidth() {
		return width;
	}

	public boolean intersects(Area other) {
		return Area.intersects(this, other);
	}

	public Area merge(Area other) {
		return Area.merge(this, other);
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();

		builder.append(getClass().getSimpleName());
		builder.append('(');
		builder.append(x);
		builder.append(',');
		builder.append(' ');
		builder.append(y);
		builder.append(';');
		builder.append(' ');
		builder.append(width);
		builder.append(',');
		builder.append(' ');
		builder.append(height);
		builder.append(')');

		return builder.toString();
	}

	public Area snapTo(Area other) {
		return Area.snapTo(this, other);
	}

	public boolean leftTo(Area other) {
		Assert.isNotNull(other);

		return (x + width / 2) < (other.x + other.width / 2);
	}

	public boolean rightTo(Area other) {
		Assert.isNotNull(other);

		return (x + width / 2) > (other.x + other.width / 2);
	}

	public boolean topTo(Area other) {
		Assert.isNotNull(other);

		return (y + height / 2) < (other.y + other.height / 2);
	}

	public boolean bottomTo(Area other) {
		Assert.isNotNull(other);

		return (y + height / 2) > (other.y + other.height / 2);
	}

	/**
	 * @param moving The area which is moving.
	 * @param still The area to which the other will snap.
	 */
	public static Area snapTo(Area moving, Area still) {
		Assert.isNotNull(moving);
		Assert.isNotNull(still);

		int x = moving.x;
		int y = moving.y;
		int w = moving.width;
		int h = moving.height;

		switch (Area.getPosition(moving, still)) {
		case LEFT:
			x = still.x - moving.width;

			if (moving.y < still.y) {
				// outside to top
				y = still.y;
			} else if ((moving.y + moving.height) > (still.y + still.height)) {
				// outside to bottom
				y = still.y + still.height - moving.height;
			}

			return new Area(x, y, w, h);
		case TOP:
			y = still.y - moving.height;

			if (moving.x < still.x) {
				// outside to left
				x = still.x;
			} else if ((moving.x + moving.width) > (still.x + still.width)) {
				// outside to right
				x = still.x + still.width - moving.width;
			}

			return new Area(x, y, w, h);
		case RIGHT:
			x = still.x + still.width;

			if (moving.y < still.y) {
				// outside to top
				y = still.y;
			} else if ((moving.y + moving.height) > (still.y + still.height)) {
				// outside to bottom
				y = still.y + still.height - moving.height;
			}

			return new Area(x, y, w, h);
		case BOTTOM:
			y = still.y + still.height;

			if (moving.x < still.x) {
				// outside to left
				x = still.x;
			} else if ((moving.x + moving.width) > (still.x + still.width)) {
				// outside to right
				x = still.x + still.width - moving.width;
			}

			return new Area(x, y, w, h);
		default:
		case SAME:
			System.out.println("same");
			return null;
		}
	}

	/**
	 * @param a The area which is moving.
	 * @param b The area to which the other will snap.
	 */
	public static Position getPosition(Area a, Area b) {
		Assert.isNotNull(a);
		Assert.isNotNull(b);

		int aMidX = a.x + a.width / 2;
		int aMidY = a.y + a.height / 2;

		int bMidX = b.x + b.width / 2;
		int bMidY = b.y + b.height / 2;

		int diffX = aMidX - bMidX;
		int diffY = aMidY - bMidY;

		if (Math.abs(diffX) > Math.abs(diffY)) {
			if (diffX > 0) {
				return Position.RIGHT;
			} else {
				return Position.LEFT;
			}
		} else if (Math.abs(diffY) > Math.abs(diffX)) {
			if (diffY > 0) {
				return Position.BOTTOM;
			} else {
				return Position.TOP;
			}
		}

		return Position.SAME;
	}
}
