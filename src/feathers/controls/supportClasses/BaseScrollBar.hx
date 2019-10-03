/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import openfl.errors.TypeError;
import openfl.geom.Point;
import openfl.display.Sprite;
import openfl.display.InteractiveObject;
import feathers.layout.Measurements;
import feathers.core.IUIControl;
import openfl.events.MouseEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import feathers.events.FeathersEvent;
import feathers.core.InvalidationFlag;
import feathers.core.FeathersControl;

/**
	Base class for scroll bar components.

	@see `feathers.controls.HScrollBar`
	@see `feathers.controls.VScrollBar`

	@since 1.0.0
**/
class BaseScrollBar extends FeathersControl implements IScrollBar {
	public function new() {
		super();
	}

	/**
		The value of the scroll bar, which must be between the `minimum` and the
		`maximum`.

		In the following example, the value is changed to `12.0`:

		```hx
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 12.0;
		```

		@default 0.0

		@see `IScrollBar.minimum`
		@see `IScrollBar.maximum`
		@see `IScrollBar.step`
	**/
	@:isVar
	public var value(get, set):Float = 0.0;

	private function get_value():Float {
		return this.value;
	}

	private function set_value(value:Float):Float {
		if (this.value == value) {
			return this.value;
		}
		this.value = value;
		this.setInvalid(InvalidationFlag.DATA);
		if (this.liveDragging || !this._dragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		return this.value;
	}

	/**
		The scroll bar's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100.0`:

		``` hx
		scrollBar.minimum = -100.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 50.0;
		```

		@default 0.0

		@see `IScrollBar.value`
		@see `IScrollBar.maximum`
	**/
	@:isVar
	public var minimum(get, set):Float = 0.0;

	private function get_minimum():Float {
		return this.minimum;
	}

	private function set_minimum(value:Float):Float {
		if (this.minimum == value) {
			return this.minimum;
		}
		this.minimum = value;
		if (this.initialized && this.value < this.minimum) {
			this.value = this.minimum;
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.minimum;
	}

	/**
		The scroll bar's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```hx
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 12.0;
		```

		@default 1.0

		@see `IScrollBar.value`
		@see `IScrollBar.minimum`
	**/
	@:isVar
	public var maximum(get, set):Float = 1.0;

	private function get_maximum():Float {
		return this.maximum;
	}

	private function set_maximum(value:Float):Float {
		if (this.maximum == value) {
			return this.maximum;
		}
		this.maximum = value;
		if (this.initialized && this.value > this.maximum) {
			this.value = this.maximum;
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.maximum;
	}

	/**
		As the scroll bar's thumb is dragged, the `value` is snapped to the
		nearest multiple of `step`. If `step` is `0.0`, the `value` is not
		snapped.

		In the following example, the step is changed to `1.0`:

		```hx
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 10.0;
		```

		@default 0.0

		@see `IScrollBar.value`
		@see `IScrollBar.minimum`
		@see `IScrollBar.maximum`
		@see `IScrollBar.page`
	**/
	@:isVar
	public var step(get, set):Float = 0.0;

	private function get_step():Float {
		return this.step;
	}

	private function set_step(value:Float):Float {
		if (this.step == value) {
			return this.step;
		}
		this.step = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.step;
	}

	/**
		The amount the scroll bar value must change to get from one "page" to
		the next or previous adjacent page.

		If `page` is `0.0`, the value of `step` will be used instead. If `step`
		is also `0.0`, then paging will be disabled.

		In the following example, the page is changed to `10.0`:

		```hx
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.page = 10.0;
		scrollBar.value = 10.0;
		```

		@default 0.0

		@see `IScrollBar.value`
		@see `IScrollBar.minimum`
		@see `IScrollBar.maximum`
		@see `IScrollBar.step`
	**/
	@:isVar
	public var page(get, set):Float = 0.0;

	private function get_page():Float {
		return this.page;
	}

	private function set_page(value:Float):Float {
		if (this.page == value) {
			return this.page;
		}
		this.page = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.page;
	}

	/**
		Determines if the scroll bar dispatches the `Event.CHANGE` event every time
		that the thumb moves while dragging, or only after the user stops
		dragging.

		In the following example, live dragging is disabled:

		```hx
		scrollBar.liveDragging = false;
		```

		@default true
	**/
	public var liveDragging(default, default):Bool = true;

	private var thumbContainer:Sprite;
	private var _thumbSkinMeasurements:Measurements = null;

	/**

	**/
	@style
	public var thumbSkin(default, set):DisplayObject = null;

	private function set_thumbSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("thumbSkin")) {
			return this.thumbSkin;
		}
		if (this.thumbSkin == value) {
			return this.thumbSkin;
		}
		if (this.thumbSkin != null) {
			if (this.thumbContainer != null) {
				this.thumbContainer.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
				this.thumbContainer.removeChild(this.thumbSkin);
				this.removeChild(this.thumbContainer);
				this.thumbContainer = null;
			} else {
				this.thumbSkin.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
				this.removeChild(this.thumbSkin);
			}
		}
		this.thumbSkin = value;
		if (this.thumbSkin != null) {
			if (Std.is(this.thumbSkin, IUIControl)) {
				cast(this.thumbSkin, IUIControl).initializeNow();
			}
			if (this._thumbSkinMeasurements == null) {
				this._thumbSkinMeasurements = new Measurements(this.thumbSkin);
			} else {
				this._thumbSkinMeasurements.save(this.thumbSkin);
			}
			if (!Std.is(this.thumbSkin, InteractiveObject)) {
				// if the skin isn't interactive, we need to add it to something
				// that is interactive
				this.thumbContainer = new Sprite();
				this.thumbContainer.addChild(this.thumbSkin);
				this.addChild(this.thumbContainer);
				this.thumbContainer.addEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			} else {
				// add it above the trackSkin and secondaryTrackSkin
				this.addChild(this.thumbSkin);
				this.thumbSkin.addEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			}
		} else {
			this._thumbSkinMeasurements = null;
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.thumbSkin;
	}

	@:style
	public var fixedThumbSize:Bool = false;

	@:style
	public var paddingTop:Float = 0.0;

	@:style
	public var paddingRight:Float = 0.0;

	@:style
	public var paddingBottom:Float = 0.0;

	@:style
	public var paddingLeft:Float = 0.0;

	private var _dragging:Bool = false;
	private var _pointerStartX:Float = 0.0;
	private var _pointerStartY:Float = 0.0;
	private var _thumbStartX:Float = 0.0;
	private var _thumbStartY:Float = 0.0;

	override private function initialize():Void {
		super.initialize();
		if (this.value < this.minimum) {
			this.value = this.minimum;
		} else if (this.value > this.maximum) {
			this.value = this.maximum;
		}
	}

	override private function update():Void {
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (stateInvalid) {
			this.refreshEnabled();
		}

		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		this.layoutContent();
	}

	private function autoSizeIfNeeded():Bool {
		throw new TypeError("Missing override for 'autoSizeIfNeeded' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function refreshEnabled():Void {
		if (Std.is(this.thumbSkin, IUIControl)) {
			cast(this.thumbSkin, IUIControl).enabled = this.enabled;
		}
	}

	private function layoutContent():Void {
		this.drawTrack();
		this.layoutThumb();
	}

	private function drawTrack():Void {
		this.graphics.clear();
		this.graphics.beginFill(0xff00ff, 0.0);
		this.graphics.drawRect(0, 0, this.actualWidth, this.actualHeight);
		this.graphics.endFill();
	}

	private function layoutThumb():Void {
		throw new TypeError("Missing override for 'layoutThumb' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function normalizeValue():Float {
		var normalized = 0.0;
		if (this.minimum != this.maximum) {
			normalized = (this.value - this.minimum) / (this.maximum - this.minimum);
			if (normalized < 0.0) {
				normalized = 0.0;
			} else if (normalized > 1) {
				normalized = 1.0;
			}
		}
		return normalized;
	}

	private function valueToLocation(value:Float):Float {
		throw new TypeError("Missing override for 'valueToLocation' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function locationToValue(x:Float, y:Float):Float {
		throw new TypeError("Missing override for 'locationToValue' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function getAdjustedPage():Float {
		var range = this.maximum - this.minimum;
		var adjustedPage = this.page;
		if (adjustedPage == 0) {
			adjustedPage = this.step;
		} else if (adjustedPage > range) {
			adjustedPage = range;
		}
		return adjustedPage;
	}

	private function thumbSkin_mouseDownHandler(event:MouseEvent):Void {
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbSkin_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, thumbSkin_stage_mouseUpHandler, false, 0, true);

		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		this._thumbStartX = this.thumbSkin.x;
		this._thumbStartY = this.thumbSkin.y;
		this._pointerStartX = location.x;
		this._pointerStartY = location.y;
		this._dragging = true;
	}

	private function thumbSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);
		this.value = this.locationToValue(location.x, location.y);
	}

	private function thumbSkin_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbSkin_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, thumbSkin_stage_mouseUpHandler);
		this._dragging = false;
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}
}
