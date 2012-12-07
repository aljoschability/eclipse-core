package com.aljoschability.eclipse.core.graphiti.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.WizardDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.handlers.HandlerUtil;

public abstract class AbstractOpenInitializeDiagramWizardHandler extends AbstractHandler {
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IFile file = null;

		// check selection
		ISelection selection = HandlerUtil.getCurrentSelection(event);
		if (selection instanceof IStructuredSelection) {
			for (Object selected : ((IStructuredSelection) selection).toArray()) {
				if (selected instanceof IFile) {
					file = (IFile) selected;
					break;
				}
			}
		}

		// open wizard
		Shell shell = HandlerUtil.getActiveShell(event);

		IWizard wizard = createWizard(file);
		new WizardDialog(shell, wizard).open();

		return null;
	}

	/**
	 * Should create the wizard letting the user select the model file for which a diagram should be created.
	 * 
	 * @param file The currently selected file or {@code null}.
	 * @return Returns the created wizard.
	 */
	protected abstract IWizard createWizard(IFile file);
}
