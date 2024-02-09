/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseProgressBar;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.skins.RectangleSkin;
import feathers.utils.MeasurementsUtil;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
	Displays the progress of a task in a vertical direction, from bottom to top.

	The following example creates a progress bar:

	```haxe
	var progressBar = new VProgressBar();
	progressBar.minimum = 0.0;
	progressBar.maximum = 100.0;
	progressBar.value = 50.0;
	this.addChild(progressBar);
	```

	@see [Tutorial: How to use the HProgressBar and VProgressBar components](https://feathersui.com/learn/haxe-openfl/progress-bar/)
	@see `feathers.controls.HProgressBar`
	@see `feathers.controls.ActivityIndicator`

	@since 1.0.0
**/
@:styleContext
class VProgressBar extends BaseProgressBar {
	/**
		Creates a new `VProgressBar` object.

		@since 1.0.0
	**/
	public function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		initializeVProgressBarTheme();

		super(value, minimum, maximum, changeListener);
	}

	private var _currentMask:RectangleSkin;

	private function initializeVProgressBarTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelVProgressBarStyles.initialize();
		#end
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

		if (this._backgroundSkinMeasurements != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var measureBackgroundSkin:IMeasureObject = null;
		if ((this._currentBackgroundSkin is IMeasureObject)) {
			measureBackgroundSkin = cast this._currentBackgroundSkin;
		}

		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this._currentBackgroundSkin != null) {
				newWidth = this._backgroundSkinMeasurements.width;
			} else {
				newWidth = 0.0;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this._currentBackgroundSkin != null) {
				newHeight = this._backgroundSkinMeasurements.height;
			} else {
				newHeight = 0.0;
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function layoutBackground():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don' t set the width or height explicitly unless necessary because if // our explicit dimensions are cleared later, the measurement may not be

		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
		}
	}

	override private function layoutFill():Void {
		if (this._currentFillSkin == null) {
			return;
		}

		var percentage = 1.0;
		if (this._minimum != this._maximum) {
			percentage = (this._value - this._minimum) / (this._maximum - this._minimum);
			if (percentage < 0.0) {
				percentage = 0.0;
			} else if (percentage > 1.0) {
				percentage = 1.0;
			}
		}
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		var calculatedHeight:Float = this._indeterminate ? maxHeight : Math.round(percentage * maxHeight);

		this._currentFillSkin.x = this.paddingLeft;
		this._currentFillSkin.width = this.actualWidth - this.paddingLeft - this.paddingRight;

		switch (this.fillMode) {
			case MASK:
				this._currentFillSkin.scrollRect = null;
				if (this._currentMask == null) {
					this._currentMask = new RectangleSkin(SolidColor(0xff00ff));
					this.addChild(this._currentMask);
				}
				this._currentFillSkin.mask = this._currentMask;
				this._currentFillSkin.y = this.paddingTop;
				this._currentFillSkin.height = this.actualHeight - this.paddingTop - this.paddingBottom;
				this._currentMask.x = this._currentFillSkin.x;
				this._currentMask.y = this.actualHeight - this.paddingBottom - calculatedHeight;
				this._currentMask.width = this._currentFillSkin.width;
				this._currentMask.height = calculatedHeight;
			case SCROLL_RECT:
				this._currentFillSkin.y = this.actualHeight - this.paddingBottom - calculatedHeight;
				this._currentFillSkin.height = this.actualHeight - this.paddingTop - this.paddingBottom;
				this._currentFillSkin.scrollRect = new Rectangle(0.0, this._currentFillSkin.height - calculatedHeight, this._currentFillSkin.width,
					calculatedHeight);
			case RESIZE:
				this._currentFillSkin.mask = null;
				this._currentFillSkin.scrollRect = null;
				if (this._currentMask != null) {
					if (this._currentMask.parent == this) {
						this.removeChild(this._currentMask);
					}
					this._currentMask = null;
				}

				if (this._fillSkinMeasurements.minHeight != null && calculatedHeight < this._fillSkinMeasurements.minHeight) {
					calculatedHeight = this._fillSkinMeasurements.minHeight;
					// if the size is too small, and the value is equal to the
					// minimum, people don't expect to see the fill
					this._currentFillSkin.visible = this._value > this._minimum;
				} else {
					// if it was hidden before, we want to show it again
					this._currentFillSkin.visible = true;
				}

				this._currentFillSkin.y = this.actualHeight - this.paddingBottom - calculatedHeight;
				this._currentFillSkin.height = calculatedHeight;
			default:
				throw new ArgumentError("Unknown fill mode: " + this.fillMode);
		}
		if ((this._currentFillSkin is IValidating)) {
			(cast this._currentFillSkin : IValidating).validateNow();
		}
	}
}
