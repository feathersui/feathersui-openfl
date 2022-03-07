/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.TreeGridViewHeaderState;
import openfl.events.IEventDispatcher;
import feathers.data.TreeGridViewCellState;
import openfl.events.EventType;
import openfl.events.Event;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#end

/**
	Events dispatched by the `TreeGridView` component.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
class TreeGridViewEvent<S> extends Event {
	/**
		The `TreeGridViewEvent.CELL_TRIGGER` event type is dispatched when a
		cell renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var CELL_TRIGGER:EventType<TreeGridViewEvent<TreeGridViewCellState>> = "cellTrigger";

	/**
		The `TreeGridViewEvent.HEADER_TRIGGER` event type is dispatched when a
		header renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var HEADER_TRIGGER:EventType<TreeGridViewEvent<TreeGridViewHeaderState>> = "headerTrigger";

	/**
		The `TreeGridViewEvent.BRANCH_OPEN` event type is dispatched when a
		branch is opened.

		@since 1.0.0
	**/
	public static inline var BRANCH_OPEN:EventType<TreeGridViewEvent<TreeGridViewCellState>> = "branchOpen";

	/**
		The `TreeGridViewEvent.BRANCH_CLOSE` event type is dispatched when a
		branch is closed.

		@since 1.0.0
	**/
	public static inline var BRANCH_CLOSE:EventType<TreeGridViewEvent<TreeGridViewCellState>> = "branchClose";

	#if !flash
	private static var _cellPool = new ObjectPool<TreeGridViewEvent<TreeGridViewCellState>>(() -> return new TreeGridViewEvent(null, null), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
		event.state = null;
	});

	private static var _headerPool = new ObjectPool<TreeGridViewEvent<TreeGridViewHeaderState>>(() -> return new TreeGridViewEvent(null, null), (event) -> {
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
		TreeGridViewEvent.dispatchForCell(component, TreeGridViewEvent.CELL_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatchForCell(dispatcher:IEventDispatcher, type:String, state:TreeGridViewCellState):Bool {
		#if flash
		var event = new TreeGridViewEvent(type, state);
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
		TreeGridViewEvent.dispatchForHeader(component, TreeGridViewEvent.HEADER_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatchForHeader(dispatcher:IEventDispatcher, type:String, state:TreeGridViewHeaderState):Bool {
		#if flash
		var event = new TreeGridViewEvent(type, state);
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
		Creates a new `TreeGridViewEvent` object with the given arguments.

		@see `TreeGridViewEvent.dispatch`

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
		return new TreeGridViewEvent(this.type, this.state);
	}
}
