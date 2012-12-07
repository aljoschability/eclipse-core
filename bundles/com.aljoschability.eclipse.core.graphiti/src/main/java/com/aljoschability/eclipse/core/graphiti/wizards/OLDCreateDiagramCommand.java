package com.aljoschability.eclipse.core.graphiti.wizards;

import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IAddFeature;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.impl.AddContext;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramLink;
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.services.GraphitiUi;

public class OLDCreateDiagramCommand extends RecordingCommand {
	private boolean isCreateNewModel;
	private boolean isInitializeContents;
	private EObject content;
	private String diagramName;

	private Resource diagramResource;
	private Resource modelResource;
	private IPath diagramPath;
	private IPath modelPath;
	private TransactionalEditingDomain editingDomain;
	private String diagramTypeId;
	private String diagramTypeProviderId;

	public OLDCreateDiagramCommand(TransactionalEditingDomain editingDomain) {
		super(editingDomain, "Create Diagram");
		this.editingDomain = editingDomain;
	}

	@Override
	protected void doExecute() {
		// create diagram
		Diagram diagram = Graphiti.getCreateService().createDiagram(diagramTypeId, diagramName, 10, true);

		// create link
		PictogramLink link = PictogramsFactory.eINSTANCE.createPictogramLink();
		link.getBusinessObjects().add(content);
		link.setPictogramElement(diagram);

		// create diagram resource
		URI diagramUri = URI.createPlatformResourceURI(diagramPath.toString(), true);
		diagramResource = editingDomain.getResourceSet().createResource(diagramUri);
		diagramResource.getContents().add(diagram);

		// create model resource
		if (isCreateNewModel) {
			URI modelURI = URI.createPlatformResourceURI(modelPath.toString(), true);
			modelResource = editingDomain.getResourceSet().createResource(modelURI);
			modelResource.getContents().add(content);
		} else {
			modelResource = content.eResource();
		}

		// initialize contents
		if (isInitializeContents) {
			IDiagramTypeProvider dtp = GraphitiUi.getExtensionManager().createDiagramTypeProvider(diagram,
					diagramTypeProviderId);
			IFeatureProvider featureProvider = dtp.getFeatureProvider();

			// Add all classes to diagram
			int x = 20;
			int y = 20;
			for (EClassifier classifier : ((EPackage) content).getEClassifiers()) {
				if (classifier instanceof EClass) {
					// Create the context information
					AddContext addContext = new AddContext();
					addContext.setNewObject(classifier);
					addContext.setTargetContainer(diagram);
					addContext.setX(x);
					addContext.setY(y);
					x = x + 20;
					y = y + 20;

					ContainerShape classShape;
					IAddFeature addFeature = featureProvider.getAddFeature(addContext);
					if (addFeature.canAdd(addContext)) {
						classShape = (ContainerShape) addFeature.add(addContext);
						for (EAttribute attribute : ((EClass) classifier).getEAttributes()) {
							addContext = new AddContext();
							addContext.setNewObject(attribute);
							addContext.setTargetContainer(classShape);
							System.out.println(addContext);
						}
					}
				}
			}
		}
	}

	public Resource getDiagramResource() {
		return diagramResource;
	}

	public Resource getModelResource() {
		return modelResource;
	}

	public void setContent(EObject content) {
		this.content = content;
	}

	public void setDiagramName(String diagramName) {
		this.diagramName = diagramName;
	}

	public void setDiagramPath(IPath diagramPath) {
		this.diagramPath = diagramPath;
	}

	public void setDiagramTypeId(String diagramTypeId) {
		this.diagramTypeId = diagramTypeId;
	}

	public void setDiagramTypeProviderId(String diagramTypeProviderId) {
		this.diagramTypeProviderId = diagramTypeProviderId;
	}

	public void setIsCreateNewModel(boolean isCreateNewModel) {
		this.isCreateNewModel = isCreateNewModel;
	}

	public void setIsInitializeContents(boolean isInitializeContents) {
		this.isInitializeContents = isInitializeContents;
	}

	public void setModelPath(IPath modelPath) {
		this.modelPath = modelPath;
	}
}
