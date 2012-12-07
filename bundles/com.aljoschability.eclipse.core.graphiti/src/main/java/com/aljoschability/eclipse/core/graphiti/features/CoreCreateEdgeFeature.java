package com.aljoschability.eclipse.core.graphiti.features;

import java.text.MessageFormat;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature;
import org.eclipse.graphiti.mm.pictograms.Connection;

public abstract class CoreCreateEdgeFeature extends AbstractCreateConnectionFeature {
	public CoreCreateEdgeFeature(IFeatureProvider fp, String name) {
		super(fp, name, MessageFormat.format("Create {0}", name));
	}

	@Override
	public boolean canCreate(ICreateConnectionContext context) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public Connection create(ICreateConnectionContext context) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean canStartConnection(ICreateConnectionContext context) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public String getCreateImageId() {
		return getEClass().getName();
	}

	protected abstract EClass getEClass();
}
