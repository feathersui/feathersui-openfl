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
#if !((desktop && !air) || (web && !flash))
import feathers.utils.DeviceUtil;
import openfl.system.Capabilities;
#end

/**

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

	@:flash.property
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
		@see `feathers.core.IScaleManager.getScale()`
	**/
	public function getScale():Float {
		var result = 1.0;
		if (this._target == null) {
			return result;
		}
		#if ((desktop && !air) || (web && !flash))
		result = this._target.stage.window.scale;
		#if web
		if (result > 2.0) {
			result *= (this._target.stage.window.scale / 2.0);
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
