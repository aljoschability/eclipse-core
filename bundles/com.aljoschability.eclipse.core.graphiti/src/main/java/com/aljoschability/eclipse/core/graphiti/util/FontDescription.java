package com.aljoschability.eclipse.core.graphiti.util;

import java.util.LinkedHashMap;
import java.util.Map;

import org.eclipse.graphiti.mm.algorithms.styles.Font;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.services.Graphiti;

public class FontDescription {
	private static Map<String, FontDescription> cache;

	public static FontDescription make(String name, int size) {
		return make(name, size, false);
	}

	public static FontDescription make(String name, int size, boolean isBold) {
		return make(name, size, isBold, false);
	}

	public static FontDescription make(String name, int size, boolean isBold, boolean isItalic) {
		// create cache
		if (cache == null) {
			cache = new LinkedHashMap<String, FontDescription>();
		}

		// get font
		String key = getKey(name, size, isBold, isItalic);
		FontDescription font = cache.get(key);
		if (font == null) {
			// create font
			font = new FontDescription(name, size, isBold, isItalic);
			cache.put(key, font);
		}

		return font;
	}

	private static String getKey(String name, int size, boolean isBold, boolean isItalic) {
		StringBuilder builder = new StringBuilder();
		builder.append(name);
		builder.append('#');
		builder.append(size);
		builder.append('#');
		builder.append(isBold);
		builder.append('#');
		builder.append(isItalic);
		return builder.toString();
	}

	private final String name;
	private final int size;
	private final boolean isBold;
	private final boolean isItalic;

	private FontDescription(String name, int size, boolean isBold, boolean isItalic) {
		this.name = name;
		this.size = size;
		this.isBold = isBold;
		this.isItalic = isItalic;
	}

	public Font get(Diagram diagram) {
		return Graphiti.getGaService().manageFont(diagram, name, size, isItalic, isBold);
	}
}
