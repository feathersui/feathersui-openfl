/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.skins.IIndeterminateSkin;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.MeasurementsUtil;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
	Displays an animation to indicate that an activity of indeterminate length
	is currently happening. The animation remains active while the activity
	indicator is added to the display list — unless its `enabled` property is
	set to `false`.

	The following example creates an `ActivityIndicator` and adds it to the
	display list:

	```haxe
	var activityIndicator = new ActivityIndicator();
	this.addChild(activityIndicator);
	```

	@see [Tutorial: How to use the ActivityIndicator component](https://feathersui.com/learn/haxe-openfl/activity-indicator/)
	@see `feathers.controls.HProgressBar`
	@see `feathers.controls.VProgressBar`

	@since 1.1.0
**/
class ActivityIndicator extends FeathersControl {
	/**
		Creates a new `ActivityIndicator` object.

		@since 1.1.0
	**/
	public function new() {
		initializeActivityIndicatorTheme();

		super();

		this.addEventListener(Event.ADDED_TO_STAGE, activityIndicator_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, activityIndicator_removedFromStageHandler);
	}

	private var _currentActivitySkin:DisplayObject;
	private var _activitySkinMeasurements:Measurements = null;

	/**
		The activity skin to display. This skin will be animated when the
		activity indicator is added to the display list, unless the activity
		indicator is disabled.

		If the skin implements the `IIndeterminateSkin` interface, its
		`indeterminatePosition` property will be updated every frame with a
		value between `0.0` and `1.0`, based on the `indeterminateDuration`
		property. If the skin does not implement `IIndeterminateSkin`, its
		`alpha` property will be animated to fade in and out repeatedly.

		The following example passes a bitmap for the activity indicator to use
		as a skin:

		```haxe
		activityIndicator.activitySkin = new Bitmap(bitmapData);
		```

		@since 1.1.0
	**/
	@:style
	public var activitySkin:DisplayObject = null;

	private var _savedSkinAlpha:Float = 1.0;
	private var _reversed:Bool = false;

	/**
		The duration of the indeterminate effect, measured in seconds.

		@since 1.1.0
	**/
	@:style
	public var indeterminateDuration:Float = 0.75;

	private var _lastUpdateTime:Int = 0;

	private function initializeActivityIndicatorTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelActivityIndicatorStyles.initialize();
		#end
	}

	override private function update():Void {
		var sizeInvalid = this.isInvalid(SIZE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid) {
			this.refreshBackgroundSkin();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		if (sizeInvalid || stylesInvalid) {
			this.layoutBackgroundSkin();
		}
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._currentActivitySkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._activitySkinMeasurements, this._currentActivitySkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if ((this._currentActivitySkin is IMeasureObject)) {
			measureSkin = cast this._currentActivitySkin;
		}

		if ((this._currentActivitySkin is IValidating)) {
			(cast this._currentActivitySkin : IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = 0.0;
			if (this._currentActivitySkin != null) {
				newWidth = Math.max(this._currentActivitySkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this._currentActivitySkin != null) {
				newHeight = Math.max(this._currentActivitySkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = 0.0;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._activitySkinMeasurements != null && this._activitySkinMeasurements.minWidth != null) {
				newMinWidth = Math.max(this._activitySkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = 0.0;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._activitySkinMeasurements != null && this._activitySkinMeasurements.minHeight != null) {
				newMinHeight = Math.max(this._activitySkinMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._activitySkinMeasurements != null && this._activitySkinMeasurements.maxWidth != null) {
				newMaxWidth = this._activitySkinMeasurements.maxWidth;
			} else {
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._activitySkinMeasurements != null && this._activitySkinMeasurements.maxHeight != null) {
				newMaxHeight = this._activitySkinMeasurements.maxHeight;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentActivitySkin == null) {
			return;
		}
		var diameter = Math.min(this.actualWidth, this.actualHeight);
		this._currentActivitySkin.width = diameter;
		this._currentActivitySkin.height = diameter;
		this._currentActivitySkin.x = (this.actualWidth - diameter) / 2.0;
		this._currentActivitySkin.y = (this.actualHeight - diameter) / 2.0;
		if ((this._currentActivitySkin is IValidating)) {
			(cast this._currentActivitySkin : IValidating).validateNow();
		}
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentActivitySkin;
		this._currentActivitySkin = this.getCurrentBackgroundSkin();
		if (this._currentActivitySkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		this.addCurrentBackgroundSkin(this._currentActivitySkin);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		return this.activitySkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._activitySkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if (this._activitySkinMeasurements == null) {
			this._activitySkinMeasurements = new Measurements(skin);
		} else {
			this._activitySkinMeasurements.save(skin);
		}
		this._savedSkinAlpha = skin.alpha;
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._activitySkinMeasurements.restore(skin);
		skin.alpha = this._savedSkinAlpha;
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function activityIndicator_addedToStageHandler(event:Event):Void {
		this._lastUpdateTime = Lib.getTimer();
		this.addEventListener(Event.ENTER_FRAME, activityIndicator_enterFrameHandler);
	}

	private function activityIndicator_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.ENTER_FRAME, activityIndicator_enterFrameHandler);
	}

	private function activityIndicator_enterFrameHandler(event:Event):Void {
		if (!this._enabled || !this.visible || this._currentActivitySkin == null) {
			return;
		}
		var currentTime = Lib.getTimer();
		var ratio = (currentTime - this._lastUpdateTime) / (this.indeterminateDuration * 1000.0);
		if (ratio >= 1.0) {
			ratio -= Math.ffloor(ratio);
			this._lastUpdateTime = currentTime;
			this._reversed = !this._reversed;
		}
		if ((this._currentActivitySkin is IIndeterminateSkin)) {
			var activitySkin:IIndeterminateSkin = cast this._currentActivitySkin;
			activitySkin.indeterminatePosition = ratio;
		} else {
			this._currentActivitySkin.alpha = this._savedSkinAlpha * (this._reversed ? 1.0 - ratio : ratio);
		}
	}
}
