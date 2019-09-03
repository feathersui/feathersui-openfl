/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import feathers.core.PopUpManager;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import feathers.events.FeathersEvent;
import openfl.errors.IllegalOperationError;
import openfl.display.DisplayObject;

/**
	@since 1.0.0
**/
class DropDownPopUpAdapter extends EventDispatcher implements IPopUpAdapter {
	private var content:DisplayObject = null;
	private var source:DisplayObject = null;

	/**
		@since 1.0.0
	**/
	public var active(get, never):Bool;

	private function get_active():Bool {
		return this.content != null;
	}

	/**
		@since 1.0.0
	**/
	public function open(content:DisplayObject, source:DisplayObject):Void {
		if (this.active) {
			throw new IllegalOperationError("Pop-up adapter is already open. Close the previous content before opening new content.");
		}
		this.content = content;
		this.source = source;
		PopUpManager.addPopUp(content, source);
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	/**
		@since 1.0.0
	**/
	public function close():Void {
		if (!this.active) {
			return;
		}
		var content = this.content;
		this.source = null;
		this.content = null;

		if (content.parent != null) {
			content.parent.removeChild(content);
		}
		FeathersEvent.dispatch(this, Event.CLOSE);
	}
}
