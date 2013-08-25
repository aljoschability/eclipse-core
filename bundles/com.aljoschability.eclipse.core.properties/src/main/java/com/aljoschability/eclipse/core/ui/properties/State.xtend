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
package com.aljoschability.eclipse.core.ui.properties

public final class State {
	public static enum Type {
		NONE,
		INFO,
		WARNING,
		ERROR
	}

	public static State NONE = new State(Type::NONE, null)

	final Type type

	final String message

	new(Type type, String message) {
		this.type = type
		this.message = message
	}

	def static error(String message) {
		return new State(Type::ERROR, message)
	}

	def static info(String message) {
		return new State(Type::INFO, message)
	}

	def static warning(String message) {
		return new State(Type::WARNING, message)
	}

	def String getMessage() {
		return message
	}

	def Type getType() {
		return type
	}

	def boolean isValid() {
		return Type::ERROR != type
	}
}
