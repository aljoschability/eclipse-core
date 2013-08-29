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

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.properties.State
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.layout.FormAttachment
import org.eclipse.swt.layout.FormData
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetWidgetFactory

abstract class AbstractCheckboxSection extends AbstractFeaturePropertySection {
	new(ElementAdaptor adaptor) {
		super(adaptor)
	}

	private Button button
	private Label icon

	override refresh() {
		if (isReady() && hasChanged()) {
			button.setSelection(getValue())
			validate()
		}
	}

	def private boolean isReady() {
		return button != null && !button.isDisposed()
	}

	def private boolean hasChanged() {
		val oldValue = button.getSelection()
		val newValue = getValue()

		if (newValue == null) {
			return false
		}

		return !newValue.equals(oldValue)
	}

	def private void validate() {
		decorateImage(icon, validate(getValue()))
	}

	override protected Boolean getValue() {
		return super.getValue() as Boolean
	}

	def protected State validate(Boolean value) {
		return State.NONE
	}

	override protected createWidgets(Composite parent, TabbedPropertySheetWidgetFactory factory) {
		button = factory.createButton(parent, getLabelText(), SWT.CHECK)

		icon = factory.createLabel(parent, EMPTY)
		icon.setToolTipText(getHelpText())
	}

	def protected String getLabelText() {
		return getFeatureText()
	}

	def protected String getHelpText() {
		return null
	}

	override protected hookWidgetListeners() {
		button.addSelectionListener(
			new SelectionAdapter() {
				override widgetSelected(SelectionEvent e) {
					set(button.getSelection())
					validate()
				}
			})
	}

	override protected layoutWidgets() {

		// control
		var data = new FormData()
		data.left = new FormAttachment(0, WIDTH_LABEL)
		data.right = new FormAttachment(100, -(16 + SIZE_MARGIN * 3))
		data.top = new FormAttachment(0)
		data.bottom = new FormAttachment(100)
		button.setLayoutData(data)

		// help
		data = new FormData()
		data.left = new FormAttachment(button, SIZE_MARGIN * 2, SWT.RIGHT)
		data.right = new FormAttachment(100, -SIZE_MARGIN)
		data.top = new FormAttachment(button, 0, SWT.TOP)
		data.bottom = new FormAttachment(button, 0, SWT.BOTTOM)
		icon.setLayoutData(data)
	}
}
