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
package com.aljoschability.eclipse.core.ui.properties.sections

import com.aljoschability.core.ui.CoreImages
import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.ui.properties.State
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.layout.FormAttachment
import org.eclipse.swt.layout.FormData
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Combo
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetWidgetFactory

public abstract class AbstractComboSection<T> extends AbstractFeaturePropertySection {
	val Map<Integer, T> map

	Label label
	Composite composite
	Combo combo
	Button button
	Label icon

	new(ElementAdaptor adaptor) {
		super(adaptor)
		map = newLinkedHashMap
	}

	override refresh() {
		if (isReady()) {
			map.clear()
			var int index = 0
			var List<T> items = getItems()
			var String[] itemTexts = newArrayOfSize(items.size())
			for (T object : items) {
				map.put(index, object)
				itemTexts.set(index, getText(object))
				index++
			}
			combo.setItems(itemTexts)

			if (hasChanged()) {
				val T value = getValue()
				if (getElement() != null) {
					combo.select(getIndex(value))
				} else {
					combo.select(-1)
				}

				validate()
			}
		}
	}

	override protected createWidgets(Composite parent, TabbedPropertySheetWidgetFactory factory) {
		label = factory.createLabel(parent, getLabelText() + ':', SWT.TRAIL)

		composite = factory.createFlatFormComposite(parent)

		combo = new Combo(composite, SWT.BORDER.bitwiseOr(SWT.READ_ONLY))

		factory.adapt(combo)
		if (shouldShowButton()) {
			button = factory.createButton(composite, "Find", SWT.PUSH)
			button.setImage(CoreImages.get(CoreImages.FIND))
		}

		icon = factory.createLabel(parent, EMPTY)
	}

	def private void validate() {
		decorateImage(icon, validate(getValue()))
	}

	override protected T getValue() {
		return super.getValue() as T
	}

	override protected abstract EStructuralFeature getFeature()

	def protected abstract List<T> getItems()

	def protected String getLabelText() {
		return getFeatureText()
	}

	def protected String getText(T element) {
		return String.valueOf(element)
	}

	def protected void handleButtonClicked() {
		// nothing by default
	}

	override protected hookWidgetListeners() {
		combo.addSelectionListener(
			new SelectionAdapter() {
				override widgetSelected(SelectionEvent e) {
					set(map.get(combo.getSelectionIndex()))
					validate()
				}
			})

		if (shouldShowButton()) {
			button.addSelectionListener(
				new SelectionAdapter() {
					override widgetSelected(SelectionEvent e) {
						handleButtonClicked()
					}
				})
		}
	}

	override protected layoutWidgets() {
		if (shouldShowButton()) {
			GridLayoutFactory.fillDefaults().numColumns(2).applyTo(composite)
		} else {
			GridLayoutFactory.fillDefaults().applyTo(composite)
		}
		GridDataFactory.fillDefaults().align(SWT.FILL, SWT.CENTER).grab(true, false).applyTo(combo)
		if (shouldShowButton()) {
			GridDataFactory.fillDefaults().align(SWT.FILL, SWT.CENTER).applyTo(button)
		}

		// control
		var data = new FormData()
		data.left = new FormAttachment(0, WIDTH_LABEL)
		data.right = new FormAttachment(100, -(16 + SIZE_MARGIN * 3))
		data.top = new FormAttachment(0)
		data.bottom = new FormAttachment(100)
		composite.setLayoutData(data)

		// help
		data = new FormData()
		data.left = new FormAttachment(composite, SIZE_MARGIN * 2, SWT.RIGHT)
		data.right = new FormAttachment(100, -SIZE_MARGIN)
		data.top = new FormAttachment(composite, 0, SWT.TOP)
		data.bottom = new FormAttachment(composite, 0, SWT.BOTTOM)
		icon.setLayoutData(data)

		// label
		data = new FormData()
		data.left = new FormAttachment(0)
		data.right = new FormAttachment(composite, -SIZE_MARGIN)
		data.top = new FormAttachment(composite, 2, SWT.TOP)
		data.bottom = new FormAttachment(composite, 0, SWT.BOTTOM)
		label.setLayoutData(data)
	}

	def protected boolean shouldShowButton() {
		return false
	}

	def protected State validate(T value) {
		return State.NONE
	}

	def private int getIndex(Object element) {
		var boolean isNull = element == null
		for (Integer key : map.keySet()) {
			var T value = map.get(key)
			if (isNull) {
				if (value == null) {
					return key
				}
			} else {
				if (element.equals(value)) {
					return key
				}
			}
		}
		return -1
	}

	def private boolean hasChanged() {
		var T oldValue = map.get(combo.getSelectionIndex())
		var T newValue = getValue()

		if (oldValue != null && oldValue.equals(newValue)) {
			return false
		}

		if (newValue != null && newValue.equals(oldValue)) {
			return false
		}

		if (newValue == null && oldValue == null) {
			return false
		}

		return true
	}

	def private boolean isReady() {
		return combo != null && !combo.isDisposed()
	}
}
