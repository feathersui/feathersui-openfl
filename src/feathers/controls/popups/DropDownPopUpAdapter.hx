/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import feathers.core.IValidating;
import openfl.geom.Point;
import feathers.core.PopUpManager;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import feathers.events.FeathersEvent;
import openfl.errors.IllegalOperationError;
import openfl.display.DisplayObject;

/**
	Displays a pop-up like a drop-down, either below or above the source.

	@since 1.0.0
**/
class DropDownPopUpAdapter extends EventDispatcher implements IPopUpAdapter {
	/**
		Creates a new `DropDownPopUpAdapter` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var content:DisplayObject = null;
	private var origin:DisplayObject = null;

	/**
		@see `feathers.controls.popups.IPopUpAdapter.active`
	**/
	public var active(get, never):Bool;

	private function get_active():Bool {
		return this.content != null;
	}

	public var modal:Bool = false;

	/**
		@see `feathers.controls.popups.IPopUpAdapter.persistent`
	**/
	public var persistent(get, never):Bool;

	private function get_persistent():Bool {
		return false;
	}

	/**
		@see `feathers.controls.popups.IPopUpAdapter.open`
	**/
	public function open(content:DisplayObject, origin:DisplayObject):Void {
		if (this.active) {
			throw new IllegalOperationError("Pop-up adapter is already open. Close the previous content before opening new content.");
		}
		this.content = content;
		this.origin = origin;
		PopUpManager.addPopUp(this.content, this.origin, this.modal, false);

		this.layout();

		FeathersEvent.dispatch(this, Event.OPEN);
	}

	/**
		@see `feathers.controls.popups.IPopUpAdapter.close`

		When the adapter closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see `openfl.events.Event.CLOSE`
	**/
	public function close():Void {
		if (!this.active) {
			return;
		}
		var content = this.content;
		this.origin = null;
		this.content = null;

		if (content.parent != null) {
			content.parent.removeChild(content);
		}
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function layout():Void {
		if (Std.is(this.origin, IValidating)) {
			cast(this.origin, IValidating).validateNow();
		}

		var popUpRoot = PopUpManager.forStage(this.origin.stage).root;

		var originTopLeft = new Point(this.origin.x, this.origin.y);
		originTopLeft = origin.parent.localToGlobal(originTopLeft);
		originTopLeft = popUpRoot.globalToLocal(originTopLeft);

		var originBottomRight = new Point(this.origin.x + this.origin.width, this.origin.y + this.origin.height);
		originBottomRight = origin.parent.localToGlobal(originBottomRight);
		originBottomRight = popUpRoot.globalToLocal(originBottomRight);

		this.content.x = originTopLeft.x;
		this.content.y = originBottomRight.y;
	}
}
