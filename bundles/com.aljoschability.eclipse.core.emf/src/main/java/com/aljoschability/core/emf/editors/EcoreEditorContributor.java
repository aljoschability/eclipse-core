package com.aljoschability.core.emf.editors;

import java.util.ArrayList;
import java.util.Collection;

import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.emf.edit.domain.IEditingDomainProvider;
import org.eclipse.emf.edit.ui.action.CopyAction;
import org.eclipse.emf.edit.ui.action.CreateChildAction;
import org.eclipse.emf.edit.ui.action.CreateSiblingAction;
import org.eclipse.emf.edit.ui.action.CutAction;
import org.eclipse.emf.edit.ui.action.DeleteAction;
import org.eclipse.emf.edit.ui.action.PasteAction;
import org.eclipse.emf.edit.ui.action.RedoAction;
import org.eclipse.emf.edit.ui.action.UndoAction;
import org.eclipse.emf.edit.ui.action.ValidateAction;
import org.eclipse.emf.edit.ui.provider.DiagnosticDecorator;
import org.eclipse.emf.edit.ui.provider.DiagnosticDecorator.LiveValidator.LiveValidationAction;
import org.eclipse.jface.action.ActionContributionItem;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IContributionItem;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IPropertyListener;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.IWorkbenchActionConstants;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.actions.ActionFactory;
import org.eclipse.ui.part.EditorActionBarContributor;
import org.eclipse.ui.part.IPageBookViewPage;
import org.eclipse.ui.views.properties.IPropertySheetPage;

import com.aljoschability.core.emf.Activator;
import com.aljoschability.core.emf.actions.LoadResourceAction;
import com.aljoschability.core.emf.actions.RefreshAction;
import com.aljoschability.core.emf.actions.ShowPropertiesAction;
import com.aljoschability.core.ui.CoreImages;

public class EcoreEditorContributor extends EditorActionBarContributor implements IMenuListener, IPropertyListener,
		ISelectionChangedListener {
	private static final String ID_CREATE_CHILD = "create-child"; //$NON-NLS-1$
	private static final String ID_CREATE_SIBLING = "create-sibling"; //$NON-NLS-1$

	private IEditorPart editorPart;
	private ISelectionProvider selectionProvider;

	private Collection<IAction> createChildActions;
	private Collection<IAction> createSiblingActions;

	private UndoAction undoAction;
	private RedoAction redoAction;

	private CutAction cutAction;
	private CopyAction copyAction;
	private PasteAction pasteAction;

	private DeleteAction deleteAction;

	private RefreshAction refreshAction;
	private LiveValidationAction liveValidationAction;
	private ValidateAction validateAction;

	private ShowPropertiesAction showPropertiesAction;

	private LoadResourceAction loadResourceAction;

	private void activate() {
		editorPart.addPropertyListener(this);

		undoAction.setActiveWorkbenchPart(editorPart);
		redoAction.setActiveWorkbenchPart(editorPart);

		cutAction.setActiveWorkbenchPart(editorPart);
		copyAction.setActiveWorkbenchPart(editorPart);
		pasteAction.setActiveWorkbenchPart(editorPart);

		deleteAction.setActiveWorkbenchPart(editorPart);

		refreshAction.setActiveWorkbenchPart(editorPart);
		validateAction.setActiveWorkbenchPart(editorPart);
		liveValidationAction.setActiveWorkbenchPart(editorPart);

		loadResourceAction.setActiveWorkbenchPart(editorPart);

		ISelectionProvider selectionProvider = getSelectionProvider();

		if (selectionProvider != null) {
			selectionProvider.addSelectionChangedListener(cutAction);
			selectionProvider.addSelectionChangedListener(copyAction);
			selectionProvider.addSelectionChangedListener(pasteAction);

			selectionProvider.addSelectionChangedListener(deleteAction);

			selectionProvider.addSelectionChangedListener(validateAction);
		}

		propertyChanged(null, 0);
	}

	private void deactivate() {
		editorPart.removePropertyListener(this);

		undoAction.setActiveWorkbenchPart(null);
		redoAction.setActiveWorkbenchPart(null);

		cutAction.setActiveWorkbenchPart(null);
		copyAction.setActiveWorkbenchPart(null);
		pasteAction.setActiveWorkbenchPart(null);

		deleteAction.setActiveWorkbenchPart(null);

		validateAction.setActiveWorkbenchPart(null);
		liveValidationAction.setActiveWorkbenchPart(null);

		loadResourceAction.setActiveWorkbenchPart(null);

		ISelectionProvider selectionProvider = getSelectionProvider();

		if (selectionProvider != null) {
			selectionProvider.removeSelectionChangedListener(cutAction);
			selectionProvider.removeSelectionChangedListener(copyAction);
			selectionProvider.removeSelectionChangedListener(pasteAction);

			selectionProvider.removeSelectionChangedListener(deleteAction);

			selectionProvider.removeSelectionChangedListener(validateAction);
		}
	}

	private Collection<IAction> generateAddActions(Collection<?> descriptors, ISelection selection, boolean isChild) {
		Collection<IAction> actions = new ArrayList<IAction>();
		if (descriptors != null) {
			for (Object descriptor : descriptors) {
				if (isChild) {
					actions.add(new CreateChildAction(editorPart, selection, descriptor));
				} else {
					actions.add(new CreateSiblingAction(editorPart, selection, descriptor));
				}
			}
		}
		return actions;
	}

	@Override
	public void init(IActionBars actionBars) {
		super.init(actionBars);

		ISharedImages sharedImages = PlatformUI.getWorkbench().getSharedImages();

		undoAction = new UndoAction();
		undoAction.setImageDescriptor(sharedImages.getImageDescriptor(ISharedImages.IMG_TOOL_UNDO));
		actionBars.setGlobalActionHandler(ActionFactory.UNDO.getId(), undoAction);

		redoAction = new RedoAction();
		redoAction.setImageDescriptor(sharedImages.getImageDescriptor(ISharedImages.IMG_TOOL_REDO));
		actionBars.setGlobalActionHandler(ActionFactory.REDO.getId(), redoAction);

		cutAction = new CutAction();
		cutAction.setText("Cut@Ctrl+X");
		cutAction.setImageDescriptor(sharedImages.getImageDescriptor(ISharedImages.IMG_TOOL_CUT));
		actionBars.setGlobalActionHandler(ActionFactory.CUT.getId(), cutAction);

		copyAction = new CopyAction();
		copyAction.setText("Copy@Ctrl+C");
		copyAction.setImageDescriptor(sharedImages.getImageDescriptor(ISharedImages.IMG_TOOL_COPY));
		actionBars.setGlobalActionHandler(ActionFactory.COPY.getId(), copyAction);

		pasteAction = new PasteAction();
		pasteAction.setText("Paste@Ctrl+V");
		pasteAction.setImageDescriptor(sharedImages.getImageDescriptor(ISharedImages.IMG_TOOL_PASTE));
		actionBars.setGlobalActionHandler(ActionFactory.PASTE.getId(), pasteAction);

		deleteAction = new DeleteAction(true);
		deleteAction.setText("Delete@Delete");
		deleteAction.setImageDescriptor(sharedImages.getImageDescriptor(ISharedImages.IMG_TOOL_DELETE));
		actionBars.setGlobalActionHandler(ActionFactory.DELETE.getId(), deleteAction);

		refreshAction = new RefreshAction();
		refreshAction.setImageDescriptor(CoreImages.getDescriptor(CoreImages.CONTROL_REFRESH));
		actionBars.setGlobalActionHandler(ActionFactory.REFRESH.getId(), refreshAction);

		validateAction = new ValidateAction();
		validateAction.setImageDescriptor(CoreImages.getDescriptor(CoreImages.CONTROL_VALIDATE));

		liveValidationAction = new DiagnosticDecorator.LiveValidator.LiveValidationAction(Activator.get()
				.getDialogSettings());

		showPropertiesAction = new ShowPropertiesAction();
		showPropertiesAction.setImageDescriptor(CoreImages.getDescriptor(CoreImages.VIEW_PROPERTIES));

		loadResourceAction = new LoadResourceAction();
		loadResourceAction.setImageDescriptor(CoreImages.getDescriptor(CoreImages.FIND));
	}

	@Override
	public void menuAboutToShow(IMenuManager manager) {
		// toggle states
		refreshAction.setEnabled(refreshAction.isEnabled());

		// create child menu
		manager.add(createAddMenu(true));

		// create sibling menu
		manager.add(createAddMenu(false));

		manager.add(new Separator());
		manager.add(new ActionContributionItem(undoAction));
		manager.add(new ActionContributionItem(redoAction));

		manager.add(new Separator());
		manager.add(new ActionContributionItem(cutAction));
		manager.add(new ActionContributionItem(copyAction));
		manager.add(new ActionContributionItem(pasteAction));

		manager.add(new Separator());
		manager.add(new ActionContributionItem(deleteAction));

		manager.add(new Separator());
		manager.add(new ActionContributionItem(refreshAction));
		manager.add(new ActionContributionItem(validateAction));
		manager.add(new ActionContributionItem(liveValidationAction));

		manager.add(new Separator());
		manager.add(new ActionContributionItem(showPropertiesAction));

		manager.add(new Separator());
		manager.add(new ActionContributionItem(loadResourceAction));

		manager.add(new Separator(IWorkbenchActionConstants.MB_ADDITIONS));
	}

	private IContributionItem createAddMenu(boolean isChildMenu) {
		ImageDescriptor descriptor = CoreImages.getDescriptor(CoreImages.ADD);

		if (isChildMenu) {
			MenuManager menu = new MenuManager("Create Child", descriptor, ID_CREATE_CHILD);
			for (IAction action : createChildActions) {
				menu.add(action);
			}
			return menu;
		} else {
			MenuManager menu = new MenuManager("Create Sibling", descriptor, ID_CREATE_SIBLING);
			for (IAction action : createSiblingActions) {
				menu.add(action);
			}
			return menu;
		}
	}

	@Override
	public void propertyChanged(Object source, int id) {
		IStructuredSelection selection = getSelection();

		undoAction.update();
		redoAction.update();

		deleteAction.updateSelection(selection);
		cutAction.updateSelection(selection);
		copyAction.updateSelection(selection);
		pasteAction.updateSelection(selection);

		validateAction.updateSelection(selection);

		loadResourceAction.update();
		liveValidationAction.update();
	}

	private IStructuredSelection getSelection() {
		// get provider
		ISelectionProvider provider = getSelectionProvider();

		// extract selection
		if (provider != null) {
			ISelection selection = provider.getSelection();
			if (selection instanceof IStructuredSelection) {
				return (IStructuredSelection) selection;
			}
		}

		return StructuredSelection.EMPTY;
	}

	private ISelectionProvider getSelectionProvider() {
		if (editorPart instanceof ISelectionProvider) {
			return (ISelectionProvider) editorPart;
		} else {
			return editorPart.getEditorSite().getSelectionProvider();
		}
	}

	@Override
	public void selectionChanged(SelectionChangedEvent event) {
		// Query the new selection for appropriate new child/sibling descriptors
		Collection<?> newChildDescriptors = null;
		Collection<?> newSiblingDescriptors = null;

		ISelection selection = event.getSelection();
		if (selection instanceof IStructuredSelection && ((IStructuredSelection) selection).size() == 1) {
			Object object = ((IStructuredSelection) selection).getFirstElement();

			EditingDomain domain = ((IEditingDomainProvider) editorPart).getEditingDomain();

			newChildDescriptors = domain.getNewChildDescriptors(object, null);
			newSiblingDescriptors = domain.getNewChildDescriptors(null, object);
		}

		// Generate actions for selection; populate and redraw the menus.
		createChildActions = generateAddActions(newChildDescriptors, selection, true);
		createSiblingActions = generateAddActions(newSiblingDescriptors, selection, false);
	}

	@Override
	public void setActiveEditor(IEditorPart part) {
		if (part != editorPart) {
			if (editorPart != null) {
				deactivate();
			}

			if (part instanceof IEditingDomainProvider) {
				editorPart = part;
				activate();
			}
		}
		editorPart = part;

		// Switch to the new selection provider.
		if (selectionProvider != null) {
			selectionProvider.removeSelectionChangedListener(this);
		}
		if (part == null) {
			selectionProvider = null;
		} else {
			selectionProvider = part.getSite().getSelectionProvider();
			selectionProvider.addSelectionChangedListener(this);

			// Fake a selection changed event to update the menus.
			if (selectionProvider.getSelection() != null) {
				selectionChanged(new SelectionChangedEvent(selectionProvider, selectionProvider.getSelection()));
			}
		}
	}

	public void shareGlobalActions(IPageBookViewPage page, IActionBars actionBars) {
		if (!(page instanceof IPropertySheetPage)) {
			actionBars.setGlobalActionHandler(ActionFactory.DELETE.getId(), deleteAction);
			actionBars.setGlobalActionHandler(ActionFactory.CUT.getId(), cutAction);
			actionBars.setGlobalActionHandler(ActionFactory.COPY.getId(), copyAction);
			actionBars.setGlobalActionHandler(ActionFactory.PASTE.getId(), pasteAction);
		}
		actionBars.setGlobalActionHandler(ActionFactory.UNDO.getId(), undoAction);
		actionBars.setGlobalActionHandler(ActionFactory.REDO.getId(), redoAction);
	}
}
