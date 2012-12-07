package com.aljoschability.core.ui.runtime

import com.aljoschability.core.runtime.ICoreActivator
import org.eclipse.jface.dialogs.IDialogSettings
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.jface.preference.PreferenceStore
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.widgets.Display

interface IActivator extends ICoreActivator {

	/**
	 * Delivers the current active {@link Display display}.
	 * 
	 * @return Returns the display.
	 */
	def Display getDisplay()

	/**
	 * Delivers the {@link PreferenceStore preference store} instance of this plug-in.
	 * 
	 * @return Returns the {@link IPreferenceStore} of this plug-in.
	 */
	def IPreferenceStore getPreferenceStore()

	/**
	 * Delivers the {@link IDialogSettings dialog settings} instance of this plug-in.
	 * 
	 * @return Returns the {@link IDialogSettings} of this plug-in.
	 */
	def IDialogSettings getDialogSettings()

	/**
	 * Delivers the {@link ImageDescriptor image descriptor} registered in the image registry of this plug-in.
	 * 
	 * @param key The key under which the image descriptor has been registered.
	 * @return Returns the {@link ImageDescriptor} registered under the key.
	 */
	def ImageDescriptor getImageDescriptor(String key)

	/**
	 * Delivers the {@link Image image} registered in the image registry of this plug-in.
	 * 
	 * @param key The key under which the image has been registered.
	 * @return Returns the {@link Image} registered under the key.
	 */
	def Image getImage(String key)

	/**
	 * Delivers the {@link Color color} registered under the given <code>key</code> in the color registry of this
	 * plug-in.
	 * 
	 * @param key The key under which the color has been registered.
	 * @return Returns the {@link Color} registered under the key.
	 */
	def Color getColor(String key)
}
