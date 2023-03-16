/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import feathers.core.IValidating;
import feathers.core.PopUpManager;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;

/**
	Displays a pop-up in a `Callout` component.

	@event openfl.events.Event.OPEN Dispatched when the pop-up adapter opens,
	and `CalloutPopUpAdapter.active` changes to `true`.

	@event openfl.events.Event.CLOSE Dispatched when the pop-up adapter closes,
	and `CalloutPopUpAdapter.active` changes to `false`.

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
class CalloutPopUpAdapter extends EventDispatcher implements IPopUpAdapter {
	/**
		Creates a new `CalloutPopUpAdapter` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var content:DisplayObject = null;
	private var origin:DisplayObject = null;
	private var callout:Callout = null;

	/**
		@see `feathers.controls.popups.IPopUpAdapter.active`
	**/
	public var active(get, never):Bool;

	private function get_active():Bool {
		return this.content != null;
	}

	/**
		Determines if the content is displayed modally on the pop-up manager.
	**/
	public var modal:Bool = false;

	private var _fitContentToOriginWidth:Bool = false;

	/**
		Determines if the `width` or `minWidth` of the content is adjusted to
		match the width of the origin, when the content is smaller than the
		origin.
	**/
	public var fitContentToOriginWidth(get, set):Bool;

	private function get_fitContentToOriginWidth():Bool {
		return this._fitContentToOriginWidth;
	}

	private function set_fitContentToOriginWidth(value:Bool):Bool {
		if (this._fitContentToOriginWidth == value) {
			return this._fitContentToOriginWidth;
		}
		this._fitContentToOriginWidth = value;
		if (this.active) {
			this.layout();
		}
		return this._fitContentToOriginWidth;
	}

	/**
		@see `feathers.controls.popups.IPopUpAdapter.persistent`
	**/
	public var persistent(get, never):Bool;

	private function get_persistent():Bool {
		return false;
	}

	private var _contentMeasurements:Measurements = new Measurements();

	/**
		@see `feathers.controls.popups.IPopUpAdapter.open`
	**/
	public function open(content:DisplayObject, origin:DisplayObject):Void {
		if (this.active) {
			throw new IllegalOperationError("Pop-up adapter is already open. Close the previous content before opening new content.");
		}
		if (origin.stage == null) {
			throw new IllegalOperationError("Pop-up adapter failed to open because the origin is not added to the stage.");
		}
		this.content = content;
		this.origin = origin;

		this.callout = Callout.show(this.content, this.origin, null, this.modal);
		this.callout.closeOnPointerOutside = false;

		if (!this.active) {
			// it's possible to immediately close this adapter in an
			// ADDED_TO_STAGE listener. in that case, we should not continue
			return;
		}

		this._contentMeasurements.save(this.content);

		this.layout();

		FeathersEvent.dispatch(this, Event.OPEN);
	}

	/**
		@see `feathers.controls.popups.IPopUpAdapter.close`

		When the adapter closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)
	**/
	public function close():Void {
		if (!this.active) {
			return;
		}

		var content = this.content;
		var callout = this.callout;
		this.callout.content = null;
		this.origin = null;
		this.content = null;
		this.callout = null;

		callout.close();

		this._contentMeasurements.restore(content);

		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function layout():Void {
		var popUpRoot = PopUpManager.forStage(this.origin.stage).root;

		var originTopLeft = new Point(this.origin.x, this.origin.y);
		originTopLeft = origin.parent.localToGlobal(originTopLeft);
		originTopLeft = popUpRoot.globalToLocal(originTopLeft);

		var originBottomRight = new Point(this.origin.x + this.origin.width, this.origin.y + this.origin.height);
		originBottomRight = origin.parent.localToGlobal(originBottomRight);
		originBottomRight = popUpRoot.globalToLocal(originBottomRight);

		var originWidth = Math.max(0.0, originBottomRight.x - originTopLeft.x);

		var hasSetMinWidth = false;
		if (this._fitContentToOriginWidth && this.callout.minWidth < originWidth) {
			this.callout.minWidth = originWidth;
			hasSetMinWidth = true;
		}
		if ((this.callout is IValidating)) {
			cast(this.callout, IValidating).validateNow();
		}
		if (this._fitContentToOriginWidth && !hasSetMinWidth && this.content.width < originWidth) {
			this.callout.width = originWidth;
		}
	}
}
