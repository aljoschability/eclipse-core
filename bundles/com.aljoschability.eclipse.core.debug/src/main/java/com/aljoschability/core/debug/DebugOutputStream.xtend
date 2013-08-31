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
package com.aljoschability.core.debug

import java.io.OutputStream
import java.io.PrintStream
import java.text.MessageFormat

class DebugOutputStream extends PrintStream {
	static PrintStream DEFAULT_OUT
	static PrintStream DEFAULT_ERR

	def static void activate() {
		DEFAULT_OUT = System.out
		DEFAULT_ERR = System.err

		System.setOut(new DebugOutputStream(DEFAULT_OUT))
		System.setErr(new DebugOutputStream(DEFAULT_ERR))
	}

	def static void deactivate() {
		System.setOut(DEFAULT_OUT)
		System.setErr(DEFAULT_ERR)
	}

	private new(OutputStream stream) {
		super(stream)
	}

	override println(Object object) {
		showLocation()
		super.println(object)
	}

	override println(String object) {
		showLocation()
		super.println(object)
	}

	def private void showLocation() {
		val element = Thread::currentThread.stackTrace.get(4)
		super.print(MessageFormat::format("({0}:{1, number,#}) : ", element.fileName, element.lineNumber))
	}
}
