package com.aljoschability.eclipse.core.graphiti.util;

public class Location {
	protected int x;
	protected int y;

	public Location(int x, int y) {
		this.x = x;
		this.y = y;
	}

	@Override
	public boolean equals(Object object) {
		if (object instanceof Location) {
			Location other = (Location) object;
			return x == other.x && y == other.y;
		}
		return super.equals(object);
	}

	public int getX() {
		return x;
	}

	public int getY() {
		return y;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + x;
		result = prime * result + y;
		return result;
	}

	public void setX(int x) {
		this.x = x;
	}

	public void setY(int y) {
		this.y = y;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();

		builder.append(getClass().getSimpleName());
		builder.append(' ');
		builder.append('(');
		builder.append(x);
		builder.append(',');
		builder.append(' ');
		builder.append(y);
		builder.append(')');

		return builder.toString();
	}
}
