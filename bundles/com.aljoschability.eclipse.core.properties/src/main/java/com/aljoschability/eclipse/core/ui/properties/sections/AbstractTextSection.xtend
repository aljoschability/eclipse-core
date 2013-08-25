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
package com.aljoschability.eclipse.core.ui.properties.sections;

import com.aljoschability.eclipse.core.properties.ElementAdaptor
import com.aljoschability.eclipse.core.ui.properties.State
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.swt.SWT
import org.eclipse.swt.events.FocusAdapter
import org.eclipse.swt.events.FocusEvent
import org.eclipse.swt.events.KeyAdapter
import org.eclipse.swt.events.KeyEvent
import org.eclipse.swt.events.ModifyEvent
import org.eclipse.swt.events.ModifyListener
import org.eclipse.swt.events.MouseAdapter
import org.eclipse.swt.events.MouseEvent
import org.eclipse.swt.layout.FormAttachment
import org.eclipse.swt.layout.FormData
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Group
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.views.properties.tabbed.TabbedPropertySheetWidgetFactory

public abstract class AbstractTextSection extends AbstractFeaturePropertySection {
	new(ElementAdaptor adaptor) {
		super(adaptor);
	}

	Label label;
	protected Text text;
	Label icon;
	Group group;

	override refresh() {
		if (isReady()) {
			val type = getType();
			val value = getValue();
			var stringValue = EcoreUtil.convertToString(type, value);

			if (!isEqual(text.getText(), stringValue)) {
				if (stringValue == null) {
					stringValue = EMPTY;
				}
				text.setText(stringValue);
			}
			validate();
		}
	}

	def private boolean isReady() {
		return text != null && !text.isDisposed();
	}

	def private void doExecute() {
		val oldValue = getValue();
		val newValue = EcoreUtil.createFromString(getType(), text.getText());

		var abort = false;
		if (oldValue != null) {
			abort = oldValue.equals(newValue);
		}
		if (!abort && newValue != null) {
			abort = newValue.equals(oldValue);
		}

		if (!abort) {
			val selection = text.getSelection();
			set(newValue);
			text.setSelection(selection);
		}
	}

	def private EDataType getType() {
		return getFeature().getEType() as EDataType;
	}

	def private static boolean isEqual(String one, String two) {
		return one == two;
	}

	def private void validate() {
		val value = getValue(text.getText());
		val state = validate(value);

		decorateBackground(text, state);
		decorateImage(icon, state);
	}

	/**
	 * Can be used to wrap a value to be set to the model.
	 *
	 * @param value The unwrapped value.
	 * @return Returns the real value that should be set to the model.
	 */
	def protected String getValue(String value) {
		return value;
	}

	def protected validate(String value) {
		return State.NONE;
	}

	override shouldUseExtraSpace() {
		return isMultiLine();
	}

	override protected void createWidgets(Composite parent, TabbedPropertySheetWidgetFactory factory) {
		val labelText = getLabelText() + ':';

		val style = if (isMultiLine) {
				SWT::BORDER.bitwiseOr(SWT::MULTI)
			} else {
				SWT::BORDER.bitwiseOr(SWT::SINGLE)
			}

		// structure
		if (isGroupWrapped()) {
			group = factory.createGroup(parent, getLabelText());
			text = factory.createText(group, EMPTY, style);
		} else {
			label = factory.createLabel(parent, labelText, SWT.TRAIL);
			text = factory.createText(parent, EMPTY, style);
		}

		// font
		if (isUsingMonospace()) {
			text.setFont(JFaceResources.getTextFont());
		}

		icon = factory.createLabel(parent, EMPTY);
	}

	def protected boolean isGroupWrapped() {
		return false;
	}

	/**
	 * Whether the text field should be multi-lined. The section will {@link #shouldUseExtraSpace() expand} accordingly.
	 *
	 * @return Returns <code>true</code> to let the text field be multi-lined.
	 */
	def protected boolean isMultiLine() {
		return false;
	}

	/**
	 * The title of the section left to the actual text field.
	 *
	 * @return Returns the text for the label.
	 */
	def protected String getLabelText() {
		return getFeatureText();
	}

	override protected hookWidgetListeners() {

		// select text on label click
		if (!isGroupWrapped()) {
			label.addMouseListener(
				new MouseAdapter() {
					override mouseDown(MouseEvent e) {
						text.setFocus();
						text.selectAll();
					}
				});
		}

		// execute command when focus lost
		text.addFocusListener(
			new FocusAdapter() {
				override focusLost(FocusEvent e) {
					doExecute();
				}
			});

		// execute command on [ENTER] key
		if (!isMultiLine()) {
			text.addKeyListener(
				new KeyAdapter() {
					override keyPressed(KeyEvent e) {
						if (SWT.CR == e.character) {
							doExecute();
						}
					}
				});
		}

		// validate on modify
		text.addModifyListener(
			new ModifyListener() {
				override modifyText(ModifyEvent e) {
					validate();
				}
			});
	}

	def protected boolean isUsingMonospace() {
		return false;
	}

	override protected layoutWidgets() {
		if (isGroupWrapped()) {

			// group
			var data = new FormData();
			data.left = new FormAttachment(0);
			data.right = new FormAttachment(100, -(16 + SIZE_MARGIN * 3));
			data.top = new FormAttachment(0);
			data.bottom = new FormAttachment(100);
			group.setLayoutData(data);

			GridLayoutFactory.fillDefaults().margins(SIZE_MARGIN, SIZE_MARGIN).applyTo(group);

			// control
			GridDataFactory.fillDefaults().grab(true, true).applyTo(text);

			// help
			data = new FormData();
			data.left = new FormAttachment(group, SIZE_MARGIN * 2, SWT.RIGHT);
			data.right = new FormAttachment(100, -SIZE_MARGIN);
			data.top = new FormAttachment(group, 0, SWT.TOP);
			data.bottom = new FormAttachment(group, 0, SWT.BOTTOM);
			icon.setLayoutData(data);
		} else {

			// control
			var data = new FormData();
			data.left = new FormAttachment(0, WIDTH_LABEL);
			data.right = new FormAttachment(100, -(16 + SIZE_MARGIN * 3));
			data.top = new FormAttachment(0);
			data.bottom = new FormAttachment(100);
			text.setLayoutData(data);

			// help
			data = new FormData();
			data.left = new FormAttachment(text, SIZE_MARGIN * 2, SWT.RIGHT);
			data.right = new FormAttachment(100, -SIZE_MARGIN);
			data.top = new FormAttachment(text, 0, SWT.TOP);
			data.bottom = new FormAttachment(text, 0, SWT.BOTTOM);
			icon.setLayoutData(data);

			// label
			data = new FormData();
			data.left = new FormAttachment(0);
			data.right = new FormAttachment(text, -SIZE_MARGIN);
			data.top = new FormAttachment(text, 2, SWT.TOP);
			data.bottom = new FormAttachment(text, 0, SWT.BOTTOM);
			label.setLayoutData(data);
		}
	}
}
