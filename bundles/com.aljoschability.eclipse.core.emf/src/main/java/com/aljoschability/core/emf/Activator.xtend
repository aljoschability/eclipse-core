package com.aljoschability.core.emf

import com.aljoschability.core.ui.runtime.AbstractActivator
import com.aljoschability.core.ui.runtime.IActivator

final class Activator extends AbstractActivator {
	var static IActivator INSTANCE;

	def static final IActivator get() {
		Activator::INSTANCE
	}

	override final void initialize() {
		Activator::INSTANCE = this

		addImage(EmfImages::FILE_ECORE)
		addImage(EmfImages::RESOURCES_PACKAGE)
		addImage(EmfImages::RESOURCES_PACKAGES)
	}

	override final void dispose() {
		Activator::INSTANCE = null
	}
}
