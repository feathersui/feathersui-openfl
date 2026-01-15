/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.controls.IRange;
import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IUIControl;
import feathers.events.FeathersEvent;
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
	Base class for slider components.

	@event openfl.events.Event.CHANGE Dispatched when `BaseSlider.value`
	changes.

	@see `feathers.controls.HSlider`
	@see `feathers.controls.VSlider`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class BaseSlider extends FeathersControl implements IRange implements IFocusObject {
	private function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		super();

		this.tabEnabled = true;
		this.tabChildren = false;

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
		The value of the slider, which must be between the `minimum` and the
		`maximum`.

		When the `value` property changes, the slider will dispatch an event of
		type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```haxe
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 12.0;
		```

		@default 0.0

		@see `BaseSlider.minimum`
		@see `BaseSlider.maximum`
		@see `BaseSlider.step`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	@:bindable("change")
	@:inspectable(defaultValue = "0.0")
	public var value(get, set):Float;

	private function get_value():Float {
		return this._value;
	}

	private function set_value(value:Float):Float {
		// don't restrict a value that has been passed in from an external
		// source to the minimum/maximum/snapInterval
		// assume that the user knows what they are doing
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
		The slider's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100.0`:

		```haxe
		slider.minimum = -100.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 50.0;
		```

		@default 0.0

		@see `BaseSlider.value`
		@see `BaseSlider.maximum`

		@since 1.0.0
	**/
	@:inspectable(defaultValue = "0.0")
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
		The slider's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```haxe
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 12.0;
		```

		@default 1.0

		@see `BaseSlider.value`
		@see `BaseSlider.minimum`

		@since 1.0.0
	**/
	@:inspectable(defaultValue = "1.0")
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

	// this should not be 0.0 by default because 0.0 breaks keyboard events
	private var _step:Float = 0.01;

	/**
		Indicates the amount that `value` is changed when the slider has focus
		and one of the arrow keys is pressed.

		The value should always be greater than `0.0` to ensure that the slider
		reacts to keyboard events when focused.

		In the following example, the step is changed to `1.0`:

		```haxe
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 10.0;
		```

		@default 0.01

		@see `BaseSlider.value`
		@see `BaseSlider.minimum`
		@see `BaseSlider.maximum`
		@see `BaseSlider.snapInterval`

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
		When the slider's `value` changes, it may be "snapped" to the nearest
		multiple of `snapInterval`. If `snapInterval` is `0.0`, the `value` is
		not snapped.

		In the following example, the snap inverval is changed to `1.0`:

		```haxe
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.snapInterval = 1.0;
		slider.value = 10.0;
		```

		@default 0.0

		@see `BaseSlider.step`

		@since 1.0.0
	**/
	@:inspectable(defaultValue = "0.0")
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

	/**
		Determines if the slider dispatches the `Event.CHANGE` event every time
		that the thumb moves while dragging, or only after the user stops
		dragging.

		In the following example, live dragging is disabled:

		```haxe
		slider.liveDragging = false;
		```

		@default true

		@since 1.0.0
	**/
	@:inspectable
	public var liveDragging:Bool = true;

	private var _currentThumbSkin:InteractiveObject = null;
	private var _thumbSkinMeasurements:Measurements = null;

	/**
		The skin to use for the slider's thumb.

		In the following example, a thumb skin is passed to the slider:

		```haxe
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		slider.thumbSkin = skin;
		```

		@see `BaseSlider.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var thumbSkin:InteractiveObject = null;

	private var _currentTrackSkin:InteractiveObject = null;
	private var _trackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the slider's track.

		In the following example, a track skin is passed to the slider:

		```haxe
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		slider.trackSkin = skin;
		```

		@see `BaseSlider.secondaryTrackSkin`
		@see `BaseSlider.thumbSkin`

		@since 1.0.0
	**/
	@:style
	public var trackSkin:InteractiveObject = null;

	private var _currentSecondaryTrackSkin:InteractiveObject = null;
	private var _secondaryTrackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the slider's optional secondary track. If a slider
		has one track, it will fill the entire length of the slider. If a slider
		has a track and a secondary track, the primary track will stretch
		between the minimum edge of the slider and the location of the slider's
		thumb, while the secondary track will stretch from the location of the
		slider's thumb to the maximum edge of the slider.

		In the following example, a track skin and a secondary track skin are
		passed to the slider:

		```haxe
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xaaaaaa);
		slider.trackSkin = skin;

		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		slider.secondaryTrackSkin = skin;
		```

		@see `BaseSlider.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var secondaryTrackSkin:InteractiveObject = null;

	/**
		The space, measured in pixels, between the minimum position of the thumb
		and the the minimum edge of the track. May be negative to optionally
		extend the draggable range of the thumb beyond the track's bounds.

		In the following example, minimum padding is set to 20 pixels:

		```haxe
		slider.minimumPadding = 20.0;
		```

		@see `BaseSlider.maximumPadding`

		@since 1.0.0
	**/
	@:style
	public var minimumPadding:Float = 0.0;

	/**
		The space, measured in pixels, between the maximum position of the thumb
		and the the maximum edge of the track. May be negative to optionally
		extend the draggable range of the thumb beyond the track's bounds.

		In the following example, maximum padding is set to 20 pixels:

		```haxe
		slider.maximumPadding = 20.0;
		```

		@see `BaseSlider.minimumPadding`

		@since 1.0.0
	**/
	@:style
	public var maximumPadding:Float = 0.0;

	/**
		Offets the horizontal position of the thumb by a specific number of
		pixels.

		In the following example, horizontal thumb offset is set to 6 pixels:

		```haxe
		slider.thumbOffsetX = 6.0;
		```

		@see `BaseSlider.thumbOffsetY`

		@since 1.4.0
	**/
	@:style
	public var thumbOffsetX:Float = 0.0;

	/**
		Offets the vertical position of the thumb by a specific number of
		pixels.

		In the following example, vertical thumb offset is set to 6 pixels:

		```haxe
		slider.thumbOffsetY = 6.0;
		```

		@see `BaseSlider.thumbOffsetX`

		@since 1.4.0
	**/
	@:style
	public var thumbOffsetY:Float = 0.0;

	private var _dragging:Bool = false;
	private var _pointerStartX:Float = 0.0;
	private var _pointerStartY:Float = 0.0;
	private var _thumbStartX:Float = 0.0;
	private var _thumbStartY:Float = 0.0;

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if ((this._currentThumbSkin is IFocusObject)) {
			var focusThumb:IFocusObject = cast this._currentThumbSkin;
			if (focusThumb.focusEnabled) {
				focusThumb.showFocus(show);
			}
		}
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
				(cast oldSkin : IProgrammaticSkin).uiContext = null;
			}
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			this.removeChild(oldSkin);
		}
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IUIControl)) {
				(cast this._currentThumbSkin : IUIControl).initializeNow();
			}
			if (this._thumbSkinMeasurements == null) {
				this._thumbSkinMeasurements = new Measurements(this._currentThumbSkin);
			} else {
				this._thumbSkinMeasurements.save(this._currentThumbSkin);
			}
			// add it in front of both the trackSkin and secondaryTrackSkin
			this.addChild(this._currentThumbSkin);
			this._currentThumbSkin.addEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			if ((this._currentThumbSkin is IProgrammaticSkin)) {
				(cast this._currentThumbSkin : IProgrammaticSkin).uiContext = this;
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
				(cast oldSkin : IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
		}
		if (this._currentTrackSkin != null) {
			if ((this._currentTrackSkin is IFocusObject)) {
				(cast this._currentTrackSkin : IFocusObject).focusEnabled = false;
			}
			if ((this._currentTrackSkin is IUIControl)) {
				(cast this._currentTrackSkin : IUIControl).initializeNow();
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
				(cast this._currentTrackSkin : IProgrammaticSkin).uiContext = this;
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
				(cast oldSkin : IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
			oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
		}
		if (this._currentSecondaryTrackSkin != null) {
			if ((this._currentSecondaryTrackSkin is IFocusObject)) {
				(cast this._currentSecondaryTrackSkin : IFocusObject).focusEnabled = false;
			}
			if ((this._currentSecondaryTrackSkin is IUIControl)) {
				(cast this._currentSecondaryTrackSkin : IUIControl).initializeNow();
			}
			if (this._secondaryTrackSkinMeasurements == null) {
				this._secondaryTrackSkinMeasurements = new Measurements(this._currentSecondaryTrackSkin);
			} else {
				this._secondaryTrackSkinMeasurements.save(this._currentSecondaryTrackSkin);
			}
			// in front of the trackSkin, if it exists
			// otherwise, on the bottom
			var index = this._currentTrackSkin != null ? 1 : 0;
			this.addChildAt(this._currentSecondaryTrackSkin, index);
			this._currentSecondaryTrackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			if ((this._currentSecondaryTrackSkin is IProgrammaticSkin)) {
				(cast this._currentSecondaryTrackSkin : IProgrammaticSkin).uiContext = this;
			}
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
	}

	private function refreshEnabled():Void {
		if ((this._currentThumbSkin is IUIControl)) {
			(cast this._currentThumbSkin : IUIControl).enabled = this._enabled;
		}
		if ((this._currentTrackSkin is IUIControl)) {
			(cast this._currentTrackSkin : IUIControl).enabled = this._enabled;
		}
		if ((this._currentSecondaryTrackSkin is IUIControl)) {
			(cast this._currentSecondaryTrackSkin : IUIControl).enabled = this._enabled;
		}
	}

	private function layoutContent():Void {
		if (this._currentTrackSkin != null && this._currentSecondaryTrackSkin != null) {
			this.layoutSplitTrack();
		} else {
			this.layoutSingleTrack();
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

		this._thumbStartX = this._currentThumbSkin.x - this.thumbOffsetX;
		this._thumbStartY = this._currentThumbSkin.y - this.thumbOffsetY;
		this._pointerStartX = this.mouseX;
		this._pointerStartY = this.mouseY;
		this._dragging = true;
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
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}
}
