package com.aljoschability.eclipse.core.graphiti.editors;

import java.util.Collections;
import java.util.List;

import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.ICreateConnectionFeature;
import org.eclipse.graphiti.features.ICreateFeature;
import org.eclipse.graphiti.palette.IConnectionCreationToolEntry;
import org.eclipse.graphiti.palette.IObjectCreationToolEntry;
import org.eclipse.graphiti.palette.IPaletteCompartmentEntry;
import org.eclipse.graphiti.palette.impl.ConnectionCreationToolEntry;
import org.eclipse.graphiti.palette.impl.ObjectCreationToolEntry;
import org.eclipse.graphiti.tb.DefaultToolBehaviorProvider;

public class CoreToolBehaviorProvider extends DefaultToolBehaviorProvider {
	public CoreToolBehaviorProvider(IDiagramTypeProvider diagramTypeProvider) {
		super(diagramTypeProvider);
	}

	@Override
	public IPaletteCompartmentEntry[] getPalette() {
		List<IPaletteCompartmentEntry> entries = createPaletteEntries();
		return entries.toArray(new IPaletteCompartmentEntry[entries.size()]);
	}

	protected List<IPaletteCompartmentEntry> createPaletteEntries() {
		return Collections.emptyList();
	}

	protected IConnectionCreationToolEntry createEdgeEntry(ICreateConnectionFeature feature) {
		String label = feature.getCreateName();
		String description = feature.getCreateDescription();
		String iconId = feature.getCreateImageId();
		String largeIconId = feature.getCreateLargeImageId();

		ConnectionCreationToolEntry entry = new ConnectionCreationToolEntry(label, description, iconId, largeIconId);
		entry.addCreateConnectionFeature(feature);

		return entry;
	}

	protected IObjectCreationToolEntry createNodeEntry(ICreateFeature feature) {
		String label = feature.getCreateName();
		String description = feature.getCreateDescription();
		String iconId = feature.getCreateImageId();
		String largeIconId = feature.getCreateLargeImageId();

		return new ObjectCreationToolEntry(label, description, iconId, largeIconId, feature);
	}
}
