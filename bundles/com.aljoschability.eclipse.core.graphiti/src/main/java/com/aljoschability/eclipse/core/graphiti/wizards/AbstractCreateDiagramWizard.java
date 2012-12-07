package com.aljoschability.eclipse.core.graphiti.wizards;

import java.io.IOException;
import java.util.Collections;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramLink;
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory;
import org.eclipse.graphiti.services.Graphiti;

import com.aljoschability.core.emf.Activator;
import com.aljoschability.core.emf.wizards.AbstractCreateModelWizard;
import com.aljoschability.core.ui.wizards.NewFileCreationPage;

public abstract class AbstractCreateDiagramWizard extends AbstractCreateModelWizard {
	private static final String NAME_DIAGRAM = "diagram"; //$NON-NLS-1$

	private String diagramPageTitle;
	private String diagramPageDescription;
	private String diagramPageInitialName;
	private String diagramPageFileExtension;

	private NewFileCreationPage diagramPage;

	public AbstractCreateDiagramWizard(String modelPageFileExtension, String diagramPageFileExtension) {
		super(modelPageFileExtension);

		this.diagramPageFileExtension = diagramPageFileExtension;

		setWindowTitle("New Diagram");

		setModelPageInitialName("default");
		setModelPageTitle("Select Model Location");
		setModelPageDescription("Select the location for the model file.");

		setDiagramPageInitialName("default");
		setDiagramPageTitle("Select Diagram Location");
		setDiagramPageDescription("Select the location for the diagram file.");
	}

	@Override
	public boolean performFinish() {
		new Job("Creating Model And Diagram Files") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				String modelPath = getModelPath();
				String diagramPath = getDiagramPath();

				monitor.beginTask("Creating model and diagram files", IProgressMonitor.UNKNOWN);

				// add model to resource
				EObject model = createModelContent();
				URI modelUri = URI.createPlatformResourceURI(modelPath, true);
				Resource modelResource = new ResourceSetImpl().createResource(modelUri);
				modelResource.getContents().add(model);

				// add diagram to resource
				URI diagramUri = URI.createPlatformResourceURI(diagramPath, true);
				Diagram diagram = Graphiti.getPeService().createDiagram(getDiagramTypeId(), diagramUri.lastSegment(),
						true);
				Resource diagramResource = modelResource.getResourceSet().createResource(diagramUri);
				diagramResource.getContents().add(diagram);

				// create link
				PictogramLink link = PictogramsFactory.eINSTANCE.createPictogramLink();
				link.getBusinessObjects().add(model);
				link.setPictogramElement(diagram);

				// save resources
				try {
					modelResource.save(Collections.emptyMap());
					diagramResource.save(Collections.emptyMap());
				} catch (IOException e) {
					monitor.done();
					return new Status(IStatus.ERROR, Activator.get().getID(), "The model file could not be created.", e);
				}

				// open editor
				openEditor(diagramPath);

				monitor.done();
				return Status.OK_STATUS;
			}
		}.schedule();

		return true;
	}

	protected abstract String getDiagramTypeId();

	protected String getDiagramPath() {
		return diagramPage.getPath();
	}

	@Override
	public void addPages() {
		super.addPages();

		diagramPage = new NewFileCreationPage(NAME_DIAGRAM, diagramPageInitialName, diagramPageFileExtension,
				getSelection());
		diagramPage.setTitle(diagramPageTitle);
		diagramPage.setDescription(diagramPageDescription);

		addPage(diagramPage);
	}

	protected final void setDiagramPageTitle(String diagramPageTitle) {
		this.diagramPageTitle = diagramPageTitle;
	}

	protected final void setDiagramPageDescription(String diagramPageDescription) {
		this.diagramPageDescription = diagramPageDescription;
	}

	protected final void setDiagramPageInitialName(String diagramPageInitialName) {
		this.diagramPageInitialName = diagramPageInitialName;
	}
}
