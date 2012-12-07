package com.aljoschability.eclipse.core.ui.properties.sections;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.edit.command.AddCommand;
import org.eclipse.emf.edit.command.RemoveCommand;
import org.eclipse.emf.edit.command.SetCommand;

import com.aljoschability.eclipse.core.properties.ElementAdaptor;

/**
 * This is the abstract base class for all {@link org.eclipse.emf.ecore.EStructuralFeature feature} based sections.
 * 
 * @author Aljoscha Hark <aljoschability@gmail.com>
 */
public abstract class AbstractFeaturePropertySection extends AbstractPropertySection {
	public AbstractFeaturePropertySection(ElementAdaptor adaptor) {
		super(adaptor);
	}

	/**
	 * Executes an {@link AddCommand} on the command stack for the {@link #getFeature() feature} with the given value.
	 * 
	 * @param values The values to add to the {@link #getFeature() feature}.
	 */
	protected final void add(Collection<Object> values) {
		add(getFeature(), values);
	}

	/**
	 * Executes an {@link AddCommand} on the command stack for the {@link #getFeature() feature} with the given value.
	 * 
	 * @param value The value to add to the {@link #getFeature() feature}.
	 */
	protected final void add(Object value) {
		add(getFeature(), value);
	}

	/**
	 * Executes a {@link RemoveCommand} on the command stack for the {@link #getFeature() feature} with the given value.
	 * 
	 * @param values The values to remove from the {@link #getFeature() feature}.
	 */
	protected final void remove(Collection<Object> values) {
		remove(getFeature(), values);
	}

	/**
	 * Executes a {@link RemoveCommand} on the command stack for the {@link #getFeature() feature} with the given value.
	 * 
	 * @param value The value to remove from the {@link #getFeature() feature}.
	 */
	protected final void remove(Object value) {
		remove(getFeature(), value);
	}

	/**
	 * Executes a {@link SetCommand} on the command stack for the {@link #getFeature() feature} with the given value.
	 * 
	 * @param value The value to set for the {@link #getFeature() feature}.
	 */
	protected final void set(Object value) {
		set(getFeature(), value);
	}

	protected Object getValue() {
		return getValue(getFeature());
	}

	/**
	 * Delivers the name of the feature as text.
	 * 
	 * @return Returns the formatted name of the feature.
	 */
	protected String getFeatureText() {
		return convertName(getFeature().getName());
	}

	private static String convertName(String name) {
		if (name == null || name.isEmpty()) {
			return String.valueOf(null);
		}

		StringBuilder builder = new StringBuilder();
		boolean lastUpper = false;
		for (int i = 0; i < name.length(); i++) {
			char c = name.charAt(i);

			if (Character.isUpperCase(c)) {
				if (!lastUpper) {
					builder.append(' ');
				}
				lastUpper = true;
			} else {
				lastUpper = false;
			}

			if (i == 0) {
				builder.append(Character.toUpperCase(c));
			} else {
				builder.append(c);
			}
		}

		return builder.toString();
	}

	@Override
	protected boolean shouldRefresh(Notification msg) {
		return super.shouldRefresh(msg) && getElement().equals(msg.getNotifier()) && getFeature() != null
				&& getFeature().equals(msg.getFeature());
	}

	/**
	 * Delivers the {@link EStructuralFeature feature} for this section. This feature typically comes from the
	 * <code>Literals</code> interface from inside the generated <code>EPackage</code>.
	 * 
	 * @return Returns the {@link EStructuralFeature feature} for this section.
	 */
	protected abstract EStructuralFeature getFeature();
}
