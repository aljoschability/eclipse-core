package com.aljoschability.eclipse.core.graphiti.outline

import org.eclipse.ui.part.Page
import org.eclipse.ui.views.contentoutline.IContentOutlinePage
import org.eclipse.swt.widgets.Composite
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.ISelection
import org.eclipse.ui.part.PageBook
import org.eclipse.swt.SWT
import java.util.Collection
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.util.SafeRunnable
import org.eclipse.core.runtime.SafeRunner
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.Action
import com.aljoschability.eclipse.core.graphiti.GraphitiImages
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.ui.part.IPageSite
import org.eclipse.gef.GraphicalViewer
import org.eclipse.ui.forms.widgets.FormToolkit
import org.eclipse.emf.ecore.resource.ResourceSet

class GraphitiContentOutlinePage extends Page implements IContentOutlinePage, ISelectionChangedListener {
	val Collection<ISelectionChangedListener> listeners

	IAdaptable adaptable

	IAction thumbnailAction
	IAction treeAction
	IAction multiAction

	FormToolkit factory

	PageBook book

	GraphitiOutlineThumbnailPart thumbnailPart
	GraphitiOutlineTreePart treePart
	GraphitiOutlineMultiPart multiPart

	new(IAdaptable adaptable) {
		listeners = newHashSet

		this.adaptable = adaptable
	}

	override createControl(Composite parent) {

		// create page book
		book = new PageBook(parent, SWT::NONE)

		// create factory
		factory = new FormToolkit(parent.display)

		// create thumbnail page
		thumbnailPart = new GraphitiOutlineThumbnailPart
		thumbnailPart.create(this, factory, book)

		thumbnailAction = new ShowPageAction(this)
		thumbnailAction.text = "Show Thumbnail"
		thumbnailAction.imageDescriptor = GraphitiImages::getImageDescriptor(GraphitiImages::OUTLINE_OVERVIEW)
		site.actionBars.toolBarManager.add(thumbnailAction)

		// tree
		treePart = new GraphitiOutlineTreePart
		treePart.create(this, factory, book)

		treeAction = new ShowPageAction(this)
		treeAction.text = "Show Content Tree"
		treeAction.imageDescriptor = GraphitiImages::getImageDescriptor(GraphitiImages::OUTLINE_TREE)
		site.actionBars.toolBarManager.add(treeAction)

		// multi
		multiPart = new GraphitiOutlineMultiPart
		multiPart.create(this, factory, book)

		multiAction = new ShowPageAction(this)
		multiAction.text = "Show Thumbnail & Tree"
		multiAction.imageDescriptor = GraphitiImages::getImageDescriptor(GraphitiImages::OUTLINE_MULTI)
		site.actionBars.toolBarManager.add(multiAction)

		showPage(thumbnailAction)
	}

	override getControl() {
		book
	}

	override setFocus() {
		book.setFocus
	}

	override addSelectionChangedListener(ISelectionChangedListener listener) {
		listeners += listener
	}

	override removeSelectionChangedListener(ISelectionChangedListener listener) {
		listeners -= listener
	}

	override getSelection() {
		treePart.selection
	}

	override setSelection(ISelection selection) {
		treePart.selection = selection
	}

	override selectionChanged(SelectionChangedEvent e) {
		println(e)
		println(e.selection)
		println(listeners)

		val event = new SelectionChangedEvent(this, e.selection);
		listeners.forEach [
			val SafeRunnable runnable = [ |
				it.selectionChanged(event)
			]
			SafeRunner::run(runnable)
		]
	}

	def showPage(IAction action) {
		if(action == thumbnailAction) {
			book.showPage(thumbnailPart.control)
			thumbnailAction.checked = true
			treeAction.checked = false
			multiAction.checked = false
		} else if(action == treeAction) {
			book.showPage(treePart.control)
			thumbnailAction.checked = false
			treeAction.checked = true
			multiAction.checked = false
		} else if(action == multiAction) {
			book.showPage(multiPart.control)
			thumbnailAction.checked = false
			treeAction.checked = false
			multiAction.checked = true
		}
	}

	override init(IPageSite site) {
		super.init(site)

		site.selectionProvider = this
	}

	def ResourceSet getResourceSet() {
		diagram?.eResource?.resourceSet
	}

	def Diagram getDiagram() {
		adaptable.getAdapter(Diagram) as Diagram
	}

	def GraphicalViewer getGraphicalViewer() {
		adaptable.getAdapter(GraphicalViewer) as GraphicalViewer
	}
}

abstract class GraphitiOutlinePage extends Page {
	protected GraphitiContentOutlinePage page
	protected FormToolkit factory

	def create(GraphitiContentOutlinePage page, FormToolkit factory, Composite parent) {
		init(page.site)
		this.page = page
		this.factory = factory

		createControl(parent)
	}

	override setFocus() {
		control.setFocus
	}

}

class ShowPageAction extends Action {
	GraphitiContentOutlinePage page

	new(GraphitiContentOutlinePage page) {
		super(null, AS_RADIO_BUTTON)
		this.page = page
	}

	override run() {
		page.showPage(this)
	}
}
