package com.aljoschability.core.emf.resources.impl;

import java.util.Collection;
import java.util.LinkedHashSet;

import com.aljoschability.core.emf.resources.ResourceTreeNode;
import com.aljoschability.core.emf.resources.ResourceType;

public class ResourceTreeNodeImpl implements ResourceTreeNode {
	private final ResourceType type;
	private final Object element;
	private final Collection<ResourceTreeNode> children;
	private ResourceTreeNode parent;

	public ResourceTreeNodeImpl(ResourceType type) {
		this(type, type);
	}

	public ResourceTreeNodeImpl(ResourceType type, Object element) {
		this.type = type;
		this.element = element;

		children = new LinkedHashSet<>();
	}

	@Override
	public ResourceType getType() {
		return type;
	}

	@Override
	public Object getElement() {
		return element;
	}

	@Override
	public void setParent(ResourceTreeNode parent) {
		this.parent = parent;
		parent.getChildren().add(this);
	}

	@Override
	public ResourceTreeNode getParent() {
		return parent;
	}

	@Override
	public Collection<ResourceTreeNode> getChildren() {
		return children;
	}
}
