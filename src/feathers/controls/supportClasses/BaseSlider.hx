/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.IFocusObject;
import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.core.IUIControl;
import feathers.controls.IRange;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
	Base class for slider components.

	@see `feathers.controls.HSlider`
	@see `feathers.controls.VSlider`

	@since 1.0.0
**/
class BaseSlider extends FeathersControl implements IRange implements IFocusObject {
	private function new() {
		super();
	}

	/**
		The value of the slider, which must be between the `minimum` and the
		`maximum`.

		When the `value` property changes, the slider will dispatch an event of
		type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```hx
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 12.0;
		```

		@default 0.0

		@see `BaseSlider.minimum`
		@see `BaseSlider.maximum`
		@see `BaseSlider.step`
		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
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
		The slider's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100.0`:

		```hx
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
		The slider's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```hx
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
		As the slider's thumb is dragged, the `value` is snapped to the nearest
		multiple of `step`. If `step` is `0.0`, the `value` is not snapped.

		In the following example, the step is changed to `1.0`:

		```hx
		slider.minimum = 0.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 10.0;
		```

		@default 0.0

		@see `BaseSlider.value`
		@see `BaseSlider.minimum`
		@see `BaseSlider.maximum`

		@since 1.0.0
	**/
	public var step(default, set):Float = 0.1;

	private function set_step(value:Float):Float {
		if (this.step == value) {
			return this.step;
		}
		this.step = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.step;
	}

	/**
		Determines if the slider dispatches the `Event.CHANGE` event every time
		that the thumb moves while dragging, or only after the user stops
		dragging.

		In the following example, live dragging is disabled:

		```hx
		slider.liveDragging = false;
		```

		@default true

		@since 1.0.0
	**/
	public var liveDragging(default, default):Bool = true;

	private var thumbContainer:Sprite;
	private var _currentThumbSkin:DisplayObject = null;
	private var _thumbSkinMeasurements:Measurements = null;

	/**
		The skin to use for the slider's thumb.

		In the following example, a thumb skin is passed to the slider:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		slider.thumbSkin = skin;
		```

		@see `BaseSlider.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var thumbSkin:DisplayObject = null;

	private var trackContainer:Sprite;
	private var _currentTrackSkin:DisplayObject = null;
	private var _trackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the slider's track.

		In the following example, a track skin is passed to the slider:

		```hx
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		slider.trackSkin = skin;
		```

		@see `BaseSlider.secondaryTrackSkin`
		@see `BaseSlider.thumbSkin`

		@since 1.0.0
	**/
	@:style
	public var trackSkin:DisplayObject = null;

	private var secondaryTrackContainer:Sprite;
	private var _currentSecondaryTrackSkin:DisplayObject = null;
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

		```hx
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
	public var secondaryTrackSkin:DisplayObject = null;

	/**
		The space, measured in pixels, between the minimum position of the thumb
		and the the minimum edge of the track. May be negative to optionally
		extend the draggable range of the thumb beyond the track's bounds.

		In the following example, minimum padding is set to 20 pixels:

		```hx
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

		```hx
		slider.maximumPadding = 20.0;
		```

		@see `BaseSlider.minimumPadding`

		@since 1.0.0
	**/
	@:style
	public var maximumPadding:Float = 0.0;

	private var _dragging:Bool = false;
	private var _pointerStartX:Float = 0.0;
	private var _pointerStartY:Float = 0.0;
	private var _thumbStartX:Float = 0.0;
	private var _thumbStartY:Float = 0.0;

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if (Std.is(this.thumbSkin, IFocusObject)) {
			var focusThumb = cast(this.thumbSkin, IFocusObject);
			if (focusThumb.focusEnabled) {
				focusThumb.showFocus(show);
			}
		}
	}

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
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

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
			if (this.thumbContainer != null) {
				this.thumbContainer.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
				this.thumbContainer.removeChild(oldSkin);
				this.removeChild(this.thumbContainer);
				this.thumbContainer = null;
			} else {
				oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
				this.removeChild(oldSkin);
			}
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
			if (!Std.is(this._currentThumbSkin, InteractiveObject)) {
				// if the skin isn't interactive, we need to add it to something
				// that is interactive
				this.thumbContainer = new Sprite();
				this.thumbContainer.addChild(this._currentThumbSkin);
				this.addChild(this.thumbContainer);
				this.thumbContainer.addEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
			} else {
				// add it above the trackSkin and secondaryTrackSkin
				this.addChild(this._currentThumbSkin);
				this.thumbSkin.addEventListener(MouseEvent.MOUSE_DOWN, thumbSkin_mouseDownHandler);
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
			if (this.trackContainer != null) {
				this.trackContainer.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
				this.trackContainer.removeChild(oldSkin);
				this.removeChild(this.trackContainer);
				this.trackContainer = null;
			} else {
				this.removeChild(oldSkin);
				oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
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
			if (!Std.is(this._currentTrackSkin, InteractiveObject)) {
				// if the skin isn't interactive, we need to add it to something
				// that is interactive
				this.trackContainer = new Sprite();
				this.trackContainer.addChild(this._currentTrackSkin);
				this.addChildAt(this.trackContainer, 0);
				this.trackContainer.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			} else {
				// always on the bottom
				this.addChildAt(this._currentTrackSkin, 0);
				this.trackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
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
			if (this.secondaryTrackContainer != null) {
				this.secondaryTrackContainer.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
				this.secondaryTrackContainer.removeChild(oldSkin);
				this.removeChild(this.secondaryTrackContainer);
				this.secondaryTrackContainer = null;
			} else {
				this.removeChild(oldSkin);
				oldSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
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

			if (!Std.is(this._currentSecondaryTrackSkin, InteractiveObject)) {
				// if the skin isn't interactive, we need to add it to something
				// that is interactive
				this.secondaryTrackContainer = new Sprite();
				this.secondaryTrackContainer.addChild(this._currentSecondaryTrackSkin);
				this.addChildAt(this.secondaryTrackContainer, index);
				this.secondaryTrackContainer.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			} else {
				this.addChildAt(this._currentSecondaryTrackSkin, index);
				this._currentSecondaryTrackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
	}

	private function refreshEnabled():Void {
		if (Std.is(this.thumbSkin, IUIControl)) {
			cast(this.thumbSkin, IUIControl).enabled = this.enabled;
		}
		if (Std.is(this.trackSkin, IUIControl)) {
			cast(this.trackSkin, IUIControl).enabled = this.enabled;
		}
		if (Std.is(this.secondaryTrackSkin, IUIControl)) {
			cast(this.secondaryTrackSkin, IUIControl).enabled = this.enabled;
		}
	}

	private function layoutContent():Void {
		if (this.trackSkin != null && this.secondaryTrackSkin != null) {
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

	private function normalizeValue():Float {
		var normalized = 1.0;
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

	private function saveThumbStart(location:Point):Void {
		throw new TypeError("Missing override for 'saveThumbStart' in type " + Type.getClassName(Type.getClass(this)));
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

	private function trackSkin_mouseDownHandler(event:MouseEvent):Void {
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, trackSkin_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, trackSkin_stage_mouseUpHandler, false, 0, true);

		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		this.saveThumbStart(location);
		this._pointerStartX = location.x;
		this._pointerStartY = location.y;
		this._dragging = true;
		this.value = this.locationToValue(location.x, location.y);
	}

	private function trackSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var location = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		this.value = this.locationToValue(location.x, location.y);
	}

	private function trackSkin_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, trackSkin_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, trackSkin_stage_mouseUpHandler);
		this._dragging = false;
		if (!this.liveDragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}
}
