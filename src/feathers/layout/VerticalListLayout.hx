/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.geom.Point;
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
class VerticalListLayout extends EventDispatcher implements IVirtualLayout {
	/**
		Creates a new `VerticalListLayout` object.

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

	/**
		@see `feathers.layout.IVirtualLayout.virtualCache`
	**/
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

		In the following example, the layout's requested row count is set to 2
		complete items:

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
		The space, in pixels, between the parent container's top edge and its
		content.

		In the following example, the layout's top padding is set to 20 pixels:

		```hx
		layout.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var paddingTop(default, set):Float = 0.0;

	private function set_paddingTop(value:Float):Float {
		if (this.paddingTop == value) {
			return this.paddingTop;
		}
		this.paddingTop = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingTop;
	}

	/**
		The space, in pixels, between the parent container's right edge and its
		content.

		In the following example, the layout's right padding is set to 20 pixels:

		```hx
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var paddingRight(default, set):Float = 0.0;

	private function set_paddingRight(value:Float):Float {
		if (this.paddingRight == value) {
			return this.paddingRight;
		}
		this.paddingRight = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingRight;
	}

	/**
		The space, in pixels, between the parent container's bottom edge and its
		content.

		In the following example, the layout's bottom padding is set to 20 pixels:

		```hx
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var paddingBottom(default, set):Float = 0.0;

	private function set_paddingBottom(value:Float):Float {
		if (this.paddingBottom == value) {
			return this.paddingBottom;
		}
		this.paddingBottom = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingBottom;
	}

	/**
		The space, in pixels, between the parent container's left edge and its
		content.

		In the following example, the layout's left padding is set to 20 pixels:

		```hx
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var paddingLeft(default, set):Float = 0.0;

	private function set_paddingLeft(value:Float):Float {
		if (this.paddingLeft == value) {
			return this.paddingLeft;
		}
		this.paddingLeft = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingLeft;
	}

	/**
		The space, in pixels, between each two adjacent items in the layout.

		In the following example, the layout's gap is set to 20 pixels:

		```hx
		layout.gap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var gap(default, set):Float = 0.0;

	private function set_gap(value:Float):Float {
		if (this.gap == value) {
			return this.gap;
		}
		this.gap = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.gap;
	}

	/**
		How the content is positioned vertically (along the y-axis) within the
		container.

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the bottom:

		```hx
		layout.verticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	public var verticalAlign(default, set):VerticalAlign = TOP;

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this.verticalAlign == value) {
			return this.verticalAlign;
		}
		this.verticalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.verticalAlign;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var viewPortWidth = this.calculateViewPortWidth(items, measurements);
		var itemWidth = viewPortWidth - this.paddingLeft - this.paddingRight;
		var virtualRowHeight = this.calculateVirtualRowHeight(items, itemWidth);
		var positionY = this.paddingTop;
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
				positionY += itemHeight + this.gap;
				continue;
			}
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = this.paddingLeft;
			item.y = positionY;
			item.width = itemWidth;
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					cacheItem = new VirtualCacheItem(itemHeight);
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				} else if (cacheItem.itemHeight != itemHeight) {
					cacheItem.itemHeight = itemHeight;
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			positionY += itemHeight + this.gap;
		}
		if (items.length > 0) {
			positionY -= this.gap;
		}
		positionY += this.paddingBottom;

		var viewPortHeight = positionY;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (this.requestedRowCount != null) {
				viewPortHeight = virtualRowHeight * this.requestedRowCount;
			}
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyVerticalAlign(items, positionY, viewPortHeight);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = viewPortWidth;
		result.contentHeight = positionY;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
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
		return maxWidth + this.paddingLeft + this.paddingRight;
	}

	private function calculateVirtualRowHeight(items:Array<DisplayObject>, itemWidth:Float):Float {
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
			item.width = itemWidth;
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

	/**
		@see `feathers.layout.IVirtualLayout.getVisibleIndices()`
	**/
	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var startIndex = -1;
		var endIndex = -1;
		var estimatedItemHeight:Null<Float> = null;
		var positionY = this.paddingTop;
		var scrollY = this.scrollY;
		if (scrollY < 0.0) {
			scrollY = 0.0;
		}
		var minItems = 0;
		var maxY = scrollY + height;
		for (i in 0...itemCount) {
			var itemHeight = 0.0;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					itemHeight = cacheItem.itemHeight;
					if (estimatedItemHeight == null) {
						estimatedItemHeight = itemHeight;
						minItems = Math.ceil(height / (estimatedItemHeight + this.gap)) + 1;
					}
				} else if (estimatedItemHeight != null) {
					itemHeight = estimatedItemHeight;
				}
			}
			positionY += itemHeight + this.gap;
			if (startIndex == -1 && positionY >= scrollY) {
				startIndex = i;
			}
			if (startIndex != -1) {
				endIndex = i;
				if (positionY >= maxY && (endIndex - startIndex + 1) >= minItems) {
					break;
				}
			}
		}
		// if we reached the end with extra space, try back-filling so that the
		// number of visible items remains mostly stable
		if ((positionY < maxY || (endIndex - startIndex + 1) < minItems) && startIndex > 0) {
			do {
				startIndex--;
				var itemHeight = 0.0;
				if (this.virtualCache != null) {
					var cacheItem = Std.downcast(this.virtualCache[startIndex], VirtualCacheItem);
					if (cacheItem != null) {
						itemHeight = cacheItem.itemHeight;
						if (estimatedItemHeight == null) {
							estimatedItemHeight = itemHeight;
							minItems = Math.ceil(height / (estimatedItemHeight + this.gap)) + 1;
						}
					} else if (estimatedItemHeight != null) {
						itemHeight = estimatedItemHeight;
					}
				}
				positionY += itemHeight + this.gap;
				if (positionY >= maxY && (endIndex - startIndex + 1) >= minItems) {
					break;
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

	/**
		@see `feathers.layout.IScrollLayout.getNearestScrollPositionForIndex()`
	**/
	public function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point {
		var estimatedItemHeight:Null<Float> = null;
		var minY = 0.0;
		var maxY = 0.0;
		var positionY = this.paddingTop;
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
			if (i == index) {
				maxY = positionY;
				minY = maxY + itemHeight - height;
				break;
			}
			positionY += itemHeight + this.gap;
		}

		var targetY = this.scrollY;
		if (targetY < minY) {
			targetY = minY;
		} else if (targetY > maxY) {
			targetY = maxY;
		}
		if (result == null) {
			result = new Point();
		}
		result.x = this.scrollX;
		result.y = targetY;
		return result;
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, contentHeight:Float, viewPortHeight:Float):Void {
		if (this.verticalAlign != BOTTOM && this.verticalAlign != MIDDLE) {
			return;
		}
		var maxAlignmentHeight = viewPortHeight - this.paddingTop - this.paddingBottom;
		if (contentHeight >= maxAlignmentHeight) {
			return;
		}
		var verticalOffset = 0.0;
		if (this.verticalAlign == BOTTOM) {
			verticalOffset = maxAlignmentHeight - contentHeight;
		} else if (this.verticalAlign == MIDDLE) {
			verticalOffset = (maxAlignmentHeight - contentHeight) / 2.0;
		}
		for (item in items) {
			if (item == null) {
				continue;
			}
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.y = Math.max(this.paddingTop, item.y + verticalOffset);
		}
	}
}

@:dox(hide)
private class VirtualCacheItem {
	public function new(itemHeight:Float) {
		this.itemHeight = itemHeight;
	}

	public var itemHeight:Float;
}
