/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseSlider;
import feathers.core.IValidating;
import feathers.style.IStyleObject;
import openfl.geom.Point;

/**

	A vertical slider where you may select a value within a range by dragging
	a thumb along the y-axis of a track.

	The following example sets the slider's range and listens for when the value
	changes:

	```hx
	var slider:VSlider = new VSlider();
	slider.minimum = 0;
	slider.maximum = 100;
	slider.step = 1;
	slider.value = 12;
	slider.addEventListener( Event.CHANGE, slider_changeHandler );
	this.addChild( slider );</listing>
	```

	@see `feathers.controls.VSlider`
	@see [How to use the Feathers `HSlider` and `VSlider` components](../../../help/slider.html)

	@since 1.0.0
**/
class VSlider extends BaseSlider {
	public function new() {
		super();
	}

	override private function get_styleContext():Class<IStyleObject> {
		return VSlider;
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
		var yPosition = Math.min(Math.max(0, this._thumbStartY + yOffset), trackScrollableHeight);
		percentage = 1 - (yPosition / trackScrollableHeight);

		return this.minimum + percentage * (this.maximum - this.minimum);
	}

	override private function autoSizeIfNeeded():Bool {
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
				cast(this.thumbSkin, IValidating);
			}
		}
		if (this.trackSkin != null) {
			this._trackSkinMeasurements.restore(this.trackSkin);
			if (Std.is(this.trackSkin, IValidating)) {
				cast(this.trackSkin, IValidating);
			}
		}
		if (this.secondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this.secondaryTrackSkin);
			if (Std.is(this.secondaryTrackSkin, IValidating)) {
				cast(this.secondaryTrackSkin, IValidating);
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this._thumbSkinMeasurements.width;
			if (newWidth < this._trackSkinMeasurements.width) {
				newWidth = this._trackSkinMeasurements.width;
			}
			if (this._secondaryTrackSkinMeasurements != null && newWidth < this._secondaryTrackSkinMeasurements.width) {
				newWidth = this._secondaryTrackSkinMeasurements.width;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._trackSkinMeasurements.height;
			if (this._secondaryTrackSkinMeasurements != null) {
				newHeight += this._secondaryTrackSkinMeasurements.height;
			}
		}

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
			locationMinusHalfThumbHeight -= this.thumbSkin.height / 2;
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
	}

	override private function layoutSingleTrack():Void {
		if (this.trackSkin == null) {
			return;
		}

		this.trackSkin.y = 0;
		this.trackSkin.height = this.actualHeight;

		if (Std.is(this.trackSkin, IValidating)) {
			cast(this.trackSkin, IValidating).validateNow();
		}

		this.trackSkin.x = (this.actualWidth - this.trackSkin.width) / 2;
	}

	override private function layoutThumb():Void {
		if (this.thumbSkin == null) {
			return;
		}
		var thumbLocation = this.valueToLocation(this.value);
		this.thumbSkin.x = Math.round((this.actualWidth - this.thumbSkin.width) / 2);
		this.thumbSkin.y = thumbLocation;
	}
}
