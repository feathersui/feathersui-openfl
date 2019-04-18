/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.Direction;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
	Select a value between a minimum and a maximum by dragging a thumb over the
	bounds of a track.

	The following example sets the slider's range and listens for when the value
	changes:

	```hx
	var slider:Slider = new Slider();
	slider.minimum = 0;
	slider.maximum = 100;
	slider.step = 1;
	slider.value = 12;
	slider.addEventListener( Event.CHANGE, slider_changeHandler );
	this.addChild( slider );</listing>
	```

	@see [How to use the Feathers Slider component](../../../help/slider.html)

	@since 1.0.0
**/
class Slider extends FeathersControl {
	public function new() {
		super();
	}

	/**
		The value of the slider, which must be between the `minimum` and the
		`maximum`.

		In the following example, the value is changed to `12`:

		```hx
		slider.minimum = 0;
		slider.maximum = 100;
		slider.step = 1;
		slider.value = 12;
		```

		@default 0

		@see `Slider.minimum`
		@see `Slider.maximum`
		@see `Slider.step`
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

		In the following example, the minimum is set to `-100`:

		``` hx
		slider.minimum = -100;
		slider.maximum = 100;
		slider.step = 1;
		slider.value = 50;</listing>
		```

		@default 0

		@see `Slider.value`
		@see `Slider.maximum`
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

		In the following example, the maximum is set to `100`:

		```hx
		slider.minimum = 0;
		slider.maximum = 100;
		slider.step = 1;
		slider.value = 12;
		```

		@default 1

		@see `Slider.value`
		@see `Slider.minimum`
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
		multiple of `step`. If `step` is `0`, the `value` is not snapped.

		In the following example, the step is changed to `1`:

		```hx
		slider.minimum = 0;
		slider.maximum = 100;
		slider.step = 1;
		slider.value = 10;
		```

		@default 0

		@see `Slider.value`
		@see `Slider.minimum`
		@see `Slider.maximum`
	**/
	public var step(default, set):Float = 0;

	private function set_step(value:Float):Float {
		if (this.step == value) {
			return this.step;
		}
		this.step = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.step;
	}

	/**
		Determines if the slider's thumb can be dragged horizontally or
		vertically.

		When the direction is changed after the slider initializes, the slider's
		width and height values may not change automatically, and the skins may
		no longer be appropriate for the new direction.

		In the following example, the direction is changed to vertical:

		```hx
		slider.direction = Direction.VERTICAL;
		```

		*Note:* The `Direction.NONE` value is not supported.

		@default `feathers.layout.Direction.HORIZONTAL`

		@see `feathers.layout.Direction#HORIZONTAL`
		@see `feathers.layout.Direction#VERTICAL`
	**/
	public var direction(default, set):Direction = Direction.HORIZONTAL;

	private function set_direction(value:Direction):Direction {
		if (this.direction == value) {
			return this.direction;
		}
		this.direction = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.direction;
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

	/**
		@see `Slider.trackSkin`
	**/
	public var thumbSkin(default, set):DisplayObject;

	private function set_thumbSkin(value:DisplayObject):DisplayObject {
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
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.thumbSkin;
	}

	private var trackContainer:Sprite;

	/**
		@see `Slider.secondaryTrackSkin`
		@see `Slider.thumbSkin`
	**/
	public var trackSkin(default, set):DisplayObject;

	private function set_trackSkin(value:DisplayObject):DisplayObject {
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
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.trackSkin;
	}

	private var secondaryTrackContainer:Sprite;

	/**
		@see `Slider.trackSkin`
	**/
	public var secondaryTrackSkin(default, set):DisplayObject;

	private function set_secondaryTrackSkin(value:DisplayObject):DisplayObject {
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
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.secondaryTrackSkin;
	}

	/**
		@see `Slider.maximumPadding`
	**/
	public var minimumPadding(default, set):Float = 0;

	private function set_minimumPadding(value:Float):Float {
		if (this.minimumPadding == value) {
			return this.minimumPadding;
		}
		this.minimumPadding = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.minimumPadding;
	}

	/**
		@see `Slider.minimumPadding`
	**/
	public var maximumPadding(default, set):Float = 0;

	private function set_maximumPadding(value:Float):Float {
		if (this.maximumPadding == value) {
			return this.minimumPadding;
		}
		this.maximumPadding = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.maximumPadding;
	}

	private var _dragging:Bool = false;
	private var _pointerStartX:Float = 0;
	private var _pointerStartY:Float = 0;
	private var _thumbStartX:Float = 0;
	private var _thumbStartY:Float = 0;

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
		return false;
	}

	private function refreshEnabled():Void {
		if (Std.is(this.thumbSkin, FeathersControl)) {
			cast(this.thumbSkin, FeathersControl).enabled = this.enabled;
		}
		if (Std.is(this.trackSkin, FeathersControl)) {
			cast(this.trackSkin, FeathersControl).enabled = this.enabled;
		}
		if (Std.is(this.secondaryTrackSkin, FeathersControl)) {
			cast(this.secondaryTrackSkin, FeathersControl).enabled = this.enabled;
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
		var location = this.valueToLocation(value);
		if (this.direction == Direction.VERTICAL) {
			if (this.thumbSkin != null) {
				if (Std.is(this.thumbSkin, IValidating)) {
					cast(this.thumbSkin, IValidating).validateNow();
				}
				location += Math.round(this.thumbSkin.height / 2);
			}

			this.trackSkin.y = 0;
			this.trackSkin.height = location;

			this.secondaryTrackSkin.y = location;
			this.secondaryTrackSkin.height = this.actualHeight - location;

			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating).validateNow();
			}
			if (Std.is(this.secondaryTrackSkin, IValidating)) {
				cast(this.secondaryTrackSkin, IValidating).validateNow();
			}

			this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2;
			this.secondaryTrackSkin.x = (this.actualWidth - this.secondaryTrackSkin.width) / 2;
		} else // horizontal
		{
			if (this.thumbSkin != null) {
				if (Std.is(this.thumbSkin, IValidating)) {
					cast(this.thumbSkin, IValidating).validateNow();
				}
				location += Math.round(this.thumbSkin.width / 2);
			}

			this.trackSkin.x = 0;
			this.trackSkin.width = location;

			this.secondaryTrackSkin.x = location;
			this.secondaryTrackSkin.width = this.actualWidth - location;

			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating).validateNow();
			}
			if (Std.is(this.secondaryTrackSkin, IValidating)) {
				cast(this.secondaryTrackSkin, IValidating).validateNow();
			}

			this.trackSkin.y = (this.actualHeight - this.trackSkin.height) / 2;
			this.secondaryTrackSkin.y = (this.actualHeight - this.secondaryTrackSkin.height) / 2;
		}
	}

	private function layoutSingleTrack():Void {
		if (this.trackSkin == null) {
			return;
		}
		if (this.direction == Direction.VERTICAL) {
			this.trackSkin.y = 0;
			this.trackSkin.height = this.actualHeight;

			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating).validateNow();
			}

			this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2;
		} else // horizontal
		{
			this.trackSkin.x = 0;
			this.trackSkin.width = this.actualWidth;

			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating).validateNow();
			}

			this.trackSkin.y = (this.actualHeight - this.trackSkin.height) / 2;
		}
	}

	private function layoutThumb():Void {
		if (this.thumbSkin == null) {
			return;
		}
		var thumbLocation = this.valueToLocation(this.value);
		if (this.direction == Direction.VERTICAL) {
			this.thumbSkin.x = Math.round((this.actualWidth - this.thumbSkin.width) / 2);
			this.thumbSkin.y = thumbLocation;
		} else // horizontal
		{
			this.thumbSkin.x = thumbLocation;
			this.thumbSkin.y = Math.round((this.actualHeight - this.thumbSkin.height) / 2);
		}
	}

	private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var percentage = 1.0;
		if (this.minimum != this.maximum) {
			percentage = (this.value - this.minimum) / (this.maximum - this.minimum);
			if (percentage < 0) {
				percentage = 0;
			} else if (percentage > 1) {
				percentage = 1;
			}
		}

		if (this.direction == Direction.VERTICAL) {
			var trackScrollableHeight = this.actualHeight - this.minimumPadding - this.maximumPadding;
			if (this.thumbSkin != null) {
				trackScrollableHeight -= this.thumbSkin.height;
			}
			// maximum is at the top, so we need to start the y position of
			// the thumb from the maximum padding
			return Math.round(this.maximumPadding + trackScrollableHeight * (1 - percentage));
		}

		// horizontal
		var trackScrollableWidth = this.actualWidth - this.minimumPadding - this.maximumPadding;
		if (this.thumbSkin != null) {
			trackScrollableWidth -= this.thumbSkin.width;
		}
		// minimum is at the left, so we need to start the x position of
		// the thumb from the minimum padding
		return Math.round(this.minimumPadding + (trackScrollableWidth * percentage));
	}

	private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		if (this.direction == Direction.VERTICAL) {
			var trackScrollableHeight = this.actualHeight - this.minimumPadding - this.maximumPadding;
			if (this.thumbSkin != null) {
				trackScrollableHeight -= this.thumbSkin.height;
			}
			var yOffset = y - this._pointerStartY - this.maximumPadding;
			var yPosition = Math.min(Math.max(0, this._thumbStartY + yOffset), trackScrollableHeight);
			percentage = 1 - (yPosition / trackScrollableHeight);
		} else // horizontal
		{
			var trackScrollableWidth = this.actualWidth - this.minimumPadding - this.maximumPadding;
			if (this.thumbSkin != null) {
				trackScrollableWidth -= this.thumbSkin.width;
			}
			var xOffset = x - this._pointerStartX - this.minimumPadding;
			var xPosition = Math.min(Math.max(0, this._thumbStartX + xOffset), trackScrollableWidth);
			percentage = xPosition / trackScrollableWidth;
		}

		return this.minimum + percentage * (this.maximum - this.minimum);
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

		if (this.direction == Direction.VERTICAL) {
			var trackHeightMinusThumbHeight = this.actualHeight;
			var locationMinusHalfThumbHeight = location.y;
			if (this.thumbSkin != null) {
				trackHeightMinusThumbHeight -= this.thumbSkin.height;
				locationMinusHalfThumbHeight -= this.thumbSkin.height / 2;
			}
			this._thumbStartX = location.x;
			this._thumbStartY = Math.min(trackHeightMinusThumbHeight - this.maximumPadding, Math.max(this.minimumPadding, locationMinusHalfThumbHeight));
		} else // horizontal
		{
			var trackWidthMinusThumbWidth = this.actualWidth;
			var locationMinusHalfThumbWidth = location.x;
			if (this.thumbSkin != null) {
				trackWidthMinusThumbWidth -= this.thumbSkin.width;
				locationMinusHalfThumbWidth -= this.thumbSkin.width / 2;
			}
			this._thumbStartX = Math.min(trackWidthMinusThumbWidth - this.maximumPadding, Math.max(this.minimumPadding, locationMinusHalfThumbWidth));
			this._thumbStartY = location.y;
		}
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
