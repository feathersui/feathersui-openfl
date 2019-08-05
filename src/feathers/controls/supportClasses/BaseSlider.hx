/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.core.IUIControl;
import feathers.core.IValidating;
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
class BaseSlider extends FeathersControl {
	private function new() {
		super();
	}

	/**
		The value of the slider, which must be between the `minimum` and the
		`maximum`.

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
	**/
	public var value(default, set):Float = 0.0;

	private function set_value(value:Float):Float {
		if (this.value == value) {
			return this.value;
		}
		this.value = value;
		this.setInvalid(InvalidationFlag.DATA);
		if (this.liveDragging && !this._dragging) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		return this.value;
	}

	/**
		The slider's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100.0`:

		``` hx
		slider.minimum = -100.0;
		slider.maximum = 100.0;
		slider.step = 1.0;
		slider.value = 50.0;
		```

		@default 0.0

		@see `BaseSlider.value`
		@see `BaseSlider.maximum`
	**/
	public var minimum(default, set):Float = 0.0;

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
	**/
	public var maximum(default, set):Float = 1.0;

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
	**/
	public var step(default, set):Float = 0.0;

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
	**/
	public var liveDragging(default, default):Bool = true;

	private var thumbContainer:Sprite;
	private var _thumbSkinMeasurements:Measurements = null;

	/**
		@see `BaseSlider.trackSkin`
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

	private var trackContainer:Sprite;
	private var _trackSkinMeasurements:Measurements = null;

	/**
		@see `BaseSlider.secondaryTrackSkin`
		@see `BaseSlider.thumbSkin`
	**/
	@style
	public var trackSkin(default, set):DisplayObject = null;

	private function set_trackSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("trackSkin")) {
			return this.trackSkin;
		}
		if (this.trackSkin == value) {
			return this.trackSkin;
		}
		if (this.trackSkin != null) {
			if (this.trackContainer != null) {
				this.trackContainer.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
				this.trackContainer.removeChild(this.trackSkin);
				this.removeChild(this.trackContainer);
				this.trackContainer = null;
			} else {
				this.removeChild(this.trackSkin);
				this.trackSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
		}
		this.trackSkin = value;
		if (this.trackSkin != null) {
			if (Std.is(this.trackSkin, IUIControl)) {
				cast(this.trackSkin, IUIControl).initializeNow();
			}
			if (this._trackSkinMeasurements == null) {
				this._trackSkinMeasurements = new Measurements(this.trackSkin);
			} else {
				this._trackSkinMeasurements.save(this.trackSkin);
			}
			if (!Std.is(this.trackSkin, InteractiveObject)) {
				// if the skin isn't interactive, we need to add it to something
				// that is interactive
				this.trackContainer = new Sprite();
				this.trackContainer.addChild(this.trackSkin);
				this.addChildAt(this.trackContainer, 0);
				this.trackContainer.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			} else {
				// always on the bottom
				this.addChildAt(this.trackSkin, 0);
				this.trackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
		} else {
			this._trackSkinMeasurements = null;
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.trackSkin;
	}

	private var secondaryTrackContainer:Sprite;
	private var _secondaryTrackSkinMeasurements:Measurements = null;

	/**
		@see `BaseSlider.trackSkin`
	**/
	@style
	public var secondaryTrackSkin(default, set):DisplayObject = null;

	private function set_secondaryTrackSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("secondaryTrackSkin")) {
			return this.secondaryTrackSkin;
		}
		if (this.secondaryTrackSkin == value) {
			return this.secondaryTrackSkin;
		}
		if (this.secondaryTrackSkin != null) {
			if (this.secondaryTrackContainer != null) {
				this.secondaryTrackContainer.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
				this.secondaryTrackContainer.removeChild(this.secondaryTrackSkin);
				this.removeChild(this.secondaryTrackContainer);
				this.secondaryTrackContainer = null;
			} else {
				this.removeChild(this.secondaryTrackSkin);
				this.secondaryTrackSkin.removeEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
		}
		this.secondaryTrackSkin = value;
		if (this.secondaryTrackSkin != null) {
			if (Std.is(this.secondaryTrackSkin, IUIControl)) {
				cast(this.secondaryTrackSkin, IUIControl).initializeNow();
			}
			if (this._secondaryTrackSkinMeasurements == null) {
				this._secondaryTrackSkinMeasurements = new Measurements(this.secondaryTrackSkin);
			} else {
				this._secondaryTrackSkinMeasurements.save(this.secondaryTrackSkin);
			}

			// on the bottom or above the trackSkin
			var index = this.trackSkin != null ? 1 : 0;

			if (!Std.is(this.secondaryTrackSkin, InteractiveObject)) {
				// if the skin isn't interactive, we need to add it to something
				// that is interactive
				this.secondaryTrackContainer = new Sprite();
				this.secondaryTrackContainer.addChild(this.secondaryTrackSkin);
				this.addChildAt(this.secondaryTrackContainer, index);
				this.secondaryTrackContainer.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			} else {
				this.addChildAt(this.secondaryTrackSkin, index);
				this.secondaryTrackSkin.addEventListener(MouseEvent.MOUSE_DOWN, trackSkin_mouseDownHandler);
			}
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.secondaryTrackSkin;
	}

	/**
		@see `BaseSlider.maximumPadding`
	**/
	@style
	public var minimumPadding(default, set):Null<Float> = null;

	private function set_minimumPadding(value:Null<Float>):Null<Float> {
		if (!this.setStyle("minimumPadding")) {
			return this.minimumPadding;
		}
		if (this.minimumPadding == value) {
			return this.minimumPadding;
		}
		this.minimumPadding = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.minimumPadding;
	}

	/**
		@see `BaseSlider.minimumPadding`
	**/
	@style
	public var maximumPadding(default, set):Null<Float> = null;

	private function set_maximumPadding(value:Null<Float>):Null<Float> {
		if (!this.setStyle("maximumPadding")) {
			return this.maximumPadding;
		}
		if (this.maximumPadding == value) {
			return this.minimumPadding;
		}
		this.maximumPadding = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.maximumPadding;
	}

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
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

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

		var location:Point = new Point(event.stageX, event.stageY);
		location = this.globalToLocal(location);

		this._thumbStartX = this.thumbSkin.x;
		this._thumbStartY = this.thumbSkin.y;
		this._pointerStartX = location.x;
		this._pointerStartY = location.y;
		this._dragging = true;
	}

	private function thumbSkin_stage_mouseMoveHandler(event:MouseEvent):Void {
		var location:Point = new Point(event.stageX, event.stageY);
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
		var location:Point = new Point(event.stageX, event.stageY);
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
