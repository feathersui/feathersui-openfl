/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.events.FeathersEvent;
import feathers.utils.ScaleUtil;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

/**
	Ensures that the application has the same internal width and height on
	all devices, while scaling it larger or smaller to fit within the bounds of
	the stage. The application may be letterboxed on some screens, which means
	that there may be some empty space on the top and bottom, or on the left and
	right, of the application's bounds within the window. The application will
	always be centered within the stage bounds.

	The following example creates a `LetterboxScaleManager` with an original
	width value of `960.0` and an original height value of `640.0`:

	```haxe
	var manager = new LetterboxScaleManager(960.0, 640.0);
	application.scaleManager = manager;
	```

	@see `feathers.controls.Application.scaleManager`

	@since 1.0.0
**/
class LetterboxScaleManager extends EventDispatcher implements IScaleManager {
	/**
		Creates a new `LetterboxScaleManager` object.

		@since 1.0.0
	**/
	public function new(originalWidth:Float, originalHeight:Float) {
		super();
		this.addTargetStageListeners();
		this._originalWidth = originalWidth;
		this._originalHeight = originalHeight;
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
			this._target.removeEventListener(Event.ADDED_TO_STAGE, letterboxScaleManager_target_addedToStageHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, letterboxScaleManager_target_removedFromStageHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(Event.ADDED_TO_STAGE, letterboxScaleManager_target_addedToStageHandler, false, 0, true);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, letterboxScaleManager_target_removedFromStageHandler, false, 0, true);
			this.addTargetStageListeners();
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._target;
	}

	private var _originalWidth:Float;

	/**
		The scale manager's original width value that will be scaled to fit
		within the stage dimensions.

		@see `LetterboxScaleManager.originalHeight`

		@since 1.0.0
	**/
	public var originalWidth(get, set):Float;

	private function get_originalWidth():Float {
		return this._originalWidth;
	}

	private function set_originalWidth(value:Float):Float {
		if (this._originalWidth == value) {
			return this._originalWidth;
		}
		this._originalWidth = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._originalWidth;
	}

	private var _originalHeight:Float;

	/**
		The scale manager's original height value that will be scaled to fit
		within the stage dimensions.

		@see `LetterboxScaleManager.originalWidth`

		@since 1.0.0
	**/
	public var originalHeight(get, set):Float;

	private function get_originalHeight():Float {
		return this._originalHeight;
	}

	private function set_originalHeight(value:Float):Float {
		if (this._originalHeight == value) {
			return this._originalHeight;
		}
		this._originalHeight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._originalHeight;
	}

	/**
		@see `feathers.core.IScaleManager.getScale()`
	**/
	public function getScale():Float {
		var stage = this._target.stage;
		if (stage == null) {
			return 1.0;
		}
		return ScaleUtil.scaleToFit(this._originalWidth, this._originalHeight, stage.stageWidth, stage.stageHeight);
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
		bounds.width = this._originalWidth * this._target.scaleX;
		bounds.height = this._originalHeight * this._target.scaleY;
		bounds.x = (stage.stageWidth - bounds.width) / 2.0;
		bounds.y = (stage.stageHeight - bounds.height) / 2.0;
		return bounds;
	}

	private function addTargetStageListeners():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.addEventListener(Event.RESIZE, letterboxScaleManager_stage_resizeHandler, false, 0, true);
	}

	private function removeTargetStageListeners():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.removeEventListener(Event.RESIZE, letterboxScaleManager_stage_resizeHandler);
	}

	private function letterboxScaleManager_target_addedToStageHandler(event:Event):Void {
		this.addTargetStageListeners();
	}

	private function letterboxScaleManager_target_removedFromStageHandler(event:Event):Void {
		this.removeTargetStageListeners();
	}

	private function letterboxScaleManager_stage_resizeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}
}
