/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	A simple list layout that positions items from top to bottom, in a single
	column, where every item fills the entire width of the container.

	If all items in the container should have the same height, consider using
	`VerticalListFixedRowLayout` instead. When a fixed height for items is
	known, that layout offers better performance optimization.

	@since 1.0.0
**/
class VerticalListVariableRowLayout extends EventDispatcher implements IScrollLayout {
	/**
		Creates a new `VerticalListVariableRowLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	/**
		@see `feathers.layout.IScrollLayout.scrollX`
	**/
	public var scrollX(default, set):Float = 0.0;

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.scrollX;
	}

	/**
		@see `feathers.layout.IScrollLayout.scrollY`
	**/
	public var scrollY(default, set):Float = 0.0;

	private function set_scrollY(value:Float):Float {
		if (this.scrollY == value) {
			return this.scrollY;
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.scrollY;
	}

	/**
		@see `feathers.layout.IScrollLayout.primaryDirection`
	**/
	public var primaryDirection(get, never):Direction;

	private function get_primaryDirection():Direction {
		return Direction.VERTICAL;
	}

	/**
		@see `feathers.layout.IScrollLayout.requiresLayoutOnScroll`
	**/
	public var requiresLayoutOnScroll(get, never):Bool;

	private function get_requiresLayoutOnScroll():Bool {
		return false;
	}

	/**
		The number of rows to render, if the height of the container has not
		been set explicitly. If `null`, shows all rows.

		In the following example, the layout's requested row count is set to 2 items:

		```hx
		layout.requestedRowCount = 2.0;
		```

		@default 5.0

		@since 1.0.0
	**/
	public var requestedRowCount(default, set):Null<Float> = 5.0;

	private function set_requestedRowCount(value:Null<Float>):Null<Float> {
		if (this.requestedRowCount == value) {
			return this.requestedRowCount;
		}
		this.requestedRowCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.requestedRowCount;
	}

	/**
		@see `feathers.layout.ILayout.layout`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var viewPortWidth = measurements.width;
		var maxWidth = 0.0;
		var estimatedItemHeight = 0.0;
		for (item in items) {
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (viewPortWidth == null && item.width > maxWidth) {
				maxWidth = item.width;
			}
			if (estimatedItemHeight == 0.0) {
				estimatedItemHeight = item.height;
			}
		}
		var itemWidth = maxWidth;
		if (viewPortWidth != null) {
			itemWidth = viewPortWidth;
		}
		var positionY = 0.0;
		for (item in items) {
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = 0.0;
			item.y = positionY;
			item.width = itemWidth;
			positionY += item.height;
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = itemWidth;
		result.contentHeight = positionY;
		if (viewPortWidth != null) {
			result.viewPortWidth = viewPortWidth;
		} else {
			result.viewPortWidth = itemWidth;
		}
		var viewPortHeight = measurements.height;
		if (viewPortHeight != null) {
			result.viewPortHeight = viewPortHeight;
		} else if (this.requestedRowCount != null) {
			result.viewPortHeight = estimatedItemHeight * this.requestedRowCount;
		} else {
			result.viewPortHeight = positionY;
		}
		return result;
	}
}
