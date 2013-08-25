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
package com.aljoschability.core.ui.runtime

import com.aljoschability.core.runtime.AbstractCoreActivator
import java.io.BufferedReader
import java.io.File
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader
import java.net.URL
import java.text.MessageFormat
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.preferences.InstanceScope
import org.eclipse.jface.dialogs.DialogSettings
import org.eclipse.jface.dialogs.IDialogSettings
import org.eclipse.jface.resource.ColorRegistry
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.jface.resource.ImageRegistry
import org.eclipse.swt.SWT
import org.eclipse.swt.SWTError
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.graphics.RGB
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.eclipse.ui.preferences.ScopedPreferenceStore
import org.osgi.framework.BundleContext

abstract class AbstractActivator extends AbstractCoreActivator implements IActivator {
	private static val DIALOG_SETTINGS = "dialog_settings.xml"
	private static val ENCODING = "UTF-8"
	private static val WORKBENCH = "Workbench"

	IDialogSettings dialogSettings

	ScopedPreferenceStore preferenceStore

	ColorRegistry colorRegistry

	ImageRegistry imageRegistry

	final override stop(BundleContext context) {

		// color registry
		colorRegistry = null

		// image registry
		imageRegistry?.dispose()
		imageRegistry = null

		// dialog settings
		if (dialogSettings != null) {
			try {
				var IPath path = Platform::getStateLocation(bundle)
				if (path == null) {
					throw new NullPointerException("The system is running with no data area.")
				}

				dialogSettings.save(path.append(DIALOG_SETTINGS).toOSString())
			} catch (IOException e) {
				error("Could not save dialog settings!", e)
			} catch (IllegalStateException e) {
				error("Could not save dialog settings!", e)
			} catch (NullPointerException e) {
				error("Could not save dialog settings!", e)
			}
		}
		dialogSettings = null

		// preference store
		if (preferenceStore != null) {
			try {
				preferenceStore.save()
			} catch (IOException e) {
				error("Could not save preference store!", e)
			}
		}
		preferenceStore = null

		super.stop(context)
	}

	final override getPreferenceStore() {
		if (preferenceStore == null) {
			preferenceStore = new ScopedPreferenceStore(InstanceScope.INSTANCE, ID)
		}
		return preferenceStore;
	}

	final override getColor(String key) {
		if (getColorRegistry.hasValueFor(key)) {
			return getColorRegistry.get(key)
		}
		return null
	}

	final def addColor(String key, RGB rgb) {
		if (getColorRegistry.hasValueFor(key)) {
			warn(MessageFormat::format("A color with the key {0} has already been added to the registry.", key))
			return
		}

		getColorRegistry.put(key, rgb)
	}

	private def getColorRegistry() {
		if (colorRegistry == null) {
			colorRegistry = new ColorRegistry(display)
		}
		return colorRegistry
	}

	final override getImage(String path) {
		var Image image = getImageRegistry.get(path)
		if (image != null) {
			return image
		}
		getImageRegistry.get(null)
	}

	final override getImageDescriptor(String path) {
		var ImageDescriptor descriptor = getImageRegistry().getDescriptor(path);
		if (descriptor != null) {
			return descriptor;
		}
		getImageRegistry.getDescriptor(null);
	}

	protected final def void addImage(String path) {
		addImage(path, path)
	}

	protected final def void addImage(String key, String path) {
		var ImageDescriptor descriptor = getImageRegistry.getDescriptor(key)
		if (descriptor != null) {
			warn(MessageFormat::format("An image with the key {0} has already been added to the registry.", key))
			return;
		}

		descriptor = AbstractUIPlugin::imageDescriptorFromPlugin(ID, path)
		if (descriptor == null) {
			warn(MessageFormat::format("The image under the path {0} could not be found.", path))
			return
		}

		getImageRegistry.put(key, descriptor)
	}

	private def ImageRegistry getImageRegistry() {
		if (imageRegistry == null) {
			imageRegistry = new ImageRegistry(display)
			imageRegistry.put(null, ImageDescriptor::getMissingImageDescriptor())
		}
		return imageRegistry
	}

	final override getDisplay() {

		// use UI thread
		if (Display::getCurrent() != null) {
			return Display::getCurrent()
		}

		// use platform display
		if (PlatformUI::isWorkbenchRunning()) {
			return PlatformUI::getWorkbench().getDisplay()
		}

		// invalid thread access
		throw new SWTError(SWT.ERROR_THREAD_INVALID_ACCESS)
	}

	final override getDialogSettings() {
		if (dialogSettings == null) {
			dialogSettings = createDialogSettings()
		}
		return dialogSettings
	}

	private def IDialogSettings createDialogSettings() {
		var IDialogSettings dialogSettings = new DialogSettings(WORKBENCH)

		// see bug 69387
		var IPath path = Platform::getStateLocation(bundle)
		if (path != null) {

			// try r/w state area in the local file system
			var String readWritePath = path.append(DIALOG_SETTINGS).toOSString()
			var File settingsFile = new File(readWritePath)
			if (settingsFile.exists()) {
				try {
					dialogSettings.load(readWritePath)
				} catch (IOException e) {

					// load failed so ensure we have an empty settings
					dialogSettings = new DialogSettings(WORKBENCH)
				}

				return dialogSettings
			}
		}

		// otherwise look for bundle specific dialog settings
		var URL dsURL = FileLocator::find(bundle, new Path(DIALOG_SETTINGS), null)
		if (dsURL == null) {
			return dialogSettings
		}

		var InputStream is = null
		try {
			is = dsURL.openStream()
			var BufferedReader reader = new BufferedReader(new InputStreamReader(is, ENCODING))
			dialogSettings.load(reader)
		} catch (IOException e) {

			// load failed so ensure we have an empty settings
			dialogSettings = new DialogSettings(WORKBENCH)
		} finally {
			try {
				if (is != null) {
					is.close()
				}
			} catch (IOException e) {
				// do nothing
			}
		}

		return dialogSettings;
	}
}
