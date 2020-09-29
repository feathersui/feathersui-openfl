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
	An abstract base class for `IEffectContext` implementations that delegate to
	other `IEffectContext` instances.

	@since 1.0.0
**/
class BaseDelegateEffectContext extends EventDispatcher implements IEffectContext {
	private function new(context:IEffectContext) {
		super();
		this._context = context;
		this._context.addEventListener(Event.CHANGE, baseDelegateEffectContext_context_changeHandler);
		this._context.addEventListener(Event.COMPLETE, baseDelegateEffectContext_context_completeHandler);
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

	private function baseDelegateEffectContext_context_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function baseDelegateEffectContext_context_completeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.COMPLETE);
	}
}
