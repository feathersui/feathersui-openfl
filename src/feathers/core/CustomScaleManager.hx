/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.utils.MathUtil;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

/**
	Allows the application's scale to be set manually to a specific value,
	instead of calculating it automatically, like other scale managers. Defaults
	to automtically calculating the application dimensions to fill the stage
	dimensions, but can optionally accept custom application dimensions too.

	The following example creates a `CustomScaleManager` with a scale value of
	`2.0`:

	```haxe
	var manager = new CustomScaleManager(2.0);
	application.scaleManager = manager;
	```

	The following example creates a `CustomScaleManager` with a scale value of
	`1.0` and custom bounds:

	```haxe
	var manager = new CustomScaleManager(1.0, new Rectangle(0.0, 0.0, 640.0, 480.0));
	application.scaleManager = manager;
	```

	@see `feathers.controls.Application.scaleManager`

	@since 1.0.0
**/
class CustomScaleManager extends EventDispatcher implements IScaleManager {
	/**
		Creates a new `CustomScaleManager` object.

		@since 1.0.0
	**/
	public function new(customScale:Float = 1.0, ?customBounds:Rectangle) {
		super();
		this._customScale = customScale;
		this._customBounds = customBounds;
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
			this._target.removeEventListener(Event.ADDED_TO_STAGE, customScaleManager_target_addedToStageHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, customScaleManager_target_removedFromStageHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(Event.ADDED_TO_STAGE, customScaleManager_target_addedToStageHandler, false, 0, true);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, customScaleManager_target_removedFromStageHandler, false, 0, true);
			this.addTargetStageListeners();
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._target;
	}

	private var _customScale:Float;

	/**
		Changes the scale manager's custom scale value.

		@since 1.0.0
	**/
	public var customScale(get, set):Float;

	private function get_customScale():Float {
		return this._customScale;
	}

	private function set_customScale(value:Float):Float {
		if (this._customScale == value) {
			return this._customScale;
		}
		this._customScale = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._customScale;
	}

	private var _customBounds:Rectangle;

	/**
		Changes the scale manager's custom bounds value.

		@since 1.0.0
	**/
	public var customBounds(get, set):Rectangle;

	private function get_customBounds():Rectangle {
		return this._customBounds;
	}

	private function set_customBounds(value:Rectangle):Rectangle {
		if (this._customBounds == value) {
			return this._customBounds;
		}
		this._customBounds = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._customBounds;
	}

	/**
		@see `feathers.core.IScaleManager.getScale()`
	**/
	public function getScale():Float {
		return this._customScale;
	}

	/**
		@see `feathers.core.IScaleManager.getBounds()`
	**/
	public function getBounds():Rectangle {
		if (this._customBounds != null) {
			return this._customBounds;
		}
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
		this._target.stage.addEventListener(Event.RESIZE, customScaleManager_stage_resizeHandler, false, 0, true);
	}

	private function removeTargetStageListeners():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.removeEventListener(Event.RESIZE, customScaleManager_stage_resizeHandler);
	}

	private function customScaleManager_target_addedToStageHandler(event:Event):Void {
		this.addTargetStageListeners();
	}

	private function customScaleManager_target_removedFromStageHandler(event:Event):Void {
		this.removeTargetStageListeners();
	}

	private function customScaleManager_stage_resizeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}
}
