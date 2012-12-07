package com.aljoschability.core.emf.providers;

import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ITreeContentProvider;

import com.aljoschability.core.emf.resources.ResourceTreeNode;

public class ResourceNodeContentProvider extends ArrayContentProvider implements ITreeContentProvider {
	@Override
	public Object[] getChildren(Object element) {
		if (element instanceof ResourceTreeNode) {
			return super.getElements(((ResourceTreeNode) element).getChildren());
		}
		return new Object[0];
	}

	@Override
	public Object getParent(Object element) {
		if (element instanceof ResourceTreeNode) {
			return ((ResourceTreeNode) element).getParent();
		}
		return null;
	}

	@Override
	public boolean hasChildren(Object element) {
		return getChildren(element).length > 0;
	}
}
