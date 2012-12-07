package com.aljoschability.eclipse.core.graphiti.properties

import org.eclipse.graphiti.ui.editor.IDiagramContainerUI
import org.eclipse.jface.viewers.ISelection
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.FormLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.views.contentoutline.ContentOutline
import org.eclipse.ui.views.properties.tabbed.ISection
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetPage
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetWidgetFactory

abstract class AbstractPropertySection implements ISection {
	protected val SIZE_MARGIN = 6

	TabbedPropertySheetPage page

	Object selection

	IDiagramContainerUI diagramContainerUi

	override final createControls(Composite parent, TabbedPropertySheetPage page) {
		this.page = page

		var section = page.widgetFactory.createFlatFormComposite(parent)
		section.layout = new FormLayout => [
			marginTop = SIZE_MARGIN
			marginRight = SIZE_MARGIN
			marginLeft = SIZE_MARGIN
		]

		createWidgets(section, page.widgetFactory)
		layoutWidgets()
		hookWidgetListeners()
	}

	/**
	 * Creates the controls for the section. Clients should take advantage of the widget factory provided by the framework to achieve a common look between
	 * property sections.
	 * 
	 * @param parent The composite on which to layout the sections content. It has a {@link FormLayout}.
	 * @param factory The factory to be used to create widgets.
	 */
	def protected void createWidgets(Composite parent, TabbedPropertySheetWidgetFactory factory)

	/**
	 * Called right after {@link #createWidgets(Composite, TabbedPropertySheetWidgetFactory)} to layout the widgets.
	 */
	def protected void layoutWidgets() {
		// nothing here
	}

	/**
	 * Called after {@link #createWidgets(Composite, TabbedPropertySheetWidgetFactory) creation} and
	 * {@link #layoutWidgets() layouting} of the widgets to hook listeners to them.
	 */
	def protected void hookWidgetListeners() {
		// nothing here
	}

	override setInput(IWorkbenchPart part, ISelection selection) {
		if (selection == this.selection) {
			return
		}

		var diagramContainerUi = part.getAdapter(IDiagramContainerUI)
		if (diagramContainerUi instanceof IDiagramContainerUI) {
			this.diagramContainerUi = diagramContainerUi
		}

		//		println(x)
		println("diagram container UI" + diagramContainerUi)

		//		diagramContainerUi.diagramBehavior.executeFeature()
		if (part instanceof ContentOutline) {
			var outline = part

			println(outline.currentPage)
		}

	//println(part)
	// store diagram editor
	// store editing domain
	// store pictogram element
	// store business element
	}

	override aboutToBeHidden() {
		println("aboutToBeHidden")
	}

	override aboutToBeShown() {
		println("aboutToBeShown")
	}

	override dispose() {
		println("dispose")
	}

	override refresh() {
		println("refresh")
	}

	override getMinimumHeight() {
		SWT::DEFAULT
	}

	override shouldUseExtraSpace() {
		false
	}
}
