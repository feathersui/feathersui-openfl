/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.utils.MeasurementsUtil;
import openfl.display.Sprite;
import feathers.layout.IScrollLayout;
import feathers.core.InvalidationFlag;
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
		var backgroundSkin = new Sprite();
		backgroundSkin.graphics.beginFill(0xff00ff, 0.0);
		backgroundSkin.graphics.drawRect(0.0, 0.0, 1.0, 1.0);
		backgroundSkin.graphics.endFill();
		this.backgroundSkin = backgroundSkin;
	}

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
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			this._actualMinVisibleWidth = value;
			if (this._explicitVisibleWidth == null && (this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue)) {
				// only invalidate if this change might affect the visibleWidth
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this._explicitMinVisibleWidth;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleWidth`
	**/
	public var maxVisibleWidth(default, set):Null<Float> = Math.POSITIVE_INFINITY;

	private function set_maxVisibleWidth(value:Null<Float>):Null<Float> {
		if (this.maxVisibleWidth == value) {
			return this.maxVisibleWidth;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleWidth cannot be null");
		}
		var oldValue = this.maxVisibleWidth;
		this.maxVisibleWidth = value;
		if (this._explicitVisibleWidth == null && (this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue)) {
			// only invalidate if this change might affect the visibleWidth
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.maxVisibleWidth;
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
			this.setInvalid(InvalidationFlag.SIZE);
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
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight == null && (this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue)) {
				// only invalidate if this change might affect the visibleHeight
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.maxVisibleHeight`
	**/
	public var maxVisibleHeight(default, set):Null<Float> = Math.POSITIVE_INFINITY;

	private function get_maxVisibleHeight():Null<Float> {
		return this.maxVisibleHeight;
	}

	private function set_maxVisibleHeight(value:Null<Float>):Null<Float> {
		if (this.maxVisibleHeight == value) {
			return this.maxVisibleHeight;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleHeight cannot be null");
		}
		var oldValue = this.maxVisibleHeight;
		this.maxVisibleHeight = value;
		if (this._explicitVisibleHeight == null && (this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue)) {
			// only invalidate if this change might affect the visibleHeight
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.maxVisibleHeight;
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
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this._explicitVisibleWidth;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.requiresMeasurementOnScroll`
	**/
	public var requiresMeasurementOnScroll(get, never):Bool;

	private function get_requiresMeasurementOnScroll():Bool {
		if (Std.is(this.layout, IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
			return scrollLayout.requiresLayoutOnScroll;
		}
		return false;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollX`
	**/
	@:isVar
	public var scrollX(get, set):Float = 0.0;

	private function get_scrollX():Float {
		return this.scrollX;
	}

	private function set_scrollX(value:Float):Float {
		this.scrollX = value;
		return this.scrollX;
	}

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollY`
	**/
	@:isVar
	public var scrollY(get, set):Float = 0.0;

	private function get_scrollY():Float {
		return this.scrollY;
	}

	private function set_scrollY(value:Float):Float {
		this.scrollY = value;
		return this.scrollY;
	}

	override private function refreshViewPortBounds():Void {
		var needsWidth = this._explicitVisibleWidth == null;
		var needsHeight = this._explicitVisibleHeight == null;
		var needsMinWidth = this._explicitMinVisibleWidth == null;
		var needsMinHeight = this._explicitMinVisibleHeight == null;
		var needsMaxWidth = this.maxVisibleWidth == null;
		var needsMaxHeight = this.maxVisibleHeight == null;

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
		var viewPortMaxWidth = this.maxVisibleWidth;
		if (needsMaxWidth) {
			viewPortMaxWidth = Math.POSITIVE_INFINITY;
		}
		var viewPortMaxHeight = this.maxVisibleHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = Math.POSITIVE_INFINITY;
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
		if (Std.is(this._currentLayout, IScrollLayout)) {
			var scrollLayout = cast(this._currentLayout, IScrollLayout);
			scrollLayout.scrollX = this.scrollX;
			scrollLayout.scrollY = this.scrollY;
		}
		this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
		super.handleCustomLayout();
	}

	override private function handleLayoutResult():Void {
		var contentWidth = this._layoutResult.contentWidth;
		var contentHeight = this._layoutResult.contentHeight;
		this.saveMeasurements(contentWidth, contentHeight, contentWidth, contentHeight, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this._actualVisibleWidth = viewPortWidth;
		this._actualVisibleHeight = viewPortHeight;
		this._actualMinVisibleWidth = viewPortWidth;
		this._actualMinVisibleHeight = viewPortHeight;
	}
}
