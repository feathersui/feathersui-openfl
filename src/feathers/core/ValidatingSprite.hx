/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.utils.DisplayUtil;
import openfl.display.Sprite;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;

/**
	An [`openfl.display.Sprite`](https://api.openfl.org/openfl/display/Sprite.html)
	with a validation system where multiple property changes may be queued up to
	be processed all at once. A performance optimization for frequently changing
	user interfaces.

	@since 1.0.0
**/
@:event(openfl.events.Event.ACTIVATE)
@:event(openfl.events.Event.ADDED)
@:event(openfl.events.Event.ADDED_TO_STAGE)
@:event(openfl.events.Event.CLEAR)
@:event(openfl.events.Event.COPY)
@:event(openfl.events.Event.CUT)
@:event(openfl.events.Event.DEACTIVATE)
@:event(openfl.events.Event.ENTER_FRAME)
@:event(openfl.events.Event.EXIT_FRAME)
@:event(openfl.events.Event.FRAME_CONSTRUCTED)
@:event(openfl.events.Event.PASTE)
@:event(openfl.events.Event.REMOVED)
@:event(openfl.events.Event.REMOVED_FROM_STAGE)
@:event(openfl.events.Event.RENDER)
@:event(openfl.events.Event.SELECT_ALL)
@:event(openfl.events.Event.TAB_CHILDREN_CHANGE)
@:event(openfl.events.Event.TAB_ENABLED_CHANGE)
@:event(openfl.events.Event.TAB_INDEX_CHANGE)
@:event(openfl.events.FocusEvent.FOCUS_IN)
@:event(openfl.events.FocusEvent.FOCUS_OUT)
@:event(openfl.events.FocusEvent.KEY_FOCUS_CHANGE)
@:event(openfl.events.FocusEvent.MOUSE_FOCUS_CHANGE)
@:event(openfl.events.KeyboardEvent.KEY_DOWN)
@:event(openfl.events.KeyboardEvent.KEY_UP)
@:event(openfl.events.MouseEvent.CLICK)
@:event(openfl.events.MouseEvent.DOUBLE_CLICK)
@:event(openfl.events.MouseEvent.MIDDLE_CLICK)
@:event(openfl.events.MouseEvent.MIDDLE_MOUSE_DOWN)
@:event(openfl.events.MouseEvent.MIDDLE_MOUSE_UP)
@:event(openfl.events.MouseEvent.MOUSE_DOWN)
@:event(openfl.events.MouseEvent.MOUSE_MOVE)
@:event(openfl.events.MouseEvent.MOUSE_OUT)
@:event(openfl.events.MouseEvent.MOUSE_OVER)
@:event(openfl.events.MouseEvent.MOUSE_UP)
@:event(openfl.events.MouseEvent.MOUSE_WHEEL)
@:event(openfl.events.MouseEvent.RELEASE_OUTSIDE)
@:event(openfl.events.MouseEvent.RIGHT_CLICK)
@:event(openfl.events.MouseEvent.RIGHT_MOUSE_DOWN)
@:event(openfl.events.MouseEvent.RIGHT_MOUSE_UP)
@:event(openfl.events.MouseEvent.ROLL_OVER)
@:event(openfl.events.MouseEvent.ROLL_OUT)
@:event(openfl.events.TextEvent.TEXT_INPUT)
@:event(openfl.events.TouchEvent.TOUCH_BEGIN)
@:event(openfl.events.TouchEvent.TOUCH_END)
@:event(openfl.events.TouchEvent.TOUCH_MOVE)
@:event(openfl.events.TouchEvent.TOUCH_OUT)
@:event(openfl.events.TouchEvent.TOUCH_OVER)
@:event(openfl.events.TouchEvent.TOUCH_ROLL_OUT)
@:event(openfl.events.TouchEvent.TOUCH_ROLL_OVER)
@:event(openfl.events.TouchEvent.TOUCH_TAP)
#if air
@:event(openfl.events.MouseEvent.CONTEXT_MENU) @:event(openfl.events.TouchEvent.PROXIMITY_BEGIN) @:event(openfl.events.TouchEvent.PROXIMITY_END) @:event(openfl.events.TouchEvent.PROXIMITY_MOVE) @:event(openfl.events.TouchEvent.PROXIMITY_OUT) @:event(openfl.events.TouchEvent.PROXIMITY_OVER) @:event(openfl.events.TouchEvent.PROXIMITY_ROLL_OUT) @:event(openfl.events.TouchEvent.PROXIMITY_ROLL_OVER)
#end
class ValidatingSprite extends Sprite implements IValidating {
	private function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, validatingSprite_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, validatingSprite_removedFromStageHandler);
	}

	private var _validating:Bool = false;

	/**
		Indicates if the display object is currently validating.

		@since 1.0.0
	**/
	public var validating(get, never):Bool;

	private function get_validating():Bool {
		return _validating;
	}

	private var _allInvalid:Bool = false;
	private var _allInvalidDelayed:Bool = false;
	private var _invalidationFlags:Map<InvalidationFlag, Bool> = new Map();
	private var _delayedInvalidationFlags:Map<InvalidationFlag, Bool> = new Map();
	private var _setInvalidCount:Int = 0;
	private var _validationQueue:ValidationQueue = null;

	private var _depth:Int = -1;

	/**
		@see `feathers.core.IValidating.depth`
	**/
	public var depth(get, never):Int;

	private function get_depth():Int {
		return this._depth;
	}

	/**
		Indicates whether the control is pending validation or not. By default,
		returns `true` if any invalidation flag has been set. If you pass in a
		specific flag, returns `true` only if that flag has been set (others may
		be set too, but it checks the specific flag only. If all flags have been
		marked as invalid, always returns `true`.

		The following example invalidates a component:

		```haxe
		component.setInvalid();
		trace(component.isInvalid()); // true
		```

		@since 1.0.0

		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	public function isInvalid(?flag:InvalidationFlag):Bool {
		if (this._allInvalid) {
			return true;
		}
		if (flag == null) {
			// return true if any flag is set
			return this._invalidationFlags.keys().hasNext();
		}
		return this._invalidationFlags.exists(flag);
	}

	@:noCompletion
	private var _ignoreInvalidationFlags = false;

	/**
		Calls a function that temporarily disables invalidation. In other words,
		calls to `setInvalid()` will be ignored until the function returns.

		@since 1.0.0
	**/
	public function runWithoutInvalidation(callback:() -> Void):Void {
		var oldIgnoreValidation = this._ignoreInvalidationFlags;
		this._ignoreInvalidationFlags = true;
		callback();
		this._ignoreInvalidationFlags = oldIgnoreValidation;
	}

	@:noCompletion
	private var _setInvalidationFlagsOnly = false;

	/**
		Calls a function that temporarily limits `setInvalid()` calls to
		setting invalidation flags only, and the control will not be added to
		the validation queue. In other words, `setInvalid()` calls will work
		similarly to `setInvalidationFlag()` instead.

		Typically, this method should be called only during validation. If
		called outside of `update()`, the component's validation may be delayed
		until a future call to `setInvalid()`.

		@since 1.2.0
	**/
	public function runWithInvalidationFlagsOnly(callback:() -> Void):Void {
		var oldValue = this._setInvalidationFlagsOnly;
		this._setInvalidationFlagsOnly = true;
		callback();
		this._setInvalidationFlagsOnly = oldValue;
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

		```haxe
		component.setInvalid();
		trace(component.isInvalid()); // true
		```

		@since 1.0.0

		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	public function setInvalid(?flag:InvalidationFlag):Void {
		if (this._ignoreInvalidationFlags) {
			return;
		}
		if (this._setInvalidationFlagsOnly) {
			if (flag == null) {
				this._allInvalid = true;
			} else {
				this.setInvalidationFlag(flag);
			}
			return;
		}
		var alreadyInvalid = this.isInvalid();
		var alreadyDelayedInvalid = false;
		if (this._validating) {
			#if feathersui_strict_set_invalid
			throw new openfl.errors.IllegalOperationError("feathersui_strict_set_invalid requires no calls to setInvalid() during update()");
			#end
			alreadyDelayedInvalid = this._delayedInvalidationFlags.keys().hasNext();
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
		@see `ValidatingSprite.update`
		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
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
		this._allInvalid = this._allInvalidDelayed;
		this._allInvalidDelayed = false;
		this._invalidationFlags.clear();
		for (flag in this._delayedInvalidationFlags.keys()) {
			this._invalidationFlags.set(flag, true);
		}
		this._delayedInvalidationFlags.clear();
		this._validating = false;
	}

	/**
		Sets an invalidation flag. This will not add the component to the
		validation queue. It only sets the flag. A subclass might use
		this function during `draw()` to manipulate the flags that
		its superclass sees.

		@since 1.0.0

		@see `ValidatingSprite.setInvalid()`
		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	@:dox(show)
	private function setInvalidationFlag(flag:InvalidationFlag):Void {
		if (this._ignoreInvalidationFlags) {
			return;
		}
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

		```haxe
		override private function update():Void {
			super.update();

		}
		```

		@since 1.0.0

		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	@:dox(show)
	private function update():Void {}

	private function validatingSprite_addedToStageHandler(event:Event):Void {
		this._depth = DisplayUtil.getDisplayObjectDepthFromStage(this);
		this._validationQueue = ValidationQueue.forStage(this.stage);
		if (this._validationQueue != null && this.isInvalid()) {
			this._setInvalidCount = 0;
			// add to validation queue, if required
			this._validationQueue.addControl(this);
		}
	}

	private function validatingSprite_removedFromStageHandler(event:Event):Void {
		this._depth = -1;
		this._validationQueue = null;
	}
}
