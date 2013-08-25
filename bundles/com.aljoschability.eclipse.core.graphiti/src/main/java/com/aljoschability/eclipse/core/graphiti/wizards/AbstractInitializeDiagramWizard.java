package com.aljoschability.eclipse.core.graphiti.wizards;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.dialogs.TrayDialog;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.wizard.IWizardContainer;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.dialogs.WizardNewFileCreationPage;

import com.aljoschability.core.emf.wizards.ExistingFileSelectionPage;

public abstract class AbstractInitializeDiagramWizard extends Wizard {
	private IFile file;

	private String modelPageTitle;
	private String modelPageDescription;
	private String diagramPageTitle;
	private String diagramPageDescription;

	private ExistingFileSelectionPage modelPage;
	private WizardNewFileCreationPage diagramPage;

	public AbstractInitializeDiagramWizard(IFile file) {
		this.file = file;

		setHelpAvailable(false);
		setNeedsProgressMonitor(false);

		setWindowTitle("Initialize Diagram");
		setModelPageTitle("Select Model Resource");
		setModelPageDescription("Select the resource containing the model.");
		setDiagramPageTitle("Select Diagram Resource");
		setDiagramPageDescription("Select the diagram resource that should be created.");
	}

	protected void setModelPageTitle(String modelPageTitle) {
		this.modelPageTitle = modelPageTitle;
	}

	protected void setModelPageDescription(String modelPageDescription) {
		this.modelPageDescription = modelPageDescription;
	}

	protected void setDiagramPageTitle(String diagramPageTitle) {
		this.diagramPageTitle = diagramPageTitle;
	}

	protected void setDiagramPageDescription(String diagramPageDescription) {
		this.diagramPageDescription = diagramPageDescription;
	}

	@Override
	public void addPages() {
		// hide help icon
		IWizardContainer container = getContainer();
		if (container instanceof TrayDialog) {
			((TrayDialog) container).setHelpAvailable(false);
		}

		// add page to select the model file
		if (file == null || !getModelFileExtension().equals(file.getFileExtension())) {
			modelPage = new ExistingFileSelectionPage("model", getModelFileExtension(), StructuredSelection.EMPTY);
			addPage(modelPage);

			modelPage.setTitle(modelPageTitle);
			modelPage.setDescription(modelPageDescription);
		}

		// add page to select the diagram resource
		IStructuredSelection selection;
		if (file == null) {
			selection = StructuredSelection.EMPTY;
		} else {
			selection = new StructuredSelection(file.getParent());
		}
		diagramPage = new WizardNewFileCreationPage("diagram", selection);
		diagramPage.setFileExtension(getDiagramFileExtension());
		addPage(diagramPage);

		diagramPage.setTitle(diagramPageTitle);
		diagramPage.setDescription(diagramPageDescription);
	}

	protected abstract String getModelFileExtension();

	protected abstract String getDiagramFileExtension();

	@Override
	public boolean performFinish() {
		String modelPath;
		if (modelPage != null) {
			modelPath = modelPage.getFile().getFullPath().toPortableString();
		} else {
			modelPath = file.getFullPath().toPortableString();
		}

		String diagramPath = diagramPage.getContainerFullPath().append(diagramPage.getFileName()).toPortableString();

		System.out.println(modelPath);
		System.out.println(diagramPath);

		return false;
	}

}
