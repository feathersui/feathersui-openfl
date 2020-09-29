/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

import feathers.events.FeathersEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;

@:event(openfl.events.Event.COMPLETE)

/**
	An advanced effect context that delegates to another `IEffectContext`
	instance.

	@since 1.0.0
**/
class DelegateEffectContext extends EventDispatcher implements IEffectContext {
	/**
		Creates a new `DelegateEffectContext` object from the given arguments.

		@since 1.0.0
	**/
	public function new(context:IEffectContext) {
		super();
		this._context = context;
		this._context.addEventListener(Event.CHANGE, delegateEffectContext_context_changeHandler);
		this._context.addEventListener(Event.COMPLETE, delegateEffectContext_context_completeHandler);
	}

	private var _context:IEffectContext;

	/**
		The effect context that is the target of this delegate.

		@since 1.0.0
	**/
	@:flash.property
	public var context(get, never):IEffectContext;

	private function get_context():IEffectContext {
		return this._context;
	}

	/**
		@see `feathers.motion.effects.IEffectContext.target`
	**/
	@:flash.property
	public var target(get, never):Dynamic;

	private function get_target():Dynamic {
		return this.context.target;
	}

	/**
		@see `feathers.motion.effects.IEffectContext.duration`
	**/
	@:flash.property
	public var duration(get, never):Float;

	private function get_duration():Float {
		return this.context.duration;
	}

	/**
		@see `feathers.motion.effects.IEffectContext.position`
	**/
	@:flash.property
	public var position(get, set):Float;

	private function get_position():Float {
		return this.context.position;
	}

	private function set_position(value:Float):Float {
		this.context.position = value;
		return this.context.position;
	}

	/**
		@see `feathers.motion.effects.IEffectContext.play()`
	**/
	public function play():Void {
		this._context.play();
	}

	/**
		@see `feathers.motion.effects.IEffectContext.playReverse()`
	**/
	public function playReverse():Void {
		this._context.playReverse();
	}

	/**
		@see `feathers.motion.effects.IEffectContext.pause()`
	**/
	public function pause():Void {
		this._context.pause();
	}

	/**
		@see `feathers.motion.effects.IEffectContext.stop()`
	**/
	public function stop():Void {
		this._context.stop();
	}

	/**
		@see `feathers.motion.effects.IEffectContext.toEnd()`
	**/
	public function toEnd():Void {
		this._context.toEnd();
	}

	/**
		@see `feathers.motion.effects.IEffectContext.interrupt()`
	**/
	public function interrupt():Void {
		this._context.interrupt();
	}

	private function delegateEffectContext_context_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function delegateEffectContext_context_completeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.COMPLETE);
	}
}
