/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.events.FeathersEvent;
import feathers.utils.MathUtil;
import feathers.utils.ScreenDensityScaleCalculator;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;
#if !(!flash && (desktop || web) && (openfl < "9.2.0" || openfl_dpi_aware))
import feathers.utils.DeviceUtil;
import openfl.system.Capabilities;
#end

/**
	Uses the device's screen density (sometimes called the DPI or PPI) to
	calculate the ideal scale value for the application. The dimensions will be
	calculated so that the application fills the entire stage, regardless of the
	screen resolution of the device (or the size of the window, where
	appropriate). With this in mind, it's best to use _fluid_ layouts, to
	account for differences in screen resolution and aspect ratios.

	On desktop and web, the contents scale factor of the stage is detected to
	determine the application scale.

	On mobile, the appropriate scale is calculated based on the value of
	`Capabilities.screenDPI`. The calculation is inspired by native apps on
	Google's Android operating system where "density-independent pixels" are
	used for layout.

	The following chart shows how different screen densities map to different
	scale values returned by `ScreenDensityScaleManager`.

	| Android | iOS              | Density | Scale |
	| ------- | ---------------- | ------- | ----- |
	| ldpi    |                  | 120     | 0.75  |
	| mdpi    | non-Retina (@1x) | 160     | 1     |
	| hdpi    |                  | 240     | 1.5   |
	| xhdpi   | Retina (@2x)     | 320     | 2     |
	| xxhdpi  | Retina HD (@3x)  | 480     | 3     |
	| xxxhdpi |                  | 640     | 4     |

	The density values in the table above are approximate. The screen density
	of an iPhone 5 is 326, so it uses the scale factor from the xhdpi/Retina
	bucket because 326 is closer to 320 than it is to 480.

	The following example creates a `ScreenDensityScaleManager`:

	```haxe
	var manager = new ScreenDensityScaleManager();
	application.scaleManager = manager;
	```

	The next example creates a `ScreenDensityScaleManager` with a custom
	`ScreenDensityScaleCalculator` with a limited set of densities.

	```haxe
	var calculator = new ScreenDensityScaleCalculator();
	calculator.addScaleForDensity(160, 1);
	calculator.addScaleForDensity(240, 1.5);
	calculator.addScaleForDensity(320, 2);
	calculator.addScaleForDensity(480, 3);
	var manager = new ScreenDensityScaleManager(calculator);
	application.scaleManager = manager;
	```

	@see `feathers.controls.Application.scaleManager`

	@since 1.0.0
**/
class ScreenDensityScaleManager extends EventDispatcher implements IScaleManager {
	/**
		Creates a new `ScreenDensityScaleManager` object.

		@since 1.0.0
	**/
	public function new(?scaler:ScreenDensityScaleCalculator) {
		super();
		this._scaler = scaler;
	}

	private var _target:DisplayObject;

	/**
		@see `feathers.core.IScaleManager.target`
	**/
	public var target(get, set):DisplayObject;

	private function get_target():DisplayObject {
		return this._target;
	}

	private function set_target(value:DisplayObject):DisplayObject {
		if (this._target == value) {
			return this._target;
		}
		if (this._target != null) {
			this.removeTargetStageListeners();
			this._target.removeEventListener(Event.ADDED_TO_STAGE, screenDensityScaleManager_target_addedToStageHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, screenDensityScaleManager_target_removedFromStageHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(Event.ADDED_TO_STAGE, screenDensityScaleManager_target_addedToStageHandler, false, 0, true);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, screenDensityScaleManager_target_removedFromStageHandler, false, 0, true);
			this.addTargetStageListeners();
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._target;
	}

	private var _scaler:ScreenDensityScaleCalculator;

	/**
		The scale manager's scale calculator.

		@since 1.0.0
	**/
	public var scaler(get, set):ScreenDensityScaleCalculator;

	private function get_scaler():ScreenDensityScaleCalculator {
		return this._scaler;
	}

	private function set_scaler(value:ScreenDensityScaleCalculator):ScreenDensityScaleCalculator {
		if (this._scaler == value) {
			return this._scaler;
		}
		this._scaler = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._scaler;
	}

	/**
		@see `feathers.core.IScaleManager.getScale()`
	**/
	public function getScale():Float {
		var result = 1.0;
		if (this._target == null) {
			return result;
		}
		#if (!flash && (desktop || web))
		#if (openfl < "9.2.0" || openfl_dpi_aware)
		result = this._target.stage.window.scale;
		#end
		#if html5
		var jsWindow = cast(js.Lib.global, js.html.Window);
		var viewportElement = jsWindow.document.getElementById("viewport");
		if (viewportElement != null && viewportElement.localName == "meta") {
			var content = viewportElement.getAttribute("content");
			if (content.indexOf("user-scalable=no") != -1) {
				var initialScalePattern = ~/initial-scale=(\d(?:\.\d+)?)/;
				if (initialScalePattern.match(content)) {
					var initialScale = Std.parseFloat(initialScalePattern.matched(1));
					// account for the initial-scale in the index.html template
					result *= (1.0 / initialScale);
				}
			}
		}
		#end
		#else
		if (!DeviceUtil.isDesktop()) {
			if (this._scaler == null) {
				this._scaler = new ScreenDensityScaleCalculator();
				this._scaler.addScaleForDensity(120, 0.75); // ldpi
				this._scaler.addScaleForDensity(160, 1); // mdpi
				this._scaler.addScaleForDensity(240, 1.5); // hdpi
				this._scaler.addScaleForDensity(320, 2); // xhdpi
				this._scaler.addScaleForDensity(480, 3); // xxhdpi
				this._scaler.addScaleForDensity(640, 4); // xxxhpi
			}
			result = this._scaler.getScale(Capabilities.screenDPI);
			#if (openfl >= "9.2.0" && !openfl_dpi_aware)
			result /= this._target.stage.window.scale;
			#end
		}
		#end
		return result;
	}

	/**
		@see `feathers.core.IScaleManager.getBounds()`
	**/
	public function getBounds():Rectangle {
		var bounds = new Rectangle();
		if (this._target == null) {
			return bounds;
		}
		var stage = this._target.stage;
		if (stage == null) {
			return bounds;
		}
		var needsToBeDivisibleByTwo = Math.ffloor(this._target.scaleX) != this._target.scaleX;
		var appWidth = Math.ffloor(stage.stageWidth);
		if (needsToBeDivisibleByTwo) {
			appWidth = MathUtil.roundDownToNearest(appWidth, 2);
		}
		bounds.width = appWidth;
		var appHeight = Math.ffloor(stage.stageHeight);
		if (needsToBeDivisibleByTwo) {
			appHeight = MathUtil.roundDownToNearest(appHeight, 2);
		}
		bounds.height = appHeight;
		return bounds;
	}

	private function addTargetStageListeners():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.addEventListener(Event.RESIZE, screenDensityScaleManager_stage_resizeHandler, false, 0, true);
	}

	private function removeTargetStageListeners():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.removeEventListener(Event.RESIZE, screenDensityScaleManager_stage_resizeHandler);
	}

	private function screenDensityScaleManager_target_addedToStageHandler(event:Event):Void {
		this.addTargetStageListeners();
	}

	private function screenDensityScaleManager_target_removedFromStageHandler(event:Event):Void {
		this.removeTargetStageListeners();
	}

	private function screenDensityScaleManager_stage_resizeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}
}
