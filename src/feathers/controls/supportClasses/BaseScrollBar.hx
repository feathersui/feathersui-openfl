/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.IUIControl;
import feathers.events.FeathersEvent;
import feathers.events.ScrollEvent;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.ExclusivePointer;
import feathers.utils.MathUtil;
import openfl.display.InteractiveObject;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
	Base class for scroll bar components.

	@see `feathers.controls.HScrollBar`
	@see `feathers.controls.VScrollBar`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.ScrollEvent.SCROLL_START)
@:event(feathers.events.ScrollEvent.SCROLL_COMPLETE)
class BaseScrollBar extends FeathersControl implements IScrollBar {
	private function new() {
		super();

		this.tabChildren = false;
		this.focusRect = null;
	}

	private var _value:Float = 0.0;

	/**
		The value of the scroll bar, which must be between the `minimum` and the
		`maximum`.

		When the `value` property changes, the scroll bar will dispatch an event
		of type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```hx
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 12.0;
		```

		@default 0.0

		@see `BaseScrollBar.minimum`
		@see `BaseScrollBar.maximum`
		@see `BaseScrollBar.step`
		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
	**/
	@:flash.property
	public var value(get, set):Float;

	private function get_value():Float {
		return this._value;
	}

	private function set_value(value:Float):Float {
		if (this._snapInterval != 0.0 && value != this._minimum && value != this._maximum) {
			value = MathUtil.roundToNearest(value, this._snapInterval);
		}
		if (value < this._minimum) {
			value = this._minimum;
		} else if (value > this._maximum) {
			value = this._maximum;
		}
		if (this._value == value) {
			return this._value;
		}
		this._value = value;
		this.setInvalid(DATA);
		if (this.liveDragging || !this._dragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		return this._value;
	}

	private var _minimum:Float = 0.0;

	/**
		The scroll bar's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100.0`:

		```hx
		scrollBar.minimum = -100.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 50.0;
		```

		@default 0.0

		@see `BaseScrollBar.value`
		@see `BaseScrollBar.maximum`

		@since 1.0.0
	**/
	@:flash.property
	public var minimum(get, set):Float;

	private function get_minimum():Float {
		return this._minimum;
	}

	private function set_minimum(value:Float):Float {
		if (this._minimum == value) {
			return this._minimum;
		}
		this._minimum = value;
		if (this.initialized && this._value < this._minimum) {
			// use the setter
			this.value = this._minimum;
		}
		this.setInvalid(DATA);
		return this._minimum;
	}

	private var _maximum:Float = 1.0;

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

		@see `BaseScrollBar.value`
		@see `BaseScrollBar.minimum`

		@since 1.0.0
	**/
	@:flash.property
	public var maximum(get, set):Float;

	private function get_maximum():Float {
		return this._maximum;
	}

	private function set_maximum(value:Float):Float {
		if (this._maximum == value) {
			return this._maximum;
		}
		this._maximum = value;
		if (this.initialized && this._value > this._maximum) {
			// use the setter
			this.value = this._maximum;
		}
		this.setInvalid(DATA);
		return this._maximum;
	}

	private var _step:Float = 0.01;

	/**
		When the scroll bar's increment/decrement buttons are triggered, the
		`value` is modified by adding or subtracting `step`.

		In the following example, the step is changed to `1.0`:

		```hx
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 10.0;
		```

		@default 0.0

		@see `BaseScrollBar.value`
		@see `BaseScrollBar.minimum`
		@see `BaseScrollBar.maximum`
		@see `BaseScrollBar.page`

		@since 1.0.0
	**/
	@:flash.property
	public var step(get, set):Float;

	private function get_step():Float {
		return this._step;
	}

	private function set_step(value:Float):Float {
		if (this._step == value) {
			return this._step;
		}
		this._step = value;
		this.setInvalid(DATA);
		return this._step;
	}

	private var _snapInterval:Float = 0.0;

	/**
		When the scroll bar's `value` changes, it may be "snapped" to the
		nearest multiple of `snapInterval`. If `snapInterval` is `0.0`, the
		`value` is not snapped.

		In the following example, the snap inverval is changed to `1.0`:

		```hx
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.snapInterval = 1.0;
		slider.value = 10.0;
		```

		@default 0.0

		@see `BaseScrollBar.step`

		@since 1.0.0
	**/
	@:flash.property
	public var snapInterval(get, set):Float;

	private function get_snapInterval():Float {
		return this._snapInterval;
	}

	private function set_snapInterval(value:Float):Float {
		if (this._snapInterval == value) {
			return this._snapInterval;
		}
		this._snapInterval = value;
		this.setInvalid(DATA);
		return this._snapInterval;
	}

	private var _page:Float = 0.0;

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

		@see `BaseScrollBar.value`
		@see `BaseScrollBar.minimum`
		@see `BaseScrollBar.maximum`
		@see `BaseScrollBar.step`

		@since 1.0.0
	**/
	@:flash.property
	public var page(get, set):Float;

	private function get_page():Float {
		return this._page;
	}

	private function set_page(value:Float):Float {
		if (this._page == value) {
			return this._page;
		}
		this._page = value;
		this.setInvalid(DATA);
		return this._page;
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

		@since 1.0.0
	**/
	public var liveDragging:Bool = true;

	private var _currentThumbSkin:InteractiveObject = null;
	private var _thumbSkinMeasurements:Measurements = null;

	/**
		The skin to use for the scroll bar's thumb.

		In the following example, a thumb skin is passed to the scroll bar:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		scrollBar.thumbSkin = skin;
		```

		@see `BaseScrollBar.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var thumbSkin:InteractiveObject = null;

	private var _currentTrackSkin:InteractiveObject = null;
	private var _trackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the scroll bar's track.

		In the following example, a track skin is passed to the scroll bar:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		scrollBar.trackSkin = skin;
		```

		@see `BaseScrollBar.secondaryTrackSkin`
		@see `BaseScrollBar.thumbSkin`

		@since 1.0.0
	**/
	@:style
	public var trackSkin:InteractiveObject = null;

	private var _currentSecondaryTrackSkin:InteractiveObject = null;
	private var _secondaryTrackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the scroll bar's optional secondary track. If a
		scroll bar has one track, it will fill the entire length of the scroll
		bar. If a scroll bar has a track and a secondary track, the primary
		track will stretch between the minimum edge of the scroll bar and the
		location of the scroll bar's thumb, while the secondary track will
		stretch from the location of the scroll bar's thumb to the maximum edge
		of the scroll bar.

		In the following example, a track skin and a secondary track skin are
		passed to the scroll bar:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xaaaaaa);
		scrollBar.trackSkin = skin;

		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		scrollBar.secondaryTrackSkin = skin;
		```

		@see `BaseScrollBar.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var secondaryTrackSkin:InteractiveObject = null;

	/**
		Determines if the scroll bar's thumb will be resized based on the
		scrollable range between the `minimum` and `maximum`, or if it will
		always be rendered at its preferred size, even if the `minimum` and
		`maximum` values change.

		In the following example, the thumb size is fixed:

		```hx
		scrollBar.fixedThumbSize = true;
		```

		@since 1.0.0
	**/
	@:style
	public var fixedThumbSize:Bool = false;

	/**
		The minimum space, in pixels, between the scroll bar's top edge and the
		scroll bar's thumb.

		In the following example, the scroll bar's top padding is set to 20
		pixels:

		```hx
		scrollBar.paddingTop = 20.0;
		```

		@see `BaseScrollBar.paddingBottom`
		@see `BaseScrollBar.paddingRight`
		@see `BaseScrollBar.paddingLeft`

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the scroll bar's right edge and
		the scroll bar's thumb.

		In the following example, the scroll bar's right padding is set to 20
		pixels:

		```hx
		scrollBar.paddingRight = 20.0;
		```

		@see `BaseScrollBar.paddingTop`
		@see `BaseScrollBar.paddingBottom`
		@see `BaseScrollBar.paddingLeft`

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the scroll bar's bottom edge and
		the scroll bar's thumb.

		In the following example, the scroll bar's bottom padding is set to 20
		pixels:

		```hx
		scrollBar.paddingBottom = 20.0;
		```

		@see `BaseScrollBar.paddingTop`
		@see `BaseScrollBar.paddingRight`
		@see `BaseScrollBar.paddingLeft`

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the scroll bar's left edge and the
		scroll bar's thumb.

		In the following example, the scroll bar's left padding is set to 20
		pixels:

		```hx
		scrollBar.paddingLeft = 20.0;
		```

		@see `BaseScrollBar.paddingTop`
		@see `BaseScrollBar.paddingBottom`
		@see `BaseScrollBar.paddingRight`

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	private var _dragging:Bool = false;
	private var _pointerStartX:Float = 0.0;
	private var _pointerStartY:Float = 0.0;
	private var _thumbStartX:Float = 0.0;
	private var _thumbStartY:Float = 0.0;

	private var _previousFallbackTrackWidth:Float = 0.0;
	private var _previousFallbackTrackHeight:Float = 0.0;

	override private function initialize():Void {
		super.initialize();
		if (this._value < this._minimum) {
			// use the setter
			this.value = this._minimum;
		} else if (this._value > this._maximum) {
			// use the setter
			this.value = this._maximum;
		}
	}

	override private function update():Void {
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid) {
			this.refreshThumb();
			this.refreshTrack();
			this.refreshSecondaryTrack();
		}

		if (stateInvalid) {
			this.refreshEnabled();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		this.layoutContent();
	}

	private function measure():Bool {
		throw new TypeError("Missing override for 'measure' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function refreshThumb():Void {
		var oldSkin = this._currentThumbSkin;
		this._currentThumbSkin = this.thumbSkin;
		if (this._currentThumbSkin == oldSkin) {
			return;
		}
		if (oldSkin != null) {
			if (Std.is(oldSkin, IProgrammaticSkin)) {
				cast(oldSkin, IProgrammaticSkin).uiContext = null;
			}
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			this.removeChild(oldSkin);
		}
		if (this._currentThumbSkin != null) {
			if (Std.is(this._currentThumbSkin, IUIControl)) {
				cast(this._currentThumbSkin, IUIControl).initializeNow();
			}
			if (this._thumbSkinMeasurements == null) {
				this._thumbSkinMeasurements = new Measurements(this._currentThumbSkin);
			} else {
				this._thumbSkinMeasurements.save(this._currentThumbSkin);
			}
			// add it above the trackSkin and secondaryTrackSkin
			this.addChild(this._currentThumbSkin);
			this._currentThumbSkin.addEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			if (Std.is(this._currentThumbSkin, IProgrammaticSkin)) {
				cast(this._currentThumbSkin, IProgrammaticSkin).uiContext = this;
			}
		} else {
			this._thumbSkinMeasurements = null;
		}
	}

	private function refreshTrack():Void {
		var oldSkin = this._currentTrackSkin;
		this._currentTrackSkin = this.trackSkin;
		if (this._currentTrackSkin == oldSkin) {
			return;
		}
		if (oldSkin != null) {
			if (Std.is(oldSkin, IProgrammaticSkin)) {
				cast(oldSkin, IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
		}
		if (this._currentTrackSkin != null) {
			if (Std.is(this._currentTrackSkin, IUIControl)) {
				cast(this._currentTrackSkin, IUIControl).initializeNow();
			}
			if (this._trackSkinMeasurements == null) {
				this._trackSkinMeasurements = new Measurements(this._currentTrackSkin);
			} else {
				this._trackSkinMeasurements.save(this._currentTrackSkin);
			}
			// always on the bottom
			this.addChildAt(this._currentTrackSkin, 0);
			this._currentTrackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			if (Std.is(this._currentTrackSkin, IProgrammaticSkin)) {
				cast(this._currentTrackSkin, IProgrammaticSkin).uiContext = this;
			}
		} else {
			this._trackSkinMeasurements = null;
		}
	}

	private function refreshSecondaryTrack():Void {
		var oldSkin = this._currentSecondaryTrackSkin;
		this._currentSecondaryTrackSkin = this.secondaryTrackSkin;
		if (this._currentSecondaryTrackSkin == oldSkin) {
			return;
		}
		if (oldSkin != null) {
			if (Std.is(oldSkin, IProgrammaticSkin)) {
				cast(oldSkin, IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
		}
		if (this._currentSecondaryTrackSkin != null) {
			if (Std.is(this._currentSecondaryTrackSkin, IUIControl)) {
				cast(this._currentSecondaryTrackSkin, IUIControl).initializeNow();
			}
			if (this._secondaryTrackSkinMeasurements == null) {
				this._secondaryTrackSkinMeasurements = new Measurements(this._currentSecondaryTrackSkin);
			} else {
				this._secondaryTrackSkinMeasurements.save(this._currentSecondaryTrackSkin);
			}

			// on the bottom or above the trackSkin
			var index = this._currentTrackSkin != null ? 1 : 0;
			this.addChildAt(this._currentSecondaryTrackSkin, index);
			this._currentSecondaryTrackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			if (Std.is(this._currentSecondaryTrackSkin, IProgrammaticSkin)) {
				cast(this._currentSecondaryTrackSkin, IProgrammaticSkin).uiContext = this;
			}
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
	}

	private function refreshEnabled():Void {
		if (Std.is(this.thumbSkin, IUIControl)) {
			cast(this.thumbSkin, IUIControl).enabled = this._enabled;
		}
	}

	private function layoutContent():Void {
		if (this.trackSkin != null && this.secondaryTrackSkin != null) {
			this.graphics.clear();
			this.layoutSplitTrack();
		} else if (this.trackSkin != null) {
			this.graphics.clear();
			this.layoutSingleTrack();
		} else {
			this.drawFallbackTrack();
		}
		this.layoutThumb();
	}

	private function layoutSplitTrack():Void {
		throw new TypeError("Missing override for 'layoutSplitTrack' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function layoutSingleTrack():Void {
		throw new TypeError("Missing override for 'layoutSingleTrack' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function layoutThumb():Void {
		throw new TypeError("Missing override for 'layoutThumb' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function drawFallbackTrack():Void {
		if (this.actualWidth == this._previousFallbackTrackWidth && this.actualHeight == this._previousFallbackTrackHeight) {
			// no need to re-draw the fallback track because it is the same size
			return;
		}
		this.graphics.clear();
		this.graphics.beginFill(0xff00ff, 0.0);
		this.graphics.drawRect(0, 0, this.actualWidth, this.actualHeight);
		this.graphics.endFill();
		this._previousFallbackTrackWidth = this.actualWidth;
		this._previousFallbackTrackHeight = this.actualHeight;
	}

	private function normalizeValue():Float {
		var normalized = 0.0;
		if (this._minimum != this._maximum) {
			normalized = (this._value - this._minimum) / (this._maximum - this._minimum);
			if (normalized < 0.0) {
				normalized = 0.0;
			} else if (normalized > 1.0) {
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

	private function saveThumbStart(location:Point):Void {
		throw new TypeError("Missing override for 'saveThumbStart' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function getAdjustedPage():Float {
		var range = this._maximum - this._minimum;
		var adjustedPage = this._page;
		if (adjustedPage == 0) {
			adjustedPage = this._step;
		} else if (adjustedPage > range) {
			adjustedPage = range;
		}
		return adjustedPage;
	}

	private function thumbSkin_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimPointer(ExclusivePointer.POINTER_ID_MOUSE, this);
		if (!result) {
			return;
		}

		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbSkin_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, thumbSkin_stage_mouseUpHandler, false, 0, true);

		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		this._thumbStartX = this.thumbSkin.x;
		this._thumbStartY = this.thumbSkin.y;
		this._pointerStartX = location.x;
		this._pointerStartY = location.y;
		this._dragging = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function thumbSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);
		// use the setter
		this.value = this.locationToValue(location.x, location.y);
	}

	private function thumbSkin_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbSkin_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, thumbSkin_stage_mouseUpHandler);
		this._dragging = false;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function trackSkin_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimPointer(ExclusivePointer.POINTER_ID_MOUSE, this);
		if (!result) {
			return;
		}

		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, trackSkin_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, trackSkin_stage_mouseUpHandler, false, 0, true);

		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		this.saveThumbStart(location);
		this._pointerStartX = location.x;
		this._pointerStartY = location.y;
		this._dragging = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);

		// use the setter
		this.value = this.locationToValue(location.x, location.y);
	}

	private function trackSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		// use the setter
		this.value = this.locationToValue(location.x, location.y);
	}

	private function trackSkin_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, trackSkin_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, trackSkin_stage_mouseUpHandler);
		this._dragging = false;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}
}
