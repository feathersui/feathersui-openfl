/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.layout.IVirtualLayout.VirtualLayoutRange;
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
class VerticalListVariableRowLayout extends EventDispatcher implements IVirtualLayout {
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
		var virtualRowHeight = this.calculateVirtualRowHeight(items, viewPortWidth);
		var positionY = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				var itemHeight = virtualRowHeight;
				if (this.virtualCache != null) {
					var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
					if (cacheItem != null) {
						itemHeight = cacheItem.itemHeight;
					}
				}
				positionY += itemHeight;
				continue;
			}
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = 0.0;
			item.y = positionY;
			item.width = viewPortWidth;
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					cacheItem = new VirtualCacheItem(virtualRowHeight);
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				} else if (cacheItem.itemHeight != virtualRowHeight) {
					cacheItem.itemHeight = virtualRowHeight;
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			positionY += itemHeight;
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = viewPortWidth;
		result.contentHeight = positionY;
		result.viewPortWidth = viewPortWidth;
		var viewPortHeight = measurements.height;
		if (viewPortHeight != null) {
			result.viewPortHeight = viewPortHeight;
		} else if (this.requestedRowCount != null) {
			result.viewPortHeight = virtualRowHeight * this.requestedRowCount;
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

	private function calculateVirtualRowHeight(items:Array<DisplayObject>, viewPortWidth:Float):Float {
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
				return cacheItem.itemHeight;
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
			return item.height;
		}
		return 0.0;
	}

	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var startIndex = -1;
		var endIndex = -1;
		var estimatedItemHeight:Null<Float> = null;
		var positionY = 0.0;
		var maxY = this.scrollY + height;
		for (i in 0...itemCount) {
			var itemHeight = 0.0;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					itemHeight = cacheItem.itemHeight;
					if (estimatedItemHeight == null) {
						estimatedItemHeight = itemHeight;
					}
				} else if (estimatedItemHeight != null) {
					itemHeight = estimatedItemHeight;
				}
			}
			if (itemHeight > 0.0) {
				positionY += itemHeight;
				if (startIndex == -1 && positionY >= this.scrollY) {
					startIndex = i;
				}
				if (startIndex != -1) {
					endIndex = i;
					if (positionY > maxY) {
						break;
					}
				}
			}
		}
		if (startIndex < 0) {
			startIndex = 0;
		}
		if (endIndex < 0) {
			endIndex = startIndex;
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
