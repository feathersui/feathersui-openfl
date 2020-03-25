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
	A simple list layout that positions items from left to right, in a single
	row, where every item fills the entire height of the container.

	@since 1.0.0
**/
class HorizontalListLayout extends EventDispatcher implements IVirtualLayout {
	/**
		Creates a new `HorizontalListLayout` object.

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
		return Direction.HORIZONTAL;
	}

	/**
		@see `feathers.layout.IScrollLayout.requiresLayoutOnScroll`
	**/
	public var requiresLayoutOnScroll(get, never):Bool;

	private function get_requiresLayoutOnScroll():Bool {
		return true;
	}

	/**
		The number of columns to render, if the width of the container has not
		been set explicitly. If `null`, shows all columns.

		In the following example, the layout's requested column count is set to
		2 complete items:

		```hx
		layout.requestedColumnCount = 2.0;
		```

		@default 5.0

		@since 1.0.0
	**/
	public var requestedColumnCount(default, set):Null<Float> = 5.0;

	private function set_requestedColumnCount(value:Null<Float>):Null<Float> {
		if (this.requestedColumnCount == value) {
			return this.requestedColumnCount;
		}
		this.requestedColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.requestedColumnCount;
	}

	/**
		@see `feathers.layout.ILayout.layout`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var viewPortHeight = this.calculateViewPortHeight(items, measurements);
		var virtualColumnWidth = this.calculateVirtualColumnWidth(items, viewPortHeight);
		var positionX = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				var itemWidth = virtualColumnWidth;
				if (this.virtualCache != null) {
					var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
					if (cacheItem != null) {
						itemWidth = cacheItem.itemWidth;
					}
				}
				positionX += itemWidth;
				continue;
			}
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = positionX;
			item.y = 0.0;
			item.height = viewPortHeight;
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					cacheItem = new VirtualCacheItem(virtualColumnWidth);
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				} else if (cacheItem.itemWidth != virtualColumnWidth) {
					cacheItem.itemWidth = virtualColumnWidth;
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			positionX += itemWidth;
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = positionX;
		result.contentHeight = viewPortHeight;
		result.viewPortHeight = viewPortHeight;
		var viewPortWidth = measurements.width;
		if (viewPortWidth != null) {
			result.viewPortWidth = viewPortWidth;
		} else if (this.requestedColumnCount != null) {
			result.viewPortWidth = virtualColumnWidth * this.requestedColumnCount;
		} else {
			result.viewPortWidth = positionX;
		}
		return result;
	}

	private function calculateViewPortHeight(items:Array<DisplayObject>, measurements:Measurements):Float {
		if (measurements.height != null) {
			return measurements.height;
		}
		var maxHeight = 0.0;
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
			var itemHeight = item.height;
			if (maxHeight < itemHeight) {
				maxHeight = itemHeight;
			}
		}
		return maxHeight;
	}

	private function calculateVirtualColumnWidth(items:Array<DisplayObject>, viewPortHeight:Float):Float {
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
				return cacheItem.itemWidth;
			}
			item.height = viewPortHeight;
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			return item.width;
		}
		return 0.0;
	}

	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var startIndex = -1;
		var endIndex = -1;
		var estimatedItemWidth:Null<Float> = null;
		var positionX = 0.0;
		var scrollX = this.scrollX;
		if (scrollX < 0.0) {
			scrollX = 0.0;
		}
		var minItems = 0;
		var maxX = scrollX + width;
		for (i in 0...itemCount) {
			var itemWidth = 0.0;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					itemWidth = cacheItem.itemWidth;
					if (estimatedItemWidth == null) {
						estimatedItemWidth = itemWidth;
						minItems = Math.ceil(width / estimatedItemWidth) + 1;
					}
				} else if (estimatedItemWidth != null) {
					itemWidth = estimatedItemWidth;
				}
			}
			if (itemWidth > 0.0) {
				positionX += itemWidth;
				if (startIndex == -1 && positionX >= scrollX) {
					startIndex = i;
				}
				if (startIndex != -1) {
					endIndex = i;
					if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
						break;
					}
				}
			}
		}
		// if we reached the end with extra space, try back-filling so that the
		// number of visible items remains mostly stable
		if ((positionX < maxX || (endIndex - startIndex + 1) < minItems) && startIndex > 0) {
			do {
				startIndex--;
				var itemWidth = 0.0;
				if (this.virtualCache != null) {
					var cacheItem = Std.downcast(this.virtualCache[startIndex], VirtualCacheItem);
					if (cacheItem != null) {
						itemWidth = cacheItem.itemWidth;
						if (estimatedItemWidth == null) {
							estimatedItemWidth = itemWidth;
							minItems = Math.ceil(width / estimatedItemWidth) + 1;
						}
					} else if (estimatedItemWidth != null) {
						itemWidth = estimatedItemWidth;
					}
				}
				if (itemWidth > 0.0) {
					positionX += itemWidth;
					if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
						break;
					}
				}
			} while (startIndex > 0);
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
	public function new(itemWidth:Float) {
		this.itemWidth = itemWidth;
	}

	public var itemWidth:Float;
}
