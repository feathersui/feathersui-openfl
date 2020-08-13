/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.controls.IToggle;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.InvalidationFlag;
import feathers.core.MeasureSprite;
import feathers.events.FeathersEvent;
import openfl.events.Event;

/**
	A base class for Feathers UI skins that are drawn programmatically.

	@since 1.0.0
**/
class ProgrammaticSkin extends MeasureSprite implements IStateObserver {
	private function new() {
		super();

		this.mouseChildren = false;
		this.tabEnabled = false;
		this.tabChildren = false;
	}

	private var _stateContext:IStateContext<Dynamic>;

	/**
		An optional `IStateContext` that is used to change the styles of the
		skin when its state changes.

		@since 1.0.0
	**/
	@:flash.property
	public var stateContext(get, set):IStateContext<Dynamic>;

	private function get_stateContext():IStateContext<Dynamic> {
		return this._stateContext;
	}

	private function set_stateContext(value:IStateContext<Dynamic>):IStateContext<Dynamic> {
		if (this._stateContext == value) {
			return this._stateContext;
		}
		if (this._stateContext != null) {
			this._stateContext.removeEventListener(FeathersEvent.STATE_CHANGE, stateContext_stateChangeHandler);
			if (Std.is(this._stateContext, IToggle)) {
				this._stateContext.removeEventListener(Event.CHANGE, stateContextToggle_changeHandler);
			}
		}
		this._stateContext = value;
		if (this._stateContext != null) {
			this._stateContext.addEventListener(FeathersEvent.STATE_CHANGE, stateContext_stateChangeHandler, false, 0, true);
			if (Std.is(this._stateContext, IToggle)) {
				this._stateContext.addEventListener(Event.CHANGE, stateContextToggle_changeHandler);
			}
		}
		this.setInvalid(DATA);
		return this._stateContext;
	}

	/**
		Subclasses may override `update()` to draw the skin.

		@since 1.0.0
	**/
	@:dox(show)
	override private function update():Void {}

	/**
		Checks if a the current state requires the skin to be redrawn. By
		default, returns `true`.

		Subclasses may override `needsStateUpdate()` to limit when state changes
		require the skin to update.

		@since 1.0.0
	**/
	@:dox(show)
	private function needsStateUpdate():Bool {
		return true;
	}

	private function checkForStateChange():Void {
		if (!this.needsStateUpdate()) {
			return;
		}
		this.setInvalid(STATE);
	}

	private function stateContext_stateChangeHandler(event:FeathersEvent):Void {
		this.checkForStateChange();
	}

	private function stateContextToggle_changeHandler(event:Event):Void {
		this.checkForStateChange();
	}
}
