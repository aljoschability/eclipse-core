package com.aljoschability.eclipse.core.graphiti.outline.thumb;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.Iterator;
import java.util.Map;

import org.eclipse.draw2d.Figure;
import org.eclipse.draw2d.FigureListener;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.KeyEvent;
import org.eclipse.draw2d.KeyListener;
import org.eclipse.draw2d.MouseEvent;
import org.eclipse.draw2d.SWTGraphics;
import org.eclipse.draw2d.UpdateListener;
import org.eclipse.draw2d.Viewport;
import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;

public class DiagramOutlineThumbnail extends Figure implements UpdateListener, Thumb {

	class ScrollSynchronizer extends MouseAdapter {
		private final Thumb thumb;

		private Point startLocation;
		private Point viewLocation;

		public ScrollSynchronizer(Thumb thumb) {
			this.thumb = thumb;
		}

		@Override
		public void mousePressed(MouseEvent me) {
			startLocation = me.getLocation();
			viewLocation = thumb.getViewLocation();
			me.consume();
		}

		@Override
		public void mouseDragged(MouseEvent me) {
			Dimension d = me.getLocation().getDifference(startLocation);
			d.scale(1.0f / thumb.getViewportScaleX(), 1.0f / thumb.getViewportScaleY());
			thumb.setViewLocation(viewLocation.getTranslated(d));
			me.consume();
		}
	}

	class ClickScrollerAndDragTransferrer extends MouseAdapter {
		private boolean dragTransfer;

		@Override
		public void mouseDragged(MouseEvent me) {
			if (dragTransfer) {
				syncher.mouseDragged(me);
			}
		}

		@Override
		public void mousePressed(MouseEvent me) {
			if (!DiagramOutlineThumbnail.this.getClientArea().contains(me.getLocation())) {
				return;
			}
			Dimension selectorCenter = selector.getBounds().getSize().scale(0.5f);
			Point scrollPoint = me
					.getLocation()
					.getTranslated(getLocation().getNegated())
					.translate(selectorCenter.negate())
					.scale(1.0f / getViewportScaleX(), 1.0f / getViewportScaleY())
					.translate(viewport.getHorizontalRangeModel().getMinimum(),
							viewport.getVerticalRangeModel().getMinimum());
			viewport.setViewLocation(scrollPoint);
			syncher.mousePressed(me);
			dragTransfer = true;
		}

		@Override
		public void mouseReleased(MouseEvent me) {
			syncher.mouseReleased(me);
			dragTransfer = false;
		}
	}

	class ThumbnailUpdater implements Runnable {
		static final int MAX_BUFFER_SIZE = 256;

		private int currentHTile;
		private int currentVTile;
		private int hTiles;
		private int vTiles;
		private boolean isActive;

		private boolean isRunning;
		private GC thumbnailGC;
		private Graphics thumbnailGraphics;
		private Dimension tileSize;

		private Image thumbnailImage;
		private Dimension thumbnailImageSize;

		public Image getThumbnailImage() {
			return thumbnailImage;
		}

		public ThumbnailUpdater() {
			isActive = true;
			isRunning = false;
		}

		private void deactivate() {
			setActive(false);
			stop();
			if (thumbnailImage != null) {
				thumbnailImage.dispose();
				thumbnailImage = null;
				thumbnailImageSize = null;
			}
		}

		private int getCurrentHTile() {
			return currentHTile;
		}

		private int getCurrentVTile() {
			return currentVTile;
		}

		private boolean isActive() {
			return isActive;
		}

		private boolean isRunning() {
			return isRunning;
		}

		private void resetThumbnailImage() {
			if (thumbnailImage != null) {
				thumbnailImage.dispose();
			}

			if (!targetSize.isEmpty()) {
				if (thumbnailImage != null && !thumbnailImage.isDisposed()) {
					thumbnailImage.dispose();
				}
				thumbnailImage = new Image(Display.getDefault(), targetSize.width, targetSize.height);
				thumbnailImageSize = new Dimension(targetSize);
			} else {
				thumbnailImage = null;
				thumbnailImageSize = new Dimension(0, 0);
			}
		}

		private void resetTileValues() {
			hTiles = (int) Math.ceil((float) getSourceRectangle().width / (float) MAX_BUFFER_SIZE);
			vTiles = (int) Math.ceil((float) getSourceRectangle().height / (float) MAX_BUFFER_SIZE);

			tileSize = new Dimension((int) Math.ceil((float) getSourceRectangle().width / (float) hTiles),
					(int) Math.ceil((float) getSourceRectangle().height / (float) vTiles));

			currentHTile = 0;
			currentVTile = 0;
		}

		private void restart() {
			stop();
			start();
		}

		@Override
		public void run() {
			if (!isActive() || !isRunning()) {
				return;
			}

			int v = getCurrentVTile();
			int sy1 = v * tileSize.height;
			int sy2 = Math.min((v + 1) * tileSize.height, getSourceRectangle().height);

			int h = getCurrentHTile();
			int sx1 = h * tileSize.width;
			int sx2 = Math.min((h + 1) * tileSize.width, getSourceRectangle().width);
			org.eclipse.draw2d.geometry.Point p = getSourceRectangle().getLocation();

			Rectangle rect = new Rectangle(sx1 + p.x, sy1 + p.y, sx2 - sx1, sy2 - sy1);

			// use the complete rectangle, not just a tile
			rect = getSourceRectangle().getCopy();

			thumbnailGraphics.pushState();
			thumbnailGraphics.setClip(rect);
			thumbnailGraphics.fillRectangle(rect);

			try {
				sourceFigure.paint(thumbnailGraphics);
			} catch (SWTException e) {
			} catch (IllegalArgumentException e) {
			}

			thumbnailGraphics.popState();

			if (getCurrentHTile() < hTiles - 1) {
				setCurrentHTile(getCurrentHTile() + 1);
			} else {
				setCurrentHTile(0);
				if (getCurrentVTile() < vTiles - 1) {
					setCurrentVTile(getCurrentVTile() + 1);
				} else {
					setCurrentVTile(0);
				}
			}

			stop();
			repaint();
		}

		private void setActive(boolean value) {
			isActive = value;
		}

		private void setCurrentHTile(int count) {
			currentHTile = count;
		}

		private void setCurrentVTile(int count) {
			currentVTile = count;
		}

		private void start() {
			if (!isActive() || isRunning()) {
				return;
			}

			isRunning = true;
			setDirty(false);
			resetTileValues();

			if (!targetSize.equals(thumbnailImageSize)) {
				resetThumbnailImage();
			}

			if (targetSize.isEmpty()) {
				return;
			}

			thumbnailGC = new GC(thumbnailImage, sourceFigure.isMirrored() ? SWT.RIGHT_TO_LEFT : SWT.NONE);
			thumbnailGraphics = new DiagramOutlineGraphics(new SWTGraphics(thumbnailGC));
			thumbnailGraphics.scale(getScaleX());
			thumbnailGraphics.translate(getSourceRectangle().getLocation().negate());

			Color color = sourceFigure.getForegroundColor();
			if (color != null) {
				thumbnailGraphics.setForegroundColor(color);
			}
			color = sourceFigure.getBackgroundColor();
			if (color != null) {
				thumbnailGraphics.setBackgroundColor(color);
			}
			thumbnailGraphics.setFont(sourceFigure.getFont());

			setScales(targetSize.width / (float) getSourceRectangle().width, targetSize.height
					/ (float) getSourceRectangle().height);

			Display.getCurrent().asyncExec(this);
		}

		private void stop() {
			isRunning = false;
			if (thumbnailGraphics != null) {
				thumbnailGraphics.dispose();
				thumbnailGraphics = null;
			}
			if (thumbnailGC != null) {
				thumbnailGC.dispose();
				thumbnailGC = null;
			}
			// Don't dispose of the thumbnail image since it is needed to paint the figure when the source is not dirty
			// (i.e. showing/hiding the dock).
		}
	}

	private SelectorFigure selector;

	private ScrollSynchronizer syncher;

	private Viewport viewport;

	private boolean isDirty;
	private float scaleX;
	private float scaleY;

	private IFigure sourceFigure;

	Dimension targetSize = new Dimension(0, 0);
	private ThumbnailUpdater updater = new ThumbnailUpdater();

	private FigureListener figureListener = new FigureListener() {
		@Override
		public void figureMoved(IFigure source) {
			reconfigureSelectorBounds();
		}
	};

	private KeyListener keyListener = new KeyListener.Stub() {
		@Override
		public void keyPressed(KeyEvent ke) {
			int moveX = viewport.getClientArea().width / 4;
			int moveY = viewport.getClientArea().height / 4;
			if (ke.keycode == SWT.HOME || (isMirrored() ? ke.keycode == SWT.ARROW_RIGHT : ke.keycode == SWT.ARROW_LEFT)) {
				viewport.setViewLocation(viewport.getViewLocation().translate(-moveX, 0));
			} else if (ke.keycode == SWT.END
					|| (isMirrored() ? ke.keycode == SWT.ARROW_LEFT : ke.keycode == SWT.ARROW_RIGHT)) {
				viewport.setViewLocation(viewport.getViewLocation().translate(moveX, 0));
			} else if (ke.keycode == SWT.ARROW_UP || ke.keycode == SWT.PAGE_UP) {
				viewport.setViewLocation(viewport.getViewLocation().translate(0, -moveY));
			} else if (ke.keycode == SWT.ARROW_DOWN || ke.keycode == SWT.PAGE_DOWN) {
				viewport.setViewLocation(viewport.getViewLocation().translate(0, moveY));
			}
		}
	};

	private PropertyChangeListener propListener = new PropertyChangeListener() {
		@Override
		public void propertyChange(PropertyChangeEvent evt) {
			reconfigureSelectorBounds();
		}
	};

	public DiagramOutlineThumbnail(Viewport port) {
		super();
		setViewport(port);
		initialize();
	}

	private Dimension adjustToAspectRatio(Dimension size, boolean adjustToMaxDimension) {
		Dimension sourceSize = getSourceRectangle().getSize();
		Dimension borderSize = new Dimension(getInsets().getWidth(), getInsets().getHeight());
		size.expand(borderSize.getNegated());
		int width, height;
		if (adjustToMaxDimension) {
			width = Math.max(size.width, (int) (size.height * sourceSize.width / (float) sourceSize.height + 0.5));
			height = Math.max(size.height, (int) (size.width * sourceSize.height / (float) sourceSize.width + 0.5));
		} else {
			width = Math.min(size.width, (int) (size.height * sourceSize.width / (float) sourceSize.height + 0.5));
			height = Math.min(size.height, (int) (size.width * sourceSize.height / (float) sourceSize.width + 0.5));
		}
		size.width = width;
		size.height = height;
		return size.expand(borderSize);
	}

	public void deactivate() {
		viewport.removePropertyChangeListener(Viewport.PROPERTY_VIEW_LOCATION, propListener);
		viewport.removeFigureListener(figureListener);
		if (selector.getParent() == this) { // if this method was called before,
			// the selector might already be
			// removed
			remove(selector);
		}
		disposeSelector();

		sourceFigure.getUpdateManager().removeUpdateListener(this);
		updater.deactivate();
	}

	public void disposeSelector() {
		selector.dispose();
	}

	@Override
	public Dimension getPreferredSize(int wHint, int hHint) {
		if (prefSize == null) {
			return adjustToAspectRatio(getBounds().getSize(), false);
		}

		Dimension preferredSize = adjustToAspectRatio(prefSize.getCopy(), true);

		if (maxSize == null) {
			return preferredSize;
		}

		Dimension maximumSize = adjustToAspectRatio(maxSize.getCopy(), true);
		if (preferredSize.contains(maximumSize)) {
			return maximumSize;
		} else {
			return preferredSize;
		}
	}

	protected float getScaleX() {
		return scaleX;
	}

	protected float getScaleY() {
		return scaleY;
	}

	protected IFigure getSource() {
		return sourceFigure;
	}

	protected Rectangle getSourceRectangle() {
		return sourceFigure.getBounds();
	}

	public Image getThumbnailImage() {
		Dimension oldSize = targetSize;
		targetSize = getPreferredSize();
		targetSize.expand(new Dimension(getInsets().getWidth(), getInsets().getHeight()).negate());
		setScales(targetSize.width / (float) getSourceRectangle().width, targetSize.height
				/ (float) getSourceRectangle().height);
		if (isDirty() && !updater.isRunning()) {
			updater.start();
		} else if (oldSize != null && !targetSize.equals(oldSize)) {
			revalidate();
			updater.restart();
		}

		return updater.getThumbnailImage();
	}

	public double getViewportScaleX() {
		return (double) targetSize.width / viewport.getContents().getBounds().width;
	}

	public double getViewportScaleY() {
		return (double) targetSize.height / viewport.getContents().getBounds().height;
	}

	private void initialize() {
		syncher = new ScrollSynchronizer(this);

		selector = new SelectorFigure(this);
		selector.addMouseListener(syncher);
		selector.addMouseMotionListener(syncher);
		selector.setFocusTraversable(true);
		selector.addKeyListener(keyListener);
		add(selector);
		ClickScrollerAndDragTransferrer transferrer = new ClickScrollerAndDragTransferrer();
		addMouseListener(transferrer);
		addMouseMotionListener(transferrer);
	}

	protected boolean isDirty() {
		return isDirty;
	}

	@Override
	public void notifyPainting(Rectangle damage, @SuppressWarnings("rawtypes") Map dirtyRegions) {
		Iterator<?> dirtyFigures = dirtyRegions.keySet().iterator();
		while (dirtyFigures.hasNext()) {
			IFigure current = (IFigure) dirtyFigures.next();
			while (current != null) {
				if (current == getSource()) {
					setDirty(true);
					repaint();
					return;
				}
				current = current.getParent();
			}
		}
	}

	@Override
	public void notifyValidating() {
		// setDirty(true);
		// revalidate();
	}

	@Override
	protected void paintFigure(Graphics graphics) {
		Image thumbnail = getThumbnailImage();
		if (thumbnail == null) {
			return;
		}
		graphics.drawImage(thumbnail, getClientArea().getLocation());
	}

	private void reconfigureSelectorBounds() {
		Rectangle rect = new Rectangle();
		Point offset = viewport.getViewLocation();
		offset.x -= viewport.getHorizontalRangeModel().getMinimum();
		offset.y -= viewport.getVerticalRangeModel().getMinimum();
		rect.setLocation(offset);
		rect.setSize(viewport.getClientArea().getSize());
		rect.scale(getViewportScaleX(), getViewportScaleY());
		rect.translate(getClientArea().getLocation());
		selector.setBounds(rect);
	}

	public void setDirty(boolean value) {
		isDirty = value;
	}

	protected void setScales(float scaleX, float scaleY) {
		if (scaleX == getScaleX() && scaleY == getScaleY()) {
			return;
		}

		this.scaleX = scaleX;
		this.scaleY = scaleY;
		reconfigureSelectorBounds();
	}

	public void setSource(IFigure fig) {
		if (sourceFigure == fig) {
			return;
		}
		if (sourceFigure != null) {
			sourceFigure.getUpdateManager().removeUpdateListener(this);
		}
		sourceFigure = fig;
		if (sourceFigure != null) {
			setScales((float) getSize().width / (float) getSourceRectangle().width, (float) getSize().height
					/ (float) getSourceRectangle().height);
			sourceFigure.getUpdateManager().addUpdateListener(this);
			repaint();
		}
	}

	public void setViewport(Viewport port) {
		port.addPropertyChangeListener(Viewport.PROPERTY_VIEW_LOCATION, propListener);
		port.addFigureListener(figureListener);
		viewport = port;
	}

	@Override
	public void setViewLocation(Point p) {
		viewport.setViewLocation(p.x(), p.y());
	}

	@Override
	public Point getViewLocation() {
		return viewport.getViewLocation();
	}
}
