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
package com.aljoschability.core.runtime

import org.osgi.framework.Bundle
import org.osgi.framework.BundleActivator
import org.osgi.framework.BundleContext

/**
 * <p>
 * Eases getting the plug-in identifier, name and other {@link BundleActivator bundle} specific
 * things as well as an easy access to the Eclipse plug-in specific logging feature.
 * </p>
 * 
 * @author Aljoscha Hark <aljoschability@gmail.com>
 */
interface ICoreActivator extends BundleActivator {

	/**
	 * Delivers the symbolic name/ID of this plug-in.
	 * 
	 * @return Returns the symbolic name of the plug-in.
	 */
	def String getSymbolicName()

	/**
	 * Delivers the bundle context.
	 * @return Returns the bundle context.
	 */
	def BundleContext getBundleContext()

	/**
	 * Delivers the bundle. Will be only available when the bundle has been {@link #start(BundleContext) started}.
	 * 
	 * @return Returns bundle when already available or <code>null</code>.
	 */
	def Bundle getBundle()

	/**
	 * Logs the given text as information entry in the status log for this
	 * plug-in.
	 * 
	 * @param text The text to log.
	 */
	def void info(String text)

	/**
	 * Logs the given text as warning entry in the status log for this plug-in.
	 * 
	 * @param text The text to log.
	 */
	def void warn(String text)

	/**
	 * Logs the given exception as warning in the status log for this plug-in
	 * trying to resolve a usable message.
	 * 
	 * @param cause The exception to be logged.
	 */
	def void warn(Throwable cause)

	/**
	 * Logs the given text and exception as warning in the ILog status log for this
	 * plug-in.
	 * 
	 * @param text The text to logged.
	 * @param cause The exception to be logged.
	 */
	def void warn(String text, Throwable cause)

	/**
	 * Logs the given text as error in the status log for this plug-in.
	 * 
	 * @param text The text to log.
	 */
	def void error(String text)

	/**
	 * Logs the exception as error in the status log for this plug-in trying to
	 * resolve a usable message.
	 * 
	 * @param cause The exception to be logged.
	 */
	def void error(Throwable cause)

	/**
	 * Logs the given text and the exception as error in the status log for this
	 * plug-in.
	 * 
	 * @param text The text to be logged.
	 * @param cause The exception be to logged.
	 */
	def void error(String text, Throwable cause)
}
