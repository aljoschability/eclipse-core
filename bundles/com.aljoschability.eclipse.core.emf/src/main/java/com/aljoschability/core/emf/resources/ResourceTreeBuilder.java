package com.aljoschability.core.emf.resources;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;

import com.aljoschability.core.emf.resources.impl.ResourceTreeNodeImpl;

public class ResourceTreeBuilder {
	private final Collection<ResourceTreeNode> roots;
	private final Map<URI, ResourceTreeNode> nodes;

	private final ResourceTreeNode registryNode;

	private final ResourceSet resourceSet;

	public ResourceTreeBuilder(ResourceSet resourceSet) {
		roots = new LinkedHashSet<>();
		nodes = new LinkedHashMap<>();

		registryNode = new ResourceTreeNodeImpl(ResourceType.REGISTRY);

		this.resourceSet = resourceSet;
	}

	public Collection<ResourceTreeNode> build() {
		for (Resource resource : resourceSet.getResources()) {
			URI uri = resource.getURI();

			if (uri.isPlatform()) {
				createPlatformTree(uri);
			} else {
				createRegistryEntry(uri);
			}
		}

		// add registry
		if (!registryNode.getChildren().isEmpty()) {
			roots.add(registryNode);
		}

		return roots;
	}

	private void createPlatformTree(URI uri) {
		if (uri.segmentCount() > 1) {
			// nodes
			ResourceTreeNode childNode = createNode(uri);
			ResourceTreeNode currentNode = childNode;

			// folders
			URI childUri = uri;
			URI currentUri = childUri.trimSegments(1);
			while (currentUri.segmentCount() > 2) {
				// create node
				currentNode = getNode(currentUri, ResourceType.FOLDER, currentUri.lastSegment());

				// set child nodes parent
				childNode.setParent(currentNode);

				childUri = currentUri;
				currentUri = currentUri.trimSegments(1);
			}

			// plug-in
			ResourceTreeNode rootNode = createRootNode(currentUri);
			if (currentNode != null) {
				currentNode.setParent(rootNode);
			}

			roots.add(rootNode);
		}
	}

	private ResourceTreeNode createRootNode(URI uri) {
		ResourceType type = null;
		if (uri.isPlatformResource()) {
			type = ResourceType.PROJECT;
		} else if (uri.isPlatformPlugin()) {
			type = ResourceType.PLUGIN;
		}
		return getNode(uri, type, uri.lastSegment());
	}

	private ResourceTreeNode createNode(URI uri) {
		Object element = uri.lastSegment();
		if (uri.isPlatformResource()) {
			IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
			IResource file = root.findMember(uri.toPlatformString(true));
			if (file instanceof IFile) {
				element = file;
			}
		}

		return getNode(uri, ResourceType.FILE, element);
	}

	private ResourceTreeNode getNode(URI uri, ResourceType type, Object element) {
		ResourceTreeNode node = nodes.get(uri);
		if (node == null) {
			node = new ResourceTreeNodeImpl(type, element);
			nodes.put(uri, node);
		}
		return node;
	}

	private void createRegistryEntry(URI uri) {
		EPackage ePackage = EPackage.Registry.INSTANCE.getEPackage(uri.toString());

		// create node
		ResourceTreeNode node = new ResourceTreeNodeImpl(ResourceType.REGISTRY, ePackage);
		node.setParent(registryNode);
	}
}
