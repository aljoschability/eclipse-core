package com.aljoschability.core.emf.actions;

import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.emf.edit.domain.IEditingDomainProvider;
import org.eclipse.jface.action.Action;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;

import com.aljoschability.core.emf.dialogs.LoadResourceDialog;

public class LoadResourceAction extends Action {
	private EditingDomain editingDomain;

	public LoadResourceAction() {
		super("Load Resources...");
		setDescription("Load resources by their URIs");
		setEnabled(false);
	}

	public void update() {
		setEnabled(editingDomain != null);
	}

	public void setActiveWorkbenchPart(IWorkbenchPart part) {
		if (part instanceof IEditingDomainProvider) {
			editingDomain = ((IEditingDomainProvider) part).getEditingDomain();
		} else {
			editingDomain = null;
		}
	}

	@Override
	public void run() {
		// create dialog
		Shell shell = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
		LoadResourceDialog dialog = new LoadResourceDialog(shell, editingDomain);

		// open dialog
		dialog.open();
	}
}
