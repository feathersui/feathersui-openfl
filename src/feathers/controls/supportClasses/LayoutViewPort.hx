/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.layout.ISnapLayout;
import feathers.layout.IScrollLayout;
import feathers.utils.MeasurementsUtil;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.geom.Point;

/**
	An implementation of `IViewPort` that provides support for layouts.

	@since 1.0.0
**/
class LayoutViewPort extends LayoutGroup implements IViewPort {
	/**
		Creates a new `LayoutViewPort` object.

		@since 1.0.0
	**/
	public function new() {
		super();

		// an invisible background that makes the entire width and height of the
		// viewport interactive for touch scrolling
		this._viewPortBackground = new Sprite();
		this._viewPortBackground.graphics.beginFill(0xff00ff, 0.0);
		this._viewPortBackground.graphics.drawRect(0.0, 0.0, 1.0, 1.0);
		this._viewPortBackground.graphics.endFill();
		// we're not using the backgroundSkin property because it is not sized
		// to fill the entire view port visible size when the content size is
		// smaller than the view port size
		this._addChildAt(this._viewPortBackground, 0);
	}

	private var _viewPortBackground:Sprite;

	private var _actualMinVisibleWidth:Float = 0.0;
	private var _explicitMinVisibleWidth:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.minVisibleWidth`
	**/
	public var minVisibleWidth(get, set):Null<Float>;

	private function get_minVisibleWidth():Null<Float> {
		if (this._explicitMinVisibleWidth == null) {
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}

	private function set_minVisibleWidth(value:Null<Float>):Null<Float> {
		if (this._explicitMinVisibleWidth == value) {
			return this._explicitMinVisibleWidth;
		}
		var oldValue = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if (value == null) {
			this._actualMinVisibleWidth = 0.0;
			this.setInvalid(SIZE);
		} else {
			this._actualMinVisibleWidth = value;
			if (this._explicitVisibleWidth == null && (this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue)) {
				// only invalidate if this change might affect the visibleWidth
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMinVisibleWidth;
	}

	private var _maxVisibleWidth:Null<Float> = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleWidth`
	**/
	public var maxVisibleWidth(get, set):Null<Float>;

	private function get_maxVisibleWidth():Null<Float> {
		return this._maxVisibleWidth;
	}

	private function set_maxVisibleWidth(value:Null<Float>):Null<Float> {
		if (this._maxVisibleWidth == value) {
			return this._maxVisibleWidth;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleWidth cannot be null");
		}
		var oldValue = this._maxVisibleWidth;
		this._maxVisibleWidth = value;
		if (this._explicitVisibleWidth == null && (this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue)) {
			// only invalidate if this change might affect the visibleWidth
			this.setInvalid(SIZE);
		}
		return this._maxVisibleWidth;
	}

	private var _actualVisibleWidth:Float = 0.0;
	private var _explicitVisibleWidth:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.visibleWidth`
	**/
	public var visibleWidth(get, set):Null<Float>;

	private function get_visibleWidth():Null<Float> {
		if (this._explicitVisibleWidth == null) {
			return this._actualVisibleWidth;
		}
		return this._explicitVisibleWidth;
	}

	private function set_visibleWidth(value:Null<Float>):Null<Float> {
		if (this._explicitVisibleWidth == value) {
			return this._explicitVisibleWidth;
		}
		this._explicitVisibleWidth = value;
		if (this._actualVisibleWidth != value) {
			this.setInvalid(SIZE);
		}
		return this._explicitVisibleWidth;
	}

	private var _actualMinVisibleHeight:Float = 0.0;
	private var _explicitMinVisibleHeight:Null<Float>;

	/**
		@see `feathers.controls.supportClasses.IViewPort.minVisibleHeight`
	**/
	public var minVisibleHeight(get, set):Null<Float>;

	private function get_minVisibleHeight():Null<Float> {
		if (this._explicitMinVisibleHeight == null) {
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}

	private function set_minVisibleHeight(value:Null<Float>):Null<Float> {
		if (this._explicitMinVisibleHeight == value) {
			return this._explicitMinVisibleHeight;
		}
		var oldValue = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if (value == null) {
			this._actualMinVisibleHeight = 0.0;
			this.setInvalid(SIZE);
		} else {
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight == null && (this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue)) {
				// only invalidate if this change might affect the visibleHeight
				this.setInvalid(SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}

	private var _maxVisibleHeight:Null<Float> = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleHeight`
	**/
	public var maxVisibleHeight(get, set):Null<Float>;

	private function get_maxVisibleHeight():Null<Float> {
		return this._maxVisibleHeight;
	}

	private function set_maxVisibleHeight(value:Null<Float>):Null<Float> {
		if (this._maxVisibleHeight == value) {
			return this._maxVisibleHeight;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleHeight cannot be null");
		}
		var oldValue = this._maxVisibleHeight;
		this._maxVisibleHeight = value;
		if (this._explicitVisibleHeight == null && (this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue)) {
			// only invalidate if this change might affect the visibleHeight
			this.setInvalid(SIZE);
		}
		return this._maxVisibleHeight;
	}

	private var _actualVisibleHeight:Float = 0.0;
	private var _explicitVisibleHeight:Null<Float> = null;

	/**
		@see `feathers.controls.supportClasses.IViewPort.visibleHeight`
	**/
	public var visibleHeight(get, set):Null<Float>;

	private function get_visibleHeight():Null<Float> {
		if (this._explicitVisibleHeight == null) {
			return this._actualVisibleHeight;
		}
		return this._explicitVisibleHeight;
	}

	private function set_visibleHeight(value:Null<Float>):Null<Float> {
		if (this._explicitVisibleHeight == value) {
			return this._explicitVisibleHeight;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value) {
			this.setInvalid(SIZE);
		}
		return this._explicitVisibleWidth;
	}

	private var _scrollX:Float = 0.0;

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollX`
	**/
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this._scrollX == value) {
			return this._scrollX;
		}
		this._scrollX = value;
		return this._scrollX;
	}

	private var _scrollY:Float = 0.0;

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollY`
	**/
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		return this._scrollY;
	}

	private function set_scrollY(value:Float):Float {
		if (this._scrollY == value) {
			return this._scrollY;
		}
		this._scrollY = value;
		return this._scrollY;
	}

	private var _snapPositionsX:Array<Float> = null;

	/**
		If not `null`, and the scroller is dragged with touch, the `scrollX`
		position is snapped to the nearest position in the array when the drag
		completes.

		@since 1.0.0
	**/
	public var snapPositionsX(get, never):Array<Float>;

	private function get_snapPositionsX():Array<Float> {
		return this._snapPositionsX;
	}

	private var _snapPositionsY:Array<Float> = null;

	/**
		If not `null`, and the scroller is dragged with touch, the `scrollY`
		position is snapped to the nearest position in the array when the drag
		completes.

		@since 1.0.0
	**/
	public var snapPositionsY(get, never):Array<Float>;

	private function get_snapPositionsY():Array<Float> {
		return this._snapPositionsY;
	}

	override private function refreshViewPortBounds():Void {
		var needsWidth = this._explicitVisibleWidth == null;
		var needsHeight = this._explicitVisibleHeight == null;
		var needsMinWidth = this._explicitMinVisibleWidth == null;
		var needsMinHeight = this._explicitMinVisibleHeight == null;
		var needsMaxWidth = this._maxVisibleWidth == null;
		var needsMaxHeight = this._maxVisibleHeight == null;

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var needsToMeasureContent = this.autoSizeMode == CONTENT || this.stage == null;
		var stageWidth:Float = 0.0;
		var stageHeight:Float = 0.0;
		if (!needsToMeasureContent) {
			// TODO: see if this can be done without allocations
			var topLeft = this.globalToLocal(new Point());
			var bottomRight = this.globalToLocal(new Point(this.stage.stageWidth, this.stage.stageHeight));
			stageWidth = bottomRight.x - topLeft.x;
			stageHeight = bottomRight.y - topLeft.y;
		}

		if (needsWidth && !needsToMeasureContent) {
			this._layoutMeasurements.width = stageWidth;
		} else {
			this._layoutMeasurements.width = this._explicitVisibleWidth;
		}

		if (needsHeight && !needsToMeasureContent) {
			this._layoutMeasurements.height = stageHeight;
		} else {
			this._layoutMeasurements.height = this._explicitVisibleHeight;
		}

		var viewPortMinWidth = this._explicitMinVisibleWidth;
		if (needsMinWidth) {
			viewPortMinWidth = 0.0;
		}
		var viewPortMinHeight = this._explicitMinVisibleHeight;
		if (needsMinHeight) {
			viewPortMinHeight = 0.0;
		}
		var viewPortMaxWidth = this._maxVisibleWidth;
		if (needsMaxWidth) {
			viewPortMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		var viewPortMaxHeight = this._maxVisibleHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		if (this._currentBackgroundSkin != null) {
			// because the layout might need it, we account for the
			// dimensions of the background skin when determining the minimum
			// dimensions of the view port.
			// we can't use the minimum dimensions of the background skin
			if (this._currentBackgroundSkin.width > viewPortMinWidth) {
				viewPortMinWidth = this._currentBackgroundSkin.width;
			}
			if (this._currentBackgroundSkin.height > viewPortMinHeight) {
				viewPortMinHeight = this._currentBackgroundSkin.height;
			}
		}
		this._layoutMeasurements.minWidth = viewPortMinWidth;
		this._layoutMeasurements.minHeight = viewPortMinHeight;
		this._layoutMeasurements.maxWidth = viewPortMaxWidth;
		this._layoutMeasurements.maxHeight = viewPortMaxHeight;
	}

	override private function handleCustomLayout():Void {
		var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
		this._ignoreLayoutChanges = true;
		if ((this._currentLayout is IScrollLayout)) {
			var scrollLayout = cast(this._currentLayout, IScrollLayout);
			scrollLayout.scrollX = this._scrollX;
			scrollLayout.scrollY = this._scrollY;
		}
		this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
		super.handleCustomLayout();
	}

	override private function handleLayoutResult():Void {
		this.saveMeasurements(this._layoutResult.contentWidth, this._layoutResult.contentHeight, this._layoutResult.contentMinWidth,
			this._layoutResult.contentMinHeight);
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this._actualVisibleWidth = viewPortWidth;
		this._actualVisibleHeight = viewPortHeight;
		this._actualMinVisibleWidth = this._layoutResult.contentMinWidth;
		this._actualMinVisibleHeight = this._layoutResult.contentMinHeight;

		this._viewPortBackground.x = Math.min(this.scrollX, 0.0);
		this._viewPortBackground.y = Math.min(this.scrollY, 0.0);
		this._viewPortBackground.width = Math.max(this.actualWidth, this._actualVisibleWidth);
		this._viewPortBackground.height = Math.max(this.actualHeight, this._actualVisibleHeight);

		if ((this.layout is ISnapLayout)) {
			var snapLayout = cast(this.layout, ISnapLayout);
			this._snapPositionsX = snapLayout.getSnapPositionsX(this.items, this._actualVisibleWidth, this._actualVisibleHeight, this._snapPositionsX);
			this._snapPositionsY = snapLayout.getSnapPositionsY(this.items, this._actualVisibleWidth, this._actualVisibleHeight, this._snapPositionsY);
		} else {
			this._snapPositionsX = null;
			this._snapPositionsY = null;
		}
	}
}
