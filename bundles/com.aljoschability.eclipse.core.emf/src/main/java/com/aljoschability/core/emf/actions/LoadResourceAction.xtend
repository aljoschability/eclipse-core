package com.aljoschability.core.emf.actions;

import com.aljoschability.core.emf.dialogs.LoadResourceDialog
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.emf.edit.domain.IEditingDomainProvider
import org.eclipse.jface.action.Action
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.PlatformUI

class LoadResourceAction extends Action {
	EditingDomain editingDomain

	new() {
		super("Load Resources...")
		description = "Load resources by their URIs"
		enabled = false
	}

	def void update() {
		enabled = editingDomain != null
	}

	def void setActiveWorkbenchPart(IWorkbenchPart part) {
		if (part instanceof IEditingDomainProvider) {
			editingDomain = part.editingDomain
		} else {
			editingDomain = null
		}
	}

	override run() {

		// create dialog
		val shell = PlatformUI::workbench.activeWorkbenchWindow.shell
		val dialog = new LoadResourceDialog(shell, editingDomain)

		// open dialog
		dialog.open()
	}
}
