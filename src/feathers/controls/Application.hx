/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.DefaultFocusManager;
import feathers.core.IFocusManager;
import feathers.core.PopUpManager;
import feathers.themes.steel.components.SteelApplicationStyles;
import feathers.utils.DeviceUtil;
import feathers.utils.MathUtil;
import feathers.utils.ScreenDensityScaleCalculator;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.Capabilities;

/**
	An optional root class for Feathers UI applications that will automatically
	scale the application based on the screen density of the device.

	@see [Tutorial: How to use the Application component](https://feathersui.com/learn/haxe-openfl/application/)

	@since 1.0.0
**/
@:styleContext
class Application extends LayoutGroup {
	private static function defaultPopUpContainerFactory():DisplayObjectContainer {
		return new Sprite();
	}

	/**
		Creates a new `Application` object.

		@since 1.0.0
	**/
	public function new() {
		initializeApplicationTheme();

		super();

		#if !disable_focus_manager
		this.focusManager = new DefaultFocusManager(this);
		#end

		this.addEventListener(Event.ADDED_TO_STAGE, application_addedToStageHandler, false, 100);
	}

	private var _scaler:ScreenDensityScaleCalculator;

	/**
		The application's scaling factor on the current device. One pixel in
		application coordinates is equal to this number of pixels in screen
		coordinates.

		@see `Application.customScale`
	**/
	public var scaleFactor(default, null):Float = 1.0;

	/**
		Instead of calculating the scale factor automatically, an application
		may be given a custom scale factor. Using this scale factor, the
		application will calculate the best width and height to fill the stage
		at that scale.

		The following example sets a custom scale factor:

		```hx
		application.customScale = 3.0;
		```

		@since 1.0.0
	**/
	public var customScale(default, set):Null<Float> = null;

	private function set_customScale(value:Null<Float>):Null<Float> {
		if (this.customScale == value) {
			return this.customScale;
		}
		this.customScale = value;
		this.refreshDimensions();
		return this.customScale;
	}

	/**
		A factory may be provided to return a custom container where the
		application's pop-ups may be added when using `PopUpManager`.

		@see `feathers.core.PopUpManager`

		@since 1.0.0
	**/
	public var popUpContainerFactory:() -> DisplayObjectContainer;

	private var _popUpContainer:DisplayObjectContainer;

	private function initializeApplicationTheme():Void {
		SteelApplicationStyles.initialize();
	}

	private function getScaleFactor():Float {
		var result = 1.0;
		if (this.stage == null) {
			return result;
		}
		if (this.customScale != null) {
			result = this.customScale;
		} else {
			#if ((desktop && !air) || (web && !flash))
			this._scaler = null;
			result = this.stage.window.scale;
			#if web
			if (result > 2.0) {
				result *= (this.stage.window.scale / 2.0);
			}
			#end
			#else
			if (DeviceUtil.isDesktop()) {
				result = this.stage.contentsScaleFactor;
			} else {
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
			}
			#end
		}
		return result;
	}

	private function refreshDimensions():Void {
		this.scaleFactor = this.getScaleFactor();
		this.scaleX = this.scaleFactor;
		this.scaleY = this.scaleFactor;

		var needsToBeDivisibleByTwo = Math.ffloor(this.scaleFactor) != this.scaleFactor;
		var appWidth = Math.ffloor(this.stage.stageWidth);
		if (needsToBeDivisibleByTwo) {
			appWidth = MathUtil.roundDownToNearest(appWidth, 2);
		}
		this.width = appWidth;
		var appHeight = Math.ffloor(this.stage.stageHeight);
		if (needsToBeDivisibleByTwo) {
			appHeight = MathUtil.roundDownToNearest(appHeight, 2);
		}
		this.height = appHeight;

		this._popUpContainer.scaleX = this.scaleFactor;
		this._popUpContainer.scaleY = this.scaleFactor;
	}

	private function preparePopUpContainer():Void {
		if (this._popUpContainer == null) {
			var factory = this.popUpContainerFactory;
			if (factory == null) {
				factory = defaultPopUpContainerFactory;
			}
			this._popUpContainer = factory();
		}
		this.stage.addChild(this._popUpContainer);
		var popUpManager = PopUpManager.forStage(this.stage);
		popUpManager.root = this._popUpContainer;
	}

	private function cleanupPopUpContainer():Void {
		var popUpManager = PopUpManager.forStage(this.stage);
		if (popUpManager.root == this._popUpContainer) {
			popUpManager.root = this.stage;
		}
		this.stage.removeChild(this._popUpContainer);
		this._popUpContainer = null;
	}

	private function application_addedToStageHandler(event:Event):Void {
		#if flash
		if (Reflect.hasField(this.stage, "nativeWindow")) {
			Reflect.field(this.stage, "nativeWindow").visible = true;
		}
		#end
		this.addEventListener(Event.REMOVED_FROM_STAGE, application_removedFromStageHandler);
		this.stage.addEventListener(Event.RESIZE, application_stage_resizeHandler, false, 0, true);
		this.preparePopUpContainer();
		this.refreshDimensions();
	}

	private function application_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, application_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, application_stage_resizeHandler);
		this.cleanupPopUpContainer();
	}

	private function application_stage_resizeHandler(event:Event):Void {
		this.refreshDimensions();
	}
}
