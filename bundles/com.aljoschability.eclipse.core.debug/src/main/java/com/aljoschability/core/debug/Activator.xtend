package com.aljoschability.core.debug

import com.aljoschability.core.ui.runtime.AbstractActivator
import com.aljoschability.core.ui.runtime.IActivator
import java.util.Collection
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.graphiti.mm.MmPackage
import org.eclipse.graphiti.mm.algorithms.AlgorithmsPackage
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage

class Activator extends AbstractActivator {
	static IActivator INSTANCE

	def static IActivator get() {
		return Activator::INSTANCE
	}

	override protected initialize() {
		Activator::INSTANCE = this

		// activate debug stream
		DebugOutputStream::activate

		// add mm class icons
		addGraphitiTypeIcons(MmPackage::eINSTANCE.EClassifiers, "mm")

		// pictograms
		addGraphitiTypeIcons(PictogramsPackage::eINSTANCE.EClassifiers, "pictograms")

		// algorithms
		addGraphitiTypeIcons(AlgorithmsPackage::eINSTANCE.EClassifiers, "algorithms")

		// styles
		addGraphitiTypeIcons(StylesPackage::eINSTANCE.EClassifiers, "styles")
	}

	override protected dispose() {
		Activator::INSTANCE = null
	}

	def private void addGraphitiTypeIcons(Collection<EClassifier> collection, String prefix) {
		for (type : collection) {
			if (type instanceof EClass) {
				if (!type.abstract && !type.interface) {
					addImage(type.name, '''icons/graphiti/«prefix»/«type.name».png''')
				}
			}
		}
	}
}
