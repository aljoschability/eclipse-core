package com.aljoschability.core.emf.editors;

import java.io.IOException;
import java.io.InputStream;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.EventObject;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.command.BasicCommandStack;
import org.eclipse.emf.common.command.Command;
import org.eclipse.emf.common.command.CommandStack;
import org.eclipse.emf.common.command.CommandStackListener;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.ui.MarkerHelper;
import org.eclipse.emf.common.ui.viewer.ColumnViewerInformationControlToolTipSupport;
import org.eclipse.emf.common.ui.viewer.IViewerProvider;
import org.eclipse.emf.common.util.BasicDiagnostic;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.UniqueEList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.emf.ecore.provider.EcoreItemProviderAdapterFactory;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EContentAdapter;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.edit.domain.AdapterFactoryEditingDomain;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.emf.edit.domain.IEditingDomainProvider;
import org.eclipse.emf.edit.provider.AdapterFactoryItemDelegator;
import org.eclipse.emf.edit.provider.ComposedAdapterFactory;
import org.eclipse.emf.edit.provider.ReflectiveItemProviderAdapterFactory;
import org.eclipse.emf.edit.provider.resource.ResourceItemProviderAdapterFactory;
import org.eclipse.emf.edit.ui.celleditor.AdapterFactoryTreeEditor;
import org.eclipse.emf.edit.ui.dnd.EditingDomainViewerDropAdapter;
import org.eclipse.emf.edit.ui.dnd.LocalTransfer;
import org.eclipse.emf.edit.ui.dnd.ViewerDragAdapter;
import org.eclipse.emf.edit.ui.provider.AdapterFactoryContentProvider;
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider;
import org.eclipse.emf.edit.ui.provider.DecoratingColumLabelProvider;
import org.eclipse.emf.edit.ui.provider.DiagnosticDecorator;
import org.eclipse.emf.edit.ui.provider.UnwrappingSelectionProvider;
import org.eclipse.emf.edit.ui.util.EditUIMarkerHelper;
import org.eclipse.emf.edit.ui.util.EditUIUtil;
import org.eclipse.emf.edit.ui.view.ExtendedPropertySheetPage;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IStatusLineManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.dialogs.IDialogSettings;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.dialogs.ProgressMonitorDialog;
import org.eclipse.jface.util.LocalSelectionTransfer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.FileTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.actions.WorkspaceModifyOperation;
import org.eclipse.ui.dialogs.SaveAsDialog;
import org.eclipse.ui.ide.IGotoMarker;
import org.eclipse.ui.part.EditorPart;
import org.eclipse.ui.part.FileEditorInput;
import org.eclipse.ui.views.contentoutline.ContentOutline;
import org.eclipse.ui.views.contentoutline.ContentOutlinePage;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;
import org.eclipse.ui.views.properties.IPropertySheetPage;
import org.eclipse.ui.views.properties.PropertySheet;
import org.eclipse.ui.views.properties.PropertySheetPage;

import com.aljoschability.core.ui.Activator;
import com.aljoschability.core.ui.PartAdapter;
import com.aljoschability.core.ui.util.ViewUtil;

public class EcoreEditor extends EditorPart implements IEditingDomainProvider, ISelectionProvider, IViewerProvider,
		IGotoMarker {
	private final class UnextendableMenuManager extends MenuManager {
		private static final String POPUP_CLASS_NAME = "org.eclipse.ui.internal.PopupMenuExtender"; //$NON-NLS-1$

		@Override
		public void addMenuListener(IMenuListener listener) {
			if (POPUP_CLASS_NAME.equals(listener.getClass().getCanonicalName())) {
				return;
			}
			super.addMenuListener(listener);
		}
	}

	private final class EditorContentOutlinePage extends ContentOutlinePage {
		@Override
		public void createControl(Composite parent) {
			super.createControl(parent);
			contentOutlineViewer = getTreeViewer();
			contentOutlineViewer.addSelectionChangedListener(this);

			// Set up the tree viewer.
			contentOutlineViewer.setContentProvider(new AdapterFactoryContentProvider(adapterFactory));
			contentOutlineViewer.setLabelProvider(new DecoratingColumLabelProvider(new AdapterFactoryLabelProvider(
					adapterFactory), new DiagnosticDecorator(editingDomain, contentOutlineViewer, Activator.get()
					.getDialogSettings())));
			contentOutlineViewer.setInput(editingDomain.getResourceSet());

			new ColumnViewerInformationControlToolTipSupport(contentOutlineViewer,
					new DiagnosticDecorator.EditingDomainLocationListener(editingDomain, contentOutlineViewer));

			// Make sure our popups work.
			createContextMenuFor(contentOutlineViewer);

			if (!editingDomain.getResourceSet().getResources().isEmpty()) {
				// Select the root object in the view.
				contentOutlineViewer.setSelection(new StructuredSelection(editingDomain.getResourceSet().getResources()
						.get(0)), true);
			}
		}

		@Override
		public void makeContributions(IMenuManager menuManager, IToolBarManager toolBarManager,
				IStatusLineManager statusLineManager) {
			super.makeContributions(menuManager, toolBarManager, statusLineManager);
			contentOutlineStatusLineManager = statusLineManager;
		}

		@Override
		public void setActionBars(IActionBars actionBars) {
			super.setActionBars(actionBars);
			getActionBarContributor().shareGlobalActions(this, actionBars);
		}
	}

	private final class EditorPartAdapter extends PartAdapter {
		@Override
		public void partActivated(IWorkbenchPart p) {
			if (p instanceof ContentOutline) {
				if (((ContentOutline) p).getCurrentPage() == contentOutlinePage) {
					getActionBarContributor().setActiveEditor(EcoreEditor.this);

					setCurrentViewer(contentOutlineViewer);
				}
			} else if (p instanceof PropertySheet) {
				if (propertySheetPages.contains(((PropertySheet) p).getCurrentPage())) {
					getActionBarContributor().setActiveEditor(EcoreEditor.this);
					handleActivate();
				}
			} else if (p == EcoreEditor.this) {
				handleActivate();
			}
		}
	}

	private final class EditorPropertySheetPage extends ExtendedPropertySheetPage {
		private EditorPropertySheetPage(AdapterFactoryEditingDomain editingDomain, Decoration decoration,
				IDialogSettings dialogSettings) {
			super(editingDomain, decoration, dialogSettings);
		}

		@Override
		public void setActionBars(IActionBars actionBars) {
			super.setActionBars(actionBars);
			getActionBarContributor().shareGlobalActions(this, actionBars);
		}

		@Override
		public void setSelectionToViewer(List<?> selection) {
			EcoreEditor.this.setSelectionToViewer(selection);
			EcoreEditor.this.setFocus();
		}
	}

	private final class EditorResourceChangeListener implements IResourceChangeListener {
		@Override
		public void resourceChanged(IResourceChangeEvent event) {
			IResourceDelta delta = event.getDelta();
			try {
				class ResourceDeltaVisitor implements IResourceDeltaVisitor {
					protected ResourceSet resourceSet = editingDomain.getResourceSet();
					protected Collection<Resource> changedResources = new ArrayList<Resource>();
					protected Collection<Resource> removedResources = new ArrayList<Resource>();

					public Collection<Resource> getChangedResources() {
						return changedResources;
					}

					public Collection<Resource> getRemovedResources() {
						return removedResources;
					}

					@Override
					public boolean visit(final IResourceDelta delta) {
						if (delta.getResource().getType() == IResource.FILE) {
							if (delta.getKind() == IResourceDelta.REMOVED || delta.getKind() == IResourceDelta.CHANGED) {
								final Resource resource = resourceSet.getResource(
										URI.createPlatformResourceURI(delta.getFullPath().toString(), true), false);
								if (resource != null) {
									if (delta.getKind() == IResourceDelta.REMOVED) {
										removedResources.add(resource);
									} else {
										if ((delta.getFlags() & IResourceDelta.MARKERS) != 0) {
											DiagnosticDecorator.DiagnosticAdapter.update(
													resource,
													markerHelper.getMarkerDiagnostics(resource,
															(IFile) delta.getResource()));
										}
										if ((delta.getFlags() & IResourceDelta.CONTENT) != 0) {
											if (!savedResources.remove(resource)) {
												changedResources.add(resource);
											}
										}
									}
								}
							}
							return false;
						}

						return true;
					}
				}

				final ResourceDeltaVisitor visitor = new ResourceDeltaVisitor();
				delta.accept(visitor);

				if (!visitor.getRemovedResources().isEmpty()) {
					getSite().getShell().getDisplay().asyncExec(new Runnable() {
						@Override
						public void run() {
							removedResources.addAll(visitor.getRemovedResources());
							if (!isDirty()) {
								getSite().getPage().closeEditor(EcoreEditor.this, false);
							}
						}
					});
				}

				if (!visitor.getChangedResources().isEmpty()) {
					getSite().getShell().getDisplay().asyncExec(new Runnable() {
						@Override
						public void run() {
							changedResources.addAll(visitor.getChangedResources());
							if (getSite().getPage().getActiveEditor() == EcoreEditor.this) {
								handleActivate();
							}
						}
					});
				}
			} catch (CoreException exception) {
				Activator.get().error(exception);
			}
		}
	}

	private final class ProblemIndicatorAdapter extends EContentAdapter {
		@Override
		public void notifyChanged(Notification notification) {
			if (notification.getNotifier() instanceof Resource) {
				switch (notification.getFeatureID(Resource.class)) {
				case Resource.RESOURCE__IS_LOADED:
				case Resource.RESOURCE__ERRORS:
				case Resource.RESOURCE__WARNINGS: {
					Resource resource = (Resource) notification.getNotifier();
					Diagnostic diagnostic = analyzeResourceProblems(resource, null);
					if (diagnostic.getSeverity() != Diagnostic.OK) {
						resourceToDiagnosticMap.put(resource, diagnostic);
					} else {
						resourceToDiagnosticMap.remove(resource);
					}

					if (updateProblemIndication) {
						getSite().getShell().getDisplay().asyncExec(new Runnable() {
							@Override
							public void run() {
								updateProblemIndication();
							}
						});
					}
					break;
				}
				}
			} else {
				super.notifyChanged(notification);
			}
		}

		@Override
		protected void setTarget(Resource target) {
			basicSetTarget(target);
		}

		@Override
		protected void unsetTarget(Resource target) {
			basicUnsetTarget(target);
			resourceToDiagnosticMap.remove(target);
			if (updateProblemIndication) {
				getSite().getShell().getDisplay().asyncExec(new Runnable() {
					@Override
					public void run() {
						updateProblemIndication();
					}
				});
			}
		}
	}

	private AdapterFactoryEditingDomain editingDomain;
	private ComposedAdapterFactory adapterFactory;
	private IContentOutlinePage contentOutlinePage;
	private IStatusLineManager contentOutlineStatusLineManager;
	private TreeViewer contentOutlineViewer;
	private List<PropertySheetPage> propertySheetPages;
	private TreeViewer selectionViewer;
	private Viewer currentViewer;
	private ISelectionChangedListener selectionChangedListener;
	private Collection<ISelectionChangedListener> selectionChangedListeners;
	private ISelection editorSelection;
	private MarkerHelper markerHelper;

	private IPartListener partListener;
	private Collection<Resource> removedResources;
	private Collection<Resource> changedResources;
	private Collection<Resource> savedResources;
	private Map<Resource, Diagnostic> resourceToDiagnosticMap;
	private boolean updateProblemIndication;
	private EContentAdapter problemIndicationAdapter;
	private IResourceChangeListener resourceChangeListener;

	private static final List<String> NON_DYNAMIC_EXTENSIONS = Arrays.asList(new String[] { "xcore", "emof", "ecore",
			"genmodel" });

	public EcoreEditor() {
		super();
		initializeEditingDomain();

		editorSelection = StructuredSelection.EMPTY;

		propertySheetPages = new ArrayList<PropertySheetPage>();
		selectionChangedListeners = new ArrayList<ISelectionChangedListener>();

		removedResources = new ArrayList<Resource>();
		changedResources = new UniqueEList<Resource>();
		savedResources = new ArrayList<Resource>();

		markerHelper = new EditUIMarkerHelper();
		resourceToDiagnosticMap = new LinkedHashMap<Resource, Diagnostic>();
		updateProblemIndication = true;
	}

	@Override
	public void addSelectionChangedListener(ISelectionChangedListener listener) {
		selectionChangedListeners.add(listener);
	}

	private Diagnostic analyzeResourceProblems(Resource resource, Exception exception) {
		if (!resource.getErrors().isEmpty() || !resource.getWarnings().isEmpty()) {
			BasicDiagnostic basicDiagnostic = new BasicDiagnostic(Diagnostic.ERROR, Activator.get().getID(), 0,
					MessageFormat.format("_UI_CreateModelError_message {0}", resource.getURI()),
					new Object[] { exception == null ? (Object) resource : exception });
			basicDiagnostic.merge(EcoreUtil.computeDiagnostic(resource, true));
			return basicDiagnostic;
		} else if (exception != null) {
			return new BasicDiagnostic(Diagnostic.ERROR, "org.eclipse.emf.ecore.editor", 0, MessageFormat.format(
					"_UI_CreateModelError_message {0}", resource.getURI()), new Object[] { exception });
		} else {
			return Diagnostic.OK_INSTANCE;
		}
	}

	private void createContextMenuFor(StructuredViewer viewer) {
		MenuManager contextMenu = new UnextendableMenuManager();
		contextMenu.setRemoveAllWhenShown(true);
		contextMenu.addMenuListener(getActionBarContributor());
		Menu menu = contextMenu.createContextMenu(viewer.getControl());
		viewer.getControl().setMenu(menu);
		getSite().registerContextMenu(contextMenu, new UnwrappingSelectionProvider(viewer));

		int dndOperations = DND.DROP_COPY | DND.DROP_MOVE | DND.DROP_LINK;
		Transfer[] transfers = new Transfer[] { LocalTransfer.getInstance(), LocalSelectionTransfer.getTransfer(),
				FileTransfer.getInstance() };
		viewer.addDragSupport(dndOperations, transfers, new ViewerDragAdapter(viewer));
		viewer.addDropSupport(dndOperations, transfers, new EditingDomainViewerDropAdapter(editingDomain, viewer));

		viewer.getControl().addMouseListener(new MouseAdapter() {
			@Override
			public void mouseDoubleClick(MouseEvent event) {
				if (event.button == 1) {
					ViewUtil.open(ViewUtil.ID_PROPERTIES);
				}
			}
		});
	}

	private void createModel() {
		final ResourceSet resourceSet = editingDomain.getResourceSet();
		final EPackage.Registry packageRegistry = resourceSet.getPackageRegistry();
		resourceSet.getURIConverter().getURIMap().putAll(EcorePlugin.computePlatformURIMap(true));

		// we're in the reflective editor, set up an option to handle missing packages.
		final EPackage genModelEPackage = packageRegistry.getEPackage("http://www.eclipse.org/emf/2002/GenModel");
		if (genModelEPackage != null) {
			resourceSet.getLoadOptions().put(XMLResource.OPTION_MISSING_PACKAGE_HANDLER,
					new XMLResource.MissingPackageHandler() {
						protected EClass genModelEClass;
						protected EStructuralFeature genPackagesFeature;
						protected EClass genPackageEClass;
						protected EStructuralFeature ecorePackageFeature;
						protected Map<String, URI> ePackageNsURIToGenModelLocationMap;

						@Override
						public EPackage getPackage(String nsURI) {
							// Initialize the metadata for accessing the GenModel reflective the first time.
							if (genModelEClass == null) {
								genModelEClass = (EClass) genModelEPackage.getEClassifier("GenModel");
								genPackagesFeature = genModelEClass.getEStructuralFeature("genPackages");
								genPackageEClass = (EClass) genModelEPackage.getEClassifier("GenPackage");
								ecorePackageFeature = genPackageEClass.getEStructuralFeature("ecorePackage");
							}

							// Initialize the map from registered package namespaces to their GenModel locations the
							// first time.
							if (ePackageNsURIToGenModelLocationMap == null) {
								ePackageNsURIToGenModelLocationMap = EcorePlugin
										.getEPackageNsURIToGenModelLocationMap(true);
							}

							// Look up the namespace URI in the map.
							EPackage ePackage = null;
							URI uri = ePackageNsURIToGenModelLocationMap.get(nsURI);
							if (uri != null) {
								// If we find it, demand load the model.
								Resource resource = resourceSet.getResource(uri, true);

								// Locate the GenModel and fetech it's genPackages.
								EObject genModel = (EObject) EcoreUtil.getObjectByType(resource.getContents(),
										genModelEClass);
								@SuppressWarnings("unchecked")
								List<EObject> genPackages = (List<EObject>) genModel.eGet(genPackagesFeature);
								for (EObject genPackage : genPackages) {
									// Check if that package's Ecore Package has them matching namespace URI.
									EPackage dynamicEPackage = (EPackage) genPackage.eGet(ecorePackageFeature);
									if (nsURI.equals(dynamicEPackage.getNsURI())) {
										// If so, that's the package we want to return, and we add it to the
										// registry so it's easy to find from now on.
										ePackage = dynamicEPackage;
										packageRegistry.put(nsURI, ePackage);
										break;
									}
								}
							}
							return ePackage;
						}
					});
		}

		URI resourceURI = EditUIUtil.getURI(getEditorInput());
		Exception exception = null;
		Resource resource = null;
		try {
			// Load the resource through the editing domain.
			resource = editingDomain.getResourceSet().getResource(resourceURI, true);
		} catch (Exception e) {
			exception = e;
			resource = editingDomain.getResourceSet().getResource(resourceURI, false);
		}

		Diagnostic diagnostic = analyzeResourceProblems(resource, exception);
		if (diagnostic.getSeverity() != Diagnostic.OK) {
			resourceToDiagnosticMap.put(resource, analyzeResourceProblems(resource, exception));
		}
		editingDomain.getResourceSet().eAdapters().add(getProblemIndicationAdapter());

		if (!resourceSet.getResources().isEmpty()) {
			resource = resourceSet.getResources().get(0);
			if (resource instanceof XMLResource) {
				((XMLResource) resource).getDefaultSaveOptions().put(XMLResource.OPTION_LINE_WIDTH, 10);
			}
		}
	}

	@Override
	public void createPartControl(Composite parent) {
		// Creates the model from the editor input
		createModel();

		// Only creates the other pages if there is something that can be edited
		if (!getEditingDomain().getResourceSet().getResources().isEmpty()) {
			// Create a page for the selection tree view.
			Tree tree = new Tree(parent, SWT.MULTI);
			selectionViewer = new TreeViewer(tree);
			setCurrentViewer(selectionViewer);

			selectionViewer.setContentProvider(new AdapterFactoryContentProvider(adapterFactory));
			selectionViewer.setLabelProvider(new DecoratingColumLabelProvider(new AdapterFactoryLabelProvider(
					adapterFactory), new DiagnosticDecorator(editingDomain, selectionViewer, Activator.get()
					.getDialogSettings())));
			selectionViewer.setInput(editingDomain.getResourceSet());
			selectionViewer.setSelection(new StructuredSelection(editingDomain.getResourceSet().getResources().get(0)),
					true);

			new AdapterFactoryTreeEditor(selectionViewer.getTree(), adapterFactory);
			new ColumnViewerInformationControlToolTipSupport(selectionViewer,
					new DiagnosticDecorator.EditingDomainLocationListener(editingDomain, selectionViewer));

			createContextMenuFor(selectionViewer);
		}

		getSite().getShell().getDisplay().asyncExec(new Runnable() {
			@Override
			public void run() {
				updateProblemIndication();
			}
		});
	}

	@Override
	public void dispose() {
		updateProblemIndication = false;

		if (resourceChangeListener != null) {
			ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceChangeListener);
			resourceChangeListener = null;
		}

		if (partListener != null) {
			getSite().getPage().removePartListener(partListener);
			partListener = null;
		}

		adapterFactory.dispose();

		for (PropertySheetPage propertySheetPage : propertySheetPages) {
			propertySheetPage.dispose();
		}

		if (contentOutlinePage != null) {
			contentOutlinePage.dispose();
		}

		super.dispose();
	}

	@Override
	public void doSave(IProgressMonitor progressMonitor) {
		// Save only resources that have actually changed.
		final Map<Object, Object> saveOptions = new HashMap<Object, Object>();
		saveOptions.put(Resource.OPTION_SAVE_ONLY_IF_CHANGED, Resource.OPTION_SAVE_ONLY_IF_CHANGED_MEMORY_BUFFER);
		saveOptions.put(Resource.OPTION_LINE_DELIMITER, Resource.OPTION_LINE_DELIMITER_UNSPECIFIED);

		// Do the work within an operation because this is a long running activity that modifies the workbench.
		WorkspaceModifyOperation operation = new WorkspaceModifyOperation() {
			@Override
			public void execute(IProgressMonitor monitor) {
				// Save the resources to the file system.
				boolean first = true;
				for (Resource resource : editingDomain.getResourceSet().getResources()) {
					if ((first || !resource.getContents().isEmpty() || isPersisted(resource))
							&& !editingDomain.isReadOnly(resource)) {
						try {
							long timeStamp = resource.getTimeStamp();
							resource.save(saveOptions);
							if (resource.getTimeStamp() != timeStamp) {
								savedResources.add(resource);
							}
						} catch (Exception exception) {
							resourceToDiagnosticMap.put(resource, analyzeResourceProblems(resource, exception));
						}
						first = false;
					}
				}
			}
		};

		updateProblemIndication = false;
		try {
			// This runs the options, and shows progress.
			new ProgressMonitorDialog(getSite().getShell()).run(true, false, operation);

			// Refresh the necessary state.
			((BasicCommandStack) editingDomain.getCommandStack()).saveIsDone();
			firePropertyChange(IEditorPart.PROP_DIRTY);
		} catch (Exception exception) {
			Activator.get().error(exception);
		}

		updateProblemIndication = true;
		updateProblemIndication();
	}

	@Override
	public void doSaveAs() {
		SaveAsDialog saveAsDialog = new SaveAsDialog(getSite().getShell());
		saveAsDialog.create();
		saveAsDialog.setMessage("_UI_SaveAs_message");
		saveAsDialog.open();
		IPath path = saveAsDialog.getResult();
		if (path != null) {
			IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(path);
			if (file != null) {
				ResourceSet resourceSet = editingDomain.getResourceSet();
				Resource currentResource = resourceSet.getResources().get(0);
				String currentExtension = currentResource.getURI().fileExtension();

				URI newURI = URI.createPlatformResourceURI(file.getFullPath().toString(), true);
				String newExtension = newURI.fileExtension();

				if (currentExtension.equals(newExtension)) {
					currentResource.setURI(newURI);
				} else {
					Resource newResource = resourceSet.createResource(newURI);
					newResource.getContents().addAll(currentResource.getContents());
					resourceSet.getResources().remove(0);
					resourceSet.getResources().move(0, newResource);
				}

				IFileEditorInput modelFile = new FileEditorInput(file);
				setInputWithNotify(modelFile);
				setPartName(file.getName());
				doSave(getActionBars().getStatusLineManager().getProgressMonitor());
			}
		}
	}

	private EcoreEditorContributor getActionBarContributor() {
		return (EcoreEditorContributor) getEditorSite().getActionBarContributor();
	}

	private IActionBars getActionBars() {
		return getActionBarContributor().getActionBars();
	}

	@Override
	public Object getAdapter(@SuppressWarnings("rawtypes") Class type) {
		if (type.equals(IContentOutlinePage.class)) {
			return showOutlineView() ? getContentOutlinePage() : null;
		} else if (type.equals(IPropertySheetPage.class)) {
			return getPropertySheetPage();
		} else if (type.equals(IGotoMarker.class)) {
			return this;
		} else if ("org.eclipse.ui.texteditor.ITextEditor".equals(type.getName())) {
			// WTP registers a property tester that tries to get this adapter even when closing the workbench
			// at which point the multi-page editor is already disposed and throws an exception.
			// Of course the Ecore editor can never be adapted to a text editor, so we can just always return null.
			return null;
		}
		return super.getAdapter(type);
	}

	private IContentOutlinePage getContentOutlinePage() {
		if (contentOutlinePage == null) {
			// The content outline is just a tree.
			contentOutlinePage = new EditorContentOutlinePage();

			// Listen to selection so that we can handle it is a special way.
			contentOutlinePage.addSelectionChangedListener(new ISelectionChangedListener() {
				// This ensures that we handle selections correctly.
				@Override
				public void selectionChanged(SelectionChangedEvent event) {
					handleContentOutlineSelection(event.getSelection());
				}
			});
		}

		return contentOutlinePage;
	}

	/**
	 * This returns the editing domain as required by the {@link IEditingDomainProvider} interface. This is important
	 * for implementing the static methods of {@link AdapterFactoryEditingDomain} and for supporting
	 * {@link org.eclipse.emf.edit.ui.action.CommandAction}. <!-- begin-user-doc --> <!-- end-user-doc -->
	 * 
	 * @generated
	 */
	@Override
	public EditingDomain getEditingDomain() {
		return editingDomain;
	}

	private IPartListener getPartListener() {
		if (partListener == null) {
			partListener = new EditorPartAdapter();
		}
		return partListener;
	}

	private EContentAdapter getProblemIndicationAdapter() {
		if (problemIndicationAdapter == null) {
			problemIndicationAdapter = new ProblemIndicatorAdapter();
		}
		return problemIndicationAdapter;
	}

	private IPropertySheetPage getPropertySheetPage() {
		PropertySheetPage propertySheetPage = new EditorPropertySheetPage(editingDomain,
				ExtendedPropertySheetPage.Decoration.LIVE, Activator.get().getDialogSettings());
		propertySheetPage.setPropertySourceProvider(new AdapterFactoryContentProvider(adapterFactory));
		propertySheetPages.add(propertySheetPage);

		return propertySheetPage;
	}

	private IResourceChangeListener getResourceChangeListener() {
		if (resourceChangeListener == null) {
			resourceChangeListener = new EditorResourceChangeListener();
		}
		return resourceChangeListener;
	}

	@Override
	public ISelection getSelection() {
		return editorSelection;
	}

	@Override
	public Viewer getViewer() {
		return currentViewer;
	}

	@Override
	public void gotoMarker(IMarker marker) {
		List<?> targetObjects = markerHelper.getTargetObjects(editingDomain, marker);
		if (!targetObjects.isEmpty()) {
			setSelectionToViewer(targetObjects);
		}
	}

	private void handleActivate() {
		if (removedResources.isEmpty() && !changedResources.isEmpty()) {
			for (Resource resource : editingDomain.getResourceSet().getResources()) {
				if (!changedResources.contains(resource)) {
					URI uri = resource.getURI();
					if (!"java".equals(uri.scheme()) && !NON_DYNAMIC_EXTENSIONS.contains(uri.fileExtension())) {
						for (Iterator<EObject> i = resource.getAllContents(); i.hasNext();) {
							EObject eObject = i.next();
							if (changedResources.contains(eObject.eClass().eResource())) {
								changedResources.add(resource);
								break;
							}
						}
					}
				}
			}
		}
		handleActivateGen();
	}

	private void handleActivateGen() {
		// Recompute the read only state.
		if (editingDomain.getResourceToReadOnlyMap() != null) {
			editingDomain.getResourceToReadOnlyMap().clear();

			// Refresh any actions that may become enabled or disabled.
			setSelection(getSelection());
		}

		if (!removedResources.isEmpty()) {
			if (handleDirtyConflict()) {
				getSite().getPage().closeEditor(EcoreEditor.this, false);
			} else {
				removedResources.clear();
				changedResources.clear();
				savedResources.clear();
			}
		} else if (!changedResources.isEmpty()) {
			changedResources.removeAll(savedResources);
			handleChangedResources();
			changedResources.clear();
			savedResources.clear();
		}
	}

	private void handleChangedResources() {
		if (!changedResources.isEmpty() && (!isDirty() || handleDirtyConflict())) {
			if (isDirty()) {
				changedResources.addAll(editingDomain.getResourceSet().getResources());
			}
			editingDomain.getCommandStack().flush();

			updateProblemIndication = false;
			List<Resource> unloadedResources = new ArrayList<Resource>();
			for (Resource resource : changedResources) {
				if (resource.isLoaded()) {
					resource.unload();
					unloadedResources.add(resource);
				}
			}

			for (Resource resource : unloadedResources) {
				try {
					resource.load(Collections.EMPTY_MAP);
				} catch (IOException exception) {
					if (!resourceToDiagnosticMap.containsKey(resource)) {
						resourceToDiagnosticMap.put(resource, analyzeResourceProblems(resource, exception));
					}
				}
			}

			if (AdapterFactoryEditingDomain.isStale(editorSelection)) {
				setSelection(StructuredSelection.EMPTY);
			}

			updateProblemIndication = true;
			updateProblemIndication();
		}
	}

	private void handleContentOutlineSelection(ISelection selection) {
		if (selectionViewer != null && !selection.isEmpty() && selection instanceof IStructuredSelection) {
			Iterator<?> selectedElements = ((IStructuredSelection) selection).iterator();
			if (selectedElements.hasNext()) {
				// Get the first selected element.
				Object selectedElement = selectedElements.next();

				ArrayList<Object> selectionList = new ArrayList<Object>();
				selectionList.add(selectedElement);
				while (selectedElements.hasNext()) {
					selectionList.add(selectedElements.next());
				}

				// Set the selection to the widget.
				selectionViewer.setSelection(new StructuredSelection(selectionList));
			}
		}
	}

	private boolean handleDirtyConflict() {
		return MessageDialog.openQuestion(getSite().getShell(), "_UI_FileConflict_label", "_WARN_FileConflict");
	}

	@Override
	public void init(IEditorSite site, IEditorInput editorInput) {
		setSite(site);
		setInputWithNotify(editorInput);
		setPartName(editorInput.getName());
		site.setSelectionProvider(this);
		site.getPage().addPartListener(getPartListener());
		ResourcesPlugin.getWorkspace().addResourceChangeListener(getResourceChangeListener(),
				IResourceChangeEvent.POST_CHANGE);
	}

	private void initializeEditingDomain() {
		// Create an adapter factory that yields item providers.
		adapterFactory = new ComposedAdapterFactory(ComposedAdapterFactory.Descriptor.Registry.INSTANCE);

		adapterFactory.addAdapterFactory(new ResourceItemProviderAdapterFactory());
		adapterFactory.addAdapterFactory(new EcoreItemProviderAdapterFactory());
		adapterFactory.addAdapterFactory(new ReflectiveItemProviderAdapterFactory());
		// adapterFactory.addAdapterFactory(new CustomStoditoItemProviderAdapterFactory());

		// Create the command stack that will notify this editor as commands are executed.
		BasicCommandStack commandStack = new BasicCommandStack();

		// Add a listener to set the most recent command's affected objects to be the selection of the viewer with
		// focus.
		commandStack.addCommandStackListener(new CommandStackListener() {
			@Override
			public void commandStackChanged(final EventObject event) {
				getSite().getShell().getDisplay().asyncExec(new Runnable() {
					@Override
					public void run() {
						firePropertyChange(IEditorPart.PROP_DIRTY);

						// Try to select the affected objects.
						Command mostRecentCommand = ((CommandStack) event.getSource()).getMostRecentCommand();
						if (mostRecentCommand != null) {
							setSelectionToViewer(mostRecentCommand.getAffectedObjects());
						}
						for (Iterator<PropertySheetPage> i = propertySheetPages.iterator(); i.hasNext();) {
							PropertySheetPage propertySheetPage = i.next();
							if (propertySheetPage.getControl().isDisposed()) {
								i.remove();
							} else {
								propertySheetPage.refresh();
							}
						}
					}
				});
			}
		});

		// Create the editing domain with a special command stack.
		editingDomain = new AdapterFactoryEditingDomain(adapterFactory, commandStack) {
			{
				resourceToReadOnlyMap = new HashMap<Resource, Boolean>();
			}

			@Override
			public boolean isReadOnly(Resource resource) {
				if (super.isReadOnly(resource) || resource == null) {
					return true;
				} else {
					URI uri = resource.getURI();
					boolean result = "java".equals(uri.scheme()) || "xcore".equals(uri.fileExtension())
							|| "genmodel".equals(uri.fileExtension()) || uri.isPlatformResource()
							&& !resourceSet.getURIConverter().normalize(uri).isPlatformResource();
					if (resourceToReadOnlyMap != null) {
						resourceToReadOnlyMap.put(resource, result);
					}
					return result;
				}
			}
		};
	}

	@Override
	public boolean isDirty() {
		return ((BasicCommandStack) editingDomain.getCommandStack()).isSaveNeeded();
	}

	/**
	 * This returns whether something has been persisted to the URI of the specified resource. The implementation uses
	 * the URI converter from the editor's resource set to try to open an input stream.
	 */
	private boolean isPersisted(Resource resource) {
		boolean result = false;
		try {
			InputStream stream = editingDomain.getResourceSet().getURIConverter().createInputStream(resource.getURI());
			if (stream != null) {
				result = true;
				stream.close();
			}
		} catch (IOException e) {
			// Ignore
		}
		return result;
	}

	@Override
	public boolean isSaveAsAllowed() {
		return true;
	}

	@Override
	public void removeSelectionChangedListener(ISelectionChangedListener listener) {
		selectionChangedListeners.remove(listener);
	}

	/**
	 * This makes sure that one content viewer, either for the current page or the outline view, if it has focus, is the
	 * current one.
	 */
	private void setCurrentViewer(Viewer viewer) {
		// If it is changing...
		if (currentViewer != viewer) {
			if (selectionChangedListener == null) {
				// Create the listener on demand.
				selectionChangedListener = new ISelectionChangedListener() {
					// This just notifies those things that are affected by the section.
					@Override
					public void selectionChanged(SelectionChangedEvent selectionChangedEvent) {
						setSelection(selectionChangedEvent.getSelection());
					}
				};
			}

			// Stop listening to the old one.
			if (currentViewer != null) {
				currentViewer.removeSelectionChangedListener(selectionChangedListener);
			}

			// Start listening to the new one.
			if (viewer != null) {
				viewer.addSelectionChangedListener(selectionChangedListener);
			}

			// Remember it.
			currentViewer = viewer;

			// Set the editors selection based on the current viewer's selection.
			setSelection(currentViewer == null ? StructuredSelection.EMPTY : currentViewer.getSelection());
		}
	}

	@Override
	public void setFocus() {
		if (currentViewer != null && !currentViewer.getControl().isDisposed()) {
			currentViewer.getControl().setFocus();
		}
	}

	@Override
	public void setSelection(ISelection selection) {
		editorSelection = selection;

		for (ISelectionChangedListener listener : selectionChangedListeners) {
			listener.selectionChanged(new SelectionChangedEvent(this, selection));
		}
		setStatusLineManager(selection);
	}

	/**
	 * This sets the selection into whichever viewer is active.
	 */
	private void setSelectionToViewer(Collection<?> collection) {
		final Collection<?> theSelection = collection;
		// Make sure it's okay.
		if (theSelection != null && !theSelection.isEmpty()) {
			Runnable runnable = new Runnable() {
				@Override
				public void run() {
					// Try to select the items in the current content viewer of the editor.
					if (currentViewer != null) {
						currentViewer.setSelection(new StructuredSelection(theSelection.toArray()), true);
					}
				}
			};
			getSite().getShell().getDisplay().asyncExec(runnable);
		}
	}

	private void setStatusLineManager(ISelection selection) {
		IStatusLineManager statusLineManager = currentViewer != null && currentViewer == contentOutlineViewer ? contentOutlineStatusLineManager
				: getActionBars().getStatusLineManager();

		if (statusLineManager != null) {
			if (selection instanceof IStructuredSelection) {
				Collection<?> collection = ((IStructuredSelection) selection).toList();
				switch (collection.size()) {
				case 0: {
					statusLineManager.setMessage("No item selected");
					break;
				}
				case 1: {
					Object element = collection.iterator().next();
					AdapterFactoryItemDelegator delegator = new AdapterFactoryItemDelegator(adapterFactory);
					String text = delegator.getText(element);
					Object image = delegator.getImage(element);
					if (image instanceof Image) {
						statusLineManager.setMessage((Image) image, text);
					} else {
						statusLineManager.setMessage(text);
					}
					break;
				}
				default: {
					statusLineManager.setMessage(MessageFormat.format("{0} items selected", collection.size()));
					break;
				}
				}
			} else {
				statusLineManager.setMessage("");
			}
		} else {
			System.out.println("status line manager not found!");
		}
	}

	/**
	 * Returns whether the outline view should be presented to the user.
	 */
	private boolean showOutlineView() {
		return true;
	}

	/**
	 * Updates the problems indication with the information described in the specified diagnostic.
	 */
	private void updateProblemIndication() {
		if (updateProblemIndication) {
			BasicDiagnostic diagnostic = new BasicDiagnostic(Diagnostic.OK, "org.eclipse.emf.ecore.editor", 0, null,
					new Object[] { editingDomain.getResourceSet() });
			for (Diagnostic childDiagnostic : resourceToDiagnosticMap.values()) {
				if (childDiagnostic.getSeverity() != Diagnostic.OK) {
					diagnostic.add(childDiagnostic);
				}
			}

			if (diagnostic.getSeverity() != Diagnostic.OK) {
				// TODO: handle diagnostic
				System.out.println(diagnostic);
			}

			if (markerHelper.hasMarkers(editingDomain.getResourceSet())) {
				markerHelper.deleteMarkers(editingDomain.getResourceSet());
				if (diagnostic.getSeverity() != Diagnostic.OK) {
					try {
						markerHelper.createMarkers(diagnostic);
					} catch (CoreException exception) {
						Activator.get().error(exception);
					}
				}
			}
		}
	}
}
