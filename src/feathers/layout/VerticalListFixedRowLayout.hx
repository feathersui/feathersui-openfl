/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.geom.Point;
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
		var actualRowHeight = this.calculateRowHeight(items, itemWidth);
		var positionY = this.paddingTop;
		for (item in items) {
			if (item != null) {
				if (Std.is(item, ILayoutObject)) {
					if (!cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
				}
				item.x = this.paddingLeft;
				item.y = positionY;
				item.width = itemWidth;
				item.height = actualRowHeight;
			}
			positionY += actualRowHeight + this.gap;
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
				viewPortHeight = actualRowHeight * this.requestedRowCount;
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

	private function calculateRowHeight(items:Array<DisplayObject>, itemWidth:Float):Float {
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
					var cacheItem = Std.downcast(this.virtualCache[0], VirtualCacheItem);
					if (cacheItem == null) {
						continue;
					}
					actualRowHeight = cacheItem.itemHeight;
					break;
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

	/**
		@see `feathers.layout.IVirtualLayout.getVisibleIndices()`
	**/
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
		itemHeight += this.gap;
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

	/**
		@see `feathers.layout.IScrollLayout.getNearestScrollPositionForIndex()`
	**/
	public function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point {
		var itemHeight = 0.0;
		if (this.rowHeight != null) {
			itemHeight = this.rowHeight;
		} else if (this.virtualCache != null) {
			var cacheItem = Std.downcast(this.virtualCache[0], VirtualCacheItem);
			if (cacheItem != null) {
				itemHeight = cacheItem.itemHeight;
			}
		}
		itemHeight += this.gap;

		var maxY = this.paddingTop + (itemHeight * index);
		var minY = maxY + itemHeight - height;

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
