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
package com.aljoschability.eclipse.core.properties.sections

import com.aljoschability.core.ui.CoreColors
import com.aljoschability.core.ui.CoreImages
import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.ui.properties.State
import com.aljoschability.eclipse.core.ui.properties.State.Type
import java.util.Collection
import org.eclipse.core.runtime.Assert
import org.eclipse.emf.common.command.Command
import org.eclipse.emf.common.notify.Adapter
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.common.notify.impl.AdapterImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.edit.command.AddCommand
import org.eclipse.emf.edit.command.RemoveCommand
import org.eclipse.emf.edit.command.SetCommand
import org.eclipse.emf.edit.domain.AdapterFactoryEditingDomain
import org.eclipse.emf.edit.domain.EditingDomain
import org.eclipse.jface.viewers.IBaseLabelProvider
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.LabelProviderChangedEvent
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.layout.FormLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Label
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.views.properties.tabbed.ISection
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetPage
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetWidgetFactory

abstract class AbstractPropertySection implements ISection {
	protected static final String EMPTY = "" //$NON-NLS-1$
	protected static final int WIDTH_LABEL = 120
	protected static final int SIZE_MARGIN = 6

	private static val IBaseLabelProvider DUMMY_PROVIDER = new LabelProvider()
	EObject element

	EditingDomain editingDomain

	Adapter listener

	TabbedPropertySheetPage page
	ISelection selection
	final ElementAdaptor adaptor

	new(ElementAdaptor adaptor) {
		this.adaptor = adaptor
		listener = new AdapterImpl() {
			override notifyChanged(Notification msg) {
				if (shouldRefresh(msg)) {
					if (Display.getCurrent() == null) {

						// execute refresh() in the SWT ui thread
						Display.getDefault().asyncExec([|refresh()])
					} else {
						refresh()
					}
				}
			}
		}
	}

	override final createControls(Composite parent, TabbedPropertySheetPage page) {
		this.page = page

		val layout = new FormLayout()
		layout.marginTop = SIZE_MARGIN
		layout.marginRight = SIZE_MARGIN
		layout.marginLeft = SIZE_MARGIN

		val section = page.getWidgetFactory().createFlatFormComposite(parent)
		section.setLayout(layout)

		createWidgets(section, page.getWidgetFactory())
		layoutWidgets()
		hookWidgetListeners()
	}

	/**
	 * <p>
	 * Creates the controls for the section.
	 * </p>
	 * <p>
	 * Clients should take advantage of the widget factory provided by the framework to achieve a common look between
	 * property sections.
	 * </p>
	 *
	 * @param parent The composite on which to layout the sections content. It has a {@link FormLayout}.
	 * @param factory The factory to be used to create widgets.
	 */
	def protected abstract void createWidgets(Composite parent, TabbedPropertySheetWidgetFactory factory)

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
		if (selection.equals(this.selection)) {
			return
		}

		removeAdapters()

		this.selection = selection

		element = adaptor.getElement(selection)
		editingDomain = AdapterFactoryEditingDomain.getEditingDomainFor(element)

		Assert.isNotNull(element)
		Assert.isNotNull(editingDomain)

		addAdapters()
	}

	override aboutToBeHidden() {
		removeAdapters()
	}

	/**
	 * Removes the listener from the {@link #getElement() element}. Is called inside {@link #aboutToBeHidden()} and when
	 * the {@link #setInput(IWorkbenchPart, ISelection) input changed}.
	 */
	def protected void removeAdapters() {
		if (element != null) {
			element.eAdapters().remove(listener)
		}
	}

	/**
	 * Adds a listener to the {@link #getElement() element}. Is called when the
	 * {@link #setInput(IWorkbenchPart, ISelection) input changed}.
	 */
	def protected void addAdapters() {
		if (element != null) {
			element.eAdapters().add(listener)
		}
	}

	override aboutToBeShown() {
		// nothing here
	}

	override dispose() {
		// nothing here
	}

	override getMinimumHeight() {
		return SWT.DEFAULT
	}

	override refresh() {
		// nothing here
	}

	override shouldUseExtraSpace() {
		return false
	}

	/**
	 * Executes an {@link AddCommand} on the command stack for the feature with the given value.
	 *
	 * @param feature The feature to which the values should be added.
	 * @param values The values to add to the given feature.
	 */
	def protected final void add(EStructuralFeature feature, Collection<Object> values) {
		execute(AddCommand.create(getEditingDomain(), getElement(), feature, values))
	}

	/**
	 * Executes an {@link AddCommand} on the command stack for the {@link #getFeature() feature} with the given value.
	 *
	 * @param feature The feature to which the value should be added.
	 * @param value The value to add to the given feature.
	 */
	def protected final void add(EStructuralFeature feature, Object value) {
		execute(AddCommand.create(getEditingDomain(), getElement(), feature, value))
	}

	/**
	 * Executes a {@link RemoveCommand} on the command stack for the feature with the given value.
	 *
	 * @param feature The feature from which the values should be removed.
	 * @param values The values to remove from the given feature.
	 */
	def protected final void remove(EStructuralFeature feature, Collection<Object> values) {
		execute(RemoveCommand.create(getEditingDomain(), getElement(), feature, values))
	}

	/**
	 * Executes a {@link RemoveCommand} on the command stack for the feature with the given value.
	 *
	 * @param feature The feature from which the value should be removed.
	 * @param values The values to remove from the given feature.
	 */
	def protected final void remove(EStructuralFeature feature, Object value) {
		execute(RemoveCommand.create(getEditingDomain(), getElement(), feature, value))
	}

	/**
	 * Executes a {@link SetCommand} on the command stack for the feature with the given value.
	 *
	 * @param feature The feature which will be set to the given value.
	 * @param value The value to set for the given feature.
	 */
	def protected final void set(EStructuralFeature feature, Object value) {
		execute(SetCommand.create(getEditingDomain(), getElement(), feature, value))
	}

	/**
	 * Executes the command on the command stack of the editing domain.
	 *
	 * @param command The command to execute.
	 */
	def protected void execute(Command command) {
		getEditingDomain().getCommandStack().execute(command)
		postExecute()
	}

	/**
	 * Delivers the {@link EditingDomain editing domain} for the currently selected {@link #getElement() element}.
	 *
	 * @return Returns the editing domain.
	 */
	def protected final EditingDomain getEditingDomain() {
		return editingDomain
	}

	def protected void postExecute() {
		// nothing here
	}

	/**
	 * Delivers the current value for the given feature of the currently selected {@link #getElement() element * }.
	 *
	 * @param feature The feature to get the value for.
	 * @return Returns the current value.
	 */
	def protected final Object getValue(EStructuralFeature feature) {
		Assert.isNotNull(feature)

		return getElement().eGet(feature)
	}

	/**
	 * Decides whether to refresh the section after a model change.
	 *
	 * @param msg The received notification.
	 * @return Returns <code>true</code> when {@link #refresh()} should be called.
	 */
	def protected boolean shouldRefresh(Notification msg) {
		return msg.getEventType() != Notification.REMOVING_ADAPTER && getElement() != null
	}

	/**
	 * Getter of the currently selected element.
	 *
	 * @return Returns the currently selected element.
	 */
	def protected EObject getElement() {
		return element
	}

	def protected final void decorateBackground(Control control, State state) {
		Assert.isNotNull(control)

		var Color color = null
		if (state != null) {
			switch (state.getType()) {
				case ERROR: {
					color = CoreColors.get(CoreColors.ERROR)
				}
				case WARNING: {
					color = CoreColors.get(CoreColors.WARNING)
				}
				default: {
				}
			}
		}

		if (!control.isDisposed()) {
			control.setBackground(color)
		}
	}

	/**
	 * Decorates the given icon label with the information from the given {@link State}. The icon will be set to an
	 * appropriate image depending on the {@link Type} of the state. The tool tip will be set to the message of the
	 * state.
	 *
	 * @param label The label to decorate.
	 * @param state The state containing the relevant information.
	 */
	def protected final void decorateImage(Label label, State state) {
		Assert.isNotNull(label)

		var Image image = null
		var String text = null
		if (state != null) {
			text = state.getMessage()
			switch (state.getType()) {
				case ERROR: {
					image = CoreImages.get(CoreImages.STATE_ERROR)
				}
				case WARNING: {
					image = CoreImages.get(CoreImages.STATE_WARNING)
				}
				case INFO: {
					image = CoreImages.get(CoreImages.STATE_INFORMATION)
				}
				default: {
				}
			}
		}

		if (!label.isDisposed()) {
			label.setImage(image)
			label.setToolTipText(text)
		}
	}

	/**
	 * Delivers the property sheet page of the section.
	 *
	 * @return Returns the page.
	 */
	def protected final TabbedPropertySheetPage getPage() {
		return page
	}

	/**
	 * Refreshes the label of the property sheet and the title of the diagram editor.
	 */
	def protected final void refreshTitle() {
		if (page != null) {
			page.labelProviderChanged(new LabelProviderChangedEvent(DUMMY_PROVIDER))
		}
	}
}
