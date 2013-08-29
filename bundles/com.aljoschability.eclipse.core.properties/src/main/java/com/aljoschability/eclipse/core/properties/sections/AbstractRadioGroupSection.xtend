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
package com.aljoschability.eclipse.core.properties.sections;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.properties.State
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.Enumerator
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.layout.FormAttachment
import org.eclipse.swt.layout.FormData
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetWidgetFactory

public abstract class AbstractRadioGroupSection<T extends Enumerator> extends AbstractFeaturePropertySection {
	val Map<T, Button> buttons;

	Label label;
	Composite composite;
	Label icon;

	new(ElementAdaptor adaptor) {
		super(adaptor);
		buttons = newLinkedHashMap
	}

	override refresh() {
		if (isReady() && hasChanged()) {

			// disable all
			for (Button button : buttons.values()) {
				if (!button.isDisposed()) {
					button.setSelection(false);
				}
			}

			val Button button = buttons.get(getValue());
			if (!button.isDisposed()) {
				button.setSelection(true);
			}

			checkEnabled();
			validate();
		}
	}

	def private void validate() {
		decorateImage(icon, validate(getValue()));
	}

	override protected T getValue() {
		return super.getValue() as T
	}

	def protected void checkEnabled() {
		for (T literal : buttons.keySet()) {
			val button = buttons.get(literal);
			if (button != null && !button.isDisposed()) {
				button.setEnabled(isEnabled(literal));
			}
		}
	}

	override protected createWidgets(Composite parent, TabbedPropertySheetWidgetFactory factory) {
		label = factory.createLabel(parent, getLabelText() + ':', SWT.TRAIL);

		composite = factory.createFlatFormComposite(parent);

		for (T literal : getValues()) {
			val button = factory.createButton(composite, getText(literal), SWT.RADIO);
			button.setToolTipText(getToolTipText(literal));

			buttons.put(literal, button);
		}

		icon = factory.createLabel(parent, EMPTY);
	}

	/**
	 * The title of the section left to the actual radio buttons.
	 *
	 * @return Returns the text for the label.
	 */
	def protected abstract String getLabelText();

	def protected State validate(T literal) {
		return State.NONE;
	}

	def protected String getText(T literal) {
		return literal.getName();
	}

	def protected String getToolTipText(T literal) {
		return null;
	}

	def protected abstract List<T> getValues();

	override protected void hookWidgetListeners() {
		for (T literal : buttons.keySet()) {
			val button = buttons.get(literal);
			button.addSelectionListener(
				new SelectionAdapter() {
					override widgetSelected(SelectionEvent e) {
						set(literal);
						validate();
					}
				});
		}
	}

	def protected boolean isEnabled(T literal) {
		return true;
	}

	def protected boolean isVertical() {
		return false;
	}

	override protected layoutWidgets() {
		if (isVertical()) {
			GridLayoutFactory.fillDefaults().applyTo(composite);
		} else {
			GridLayoutFactory.fillDefaults().numColumns(buttons.size()).applyTo(composite);
		}

		for (Button button : buttons.values()) {
			GridDataFactory.fillDefaults().grab(false, true).applyTo(button);
		}

		// control
		var data = new FormData();
		data.left = new FormAttachment(0, WIDTH_LABEL);
		data.right = new FormAttachment(100, -(16 + SIZE_MARGIN * 3));
		data.top = new FormAttachment(0);
		data.bottom = new FormAttachment(100);
		composite.setLayoutData(data);

		// help
		data = new FormData();
		data.left = new FormAttachment(composite, SIZE_MARGIN * 2, SWT.RIGHT);
		data.right = new FormAttachment(100, -SIZE_MARGIN);
		data.top = new FormAttachment(composite, 0, SWT.TOP);
		data.bottom = new FormAttachment(composite, 0, SWT.BOTTOM);
		icon.setLayoutData(data);

		// label
		data = new FormData();
		data.left = new FormAttachment(0);
		data.right = new FormAttachment(composite, -SIZE_MARGIN);
		data.top = new FormAttachment(composite, 2, SWT.TOP);
		data.bottom = new FormAttachment(composite, 0, SWT.BOTTOM);
		label.setLayoutData(data);
	}

	def private boolean hasChanged() {
		return !buttons.get(getValue()).getSelection();
	}

	def private boolean isReady() {
		return composite != null && !composite.isDisposed();
	}
}
