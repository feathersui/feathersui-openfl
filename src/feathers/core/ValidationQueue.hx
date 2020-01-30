/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.Stage;
import openfl.events.Event;

/**
	A queue for components that are invalid.

	@since 1.0.0
**/
class ValidationQueue {
	private static final STAGE_TO_VALIDATION_QUEUE:Map<Stage, ValidationQueue> = new Map();

	/**
		Returns the validation queue for the specified `Stage`. If a validation
		queue doesn't exist for that `Stage`, a new one is created.

		@since 1.0.0
	**/
	public static function forStage(stage:Stage):ValidationQueue {
		if (stage == null) {
			return null;
		}
		if (!STAGE_TO_VALIDATION_QUEUE.exists(stage)) {
			STAGE_TO_VALIDATION_QUEUE.set(stage, new ValidationQueue(stage));
		}
		return STAGE_TO_VALIDATION_QUEUE[stage];
	}

	/**
		Creates a new `ValidationQueue` object with the given arguments.

		@since 1.0.0
	**/
	public function new(stage:Stage) {
		this._stage = stage;
		this._stage.addEventListener(Event.ENTER_FRAME, stage_enterFrameHandler, false, -1000, true);
	}

	private var _stage:Stage = null;
	private var _queue:Array<IValidating> = [];

	/**
		If `true`, the queue is currently validating.

		@since 1.0.0
	**/
	public var validating(default, null):Bool = false;

	/**
		Cleans up the validation queue.

		@since 1.0.0
	**/
	public function dispose():Void {
		if (this._stage == null) {
			return;
		}
		this._stage.removeEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
		this._stage = null;
	}

	/**
		Adds a validating component to the queue.

		@since 1.0.0
	**/
	public function addControl(control:IValidating) {
		if (this._queue.indexOf(control) != -1) {
			// already queued
			return;
		}
		var queueLength = this._queue.length;
		if (this.validating) {
			// special case: we need to keep it sorted
			var depth = control.depth;

			// we're traversing the queue backwards because it's
			// significantly more likely that we're going to push than that
			// we're going to splice, so there's no point to iterating over
			// the whole queue
			var i = queueLength - 1;
			while (i >= 0) {
				var otherControl:IValidating = this._queue[i];
				var otherDepth = otherControl.depth;
				// we can skip the overhead of calling queueSortFunction and
				// of looking up the value we've already stored in the depth
				// local variable.
				if (depth >= otherDepth) {
					break;
				}
				i--;
			}
			// add one because we're going after the last item we checked
			// if we made it through all of them, i will be -1, and we want 0
			i++;
			this._queue.insert(i, control);
		} else {
			// faster than push() because push() creates a temporary rest
			// Array that needs to be garbage collected
			this._queue[queueLength] = control;
		}
	}

	/**
		Immediately validates all components in the queue.

		@since 1.0.0
	**/
	public function validateNow():Void {
		if (this.validating) {
			return;
		}
		var queueLength = this._queue.length;
		if (queueLength == 0) {
			return;
		}
		this.validating = true;
		if (queueLength > 1) {
			this._queue.sort(function(first:IValidating, second:IValidating):Int {
				var difference = second.depth - first.depth;
				if (difference > 0) {
					return -1;
				} else if (difference < 0) {
					return 1;
				}
				return 0;
			});
		}
		// rechecking length every time because addControl() might have added
		// a new item during the last validation.
		// we could use an int and check the length again at the end of the
		// loop, but there is little difference in performance, even with
		// millions of items in queue.
		while (this._queue.length > 0) {
			var item:IValidating = this._queue.shift();
			if (item.depth < 0) {
				// skip items that are no longer on the display list
				continue;
			}
			item.validateNow();
		}
		this.validating = false;
	}

	private function stage_enterFrameHandler(event:Event):Void {
		this.validateNow();
	}
}
