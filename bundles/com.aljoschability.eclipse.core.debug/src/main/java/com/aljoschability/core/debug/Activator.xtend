package com.aljoschability.core.debug

import com.aljoschability.core.ui.runtime.AbstractActivator
import com.aljoschability.core.ui.runtime.IActivator
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage
import org.eclipse.emf.ecore.EClass
import org.eclipse.graphiti.mm.algorithms.AlgorithmsPackage
import org.eclipse.graphiti.mm.algorithms.styles.StylesPackage
import org.eclipse.graphiti.mm.MmPackage

class Activator extends AbstractActivator {
	static IActivator INSTANCE

	override protected initialize() {
		Activator::INSTANCE = this

		// mm
		for (type : MmPackage::eINSTANCE.EClassifiers) {
			if (type instanceof EClass) {
				if (!type.abstract && !type.interface) {
					addImage(type.name, '''icons/graphiti/mm/«type.name».png''')
				}
			}
		}

		// pictograms
		for (type : PictogramsPackage::eINSTANCE.EClassifiers) {
			if (type instanceof EClass) {
				if (!type.abstract && !type.interface) {
					addImage(type.name, '''icons/graphiti/pictograms/«type.name».png''')
				}
			}
		}

		// algorithms
		for (type : AlgorithmsPackage::eINSTANCE.EClassifiers) {
			if (type instanceof EClass) {
				if (!type.abstract && !type.interface) {
					addImage(type.name, '''icons/graphiti/algorithms/«type.name».png''')
				}
			}
		}

		// styles
		for (type : StylesPackage::eINSTANCE.EClassifiers) {
			if (type instanceof EClass) {
				if (!type.abstract && !type.interface) {
					addImage(type.name, '''icons/graphiti/styles/«type.name».png''')
				}
			}
		}
	}

	override protected dispose() {
		Activator::INSTANCE = null
	}

	def static IActivator get() {
		return Activator::INSTANCE
	}
}
