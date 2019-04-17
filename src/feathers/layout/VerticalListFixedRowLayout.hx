/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	A simple list layout that positions items from top to bottom, in a single
	column, where every item fills the entire width of the container.

	@since 1.0.0
**/
class VerticalListFixedRowLayout extends EventDispatcher implements IScrollLayout {
	public var scrollX(default, set):Float = 0.0;

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.scrollX;
	}

	public var scrollY(default, set):Float = 0.0;

	private function set_scrollY(value:Float):Float {
		if (this.scrollY == value) {
			return this.scrollY;
		}
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.scrollY;
	}

	/**
		The height to set on each item, or `null`, if the row height should be
		calculated automatically.
	**/
	public var rowHeight(default, set):Null<Float> = null;

	private function set_rowHeight(value:Null<Float>):Null<Float> {
		if (this.rowHeight == value) {
			return this.rowHeight;
		}
		this.rowHeight = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.rowHeight;
	}

	/**
		The number of rows to render, if the height of the container has not
		been set explicitly. If `null`, shows all rows.
	**/
	public var requestedRowCount(default, set):Null<Int> = 5;

	private function set_requestedRowCount(value:Null<Int>):Null<Int> {
		if (this.requestedRowCount == value) {
			return this.requestedRowCount;
		}
		this.requestedRowCount = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.requestedRowCount;
	}

	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var viewPortWidth = measurements.width;
		var maxWidth:Float = 0.0;
		var maxHeight:Float = 0.0;
		if (viewPortWidth == null || this.rowHeight == null) {
			for (i in 0...items.length) {
				var item = items[i];
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
		for (i in 0...items.length) {
			var item = items[i];
			item.x = 0;
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
