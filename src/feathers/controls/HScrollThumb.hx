/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IValidating;
import feathers.controls.supportClasses.BaseScrollThumb;
import feathers.themes.steel.components.SteelHScrollThumbStyles;

/**
	@since 1.0.0
**/
@:styleContext
class HScrollThumb extends BaseScrollThumb {
	public function new() {
		this.initializeHScrollThumbTheme();

		super();
	}

	private function initializeHScrollThumbTheme():Void {
		SteelHScrollThumbStyles.initialize();
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}
		var normalized = this.normalizeValue();
		var trackScrollableWidth = this.actualWidth - this.thumbSkin.width;
		return Math.round(trackScrollableWidth * normalized);
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableWidth = this.actualWidth - this.thumbSkin.width;
		var xOffset = x - this._pointerStartX;
		var xPosition = Math.min(Math.max(0.0, this._thumbStartX + xOffset), trackScrollableWidth);
		percentage = xPosition / trackScrollableWidth;
		return this.minimum + percentage * (this.maximum - this.minimum);
	}

	override function autoSizeIfNeeded():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		this._thumbSkinMeasurements.restore(this.thumbSkin);
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.thumbSkin.width;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.thumbSkin.height;
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function layoutThumb():Void {
		if (this.thumbSkin == null) {
			return;
		}

		var range = this.maximum - this.minimum;
		/*this.thumbSkin.visible = range > 0.0;
			if (!this.thumbSkin.visible) {
				return;
		}*/

		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var valueOffset = 0.0;
		if (this.value < this.minimum) {
			valueOffset = this.minimum - this.value;
		} else if (this.value > this.maximum) {
			valueOffset = this.maximum - this.value;
		}

		if (this.fixedThumbSize) {
			this.thumbSkin.width = this._thumbSkinMeasurements.width;
		} else {
			var thumbWidth = this.actualWidth * this.getAdjustedPage() / range;
			var widthOffset = this.actualWidth - thumbWidth;
			if (widthOffset > thumbWidth) {
				widthOffset = thumbWidth;
			}
			widthOffset *= valueOffset / (range * thumbWidth / this.actualWidth);
			thumbWidth -= widthOffset;
			if (thumbWidth < this._thumbSkinMeasurements.minWidth) {
				thumbWidth = this._thumbSkinMeasurements.minWidth;
			}
			this.thumbSkin.width = thumbWidth;
		}
		var thumbLocation = this.valueToLocation(this.value);
		this.thumbSkin.x = thumbLocation;
		this.thumbSkin.y = Math.round((this.actualHeight - this.thumbSkin.height) / 2);
	}
}
