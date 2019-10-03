/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IValidating;
import feathers.controls.supportClasses.BaseScrollBar;
import feathers.themes.steel.components.SteelVScrollBarStyles;

/**
	@since 1.0.0
**/
@:styleContext
class VScrollBar extends BaseScrollBar {
	public function new() {
		this.initializeVScrollBarTheme();

		super();
	}

	private function initializeVScrollBarTheme():Void {
		SteelVScrollBarStyles.initialize();
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if (Std.is(this.thumbSkin, IValidating)) {
			cast(this.thumbSkin, IValidating).validateNow();
		}
		var normalized = this.normalizeValue();
		var trackScrollableHeight = this.actualHeight - this.paddingTop - this.paddingBottom - this.thumbSkin.height;
		return this.paddingTop + (trackScrollableHeight * normalized);
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var trackScrollableHeight = this.actualHeight - this.paddingTop - this.paddingBottom - this.thumbSkin.height;
		var yOffset = y - this._pointerStartY;
		var yPosition = Math.min(Math.max(0.0, this._thumbStartY + yOffset), trackScrollableHeight);
		percentage = yPosition / trackScrollableHeight;
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
		var newMaxWidth = newWidth;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, Math.POSITIVE_INFINITY);
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
			valueOffset = this.value - this.maximum;
		}

		var contentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var contentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;

		if (this.fixedThumbSize) {
			this.thumbSkin.height = this._thumbSkinMeasurements.height;
		} else {
			var thumbHeight = contentHeight * this.getAdjustedPage() / range;
			var heightOffset = contentHeight - thumbHeight;
			if (heightOffset > thumbHeight) {
				heightOffset = thumbHeight;
			}
			heightOffset *= valueOffset / (range * thumbHeight / contentHeight);
			thumbHeight -= heightOffset;
			if (thumbHeight < this._thumbSkinMeasurements.minHeight) {
				thumbHeight = this._thumbSkinMeasurements.minHeight;
			}
			this.thumbSkin.height = thumbHeight;
		}
		this.thumbSkin.x = this.paddingLeft + (contentWidth - this.thumbSkin.width) / 2;
		this.thumbSkin.y = this.valueToLocation(this.value);
	}
}
