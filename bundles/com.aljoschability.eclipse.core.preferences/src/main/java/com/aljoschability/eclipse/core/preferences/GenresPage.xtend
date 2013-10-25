package com.aljoschability.eclipse.core.preferences

import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.SWT
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.swt.widgets.Group
import org.eclipse.jface.viewers.TreeViewer

interface IPreferencePage {
	def void create(Composite parent)

	def Control getControl()
}

class GenresPage implements IPreferencePage {
	Composite composite

	override create(Composite parent) {
		composite = new Composite(parent, SWT::NONE)
		GridLayoutFactory::swtDefaults.applyTo(composite)

		val genresGroup = new Group(composite, SWT::NONE)
		GridLayoutFactory::swtDefaults.applyTo(genresGroup)
		GridDataFactory::swtDefaults.grab(true, false).applyTo(genresGroup)
		genresGroup.text = "Genres"

		val viewer = new TreeViewer(genresGroup, SWT::BORDER)
		GridDataFactory::fillDefaults.grab(true, true).applyTo(viewer.control)
	}

	override getControl() {
		return composite
	}
}

/**
Action
Adventure
Animation
Comedy
Crime
Disaster
Documentary
Drama
Eastern
Family
Fan Film
Fantasy
Film Noir
History
Holiday
Horror
Indie
Music
Musical
Mystery
None
Road
Romance
Science Fiction
Short
Sporting Event
Sports
Suspense
Thriller
TV Movie
War
Western
 */