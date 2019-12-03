/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

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

	@since 1.0.0
**/
class VerticalListFixedRowLayout extends EventDispatcher implements IScrollLayout {
	/**
		Creates a new `VerticalListFixedRowLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	/**
		@inheritDoc
	**/
	@:dox(hide)
	public var scrollX(default, set):Float = 0.0;

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.scrollX;
	}

	/**
		@inheritDoc
	**/
	@:dox(hide)
	public var scrollY(default, set):Float = 0.0;

	private function set_scrollY(value:Float):Float {
		if (this.scrollY == value) {
			return this.scrollY;
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.scrollY;
	}

	/**
		@inheritDoc
	**/
	@:dox(hide)
	public var primaryDirection(get, never):Direction;

	private function get_primaryDirection():Direction {
		return Direction.VERTICAL;
	}

	/**
		@inheritDoc
	**/
	@:dox(hide)
	public var requiresLayoutOnScroll(get, never):Bool;

	private function get_requiresLayoutOnScroll():Bool {
		return false;
	}

	/**
		The height to set on each item, or `null`, if the row height should be
		calculated automatically.

		@since 1.0.0
	**/
	public var rowHeight(default, set):Null<Float> = null;

	private function set_rowHeight(value:Null<Float>):Null<Float> {
		if (this.rowHeight == value) {
			return this.rowHeight;
		}
		this.rowHeight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.rowHeight;
	}

	/**
		The number of rows to render, if the height of the container has not
		been set explicitly. If `null`, shows all rows.

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
		@inheritDoc
	**/
	@:dox(hide)
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var viewPortWidth = measurements.width;
		var maxWidth:Float = 0.0;
		var maxHeight:Float = 0.0;
		if (viewPortWidth == null || this.rowHeight == null) {
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
				if (this.rowHeight == null && item.height > maxHeight) {
					maxHeight = item.height;
				}
			}
		}
		var itemWidth = maxWidth;
		if (viewPortWidth != null) {
			itemWidth = viewPortWidth;
		}
		var itemHeight = maxHeight;
		if (this.rowHeight != null) {
			itemHeight = this.rowHeight;
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
			item.height = itemHeight;
			positionY += itemHeight;
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
			result.viewPortHeight = itemHeight * this.requestedRowCount;
		} else {
			result.viewPortHeight = positionY;
		}
		return result;
	}
}
