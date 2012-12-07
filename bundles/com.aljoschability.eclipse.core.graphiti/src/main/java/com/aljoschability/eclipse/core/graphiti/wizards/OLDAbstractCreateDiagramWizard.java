/**
 * Copyright 2012 Aljoschability. All rights reserved. This program and the accompanying materials are made available
 * under the terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *    Aljoscha Hark - initial API and implementation.
 */
package com.aljoschability.eclipse.core.graphiti.wizards;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.Collections;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;

public abstract class OLDAbstractCreateDiagramWizard extends Wizard implements INewWizard {
	private final OLDAbstractCreateDiagramResourcePage newDiagramPage;
	private final OLDAbstractCreateModelResourcePage newModelPage;
	private final OLDAbstractUseExistingModelPage useExistingModelPage;

	private ResourceSet resourceSet;
	private TransactionalEditingDomain editingDomain;

	public OLDAbstractCreateDiagramWizard() {
		setWindowTitle(getWizardTitle());
		setNeedsProgressMonitor(true);

		resourceSet = new ResourceSetImpl();

		newDiagramPage = getCreateDiagramResourcePage();
		newModelPage = getCreateModelResourcePage();
		useExistingModelPage = getUseExistingModelPage();
	}

	@Override
	public void addPages() {
		addPage(newDiagramPage);
		addPage(newModelPage);
		addPage(useExistingModelPage);
	}

	@Override
	public boolean canFinish() {
		if (newDiagramPage.isCreateNewModel()) {
			return newDiagramPage.isPageComplete() && newModelPage.isPageComplete();
		} else {
			return super.canFinish();
		}
	}

	protected abstract OLDAbstractCreateDiagramResourcePage getCreateDiagramResourcePage();

	protected abstract OLDAbstractCreateModelResourcePage getCreateModelResourcePage();

	protected abstract String getDiagramTypeId();

	@Override
	public IWizardPage getNextPage(IWizardPage page) {
		if (newDiagramPage.equals(page)) {
			if (newDiagramPage.isCreateNewModel()) {
				return newModelPage;
			} else {
				return useExistingModelPage;
			}
		}
		return null;
	}

	public ResourceSet getResourceSet() {
		return resourceSet;
	}

	protected abstract OLDAbstractUseExistingModelPage getUseExistingModelPage();

	protected abstract String getWizardTitle();

	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		for (Object selected : selection.toArray()) {
			System.out.println(selected);
		}
	}

	@Override
	public boolean performFinish() {
		try {
			getContainer().run(true, false, new IRunnableWithProgress() {
				@Override
				public void run(IProgressMonitor monitor) throws InvocationTargetException, InterruptedException {
					monitor.beginTask("Creating Class Diagram...", IProgressMonitor.UNKNOWN);
					setOrCreateEditingDomain();

					try {
						OLDCreateDiagramCommand command = new OLDCreateDiagramCommand(editingDomain);
						command.setIsCreateNewModel(newDiagramPage.isCreateNewModel());
						command.setIsInitializeContents(useExistingModelPage.isInitialize());
						if (newDiagramPage.isCreateNewModel()) {
							command.setContent(newModelPage.getContent());
						} else {
							command.setContent(useExistingModelPage.getPackage());
						}
						command.setDiagramName(newDiagramPage.getDiagramName());
						command.setDiagramTypeId(newDiagramPage.getDiagramTypeId());
						command.setDiagramTypeProviderId(newDiagramPage.getDiagramTypeProviderId());
						command.setDiagramPath(newDiagramPage.getDiagramPath());
						command.setModelPath(newModelPage.getResourcePath());

						editingDomain.getCommandStack().execute(command);

						// save model resource when newly created
						if (newDiagramPage.isCreateNewModel()) {
							Resource modelResource = command.getModelResource();
							modelResource.save(Collections.emptyMap());
						}

						// save diagram resource
						Resource diagramResource = command.getDiagramResource();
						diagramResource.save(Collections.emptyMap());

					} catch (IOException e) {
						throw new InvocationTargetException(e);
					} finally {
						monitor.done();
						editingDomain.dispose();
						editingDomain = null;
					}
				}
			});
		} catch (InvocationTargetException e) {
			e.printStackTrace();
			return false;
		} catch (InterruptedException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}

	private void setOrCreateEditingDomain() {
		editingDomain = TransactionUtil.getEditingDomain(resourceSet);
		if (editingDomain == null) {
			// Not yet existing, create one
			editingDomain = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(resourceSet);
		}
	}
}
