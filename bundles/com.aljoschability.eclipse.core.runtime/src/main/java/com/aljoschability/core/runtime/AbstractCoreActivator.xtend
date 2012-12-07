package com.aljoschability.core.runtime

import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.Status
import org.osgi.framework.BundleContext

/**
 * <p>
 * The base implementation of an {@link ICoreActivator core activator} class. This class should be used as parent class
 * for a bundle activator class which is only dependent on the <code>org.eclipse.core</code> plug-in.
 * </p>
 * 
 * @see ICoreActivator
 */
abstract class AbstractCoreActivator implements ICoreActivator {
	BundleContext bundleContext

	override getID() {
		bundle?.symbolicName
	}

	override getBundleContext() {
		bundleContext
	}

	override getBundle() {
		bundleContext?.bundle
	}

	override info(String text) {
		log(IStatus::INFO, text, null)
	}

	override warn(String text) {
		warn(text, null)
	}

	override warn(Throwable cause) {
		warn(null, cause)
	}

	override warn(String text, Throwable cause) {
		log(IStatus::WARNING, text, cause)
	}

	override error(String text) {
		error(text, null)
	}

	override error(Throwable cause) {
		error(null, cause)
	}

	override error(String text, Throwable cause) {
		log(IStatus::ERROR, text, cause)
	}

	override start(BundleContext context) {
		bundleContext = context
		initialize()
	}

	override stop(BundleContext context) {
		dispose()
		bundleContext = null
	}

	private def log(int severity, String text, Throwable cause) {
		log(new Status(severity, ID, text, cause))
	}

	private def log(IStatus status) {
		if (bundleContext != null) {
			Platform::getLog(bundle).log(status)
		} else {
			println(status)
		}
	}

	/**
	 * This method is called when the activator has been started. Should be used to store the singleton instance when
	 * necessary and to fill the image registry.
	 */
	protected def void initialize()

	/**
	 * This method is called before the bundle activator will be stopped. Should be used to delete the singleton
	 * instance reference.
	 */
	protected def void dispose()
}
