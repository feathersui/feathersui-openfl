/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
	Allows a component to claim exclusive access to a pointer to avoid dragging,
	scrolling, or other interaction conflicts. In particular, if objects are
	nested, and they can be scrolled or dragged, it's better for one to
	eventually gain exclusive control over the pointer. Multiple objects being
	controlled by the same pointer often results in unexpected behavior.

	@since 1.0.0
**/
class ExclusivePointer {
	public static final POINTER_ID_MOUSE = -1000;

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

	private var _claims:Map<Int, DisplayObject> = [];

	/**
		Allows a display object to claim a pointer by its ID. Returns `true` if
		if the pointer is claimed. Returns `false` if the pointer was previously
		claimed by another display object.

		@since 1.0.0
	**/
	public function claimPointer(pointerID:Int, target:DisplayObject):Bool {
		if (target == null) {
			throw new ArgumentError("Target cannot be null.");
		}
		if (target.stage != this._stage) {
			throw new ArgumentError("Target cannot claim a pointer on the selected stage because it appears on a different stage.");
		}
		if (pointerID < 0 && pointerID != POINTER_ID_MOUSE) {
			throw new ArgumentError("Invalid pointer. Pointer ID must be >= 0 or ExclusivePointer.POINTER_ID_MOUSE.");
		}
		var existingTarget = this._claims.get(pointerID);
		if (existingTarget != null) {
			return false;
		}
		this._claims.set(pointerID, target);
		if (this._stageListenerCount == 0) {
			this._stage.addEventListener(MouseEvent.MOUSE_UP, exclusivePointer_stage_mouseUpHandler, false, 0, true);
			this._stage.addEventListener(TouchEvent.TOUCH_END, exclusivePointer_stage_touchEndHandler, false, 0, true);
		}
		this._stageListenerCount++;
		return true;
	}

	/**
		Removes a claim to the pointer with the specified ID.

		@since 1.0.0
	 */
	public function removeClaim(pointerID:Int):Void {
		var existingTarget = this._claims.get(pointerID);
		if (existingTarget == null) {
			return;
		}
		this._claims.remove(pointerID);
		this._stageListenerCount--;
		if (this._stageListenerCount == 0) {
			this._stage.removeEventListener(MouseEvent.MOUSE_UP, exclusivePointer_stage_mouseUpHandler);
			this._stage.removeEventListener(TouchEvent.TOUCH_END, exclusivePointer_stage_touchEndHandler);
		}
	}

	/**
		Gets the display object that has claimed a pointer with the specified
		ID. If no display object claims the pointer with the specified ID,
		returns `null`.

		@since 1.0.0
	**/
	public function getClaim(pointerID:Int):DisplayObject {
		if (pointerID < 0 && pointerID != POINTER_ID_MOUSE) {
			throw new ArgumentError("Invalid pointer. Pointer ID must be >= 0 or ExclusivePointer.POINTER_ID_MOUSE.");
		}
		return this._claims.get(pointerID);
	}

	private function dispose():Void {
		for (pointerID in this._claims.keys()) {
			this.removeClaim(pointerID);
		}
	}

	private function exclusivePointer_stage_mouseUpHandler(event:MouseEvent):Void {
		this.removeClaim(POINTER_ID_MOUSE);
	}

	private function exclusivePointer_stage_touchEndHandler(event:TouchEvent):Void {
		this.removeClaim(event.touchPointID);
	}
}
