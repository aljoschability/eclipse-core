package com.aljoschability.eclipse.core.graphiti.editors;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.graphiti.ui.editor.DefaultPersistencyBehavior;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;

public class CorePersistencyBehavior extends DefaultPersistencyBehavior {
	private static final String ENCODING = "UTF-8"; //$NON-NLS-1$

	public CorePersistencyBehavior(DiagramBehavior diagramBehavior) {
		super(diagramBehavior);
	}

	@Override
	protected Map<Resource, Map<?, ?>> createSaveOptions() {
		final Map<Object, Object> options = new LinkedHashMap<Object, Object>();

		// save only resources that have actually changed
		options.put(Resource.OPTION_SAVE_ONLY_IF_CHANGED, Resource.OPTION_SAVE_ONLY_IF_CHANGED_MEMORY_BUFFER);

		// set unicode encoding
		options.put(XMLResource.OPTION_ENCODING, ENCODING);

		List<Resource> resources = diagramBehavior.getEditingDomain().getResourceSet().getResources();
		final Map<Resource, Map<?, ?>> map = new LinkedHashMap<Resource, Map<?, ?>>();
		for (Resource resource : resources) {
			map.put(resource, options);
		}
		return map;
	}
}
