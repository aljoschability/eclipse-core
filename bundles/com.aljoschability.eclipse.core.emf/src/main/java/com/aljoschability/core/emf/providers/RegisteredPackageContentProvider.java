package com.aljoschability.core.emf.providers;

import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ITreeContentProvider;

public class RegisteredPackageContentProvider extends ArrayContentProvider implements ITreeContentProvider {
	@Override
	public Object[] getChildren(Object element) {
		return new Object[0];
	}

	@Override
	public Object getParent(Object element) {
		return null;
	}

	@Override
	public boolean hasChildren(Object element) {
		return false;
	}
}
