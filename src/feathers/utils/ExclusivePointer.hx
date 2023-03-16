/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
	Allows a component to claim exclusive access to a pointer (a touch point or
	the mouse cursor) to avoid dragging conflicts, scrolling conflicts, or other
	interaction conflicts. In particular, if objects are nested, and they can be
	scrolled or dragged, it's better for one to eventually gain exclusive
	control over a pointer. Multiple objects being controlled by the same
	pointer often results in unexpected behavior for user experience.

	@since 1.0.0
**/
class ExclusivePointer {
	private static final stageToObject:Map<Stage, ExclusivePointer> = [];

	/**
		Retrieves the exclusive pointer manager for the specified stage
		(creating one if it does not yet exist).

		@since 1.0.0
	 */
	public static function forStage(stage:Stage):ExclusivePointer {
		if (stage == null) {
			throw new ArgumentError("Stage cannot be null.");
		}
		var exclusivePointer = stageToObject.get(stage);
		if (exclusivePointer != null) {
			return exclusivePointer;
		}
		exclusivePointer = new ExclusivePointer(stage);
		stageToObject.set(stage, exclusivePointer);
		return exclusivePointer;
	}

	/**
		Disposes the exclusive pointer manager for the specified stage.

		@since 1.0.0
	**/
	public static function disposeForStage(stage:Stage):Void {
		var exclusivePointer = stageToObject.get(stage);
		if (exclusivePointer == null) {
			return;
		}
		exclusivePointer.dispose();
		stageToObject.remove(stage);
	}

	private function new(stage:Stage) {
		if (stage == null) {
			throw new ArgumentError("Stage cannot be null.");
		}
		this._stage = stage;
	}

	private var _stageListenerCount:Int = 0;

	private var _stage:Stage;

	private var _mouseClaim:DisplayObject = null;
	private var _touchClaims:Map<Int, DisplayObject> = [];

	/**
		Allows a display object to claim a touch by its ID. Returns `true` if
		if the touch is claimed. Returns `false` if the touch was previously
		claimed by another display object.

		@since 1.0.0
	**/
	public function claimTouch(touchPointID:Int, target:DisplayObject):Bool {
		if (target == null) {
			throw new ArgumentError("Target cannot be null.");
		}
		if (target.stage != this._stage) {
			throw new ArgumentError("Target cannot claim a pointer on the selected stage because it appears on a different stage.");
		}
		var existingTarget = this._touchClaims.get(touchPointID);
		if (existingTarget != null) {
			return false;
		}
		this._touchClaims.set(touchPointID, target);
		target.addEventListener(Event.REMOVED_FROM_STAGE, exclusivePointer_target_removedFromStageHandler, false, 0, true);
		if (this._stageListenerCount == 0) {
			this._stage.addEventListener(MouseEvent.MOUSE_UP, exclusivePointer_stage_mouseUpHandler, false, 0, true);
			this._stage.addEventListener(TouchEvent.TOUCH_END, exclusivePointer_stage_touchEndHandler, false, 0, true);
		}
		this._stageListenerCount++;
		return true;
	}

	/**
		Allows a display object to claim the mouse. Returns `true` if
		if the mouse is claimed. Returns `false` if the mouse was previously
		claimed by another display object.

		@see `ExclusivePointer.claimTouch()`
	**/
	public function claimMouse(target:DisplayObject):Bool {
		if (target == null) {
			throw new ArgumentError("Target cannot be null.");
		}
		if (target.stage != this._stage) {
			throw new ArgumentError("Target cannot claim a pointer on the selected stage because it appears on a different stage.");
		}
		if (this._mouseClaim != null) {
			return false;
		}
		this._mouseClaim = target;
		target.addEventListener(Event.REMOVED_FROM_STAGE, exclusivePointer_target_removedFromStageHandler, false, 0, true);
		if (this._stageListenerCount == 0) {
			this._stage.addEventListener(MouseEvent.MOUSE_UP, exclusivePointer_stage_mouseUpHandler, false, 0, true);
			this._stage.addEventListener(TouchEvent.TOUCH_END, exclusivePointer_stage_touchEndHandler, false, 0, true);
		}
		this._stageListenerCount++;
		return true;
	}

	/**
		Removes a claim to the touch with the specified ID.

		@since 1.0.0
	 */
	public function removeTouchClaim(touchPointID:Int):Void {
		var existingTarget = this._touchClaims.get(touchPointID);
		if (existingTarget == null) {
			return;
		}
		this._touchClaims.remove(touchPointID);
		if (!this.hasClaimOn(existingTarget)) {
			existingTarget.removeEventListener(Event.REMOVED_FROM_STAGE, exclusivePointer_target_removedFromStageHandler);
		}
		this._stageListenerCount--;
		if (this._stageListenerCount == 0) {
			this._stage.removeEventListener(MouseEvent.MOUSE_UP, exclusivePointer_stage_mouseUpHandler);
			this._stage.removeEventListener(TouchEvent.TOUCH_END, exclusivePointer_stage_touchEndHandler);
		}
	}

	/**
		Removes a claim to the mouse.

		@since 1.0.0
	 */
	public function removeMouseClaim():Void {
		var existingTarget = this._mouseClaim;
		if (existingTarget == null) {
			return;
		}
		this._mouseClaim = null;
		if (!this.hasClaimOn(existingTarget)) {
			existingTarget.removeEventListener(Event.REMOVED_FROM_STAGE, exclusivePointer_target_removedFromStageHandler);
		}
		this._stageListenerCount--;
		if (this._stageListenerCount == 0) {
			this._stage.removeEventListener(MouseEvent.MOUSE_UP, exclusivePointer_stage_mouseUpHandler);
			this._stage.removeEventListener(TouchEvent.TOUCH_END, exclusivePointer_stage_touchEndHandler);
		}
	}

	/**
		Indicates if there is at least one claim to mouse or touch.

		@since 1.0.0
	**/
	public function hasClaim():Bool {
		if (this._mouseClaim != null) {
			return true;
		}
		for (touchPointID in this._touchClaims.keys()) {
			return true;
		}
		return false;
	}

	/**
		Gets the display object that has claimed a touch with the specified
		ID. If no display object claims the touch with the specified ID,
		returns `null`.

		@since 1.0.0
	**/
	public function getTouchClaim(touchPointID:Int):DisplayObject {
		return this._touchClaims.get(touchPointID);
	}

	/**
		Gets the display object that has claimed the mouse. If no display object
		claims the mouse, returns `null`.

		@since 1.0.0
	**/
	public function getMouseClaim():DisplayObject {
		return this._mouseClaim;
	}

	/**
		Removes all claims to mouse or touch.

		@since 1.0.0
	**/
	public function removeAllClaims():Void {
		for (touchPointID in this._touchClaims.keys()) {
			this.removeTouchClaim(touchPointID);
		}
		this.removeMouseClaim();
	}

	private function dispose():Void {
		this.removeAllClaims();
	}

	private function hasClaimOn(target:DisplayObject):Bool {
		if (this._mouseClaim == target) {
			return true;
		}
		for (touchPointID => existingTarget in this._touchClaims) {
			if (existingTarget == target) {
				return true;
			}
		}
		return false;
	}

	private function exclusivePointer_target_removedFromStageHandler(event:Event):Void {
		var target:DisplayObject = cast(event.currentTarget, DisplayObject);
		if (this._mouseClaim == target) {
			this.removeMouseClaim();
		}
		for (touchPointID => existingTarget in this._touchClaims) {
			if (existingTarget == target) {
				this.removeTouchClaim(touchPointID);
			}
		}
	}

	private function exclusivePointer_stage_mouseUpHandler(event:MouseEvent):Void {
		this.removeMouseClaim();
	}

	private function exclusivePointer_stage_touchEndHandler(event:TouchEvent):Void {
		this.removeTouchClaim(event.touchPointID);
	}
}
