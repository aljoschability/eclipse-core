package com.aljoschability.core.emf.wizards;

import java.io.IOException;
import java.text.MessageFormat;
import java.util.Collections;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.jface.dialogs.TrayDialog;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.IWizardContainer;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.part.FileEditorInput;

import com.aljoschability.core.emf.Activator;
import com.aljoschability.core.ui.util.ViewUtil;

public abstract class AbstractCreateModelWizard extends Wizard implements INewWizard {
	private static final String NAME_MODEL = "model"; //$NON-NLS-1$

	private IStructuredSelection selection;

	private String modelPageTitle;
	private String modelPageDescription;
	private String modelPageInitialName;
	private String modelPageFileExtension;

	private NewFileCreationPage modelPage;

	public AbstractCreateModelWizard(String modelPageFileExtension) {
		this.modelPageFileExtension = modelPageFileExtension;

		setNeedsProgressMonitor(false);
		setHelpAvailable(false);

		setWindowTitle("New Model");
		setModelPageInitialName("default");
	}

	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		this.selection = selection;
	}

	@Override
	public void addPages() {
		// hide help icon
		IWizardContainer container = getContainer();
		if (container instanceof TrayDialog) {
			((TrayDialog) container).setHelpAvailable(false);
		}

		// create model page
		modelPage = new NewFileCreationPage(NAME_MODEL, modelPageInitialName, modelPageFileExtension, selection);
		modelPage.setTitle(modelPageTitle);
		modelPage.setDescription(modelPageDescription);

		addPage(modelPage);
	}

	protected String getModelPath() {
		return modelPage.getPath();
	}

	@Override
	public boolean performFinish() {
		new Job("Creating Model File") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				String path = getModelPath();

				monitor.beginTask(MessageFormat.format("Creating model file {0}", path), IProgressMonitor.UNKNOWN);

				// add content to resource
				URI uri = URI.createPlatformResourceURI(path, true);
				Resource resource = new ResourceSetImpl().createResource(uri);
				resource.getContents().add(createModelContent());

				// save resources
				try {
					resource.save(Collections.emptyMap());
				} catch (IOException e) {
					monitor.done();
					return new Status(IStatus.ERROR, Activator.get().getID(), "The model file could not be created.", e);
				}

				// open editor
				openEditor(path);

				monitor.done();
				return Status.OK_STATUS;
			}
		}.schedule();

		return true;
	}

	protected void openEditor(String path) {
		String editorId = getEditorId();
		if (editorId != null) {
			IResource member = ResourcesPlugin.getWorkspace().getRoot().findMember(path);
			if (member instanceof IFile) {
				IEditorInput input = new FileEditorInput((IFile) member);
				ViewUtil.openEditor(input, editorId);
			}
		}
	}

	protected IStructuredSelection getSelection() {
		return selection;
	}

	protected void setModelPageTitle(String modelPageTitle) {
		this.modelPageTitle = modelPageTitle;
	}

	protected void setModelPageDescription(String modelPageDescription) {
		this.modelPageDescription = modelPageDescription;
	}

	protected void setModelPageInitialName(String modelPageInitialName) {
		this.modelPageInitialName = modelPageInitialName;
	}

	/**
	 * This is called after the resource has been created and should add and initialize all contents to the resource.
	 *
	 * @param resource The resource that will be created.
	 * @return
	 */
	protected abstract EObject createModelContent();

	/**
	 * Delivers the editor ID to open after wizard completion. When returning {@code null} no editor will be opened.
	 *
	 * @return Returns the editor ID or {@code null}.
	 */
	protected String getEditorId() {
		return null;
	}

}
