/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
import openfl.display.Stage;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
	Base class for scroll bar components.

	@event openfl.events.Event.CHANGE Dispatched when `BaseScrollBar.value`
	changes.

	@event feathers.events.ScrollEvent.SCROLL_START Dispatched when scrolling
	begins.

	@event feathers.events.ScrollEvent.SCROLL_COMPLETE Dispatched when scrolling
	ends.

	@see `feathers.controls.HScrollBar`
	@see `feathers.controls.VScrollBar`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.ScrollEvent.SCROLL_START)
@:event(feathers.events.ScrollEvent.SCROLL_COMPLETE)
class BaseScrollBar extends FeathersControl implements IScrollBar {
	private function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		super();

		this.tabChildren = false;
		this.focusRect = null;

		this.minimum = minimum;
		this.maximum = maximum;
		this.value = value;

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var _isDefaultValue = true;

	private var _value:Float = 0.0;

	/**
		The value of the scroll bar, which must be between the `minimum` and the
		`maximum`.

		When the `value` property changes, the scroll bar will dispatch an event
		of type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```haxe
		scrollBar.minimum = 0.0;
		scrollBar.maximum = 100.0;
		scrollBar.step = 1.0;
		scrollBar.value = 12.0;
		```

		@default 0.0

		@see `BaseScrollBar.minimum`
		@see `BaseScrollBar.maximum`
		@see `BaseScrollBar.step`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var value(get, set):Float;

	private function get_value():Float {
		return this._value;
	}

	private function set_value(value:Float):Float {
		// don't restrict a value that has been passed in from an external
		// source to the minimum/maximum/snapInterval
		// assume that the user knows what they are doing
		// this allows the thumb to shrink when outside the minimum or maximum
		if (this._value == value) {
			return this._value;
		}
		this._isDefaultValue = false;
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

		```haxe
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
	public var minimum(get, set):Float;

	private function get_minimum():Float {
		return this._minimum;
	}

	private function set_minimum(value:Float):Float {
		if (this._minimum == value) {
			return this._minimum;
		}
		this._minimum = value;
		this.setInvalid(DATA);
		return this._minimum;
	}

	private var _maximum:Float = 1.0;

	/**
		The scroll bar's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```haxe
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
	public var maximum(get, set):Float;

	private function get_maximum():Float {
		return this._maximum;
	}

	private function set_maximum(value:Float):Float {
		if (this._maximum == value) {
			return this._maximum;
		}
		this._maximum = value;
		this.setInvalid(DATA);
		return this._maximum;
	}

	private var _step:Float = 0.01;

	/**
		When the scroll bar's increment/decrement buttons are triggered, the
		`value` is modified by adding or subtracting `step`.

		In the following example, the step is changed to `1.0`:

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
		scrollBar.paddingLeft = 20.0;
		```

		@see `BaseScrollBar.paddingTop`
		@see `BaseScrollBar.paddingBottom`
		@see `BaseScrollBar.paddingRight`

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		Determines if the thumb is hidden or not when the scroll bar is
		disabled.

		In the following example, the scroll bar's thumb is hidden when the
		scroll bar is disabled:

		```haxe
		scrollBar.hideThumbWhenDisabled = true;
		```

		@since 1.0.0
	**/
	@:style
	public var hideThumbWhenDisabled:Bool = false;

	private var _dragging:Bool = false;
	private var _pointerStartX:Float = 0.0;
	private var _pointerStartY:Float = 0.0;
	private var _thumbStartX:Float = 0.0;
	private var _thumbStartY:Float = 0.0;

	private var _previousFallbackTrackWidth:Float = 0.0;
	private var _previousFallbackTrackHeight:Float = 0.0;

	/**
		Sets all four padding properties to the same value.

		@see `BaseScrollBar.paddingTop`
		@see `BaseScrollBar.paddingRight`
		@see `BaseScrollBar.paddingBottom`
		@see `BaseScrollBar.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		Applies the `minimum`, `maximum`, and `snapInterval` restrictions to the
		current `value`.

		Because it's possible to set `value` to a numeric value that is outside
		the allowed range, or to a value that has not been snapped to the
		interval, this method may be called to apply the restrictions manually.

		@since 1.0.0
	**/
	public function applyValueRestrictions():Void {
		this.value = this.restrictValue(this._value);
	}

	override private function initialize():Void {
		super.initialize();
		// if the user hasn't changed the value, automatically restrict it based
		// on things like minimum, maximum, and snapInterval
		// if the user has changed the value, assume that they know what they're
		// doing and don't want hand holding
		if (this._isDefaultValue) {
			// use the setter
			this.value = this.restrictValue(this._value);
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

		if (stateInvalid || stylesInvalid) {
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
			if ((oldSkin is IProgrammaticSkin)) {
				cast(oldSkin, IProgrammaticSkin).uiContext = null;
			}
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			this.removeChild(oldSkin);
		}
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IUIControl)) {
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
			if ((this._currentThumbSkin is IProgrammaticSkin)) {
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
			if ((oldSkin is IProgrammaticSkin)) {
				cast(oldSkin, IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
		}
		if (this._currentTrackSkin != null) {
			if ((this._currentTrackSkin is IUIControl)) {
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
			if ((this._currentTrackSkin is IProgrammaticSkin)) {
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
			if ((oldSkin is IProgrammaticSkin)) {
				cast(oldSkin, IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
		}
		if (this._currentSecondaryTrackSkin != null) {
			if ((this._currentSecondaryTrackSkin is IUIControl)) {
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
			if ((this._currentSecondaryTrackSkin is IProgrammaticSkin)) {
				cast(this._currentSecondaryTrackSkin, IProgrammaticSkin).uiContext = this;
			}
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
	}

	private function refreshEnabled():Void {
		if ((this._currentThumbSkin is IUIControl)) {
			cast(this._currentThumbSkin, IUIControl).enabled = this._enabled;
		}
	}

	private function layoutContent():Void {
		if (this._currentTrackSkin != null && this._currentSecondaryTrackSkin != null) {
			this.graphics.clear();
			this.layoutSplitTrack();
		} else if (this._currentTrackSkin != null) {
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

	private function normalizeValue(value:Float):Float {
		var normalized = 0.0;
		if (this._minimum != this._maximum) {
			normalized = (value - this._minimum) / (this._maximum - this._minimum);
			if (normalized < 0.0) {
				normalized = 0.0;
			} else if (normalized > 1.0) {
				normalized = 1.0;
			}
		}
		return normalized;
	}

	private function restrictValue(value:Float):Float {
		if (this._snapInterval != 0.0 && value != this._minimum && value != this._maximum) {
			value = MathUtil.roundToNearest(value, this._snapInterval);
		}
		if (value < this._minimum) {
			value = this._minimum;
		} else if (value > this._maximum) {
			value = this._maximum;
		}
		return value;
	}

	private function valueToLocation(value:Float):Float {
		throw new TypeError("Missing override for 'valueToLocation' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function locationToValue(x:Float, y:Float):Float {
		throw new TypeError("Missing override for 'locationToValue' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function saveThumbStart(x:Float, y:Float):Void {
		throw new TypeError("Missing override for 'saveThumbStart' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function getAdjustedPage():Float {
		var range = this._maximum - this._minimum;
		var adjustedPage = this._page;
		if (adjustedPage == 0.0) {
			adjustedPage = this._step;
		} else if (adjustedPage > range) {
			adjustedPage = range;
		}
		return adjustedPage;
	}

	private function thumbSkin_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}

		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbSkin_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, thumbSkin_stage_mouseUpHandler, false, 0, true);

		this._thumbStartX = this._currentThumbSkin.x;
		this._thumbStartY = this._currentThumbSkin.y;
		// use mouseX/Y here instead of the values from the event because the
		// event values seem to be inaccurate and jumpy
		this._pointerStartX = this.mouseX;
		this._pointerStartY = this.mouseY;
		this._dragging = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function thumbSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var newValue = this.locationToValue(this.mouseX, this.mouseY);
		newValue = this.restrictValue(newValue);
		// use the setter
		this.value = newValue;
	}

	private function thumbSkin_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbSkin_stage_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, thumbSkin_stage_mouseUpHandler);
		this._dragging = false;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function trackSkin_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}

		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, trackSkin_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, trackSkin_stage_mouseUpHandler, false, 0, true);

		this.saveThumbStart(this.mouseX, this.mouseY);
		this._pointerStartX = this.mouseX;
		this._pointerStartY = this.mouseY;
		this._dragging = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);

		var newValue = this.locationToValue(this.mouseX, this.mouseY);
		newValue = this.restrictValue(newValue);
		// use the setter
		this.value = newValue;
	}

	private function trackSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var newValue = this.locationToValue(this.mouseX, this.mouseY);
		newValue = this.restrictValue(newValue);
		// use the setter
		this.value = newValue;
	}

	private function trackSkin_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, trackSkin_stage_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, trackSkin_stage_mouseUpHandler);
		this._dragging = false;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}
}
