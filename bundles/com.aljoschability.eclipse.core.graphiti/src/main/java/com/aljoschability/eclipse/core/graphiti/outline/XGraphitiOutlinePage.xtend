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
package com.aljoschability.eclipse.core.graphiti.outline

import org.eclipse.core.runtime.IAdaptable
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.actions.GEFActionConstants
import org.eclipse.jface.action.IAction
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Canvas
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.part.IPageSite
import org.eclipse.ui.part.Page
import org.eclipse.ui.part.PageBook
import org.eclipse.ui.views.contentoutline.IContentOutlinePage

class XGraphitiOutlinePage extends Page implements IContentOutlinePage, ISelectionChangedListener {
	val ACTION_IDS = #{
		"export_diagram_action", //SaveImageAction
		"predefined remove action", //RemoveAction
		"predefined update action", //UpdateAction
		"toggle_context_button_pad", //ToggleContextButtonPadAction
		ActionFactory::UNDO.id,
		ActionFactory::REDO.id,
		ActionFactory::CUT.id,
		ActionFactory::COPY.id,
		ActionFactory::PASTE.id,
		ActionFactory::PRINT.id,
		ActionFactory::SAVE.id,
		ActionFactory::SAVE_AS.id,
		ActionFactory::SELECT_ALL.id,
		ActionFactory::DELETE.id,
		ActionFactory.EXPORT.id,
		GEFActionConstants::ALIGN_LEFT,
		GEFActionConstants::ALIGN_CENTER,
		GEFActionConstants::ALIGN_RIGHT,
		GEFActionConstants::ALIGN_TOP,
		GEFActionConstants::ALIGN_MIDDLE,
		GEFActionConstants::ALIGN_BOTTOM,
		GEFActionConstants::MATCH_WIDTH,
		GEFActionConstants::MATCH_HEIGHT,
		GEFActionConstants::ZOOM_IN,
		GEFActionConstants::ZOOM_OUT,
		GEFActionConstants.TOGGLE_GRID_VISIBILITY,
		GEFActionConstants.TOGGLE_SNAP_TO_GEOMETRY,
		GEFActionConstants.ZOOM_TOOLBAR_WIDGET
	}

	GraphicalViewer graphicalViewer
	ActionRegistry actionRegistry

	PageBook book
	TreeViewer treeViewer
	Canvas thumbnailCanvas

	new(IAdaptable adaptable) {
		graphicalViewer = adaptable.getAdapter(GraphicalViewer) as GraphicalViewer
		actionRegistry = adaptable.getAdapter(ActionRegistry) as ActionRegistry
	}

	override createControl(Composite parent) {
		book = new PageBook(parent, SWT::NONE)

		// create overview canvas
		thumbnailCanvas = new Canvas(book, SWT::NONE)
		thumbnailCanvas.layoutData = GridDataFactory::fillDefaults().grab(true, true).create

	}

	override getControl() {
		book
	}

	override setFocus() {
		if(hasTreeViewer) {
			treeViewer.control.setFocus
		}
	}

	override init(IPageSite site) {
		super.init(site)

		site.selectionProvider = this

		// register global action
		ACTION_IDS.forEach [
			val IAction action = actionRegistry.getAction(it)
			if (action != null) {
				site.actionBars.setGlobalActionHandler(it, action)
			}
		]

		// update action bars
		site.actionBars.updateActionBars
	}

	def private hasTreeViewer() {
		treeViewer != null && !treeViewer.control.disposed
	}

	override selectionChanged(SelectionChangedEvent event) {
		val nevent = new SelectionChangedEvent(this, event.selection);
		println(nevent)

	//		selectionChangedListeners.forEach [
	//			val SafeRunnable runnable = [ |
	//				it.selectionChanged(nevent)
	//			]
	//			SafeRunner::run(runnable)
	//		]
	}

	override getSelection() {
		if(hasTreeViewer) {
			treeViewer.selection
		}
		StructuredSelection::EMPTY
	}

	override setSelection(ISelection selection) {
		if(hasTreeViewer) {
			treeViewer.selection = selection
		}
	}

	override addSelectionChangedListener(ISelectionChangedListener listener) {
		if(hasTreeViewer) {
			treeViewer.addSelectionChangedListener(listener)
		}
	}

	override removeSelectionChangedListener(ISelectionChangedListener listener) {
		if(hasTreeViewer) {
			treeViewer.removeSelectionChangedListener(listener)
		}
	}
}
