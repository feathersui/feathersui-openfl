/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.events.Event;

@:dox(hide)
@:noCompletion
class AdvancedLayoutViewPort extends FeathersControl implements IViewPort {
	public function new() {
		super();

		// an invisible background that makes the entire width and height of the
		// viewport interactive for touch scrolling
		this._background = new Sprite();
		this._background.graphics.beginFill(0xff00ff, 0.0);
		this._background.graphics.drawRect(0.0, 0.0, 1.0, 1.0);
		this._background.graphics.endFill();
		this.addChild(this._background);
	}

	private var _background:Sprite;

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

	public var layout(default, set):ILayout;

	private function set_layout(value:ILayout):ILayout {
		if (this.layout == value) {
			return this.layout;
		}
		if (this.layout != null) {
			this.layout.removeEventListener(Event.CHANGE, layout_changeHandler);
		}
		this.layout = value;
		if (this.layout != null) {
			this.layout.addEventListener(Event.CHANGE, layout_changeHandler);
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.layout;
	}

	private var _layoutItems:Array<DisplayObject> = [];

	/**
		@see `feathers.controls.supportClasses.IViewPort.requiresMeasurementOnScroll`
	**/
	public var requiresMeasurementOnScroll(get, never):Bool;

	private function get_requiresMeasurementOnScroll():Bool {
		if (!Std.is(this.layout, IScrollLayout)) {
			return false;
		}
		return cast(this.layout, IScrollLayout).requiresLayoutOnScroll;
	}

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreLayoutChanges = false;

	/**
		@see `feathers.controls.supportClasses.IViewPort.scrollX`
	**/
	@:isVar
	public var scrollX(get, set):Float = 0.0;

	private function get_scrollX():Float {
		return this.scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		this.scrollX = value;
		this.setInvalid(InvalidationFlag.SCROLL);
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
		if (this.scrollY == value) {
			return this.scrollY;
		}
		this.scrollY = value;
		this.setInvalid(InvalidationFlag.SCROLL);
		return this.scrollY;
	}

	public dynamic function refreshChildren(items:Array<DisplayObject>):Void {}

	override private function update():Void {
		this.refreshLayoutMeasurements();
		this.refreshLayoutProperties();
		this.refreshChildren(this._layoutItems);
		this.layout.layout(this._layoutItems, this._layoutMeasurements, this._layoutResult);
		this.handleLayoutResult();
	}

	private function refreshLayoutProperties():Void {
		var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
		this._ignoreLayoutChanges = true;
		if (Std.is(this.layout, IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
			scrollLayout.scrollX = this.scrollX;
			scrollLayout.scrollY = this.scrollY;
		}
		this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
	}

	private function refreshLayoutMeasurements():Void {
		var needsMinWidth = this._explicitMinVisibleWidth == null;
		var needsMinHeight = this._explicitMinVisibleHeight == null;
		var needsMaxWidth = this.maxVisibleWidth == null;
		var needsMaxHeight = this.maxVisibleHeight == null;

		this._layoutMeasurements.width = this._explicitVisibleWidth;
		this._layoutMeasurements.height = this._explicitVisibleHeight;

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
		this._layoutMeasurements.minWidth = viewPortMinWidth;
		this._layoutMeasurements.minHeight = viewPortMinHeight;
		this._layoutMeasurements.maxWidth = viewPortMaxWidth;
		this._layoutMeasurements.maxHeight = viewPortMaxHeight;
	}

	private function handleLayoutResult():Void {
		var contentWidth = this._layoutResult.contentWidth;
		var contentHeight = this._layoutResult.contentHeight;
		this.saveMeasurements(contentWidth, contentHeight, contentWidth, contentHeight, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this._actualVisibleWidth = viewPortWidth;
		this._actualVisibleHeight = viewPortHeight;
		this._actualMinVisibleWidth = viewPortWidth;
		this._actualMinVisibleHeight = viewPortHeight;

		this._background.x = 0.0;
		this._background.y = 0.0;
		this._background.width = this.actualWidth;
		this._background.height = this.actualHeight;
	}

	private function layout_changeHandler(event:Event):Void {
		if (this._ignoreLayoutChanges) {
			return;
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
	}
}
