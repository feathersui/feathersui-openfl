/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.errors.IllegalOperationError;
import openfl.display.Sprite;
import openfl.events.Event;
import feathers.utils.DisplayUtil;

/**
	An [`openfl.display.Sprite`](https://api.openfl.org/openfl/display/Sprite.html)
	with a validation system where multiple property changes may be queued up to
	be processed all at once. A performance optimization for frequently changing
	user interfaces.

	@since 1.0.0
**/
class ValidatingSprite extends Sprite implements IValidating {
	private function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, validatingSprite_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, validatingSprite_removedFromStageHandler);
	}

	private var _validating:Bool = false;
	private var _allInvalid:Bool = false;
	private var _allInvalidDelayed:Bool = false;
	private var _invalidationFlags:Map<String, Bool> = new Map();
	private var _delayedInvalidationFlags:Map<String, Bool> = new Map();
	private var _setInvalidCount:Int = 0;
	private var _validationQueue:ValidationQueue = null;

	/**
		@see `feathers.core.IValidating.depth`
	**/
	public var depth(default, null):Int = -1;

	/**
		Indicates whether the control is pending validation or not. By default,
		returns `true` if any invalidation flag has been set. If you pass in a
		specific flag, returns `true` only if that flag has been set (others may
		be set too, but it checks the specific flag only. If all flags have been
		marked as invalid, always returns `true`.

		The following example invalidates a component:

		```hx
		component.setInvalid();
		trace(component.isInvalid()); // true
		```

		@since 1.0.0
	**/
	public function isInvalid(flag:String = null):Bool {
		if (this._allInvalid) {
			return true;
		}
		if (flag == null) {
			// return true if any flag is set
			return this._invalidationFlags.keys().hasNext();
		}
		return this._invalidationFlags.exists(flag);
	}

	/**
		Call this function to tell the UI control that a redraw is pending.
		The redraw will happen immediately before OpenFL renders the UI
		control to the screen. The validation system exists to ensure that
		multiple properties can be set together without redrawing multiple
		times in between each property change.

		If you cannot wait until later for the validation to happen, you
		can call `validate()` to redraw immediately. As an example,
		you might want to validate immediately if you need to access the
		correct `width` or `height` values of the UI
		control, since these values are calculated during validation.

		The following example invalidates a component:

		```hx
		component.setInvalid();
		trace(component.isInvalid()); // true
		```

		@since 1.0.0
	**/
	public function setInvalid(flag:String = null):Void {
		var alreadyInvalid = this.isInvalid();
		var alreadyDelayedInvalid = false;
		if (this._validating) {
			for (otherFlag in this._delayedInvalidationFlags.keys()) {
				alreadyDelayedInvalid = true;
				break;
			}
		}
		if (flag == null) {
			if (this._validating) {
				this._allInvalidDelayed = true;
			} else {
				this._allInvalid = true;
			}
		} else {
			if (this._validating) {
				this._delayedInvalidationFlags.set(flag, true);
			} else if (flag != null && !this._invalidationFlags.exists(flag)) {
				this._invalidationFlags.set(flag, true);
			}
		}
		if (this._validationQueue == null) {
			// we'll add this object to the queue later, after it has been
			// added to the stage.
			return;
		}
		if (this._validating) {
			// if we've already incremented this counter this time, we can
			// return. we're already in queue.
			if (alreadyDelayedInvalid) {
				return;
			}
			this._setInvalidCount++;
			// if setInvalid() is called during validation, we'll be added
			// back to the end of the queue. we'll keep trying this a certain
			// number of times, but at some point, it needs to be considered
			// an infinite loop or a serious bug because it affects
			// performance.
			if (this._setInvalidCount >= 10) {
				throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
					+
					" returned to validation queue too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls setInvalid() during validation.");
			}
			this._validationQueue.addControl(this);
			return;
		}
		if (alreadyInvalid) {
			return;
		}
		this._setInvalidCount = 0;
		this._validationQueue.addControl(this);
	}

	/**
		@see `feathers.core.IValidating.validateNow`
	**/
	public function validateNow():Void {
		// if we're not actually invalid, there's nothing to do here, so
		// simply return.
		if (!this.isInvalid()) {
			return;
		}
		if (this._validating) {
			// we were already validating, so there's nothing to do here.
			// the existing validation will continue.
			return;
		}
		this._validating = true;
		this.update();
		for (flag in this._invalidationFlags.keys()) {
			this._invalidationFlags.remove(flag);
		}
		this._allInvalid = this._allInvalidDelayed;
		for (flag in this._delayedInvalidationFlags.keys()) {
			if (flag == null) {
				this._allInvalid = true;
			} else {
				this._invalidationFlags.set(flag, true);
			}
			this._delayedInvalidationFlags.remove(flag);
		}
		this._validating = false;
	}

	/**
		Sets an invalidation flag. This will not add the component to the
		validation queue. It only sets the flag. A subclass might use
		this function during `draw()` to manipulate the flags that
		its superclass sees.

		@see `ValidatingSprite.setInvalid()`

		@since 1.0.0
	**/
	@:dox(show)
	private function setInvalidationFlag(flag:String):Void {
		if (this._invalidationFlags.exists(flag)) {
			return;
		}
		this._invalidationFlags.set(flag, true);
	}

	/**
		Override to customize layout and to adjust properties of children.
		Called when the component validates, if any flags have been marked
		to indicate that validation is pending.

		The following example overrides updating after invalidation:

		```hx
		override private function update():Void {
			super.update();

		}
		```

		@since 1.0.0
	**/
	@:dox(show)
	private function update():Void {}

	private function validatingSprite_addedToStageHandler(event:Event):Void {
		this.depth = DisplayUtil.getDisplayObjectDepthFromStage(this);
		this._validationQueue = ValidationQueue.forStage(this.stage);
		if (this.isInvalid()) {
			this._setInvalidCount = 0;
			// add to validation queue, if required
			this._validationQueue.addControl(this);
		}
	}

	private function validatingSprite_removedFromStageHandler(event:Event):Void {
		this.depth = -1;
		this._validationQueue = null;
	}
}
