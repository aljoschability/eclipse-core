package com.aljoschability.eclipse.core.graphiti.features;

import java.text.MessageFormat;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IAreaContext;
import org.eclipse.graphiti.features.context.ICreateContext;
import org.eclipse.graphiti.features.context.impl.AddContext;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;

public abstract class CoreCreateNodeFeature extends AbstractCreateFeature {
	public CoreCreateNodeFeature(IFeatureProvider fp, String name) {
		super(fp, name, MessageFormat.format("Create {0}", name));
	}

	protected EObject getBO(PictogramElement pe) {
		return Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
	}

	@Override
	public Object[] create(ICreateContext context) {
		EObject element = createElement(context);

		IAreaContext addContext = new AddContext(context, element);

		addGraphicalRepresentation(addContext, element);

		getFeatureProvider().getDirectEditingInfo().setActive(isDirectEditingActive());

		return new Object[] { element };
	}

	protected boolean isDirectEditingActive() {
		return true;
	}

	@Override
	public String getCreateImageId() {
		return getEClass().getName();
	}

	protected abstract EClass getEClass();

	protected abstract EObject createElement(ICreateContext context);
}
