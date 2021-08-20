/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IFocusManagerAware;
import feathers.core.IScaleManager;
import feathers.core.PopUpManager;
import feathers.themes.steel.components.SteelApplicationStyles;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
#if !disable_focus_manager
import feathers.core.FocusManager;
import feathers.core.IFocusManager;
#end
#if !disable_tool_tip_manager
import feathers.core.IToolTipManager;
import feathers.core.ToolTipManager;
#end
#if flash
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
#end

/**
	An optional root class for Feathers UI applications that will automatically
	scale the application based on the screen density of the device.

	@see [Tutorial: How to use the Application component](https://feathersui.com/learn/haxe-openfl/application/)

	@since 1.0.0
**/
@:styleContext
class Application extends LayoutGroup implements IFocusManagerAware {
	private static var _topLevelApplication:Application;

	/**
		The first `Application` instance created is the top-level application.

		Feathers UI does not require developers to use the `Application`
		component, so this value may be `null` in some projects.

		@since 1.0.0
	**/
	@:flash.property
	public static var topLevelApplication(get, never):Application;

	private static function get_topLevelApplication():Application {
		return _topLevelApplication;
	}

	private static function defaultPopUpContainerFactory():DisplayObjectContainer {
		return new Sprite();
	}

	/**
		Creates a new `Application` object.

		@since 1.0.0
	**/
	public function new() {
		if (Application._topLevelApplication == null) {
			Application._topLevelApplication = this;
		}
		initializeApplicationTheme();

		super();

		#if flash
		if (this.stage != null && this.root == this) {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
		}
		#end

		this.addEventListener(Event.ADDED_TO_STAGE, application_addedToStageHandler, false, 100);
	}

	private var _scaleFactor:Float = 1.0;

	/**
		The application's scaling factor on the current device. One pixel in
		application coordinates is equal to this number of pixels in screen
		coordinates.
	**/
	@:flash.property
	public var scaleFactor(get, never):Float;

	private function get_scaleFactor():Float {
		return this._scaleFactor;
	}

	private var _currentScaleManager:IScaleManager;

	/**
		@since 1.0.0
	**/
	@:style
	public var scaleManager:IScaleManager = null;

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

	#if !disable_focus_manager
	private var _applicationFocusManager:IFocusManager;
	#end

	#if !disable_tool_tip_manager
	private var _applicationToolTipManager:IToolTipManager;
	#end

	override private function update():Void {
		var sizeInvalid = this.isInvalid(SIZE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (sizeInvalid || stylesInvalid) {
			this.refreshScaleManager();
		}

		super.update();
	}

	private function refreshScaleManager():Void {
		var oldScaleManager = this._currentScaleManager;
		this._currentScaleManager = this.scaleManager;
		if (this._currentScaleManager == oldScaleManager) {
			return;
		}
		if (oldScaleManager != null) {
			oldScaleManager.removeEventListener(Event.CHANGE, application_scaleManager_changeHandler);
			oldScaleManager.target = null;
		}
		if (this._currentScaleManager != null) {
			this._currentScaleManager.addEventListener(Event.CHANGE, application_scaleManager_changeHandler, false, 0, true);
			this._currentScaleManager.target = this;
		}
	}

	private function refreshDimensions():Void {
		if (this._currentScaleManager == null) {
			return;
		}
		this._scaleFactor = this._currentScaleManager.getScale();
		this.scaleX = this._scaleFactor;
		this.scaleY = this._scaleFactor;

		var bounds = this._currentScaleManager.getBounds();
		this.x = bounds.x;
		this.y = bounds.y;
		this.width = bounds.width;
		this.height = bounds.height;

		if (this._popUpContainer != null) {
			this._popUpContainer.scaleX = this._scaleFactor;
			this._popUpContainer.scaleY = this._scaleFactor;
		}
	}

	private function preparePopUpManager():Void {
		if (this._popUpContainer == null) {
			var factory = this.popUpContainerFactory;
			if (factory == null) {
				factory = defaultPopUpContainerFactory;
			}
			this._popUpContainer = factory();
		}
		this._popUpContainer.scaleX = this._scaleFactor;
		this._popUpContainer.scaleY = this._scaleFactor;
		this.stage.addChild(this._popUpContainer);
		var popUpManager = PopUpManager.forStage(this.stage);
		popUpManager.root = this._popUpContainer;
	}

	private function cleanupPopUpManager():Void {
		var popUpManager = PopUpManager.forStage(this.stage);
		if (popUpManager.root == this._popUpContainer) {
			popUpManager.root = this.stage;
		}
		this.stage.removeChild(this._popUpContainer);
		this._popUpContainer = null;
	}

	private function prepareFocusManager():Void {
		#if !disable_focus_manager
		if (!FocusManager.hasRoot(this.stage)) {
			this._applicationFocusManager = FocusManager.addRoot(this.stage);
		}
		#end
	}

	private function cleanupFocusManager():Void {
		#if !disable_focus_manager
		if (this._applicationFocusManager != null) {
			this._applicationFocusManager = null;
			FocusManager.removeRoot(this.stage);
		}
		#end
	}

	private function prepareToolTipManager():Void {
		#if !disable_tool_tip_manager
		if (!ToolTipManager.hasRoot(this.stage)) {
			this._applicationToolTipManager = ToolTipManager.addRoot(this.stage);
		}
		#end
	}

	private function cleanupToolTipManager():Void {
		#if !disable_tool_tip_manager
		if (this._applicationToolTipManager != null) {
			this._applicationToolTipManager = null;
			ToolTipManager.removeRoot(this.stage);
		}
		#end
	}

	private function application_addedToStageHandler(event:Event):Void {
		#if flash
		if (Reflect.hasField(this.stage, "nativeWindow")) {
			var window = Reflect.field(this.stage, "nativeWindow");
			if (window != null) {
				Reflect.setProperty(window, "visible", true);
			}
		}
		#end
		this.addEventListener(Event.REMOVED_FROM_STAGE, application_removedFromStageHandler);
		this.prepareFocusManager();
		this.preparePopUpManager();
		this.prepareToolTipManager();
	}

	private function application_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, application_removedFromStageHandler);
		this.cleanupToolTipManager();
		this.cleanupPopUpManager();
		this.cleanupFocusManager();
	}

	private function application_scaleManager_changeHandler(event:Event):Void {
		this.refreshDimensions();
	}
}
