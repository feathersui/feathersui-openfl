/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollBar;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import openfl.events.Event;

/**
	A vertical scroll bar, for use with scrolling containers like
	`ScrollContainer` and `ListView`.

	@see [Tutorial: How to use the HScrollBar and VScrollBar components](https://feathersui.com/learn/haxe-openfl/scroll-bar/)
	@see `feathers.controls.HScrollBar`

	@since 1.0.0
**/
@:styleContext
class VScrollBar extends BaseScrollBar {
	/**
		The variant used to style the decrement `Button` child component in a theme.

		To override this default variant, set the
		`BaseScrollBar.customDecrementButtonVariant` property.

		@see `BaseScrollBar.customDecrementButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.3.0
	**/
	public static final CHILD_VARIANT_DECREMENT_BUTTON = "vScrollBar_decrementButton";

	/**
		The variant used to style the increment `Button` child component in a theme.

		To override this default variant, set the
		`BaseScrollBar.customIncrementButtonVariant` property.

		@see `BaseScrollBar.customIncrementButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.3.0
	**/
	public static final CHILD_VARIANT_INCREMENT_BUTTON = "vScrollBar_incrementButton";

	/**
		Creates a new `VScrollBar` object.

		@since 1.0.0
	**/
	public function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		this.initializeVScrollBarTheme();

		super(value, minimum, maximum, changeListener);
	}

	private function initializeVScrollBarTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelVScrollBarStyles.initialize();
		#end
	}

	override private function valueToLocation(value:Float):Float {
		// this will auto-size the thumb, if needed
		if ((this._currentThumbSkin is IValidating)) {
			(cast this._currentThumbSkin : IValidating).validateNow();
		}
		if (this.showDecrementAndIncrementButtons) {
			this.decrementButton.validateNow();
			this.incrementButton.validateNow();
		}
		var normalized = this.normalizeValue(value);
		var trackScrollableHeight = this.actualHeight - this.paddingTop - this.paddingBottom - this._currentThumbSkin.height;
		if (this.showDecrementAndIncrementButtons) {
			trackScrollableHeight -= (this.decrementButton.height + this.incrementButton.height);
		}
		if (trackScrollableHeight < 0.0) {
			trackScrollableHeight = 0.0;
		}
		var result = this.paddingTop + (trackScrollableHeight * normalized);
		if (this.showDecrementAndIncrementButtons) {
			result += this.decrementButton.height;
		}
		return result;
	}

	override private function locationToValue(x:Float, y:Float):Float {
		var percentage = 0.0;
		var minYPosition = this.paddingTop;
		var trackScrollableHeight = this.actualHeight - this.paddingTop - this.paddingBottom - this._currentThumbSkin.height;
		if (this.showDecrementAndIncrementButtons) {
			minYPosition += this.decrementButton.height;
			trackScrollableHeight -= (this.decrementButton.height + this.incrementButton.height);
		}
		if (trackScrollableHeight < 0.0) {
			trackScrollableHeight = 0.0;
		}
		var yOffset = y - this._pointerStartY;
		var yPosition = Math.min(Math.max(0.0, this._thumbStartY + yOffset - minYPosition), trackScrollableHeight);
		percentage = yPosition / trackScrollableHeight;
		return this._minimum + percentage * (this._maximum - this._minimum);
	}

	override private function saveThumbStart(x:Float, y:Float):Void {
		var trackHeightMinusThumbHeight = this.actualHeight;
		var locationMinusHalfThumbHeight = y;
		if (this._currentThumbSkin != null) {
			trackHeightMinusThumbHeight -= this._currentThumbSkin.height;
			locationMinusHalfThumbHeight -= this._currentThumbSkin.height / 2.0;
		}
		this._thumbStartX = x;
		this._thumbStartY = Math.min(trackHeightMinusThumbHeight, locationMinusHalfThumbHeight);
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

		if (this.decrementButton != null) {
			this.decrementButtonMeasurements.restore(this.decrementButton);
			this.decrementButton.validateNow();
		}

		if (this.incrementButton != null) {
			this.incrementButtonMeasurements.restore(this.incrementButton);
			this.incrementButton.validateNow();
		}

		if (this._currentThumbSkin != null) {
			this._thumbSkinMeasurements.restore(this._currentThumbSkin);
			if ((this._currentThumbSkin is IValidating)) {
				(cast this._currentThumbSkin : IValidating).validateNow();
			}
		}
		if (this._currentTrackSkin != null) {
			this._trackSkinMeasurements.restore(this._currentTrackSkin);
			if ((this._currentTrackSkin is IValidating)) {
				(cast this._currentTrackSkin : IValidating).validateNow();
			}
		}
		if (this._currentSecondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this._currentSecondaryTrackSkin);
			if ((this._currentSecondaryTrackSkin is IValidating)) {
				(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.paddingLeft + this.paddingRight;
			if (this._currentThumbSkin != null) {
				newWidth += this._currentThumbSkin.width;
			}
			if (this._currentTrackSkin != null) {
				if (newWidth < this._currentTrackSkin.width) {
					newWidth = this._currentTrackSkin.width;
				}
				if (this._currentSecondaryTrackSkin != null && newWidth < this._currentSecondaryTrackSkin.width) {
					newWidth = this._currentSecondaryTrackSkin.width;
				}
			}
			if (this.showDecrementAndIncrementButtons) {
				var buttonWidth = Math.max(this.decrementButton.width, this.incrementButton.width);
				if (newWidth < buttonWidth) {
					newWidth = buttonWidth;
				}
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this._currentTrackSkin != null) {
				newHeight += this._currentTrackSkin.height;
				if (this._currentSecondaryTrackSkin != null) {
					newHeight += this._currentSecondaryTrackSkin.height;
				}
			}
			var thumbHeight = this.paddingTop + this.paddingBottom;
			if (this._currentThumbSkin != null) {
				thumbHeight += this._currentThumbSkin.height;
			}
			if (newHeight < thumbHeight) {
				newHeight = thumbHeight;
			}
			if (this.showDecrementAndIncrementButtons) {
				newHeight += this.decrementButton.height + this.incrementButton.height;
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, null);
	}

	override private function layoutButtons():Void {
		if (!this.showDecrementAndIncrementButtons) {
			return;
		}
		if (this.decrementButton != null) {
			this.decrementButton.validateNow();
		}
		this.decrementButton.x = (this.actualWidth - this.decrementButton.width) / 2.0;
		this.decrementButton.y = 0.0;

		if (this.incrementButton != null) {
			this.incrementButton.validateNow();
		}
		this.incrementButton.x = (this.actualWidth - this.incrementButton.width) / 2.0;
		this.incrementButton.y = this.actualHeight - this.incrementButton.height;
	}

	override private function layoutSplitTrack():Void {
		var location = this.valueToLocation(value);
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IValidating)) {
				(cast this._currentThumbSkin : IValidating).validateNow();
			}
			location += Math.round(this._currentThumbSkin.height / 2.0);
		}

		var minTrackY = 0.0;
		var maxTrackY = this.actualHeight;
		if (this.showDecrementAndIncrementButtons) {
			minTrackY = this.decrementButton.height;
			maxTrackY -= this.incrementButton.height;
		}

		this._currentSecondaryTrackSkin.y = minTrackY;
		this._currentSecondaryTrackSkin.height = location;

		this._currentTrackSkin.y = location;
		this._currentTrackSkin.height = maxTrackY - location;

		if ((this._currentSecondaryTrackSkin is IValidating)) {
			(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
		}
		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}

		this._currentSecondaryTrackSkin.x = (this.actualWidth - this._currentSecondaryTrackSkin.width) / 2.0;
		this._currentTrackSkin.x = (this.actualWidth - this._currentTrackSkin.width) / 2.0;
	}

	override private function layoutSingleTrack():Void {
		if (this._currentTrackSkin == null) {
			return;
		}

		var minTrackY = 0.0;
		var maxTrackY = this.actualHeight;
		if (this.showDecrementAndIncrementButtons) {
			minTrackY = this.decrementButton.height;
			maxTrackY -= this.incrementButton.height;
		}

		this._currentTrackSkin.y = minTrackY;
		this._currentTrackSkin.height = maxTrackY - minTrackY;

		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}

		this._currentTrackSkin.x = (this.actualWidth - this._currentTrackSkin.width) / 2.0;
	}

	override private function layoutThumb():Void {
		if (this._currentThumbSkin == null) {
			return;
		}

		var range = this._maximum - this._minimum;
		this._currentThumbSkin.visible = (!this.hideThumbWhenDisabled || this._enabled) && range > 0.0;
		if (!this._currentThumbSkin.visible) {
			return;
		}

		if ((this._currentThumbSkin is IValidating)) {
			(cast this._currentThumbSkin : IValidating).validateNow();
		}

		var valueOffset = 0.0;
		if (this._value < this._minimum) {
			valueOffset = this._minimum - this._value;
		} else if (this._value > this._maximum) {
			valueOffset = this._value - this._maximum;
		}

		var contentWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (contentWidth < 0.0) {
			contentWidth = 0.0;
		}
		var contentHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (contentHeight < 0.0) {
			contentHeight = 0.0;
		}

		if (this.fixedThumbSize) {
			if (this._thumbSkinMeasurements.height != null) {
				this._currentThumbSkin.height = this._thumbSkinMeasurements.height;
			}
		} else {
			var adjustedPage = this.getAdjustedPage();
			var thumbHeight = contentHeight * adjustedPage / (range + adjustedPage);
			if (thumbHeight > 0.0) {
				var heightOffset = contentHeight - thumbHeight;
				if (heightOffset > thumbHeight) {
					heightOffset = thumbHeight;
				}
				heightOffset *= valueOffset / (range * thumbHeight / contentHeight);
				thumbHeight -= heightOffset;
			}
			if (this._thumbSkinMeasurements.minHeight != null) {
				if (thumbHeight < this._thumbSkinMeasurements.minHeight) {
					thumbHeight = this._thumbSkinMeasurements.minHeight;
				}
			} else if ((this._currentThumbSkin is IMeasureObject)) {
				var measureSkin:IMeasureObject = cast this._currentThumbSkin;
				if (thumbHeight < measureSkin.minHeight) {
					thumbHeight = measureSkin.minHeight;
				}
			}
			if (thumbHeight < 0.0) {
				thumbHeight = 0.0;
			}
			this._currentThumbSkin.height = thumbHeight;
		}
		this._currentThumbSkin.x = this.paddingLeft + (contentWidth - this._currentThumbSkin.width) / 2.0;
		this._currentThumbSkin.y = this.valueToLocation(this._value);
	}
}
