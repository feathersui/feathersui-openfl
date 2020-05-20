/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.ListViewItemState;
import openfl.events.EventType;
import openfl.events.Event;

/**
	Events dispatched by the `ListView` component.

	@see `feathers.controls.ListView`

	@since 1.0.0
**/
class ListViewEvent extends Event {
	/**
		The `ListViewEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var ITEM_TRIGGER:EventType<ListViewEvent> = "itemTrigger";

	public function new(type:String, state:ListViewItemState) {
		super(type, false, false);
		this.state = state;
	}

	public var state:ListViewItemState;
}
