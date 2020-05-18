/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseSlider;
import feathers.core.IValidating;
import feathers.themes.steel.components.SteelVSliderStyles;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;

/**

	A vertical slider where you may select a value within a range by dragging
	a thumb along the y-axis of a track.

	The following example sets the slider's range and listens for when the value
	changes:

	```hx
	var slider = new VSlider();
	slider.minimum = 0.0;
	slider.maximum = 100.0;
	slider.step = 1.0;
	slider.value = 12.0;
	slider.addEventListener(Event.CHANGE, slider_changeHandler);
	this.addChild(slider);
	```

	@see [Tutorial: How to use the HSlider and VSlider components](https://feathersui.com/learn/haxe-openfl/slider/)
	@see `feathers.controls.HSlider`

	@since 1.0.0
**/
@:styleContext
class VSlider extends BaseSlider {
	/**
		Creates a new `VSlider` object.

		@since 1.0.0
	**/
	public function new() {
		initializeVSliderTheme();

		super();

		this.addEventListener(KeyboardEvent.KEY_DOWN, vSlider_keyDownHandler);
	}

	private function initializeVSliderTheme():Void {
		SteelVSliderStyles.initialize();
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var normalized = this.normalizeValue();

		var trackScrollableHeight = this.actualHeight - this.minimumPadding - this.maximumPadding;
		if (this.thumbSkin != null) {
			trackScrollableHeight -= this.thumbSkin.height;
		}
		// maximum is at the top, so we need to start the y position of
		// the thumb from the maximum padding
		return Math.round(this.maximumPadding + trackScrollableHeight * (1.0 - normalized));
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;

		var trackScrollableHeight = this.actualHeight - this.minimumPadding - this.maximumPadding;
		if (this.thumbSkin != null) {
			trackScrollableHeight -= this.thumbSkin.height;
		}
		var yOffset = y - this._pointerStartY - this.maximumPadding;
		var yPosition = Math.min(Math.max(0.0, this._thumbStartY + yOffset), trackScrollableHeight);
		percentage = 1.0 - (yPosition / trackScrollableHeight);

		return this.minimum + percentage * (this.maximum - this.minimum);
	}

	override private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this.thumbSkin != null) {
			this._thumbSkinMeasurements.restore(this.thumbSkin);
			if (Std.is(this.thumbSkin, IValidating)) {
				cast(this.thumbSkin, IValidating).validateNow();
			}
		}
		if (this.trackSkin != null) {
			this._trackSkinMeasurements.restore(this.trackSkin);
			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating).validateNow();
			}
		}
		if (this.secondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this.secondaryTrackSkin);
			if (Std.is(this.secondaryTrackSkin, IValidating)) {
				cast(this.secondaryTrackSkin, IValidating).validateNow();
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.thumbSkin.width;
			if (newWidth < this.trackSkin.width) {
				newWidth = this.trackSkin.width;
			}
			if (this.secondaryTrackSkin != null && newWidth < this.secondaryTrackSkin.width) {
				newWidth = this.secondaryTrackSkin.width;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.trackSkin.height;
			if (this.secondaryTrackSkin != null) {
				newHeight += this.secondaryTrackSkin.height;
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function saveThumbStart(location:Point):Void {
		var trackHeightMinusThumbHeight = this.actualHeight;
		var locationMinusHalfThumbHeight = location.y;
		if (this.thumbSkin != null) {
			trackHeightMinusThumbHeight -= this.thumbSkin.height;
			locationMinusHalfThumbHeight -= this.thumbSkin.height / 2.0;
		}
		this._thumbStartX = location.x;
		this._thumbStartY = Math.min(trackHeightMinusThumbHeight - this.maximumPadding, Math.max(this.minimumPadding, locationMinusHalfThumbHeight));
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this.thumbSkin != null) {
			if (Std.is(this.thumbSkin, IValidating)) {
				cast(this.thumbSkin, IValidating).validateNow();
			}
			location += Math.round(this.thumbSkin.height / 2.0);
		}

		this.secondaryTrackSkin.y = 0.0;
		this.secondaryTrackSkin.height = location;

		this.trackSkin.y = location;
		this.trackSkin.height = this.actualHeight - location;

		if (Std.is(this.secondaryTrackSkin, IValidating)) {
			cast(this.secondaryTrackSkin, IValidating).validateNow();
		}
		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}

		this.secondaryTrackSkin.x = (this.actualWidth - this.secondaryTrackSkin.width) / 2.0;
		this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this.trackSkin == null) {
			return;
		}

		this.trackSkin.y = 0.0;
		this.trackSkin.height = this.actualHeight;

		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}

		this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2.0;
	}

	override private function layoutThumb():Void {
		if (this.thumbSkin == null) {
			return;
		}
		var thumbLocation = this.valueToLocation(this.value);
		this.thumbSkin.x = Math.round((this.actualWidth - this.thumbSkin.width) / 2.0);
		this.thumbSkin.y = thumbLocation;
	}

	private function vSlider_keyDownHandler(event:KeyboardEvent):Void {
		var newValue = this.value;
		switch (event.keyCode) {
			case Keyboard.DOWN:
				newValue -= this.step;
			case Keyboard.UP:
				newValue += this.step;
			case Keyboard.HOME:
				newValue = this.minimum;
			case Keyboard.END:
				newValue = this.maximum;
			default:
				return;
		}
		event.stopPropagation();
		this.value = newValue;
	}
}
