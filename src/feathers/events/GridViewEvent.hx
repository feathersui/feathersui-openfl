/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.GridViewCellState;
import feathers.data.GridViewHeaderState;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#end

/**
	Events dispatched by the `GridView` component.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
class GridViewEvent<S> extends Event {
	/**
		The `GridViewEvent.CELL_TRIGGER` event type is dispatched when a cell
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var CELL_TRIGGER:EventType<GridViewEvent<GridViewCellState>> = "cellTrigger";

	/**
		The `GridViewEvent.CELL_DOUBLE_CLICK` event type is dispatched when a cell
		renderer is double-clicked with a mouse.

		@since 1.4.0
	**/
	public static inline var CELL_DOUBLE_CLICK:EventType<GridViewEvent<GridViewCellState>> = "cellDoubleClick";

	/**
		The `GridViewEvent.HEADER_TRIGGER` event type is dispatched when a
		header renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var HEADER_TRIGGER:EventType<GridViewEvent<GridViewHeaderState>> = "headerTrigger";

	#if !flash
	private static var _cellPool = new ObjectPool<GridViewEvent<GridViewCellState>>(() -> return new GridViewEvent(null, null), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
		event.state = null;
	});

	private static var _headerPool = new ObjectPool<GridViewEvent<GridViewHeaderState>>(() -> return new GridViewEvent(null, null), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
		event.state = null;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```haxe
		GridViewEvent.dispatchForCell(component, GridViewEvent.CELL_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatchForCell(dispatcher:IEventDispatcher, type:String, state:GridViewCellState):Bool {
		#if flash
		var event = new GridViewEvent(type, state);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _cellPool.get();
		event.type = type;
		event.state = state;
		var result = dispatcher.dispatchEvent(event);
		_cellPool.release(event);
		return result;
		#end
	}

	/**
		Dispatches a pooled event with the specified properties.

		```haxe
		GridViewEvent.dispatchForHeader(component, GridViewEvent.HEADER_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatchForHeader(dispatcher:IEventDispatcher, type:String, state:GridViewHeaderState):Bool {
		#if flash
		var event = new GridViewEvent(type, state);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _headerPool.get();
		event.type = type;
		event.state = state;
		var result = dispatcher.dispatchEvent(event);
		_headerPool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `GridViewEvent` object with the given arguments.

		@see `GridViewEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, state:S) {
		super(type, false, false);
		this.state = state;
	}

	/**
		The current state of the cell or header associated with this event.

		@since 1.0.0
	**/
	public var state:S;

	override public function clone():Event {
		return new GridViewEvent(this.type, this.state);
	}
}
