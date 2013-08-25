/*
 * Copyright 2013 Aljoschability and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * 	Aljoscha Hark <mail@aljoschability.com> - initial API and implementation
 */
package com.aljoschability.eclipse.core.graphiti.outline;

import com.aljoschability.core.emf.providers.ComposedAdapterFactoryLabelProvider
import com.aljoschability.core.emf.providers.ContainmentContentProvider
import com.aljoschability.eclipse.core.graphiti.GraphitiImages
import com.aljoschability.eclipse.core.graphiti.editors.CoreDiagramEditor
import com.aljoschability.eclipse.core.graphiti.outline.thumb.DiagramOutlineThumbnail
import org.eclipse.draw2d.LightweightSystem
import org.eclipse.draw2d.Viewport
import org.eclipse.emf.common.notify.Adapter
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EContentAdapter
import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.LayerConstants
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.jface.action.Action
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IToolBarManager
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.util.LocalSelectionTransfer
import org.eclipse.jface.viewers.IBaseLabelProvider
import org.eclipse.jface.viewers.IContentProvider
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.ViewerComparator
import org.eclipse.swt.SWT
import org.eclipse.swt.dnd.DND
import org.eclipse.swt.dnd.DragSourceAdapter
import org.eclipse.swt.dnd.DragSourceEvent
import org.eclipse.swt.dnd.Transfer
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Canvas
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.ui.IActionBars
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.part.IPageSite
import org.eclipse.ui.part.PageBook
import org.eclipse.ui.views.contentoutline.ContentOutlinePage

class DiagramOutlinePage extends ContentOutlinePage {
	static protected val PAGE_THUMBNAIL = 0
	static protected val PAGE_TREE = 1

	PageBook book
	Canvas thumbnailCanvas
	DiagramOutlineThumbnail thumbnail
	TreeViewer treeViewer

	Adapter modelAdapter
	Action showOutlineAction
	Action showOverviewAction

	ActionRegistry actionRegistry
	protected DiagramEditor editor

	new(CoreDiagramEditor editor) {
		this.editor = editor;

		actionRegistry = editor.getActionRegistry();

		modelAdapter = new EContentAdapter2(this)
	}

	override void createControl(Composite parent) {

		// create page book
		book = new PageBook(parent, SWT.NONE);

		// create overview canvas
		thumbnailCanvas = new Canvas(book, SWT::NONE)
		thumbnailCanvas.layoutData = GridDataFactory::fillDefaults().grab(true, true).create

		// create model tree view
		treeViewer = new TreeViewer(book, SWT::MULTI.bitwiseOr(SWT::H_SCROLL).bitwiseOr(SWT::V_SCROLL));
		treeViewer.setContentProvider(getContentProvider());
		treeViewer.setLabelProvider(getLabelProvider());
		treeViewer.setComparator(getViewerComparator());

		var Transfer[] transfers = #[LocalSelectionTransfer::getTransfer()]

		treeViewer.addDragSupport(DND::DROP_COPY.bitwiseOr(DND::DROP_MOVE).bitwiseOr(DND::DROP_LINK), transfers,
			new DragSourceAdapter2(this));

		var EObject element = getBusinessObject();
		element.eAdapters().add(modelAdapter);
		treeViewer.setInput(element);

		getSite().setSelectionProvider(treeViewer);

		book.showPage(treeViewer.getControl());
		createOutlineViewer();
	}

	def protected IContentProvider getContentProvider() {
		new ContainmentContentProvider()
	}

	def protected IBaseLabelProvider getLabelProvider() {
		new ComposedAdapterFactoryLabelProvider()
	}

	def protected ViewerComparator getViewerComparator() {
		new ViewerComparator()
	}

	override void dispose() {
		if(thumbnail != null) {
			thumbnail.deactivate()
		}
		var EObject element = getBusinessObject();
		if(element != null) {
			element.eAdapters().remove(modelAdapter);
		}

		super.dispose();
	}

	def private EObject getBusinessObject() {
		var Diagram diagram = editor.getDiagramTypeProvider().getDiagram();
		return Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(diagram);
	}

	def protected void createOutlineViewer() {

		// set the standard handlers
		// getViewer().setEditDomain(editDomain);
		// getViewer().setKeyHandler(keyHandler);
		// add a context-menu
		var ContextMenuProvider contextMenuProvider = createContextMenuProvider();
		if(contextMenuProvider != null) {
			getViewer().setContextMenu(contextMenuProvider);
		}

		// add buttons outline/overview to toolbar
		var IToolBarManager tbm = site?.actionBars?.toolBarManager
		showOutlineAction = new ShowOutlineAction(this)
		showOutlineAction.imageDescriptor = GraphitiImages.getImageDescriptor(GraphitiImages.OUTLINE_TREE);
		tbm.add(showOutlineAction);

		showOverviewAction = new ShowThumbnailAction(this)
		showOverviewAction.imageDescriptor = GraphitiImages.getImageDescriptor(GraphitiImages.OUTLINE_OVERVIEW)
		tbm.add(showOverviewAction);

		// by default show the outline-page
		showPage(PAGE_THUMBNAIL);
	}

	def private ContextMenuProvider createContextMenuProvider() {
		return null;
	}

	def protected void showPage(int id) {
		if(id == PAGE_TREE) {
			showOutlineAction.setChecked(true);
			showOverviewAction.setChecked(false);
			book.showPage(treeViewer.getControl());
		} else if(id == PAGE_THUMBNAIL) {
			if(thumbnail == null) {
				createThumbnailViewer();
			}
			showOutlineAction.setChecked(false);
			showOverviewAction.setChecked(true);
			book.showPage(thumbnailCanvas);
		}
	}

	def protected void createThumbnailViewer() {
		var ScalableFreeformRootEditPart rootEditPart = getViewer().getRootEditPart() as ScalableFreeformRootEditPart;
		thumbnail = new DiagramOutlineThumbnail(rootEditPart.getFigure() as Viewport);
		thumbnail.setSource(rootEditPart.getLayer(LayerConstants.PRINTABLE_LAYERS));

		var LightweightSystem lws = new LightweightSystem(thumbnailCanvas);
		lws.setContents(thumbnail);

		var root = thumbnail.parent

		root.backgroundColor = new Color(thumbnailCanvas.display, treeViewer.control.background.RGB)
	}

	def void refresh() {
		var EditPart contents = getViewer().getContents();
		if(contents != null) {
			contents.refresh();
		}
		if(treeViewer != null && !treeViewer.isBusy() && !treeViewer.getTree().isDisposed()) {
			treeViewer.refresh();
		}

	//		println(thumbnail.parent)
	}

	def private GraphicalViewer getViewer() {
		return editor.getGraphicalViewer();
	}

	override void init(IPageSite pageSite) {
		super.init(pageSite);
		var IActionBars actionBars = pageSite.getActionBars();
		registerGlobalActionHandler(actionBars, ActionFactory.UNDO.getId());
		registerGlobalActionHandler(actionBars, ActionFactory.REDO.getId());
		registerGlobalActionHandler(actionBars, ActionFactory.COPY.getId());
		registerGlobalActionHandler(actionBars, ActionFactory.PASTE.getId());
		registerGlobalActionHandler(actionBars, ActionFactory.PRINT.getId());
		registerGlobalActionHandler(actionBars, ActionFactory.SAVE_AS.getId());
		actionBars.updateActionBars();
	}

	def private void registerGlobalActionHandler(IActionBars actionBars, String id) {
		var IAction action = actionRegistry.getAction(id);
		if(action != null) {
			actionBars.setGlobalActionHandler(id, action);
		}
	}

	override Control getControl() {
		return book;
	}

	override setFocus() {
		book.setFocus();
	}

	override getSelection() {
		if(treeViewer == null || treeViewer.control.disposed) {
			return StructuredSelection::EMPTY
		}
		treeViewer.selection
	}
}

class EContentAdapter2 extends EContentAdapter {
	DiagramOutlinePage page

	new(DiagramOutlinePage page) {
		this.page = page
	}

	override void notifyChanged(Notification msg) {
		page.refresh()
	}
}

class ShowOutlineAction extends Action {
	DiagramOutlinePage page

	new(DiagramOutlinePage page) {
		this.page = page
	}

	override run() {
		page.showPage(DiagramOutlinePage::PAGE_TREE)
	}
}

class ShowThumbnailAction extends Action {
	DiagramOutlinePage page

	new(DiagramOutlinePage page) {
		this.page = page
	}

	override run() {
		page.showPage(DiagramOutlinePage::PAGE_THUMBNAIL)
	}
}

class DragSourceAdapter2 extends DragSourceAdapter {
	DiagramOutlinePage page

	new(DiagramOutlinePage page) {
		this.page = page
	}

	override void dragStart(DragSourceEvent event) {
		LocalSelectionTransfer.getTransfer().setSelection(page.getSelection());
	}

	override void dragFinished(DragSourceEvent event) {
		LocalSelectionTransfer.getTransfer().setSelection(null);
		page.refresh();
	}
}
