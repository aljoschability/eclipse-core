package com.aljoschability.core.emf.resources;

import java.util.Collection;

public interface ResourceTreeNode {
	ResourceType getType();

	Object getElement();

	ResourceTreeNode getParent();

	void setParent(ResourceTreeNode parent);

	Collection<ResourceTreeNode> getChildren();
}
