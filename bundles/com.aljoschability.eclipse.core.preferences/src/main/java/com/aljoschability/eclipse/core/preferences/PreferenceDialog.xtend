package com.aljoschability.eclipse.core.preferences

import org.eclipse.jface.dialogs.IPageChangeProvider
import org.eclipse.jface.dialogs.IPageChangedListener
import org.eclipse.jface.dialogs.TitleAreaDialog
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.preference.IPreferencePageContainer
import org.eclipse.jface.preference.PreferenceManager
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.SashForm
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.part.PageBook

class PreferenceDialog extends TitleAreaDialog implements IPreferencePageContainer, IPageChangeProvider {
	PreferenceManager manager

	PageBook book

	new(Shell shell, PreferenceManager manager) {
		super(shell)

		this.manager = manager
	}

	override protected configureShell(Shell shell) {
		super.configureShell(shell)

		shell.text = "Preferences"

	}

	override protected createDialogArea(Composite parent) {
		val area = super.createDialogArea(parent) as Composite

		val sash = new SashForm(area, SWT::HORIZONTAL)
		sash.layout = new FillLayout
		GridDataFactory::fillDefaults.grab(true, true).applyTo(sash)

		createTreeViewer(sash)

		createPageBook(sash)

		book.showPage(createEmptyPage(book))

		val genresPage = new GenresPage
		genresPage.create(book)

		book.showPage(genresPage.control)

		sash.weights = #[1, 3]

		title = "Preferences"
		message = "Message"

		return area
	}

	def private Control createEmptyPage(Composite parent) {
		val composite = new Composite(parent, SWT::NONE)
		GridLayoutFactory::swtDefaults.applyTo(composite)

		val label = new Label(composite, SWT::LEAD)
		GridDataFactory::fillDefaults.grab(true, true).applyTo(label)
		label.text = "No page found."

		return composite
	}

	def private void createTreeViewer(Composite parent) {
		val composite = new Composite(parent, SWT::NONE)
		GridLayoutFactory::fillDefaults.numColumns(2).applyTo(composite)
		composite.background = parent.display.getSystemColor(SWT::COLOR_LIST_BACKGROUND)

		val viewer = new TreeViewer(composite, SWT::FULL_SELECTION)
		GridDataFactory::fillDefaults.grab(true, true).applyTo(viewer.control)

		val separator = new Label(composite, SWT::SEPARATOR.bitwiseOr(SWT::VERTICAL))
		GridDataFactory::fillDefaults.grab(false, true).applyTo(separator)
	}

	def private void createPageBook(Composite parent) {
		val composite = new Composite(parent, SWT::NONE)
		GridLayoutFactory::fillDefaults.applyTo(composite)

		book = new PageBook(composite, SWT::NONE)
		GridDataFactory::fillDefaults.grab(true, true).applyTo(book)
	}

	override protected createButtonBar(Composite parent) {
		val contentSeparatorLabel = new Label(parent, SWT::SEPARATOR.bitwiseOr(SWT::HORIZONTAL))
		GridDataFactory::fillDefaults.grab(true, false).applyTo(contentSeparatorLabel)

		val composite = new Composite(parent, SWT::NONE)
		GridLayoutFactory::swtDefaults.numColumns(2).margins(5, 16).applyTo(composite)
		GridDataFactory::fillDefaults.grab(true, false).applyTo(composite)

		// filter text
		val filterText = new Text(composite,
			SWT::LEAD.bitwiseOr(SWT::BORDER).bitwiseOr(SWT::SEARCH).bitwiseOr(SWT::ICON_SEARCH))
		filterText.text = "Filter Preferences..."

		// buttons
		val buttonsComposite = new Composite(composite, SWT::NONE)
		GridLayoutFactory::fillDefaults.applyTo(buttonsComposite)
		GridDataFactory::fillDefaults.grab(true, false).align(SWT::TRAIL, SWT::CENTER).applyTo(buttonsComposite)

		createButtonsForButtonBar(buttonsComposite)

		return composite
	}

	override protected isResizable() { true }

	override getPreferenceStore() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override updateButtons() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override updateMessage() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override updateTitle() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override getSelectedPage() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addPageChangedListener(IPageChangedListener listener) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override removePageChangedListener(IPageChangedListener listener) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}
