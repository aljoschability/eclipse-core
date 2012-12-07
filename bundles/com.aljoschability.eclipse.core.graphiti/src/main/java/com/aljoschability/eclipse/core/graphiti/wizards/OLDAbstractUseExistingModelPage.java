/**
 * Copyright 2012 Aljoschability. All rights reserved. This program and the accompanying materials are made available
 * under the terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *    Aljoscha Hark - initial API and implementation.
 */
package com.aljoschability.eclipse.core.graphiti.wizards;

import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.IContentProvider;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.ViewerComparator;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.dialogs.ElementTreeSelectionDialog;
import org.eclipse.ui.dialogs.ISelectionStatusValidator;
import org.eclipse.ui.model.BaseWorkbenchContentProvider;
import org.eclipse.ui.model.WorkbenchLabelProvider;
import org.eclipse.ui.model.WorkbenchViewerComparator;

public abstract class OLDAbstractUseExistingModelPage extends WizardPage {
	private final ElementTreeSelectionDialog fileDialog;

	private EObject pack;

	private TreeViewer packagesTreeViewer;
	private Text resourceText;

	private String fileName;

	private boolean initialize;

	public OLDAbstractUseExistingModelPage() {
		super(OLDAbstractUseExistingModelPage.class.getSimpleName());
		setTitle("Select Story Diagram Model");
		setDescription("Select the existing story diagram activity model.");
		setImageDescriptor(getImageDescriptor());

		ILabelProvider labelProvider = new WorkbenchLabelProvider();
		ITreeContentProvider contentProvider = new BaseWorkbenchContentProvider();
		fileDialog = new ElementTreeSelectionDialog(getShell(), labelProvider, contentProvider);
		fileDialog.setAllowMultiple(false);
		fileDialog.setInput(ResourcesPlugin.getWorkspace().getRoot());
		fileDialog.setMessage("Select the resource containing the model for the class diagram.");
		fileDialog.setTitle("Select The Model Resource");
		fileDialog.setDoubleClickSelects(true);
		fileDialog.setBlockOnOpen(true);
		fileDialog.setComparator(new WorkbenchViewerComparator());
		fileDialog.setValidator(new ISelectionStatusValidator() {
			@Override
			public IStatus validate(Object[] selection) {
				String message = "The selected resource seems to be okay.";
				if (selection.length == 1) {
					if (selection[0] instanceof IFile) {
						return new Status(IStatus.OK, "???", message);
					} else {
						message = "Please select a valid resource!";
						return new Status(IStatus.ERROR, "???", message);
					}
				}

				message = "Please select the resource containing the model for the story diagram.";
				return new Status(IStatus.ERROR, "???", message);
			}
		});
	}

	@Override
	public void createControl(Composite parent) {
		Composite mainComposite = new Composite(parent, SWT.NONE);
		setControl(mainComposite);
		mainComposite.setLayout(new GridLayout(1, false));

		Composite resourceComposite = new Composite(mainComposite, SWT.NONE);
		resourceComposite.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, false, 1, 1));
		resourceComposite.setLayout(new GridLayout(3, false));

		Label resourceLabel = new Label(resourceComposite, SWT.NONE);
		resourceLabel.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));

		resourceText = new Text(resourceComposite, SWT.BORDER);
		resourceText.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		resourceText.addModifyListener(new ModifyListener() {
			@Override
			public void modifyText(ModifyEvent event) {
				fileName = resourceText.getText();
				try {
					getContainer().run(true, false, new IRunnableWithProgress() {
						@Override
						public void run(IProgressMonitor monitor) throws InvocationTargetException,
								InterruptedException {
							PlatformUI.getWorkbench().getDisplay().asyncExec(new Runnable() {
								@Override
								public void run() {
									packagesTreeViewer.setInput(null);
								}
							});
							String task = String.format("Loading Resource '%1s' ...", fileName);
							monitor.beginTask(task, IProgressMonitor.UNKNOWN);
							try {
								// get workspace root
								IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();

								// find the file
								IResource file = root.findMember(fileName);
								if (file instanceof IFile) {
									// create file uri
									String path = file.getFullPath().toString();
									URI uri = URI.createPlatformResourceURI(path, true);

									// clear resource set
									getResourceSet().getResources().clear();

									// get and load the resource
									final Resource resource = getResourceSet().getResource(uri, true);

									if (resource != null) {
										PlatformUI.getWorkbench().getDisplay().asyncExec(new Runnable() {
											@Override
											public void run() {
												packagesTreeViewer.setInput(resource.getContents());
											}
										});
									}
								}
							} catch (WrappedException e) {
								throw new InvocationTargetException(e);
							} finally {
								monitor.done();
							}
						}
					});
				} catch (InvocationTargetException e) {
					String message = "The model file could not be loaded.";
					// TODO: log error
					// Activator.getInstance().error(e.getCause(), message);
					setErrorMessage(String.format(message, fileName));
					packagesTreeViewer.setInput(null);
				} catch (InterruptedException e) {
					String message = "The loading of the file has been terminated by the user.";
					// TODO: log error
					// Activator.getInstance().info(message);
					setErrorMessage(message);
					packagesTreeViewer.setInput(null);
				}

				setPageComplete(isValid());
			}
		});

		final Button resourceButton = new Button(resourceComposite, SWT.PUSH);
		resourceButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				IResource selected = ResourcesPlugin.getWorkspace().getRoot().findMember(fileName);
				fileDialog.setInitialSelection(selected);
				if (fileDialog.open() == IStatus.OK) {
					Object result = fileDialog.getFirstResult();
					if (result instanceof IFile) {
						resourceText.setText(((IFile) result).getFullPath().toString());
					}
				}
			}
		});

		Group activitiesGroup = new Group(mainComposite, SWT.NONE);
		activitiesGroup.setLayout(new GridLayout(1, false));
		activitiesGroup.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 0, 0));

		packagesTreeViewer = new TreeViewer(activitiesGroup, SWT.BORDER);
		packagesTreeViewer.setContentProvider(getContentProvider());
		packagesTreeViewer.setLabelProvider(getLabelProvider());
		packagesTreeViewer.setComparator(new ViewerComparator());
		ViewerFilter filter = getFilter();
		if (filter != null) {
			packagesTreeViewer.addFilter(filter);
		}
		packagesTreeViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				ISelection selection = packagesTreeViewer.getSelection();
				if (!selection.isEmpty()) {
					Object selected = ((IStructuredSelection) selection).getFirstElement();
					if (selected instanceof EObject) {
						pack = (EObject) selected;
					}
				}
				setPageComplete(isValid());
			}
		});

		Tree activitiesTree = packagesTreeViewer.getTree();
		activitiesTree.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 1, 1));

		final Button initializeButton = new Button(mainComposite, SWT.CHECK);
		initializeButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				initialize = initializeButton.getSelection();
			}
		});

		// initialization
		resourceLabel.setText("Model Resource:");
		resourceText.setText("default.ecore");
		resourceButton.setText("Select");
		activitiesGroup.setText("Contained Activities");
		initializeButton.setText("Initialize All Components");
		initializeButton.setSelection(true);

		setControl(mainComposite);
	}

	protected abstract IContentProvider getContentProvider();

	protected ViewerFilter getFilter() {
		return null;
	}

	protected abstract ImageDescriptor getImageDescriptor();

	protected abstract IBaseLabelProvider getLabelProvider();

	public EObject getPackage() {
		return pack;
	}

	private ResourceSet getResourceSet() {
		return ((OLDAbstractCreateDiagramWizard) getWizard()).getResourceSet();
	}

	public boolean isInitialize() {
		return initialize;
	}

	private boolean isValid() {
		if (packagesTreeViewer.getTree().getItems().length < 1) {
			setErrorMessage("No package found in the selected resource!");
			packagesTreeViewer.getTree().setEnabled(false);
			return false;
		}

		if (pack == null) {
			setErrorMessage("Select the package!");
			packagesTreeViewer.getTree().setEnabled(true);
			return false;
		}

		packagesTreeViewer.getTree().setEnabled(true);
		setErrorMessage(null);
		return true;
	}
}
