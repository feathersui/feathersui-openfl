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
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this.thumbSkin.width;
		return this.paddingLeft + (trackScrollableWidth * normalized);
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableWidth = this.actualWidth - this.paddingLeft - this.paddingRight - this.thumbSkin.width;
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
			newWidth = this.thumbSkin.width + this.paddingLeft + this.paddingRight;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.thumbSkin.height + this.paddingTop + this.paddingBottom;
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, Math.POSITIVE_INFINITY, newMaxHeight);
	}

	override private function layoutThumb():Void {
		if (this.thumbSkin == null) {
			return;
		}

		var range = this.maximum - this.minimum;
		this.thumbSkin.visible = range > 0.0;
		if (!this.thumbSkin.visible) {
			return;
		}

		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}

		var valueOffset = 0.0;
		if (this.value < this.minimum) {
			valueOffset = this.minimum - this.value;
		} else if (this.value > this.maximum) {
			valueOffset = this.maximum - this.value;
		}

		var contentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var contentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;

		if (this.fixedThumbSize) {
			this.thumbSkin.width = this._thumbSkinMeasurements.width;
		} else {
			var thumbWidth = contentWidth * this.getAdjustedPage() / range;
			var widthOffset = contentWidth - thumbWidth;
			if (widthOffset > thumbWidth) {
				widthOffset = thumbWidth;
			}
			widthOffset *= valueOffset / (range * thumbWidth / contentWidth);
			thumbWidth -= widthOffset;
			if (thumbWidth < this._thumbSkinMeasurements.minWidth) {
				thumbWidth = this._thumbSkinMeasurements.minWidth;
			}
			this.thumbSkin.width = thumbWidth;
		}
		this.thumbSkin.x = this.valueToLocation(this.value);
		this.thumbSkin.y = this.paddingTop + (contentHeight - this.thumbSkin.height) / 2;
	}
}
