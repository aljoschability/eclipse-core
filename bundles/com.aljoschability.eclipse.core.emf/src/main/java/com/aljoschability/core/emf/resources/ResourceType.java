package com.aljoschability.core.emf.resources;

public enum ResourceType {
	/**
	 * This type represents a resource that comes from the workspace.
	 */
	WORKSPACE,

	/**
	 * This type represents a resource that comes from a plug-in.
	 */
	PLUGIN,

	/**
	 * This type represents a resource that comes from a plug-in.
	 */
	FOLDER,

	/**
	 * This type represents a resource that comes from the registry.
	 */
	REGISTRY, FILE, PROJECT;
}
