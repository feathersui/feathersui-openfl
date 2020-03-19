/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.IVirtualLayout.VirtualLayoutRange;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	A simple list layout that positions items from top to bottom, in a single
	column, where every item has the same width and height. The items fill the
	entire width of the container. The height of items is determined by the
	measured height of the first item, or it may be overridden using the
	`rowHeight` property.

	@since 1.0.0
**/
class VerticalListFixedRowLayout extends EventDispatcher implements IVirtualLayout {
	/**
		Creates a new `VerticalListFixedRowLayout` object.

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
		this.scrollX = value;
		return this.scrollX;
	}

	/**
		@see `feathers.layout.IScrollLayout.scrollY`
	**/
	public var scrollY(default, set):Float = 0.0;

	private function set_scrollY(value:Float):Float {
		this.scrollY = value;
		return this.scrollY;
	}

	@:isVar
	public var virtualCache(get, set):Array<Dynamic>;

	private function get_virtualCache():Array<Dynamic> {
		return this.virtualCache;
	}

	private function set_virtualCache(value:Array<Dynamic>):Array<Dynamic> {
		this.virtualCache = value;
		return this.virtualCache;
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
		return true;
	}

	/**
		The height to set on each item, or `null`, if the row height should be
		calculated automatically.

		In the following example, the layout's row height is set to 20 pixels:

		```hx
		layout.rowHeight = 20.0;
		```

		@default null

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
		var viewPortWidth = this.calculateViewPortWidth(items, measurements);
		var actualRowHeight = this.calculateRowHeight(items, viewPortWidth);
		var positionY = 0.0;
		for (item in items) {
			if (item != null) {
				if (Std.is(item, ILayoutObject)) {
					if (!cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
				}
				item.x = 0.0;
				item.y = positionY;
				item.width = viewPortWidth;
				item.height = actualRowHeight;
			}
			positionY += actualRowHeight;
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = viewPortWidth;
		result.contentHeight = items.length * actualRowHeight;
		result.viewPortWidth = viewPortWidth;
		var viewPortHeight = measurements.height;
		if (viewPortHeight != null) {
			result.viewPortHeight = viewPortHeight;
		} else if (this.requestedRowCount != null) {
			result.viewPortHeight = actualRowHeight * this.requestedRowCount;
		} else {
			result.viewPortHeight = positionY;
		}
		return result;
	}

	private function calculateViewPortWidth(items:Array<DisplayObject>, measurements:Measurements):Float {
		if (measurements.width != null) {
			return measurements.width;
		}
		var maxWidth = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				continue;
			}
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (itemWidth > maxWidth) {
				maxWidth = itemWidth;
			}
		}
		return maxWidth;
	}

	private function calculateRowHeight(items:Array<DisplayObject>, viewPortWidth:Float):Float {
		var actualRowHeight = 0.0;
		if (this.rowHeight != null) {
			actualRowHeight = this.rowHeight;
		} else {
			// find the height of the first existing item
			for (i in 0...items.length) {
				var item = items[i];
				if (item == null) {
					if (this.virtualCache == null || virtualCache.length <= i) {
						continue;
					}
					var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
					if (cacheItem == null) {
						continue;
					}
					actualRowHeight = cacheItem.itemHeight;
					break;
				}
				item.width = viewPortWidth;
				if (Std.is(item, ILayoutObject)) {
					if (!cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
				}
				if (Std.is(item, IValidating)) {
					cast(item, IValidating).validateNow();
				}
				actualRowHeight = item.height;
				if (this.virtualCache != null) {
					// since all items are the same height, we can store just
					// one value as an optimization
					var cacheItem = Std.downcast(this.virtualCache[0], VirtualCacheItem);
					if (cacheItem == null) {
						cacheItem = new VirtualCacheItem(actualRowHeight);
						this.virtualCache[0] = cacheItem;
						FeathersEvent.dispatch(this, Event.CHANGE);
					} else if (cacheItem.itemHeight != actualRowHeight) {
						cacheItem.itemHeight = actualRowHeight;
						this.virtualCache[0] = cacheItem;
						FeathersEvent.dispatch(this, Event.CHANGE);
					}
					// changing the item height in the cache may affect the
					// number of items that are visible, so we dispatch
					// Event.CHANGE need to check that again
				}
				break;
			}
		}
		return actualRowHeight;
	}

	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var itemHeight = 0.0;
		if (this.rowHeight != null) {
			itemHeight = this.rowHeight;
		} else if (this.virtualCache != null) {
			var cacheItem = Std.downcast(this.virtualCache[0], VirtualCacheItem);
			if (cacheItem != null) {
				itemHeight = cacheItem.itemHeight;
			}
		}
		var startIndex = 0;
		var endIndex = 0;
		if (itemHeight > 0.0) {
			startIndex = Math.floor(this.scrollY / itemHeight);
			if (startIndex < 0) {
				startIndex = 0;
			}
			endIndex = startIndex + Math.ceil(height / itemHeight);
			if (endIndex >= itemCount) {
				var oldEndIndex = endIndex;
				endIndex = itemCount - 1;
				// for performance reasons, it's better to always display the same
				// number of items, even if we technically don't need that many
				startIndex -= (oldEndIndex - endIndex);
				if (startIndex < 0) {
					startIndex = 0;
				}
			}
		}
		if (result == null) {
			return new VirtualLayoutRange(startIndex, endIndex);
		}
		result.start = startIndex;
		result.end = endIndex;
		return result;
	}
}

@:dox(hide)
private class VirtualCacheItem {
	public function new(itemHeight:Float) {
		this.itemHeight = itemHeight;
	}

	public var itemHeight:Float;
}
