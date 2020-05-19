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
		How the content is positioned horizontally (along the x-axis) within the
		container.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the right:

		```hx
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	public var horizontalAlign(default, set):HorizontalAlign = LEFT;

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this.horizontalAlign == value) {
			return this.horizontalAlign;
		}
		this.horizontalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.horizontalAlign;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var viewPortHeight = this.calculateViewPortHeight(items, measurements);
		var itemHeight = viewPortHeight - this.paddingTop - this.paddingBottom;
		var virtualColumnWidth = this.calculateVirtualColumnWidth(items, itemHeight);
		var positionX = this.paddingLeft;
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
				positionX += itemWidth + this.gap;
				continue;
			}
			if (Std.is(item, ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = positionX;
			item.y = this.paddingTop;
			item.height = itemHeight;
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					cacheItem = new VirtualCacheItem(itemWidth);
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				} else if (cacheItem.itemWidth != itemWidth) {
					cacheItem.itemWidth = itemWidth;
					this.virtualCache[i] = cacheItem;
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			positionX += itemWidth + this.gap;
		}
		if (items.length > 0) {
			positionX -= this.gap;
		}
		positionX += this.paddingRight;

		var viewPortWidth = positionX;
		if (measurements.height != null) {
			viewPortWidth = measurements.width;
		} else {
			if (this.requestedColumnCount != null) {
				viewPortWidth = virtualColumnWidth * this.requestedColumnCount;
			}
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}

		this.applyHorizontalAlign(items, positionX, viewPortWidth);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = positionX;
		result.contentHeight = viewPortHeight;
		result.viewPortHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
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
		return maxHeight + this.paddingTop + this.paddingBottom;
	}

	private function calculateVirtualColumnWidth(items:Array<DisplayObject>, itemHeight:Float):Float {
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
			item.height = itemHeight;
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

	/**
		@see `feathers.layout.IVirtualLayout.getVisibleIndices()`
	**/
	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var startIndex = -1;
		var endIndex = -1;
		var estimatedItemWidth:Null<Float> = null;
		var positionX = this.paddingLeft;
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
						minItems = Math.ceil(width / (estimatedItemWidth) + this.gap) + 1;
					}
				} else if (estimatedItemWidth != null) {
					itemWidth = estimatedItemWidth;
				}
			}
			positionX += itemWidth + this.gap;
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
							minItems = Math.ceil(width / (estimatedItemWidth) + this.gap) + 1;
						}
					} else if (estimatedItemWidth != null) {
						itemWidth = estimatedItemWidth;
					}
				}
				positionX += itemWidth + this.gap;
				if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
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
		var estimatedItemWidth:Null<Float> = null;
		var minX = 0.0;
		var maxX = 0.0;
		var positionX = this.paddingLeft;
		for (i in 0...itemCount) {
			var itemWidth = 0.0;
			if (this.virtualCache != null) {
				var cacheItem = Std.downcast(this.virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					itemWidth = cacheItem.itemWidth;
					if (estimatedItemWidth == null) {
						estimatedItemWidth = itemWidth;
					}
				} else if (estimatedItemWidth != null) {
					itemWidth = estimatedItemWidth;
				}
			}
			if (i == index) {
				maxX = positionX;
				minX = maxX + itemWidth - width;
				break;
			}
			positionX += itemWidth + this.gap;
		}

		var targetX = this.scrollX;
		if (targetX < minX) {
			targetX = minX;
		} else if (targetX > maxX) {
			targetX = maxX;
		}
		if (result == null) {
			result = new Point();
		}
		result.x = targetX;
		result.y = this.scrollY;
		return result;
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		if (this.horizontalAlign != RIGHT && this.horizontalAlign != CENTER) {
			return;
		}
		var maxAlignmentWidth = viewPortWidth - this.paddingLeft - this.paddingRight;
		if (contentWidth >= maxAlignmentWidth) {
			return;
		}
		var horizontalOffset = 0.0;
		if (this.horizontalAlign == RIGHT) {
			horizontalOffset = maxAlignmentWidth - contentWidth;
		} else if (this.horizontalAlign == CENTER) {
			horizontalOffset = (maxAlignmentWidth - contentWidth) / 2.0;
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
			item.x = Math.max(this.paddingLeft, item.x + horizontalOffset);
		}
	}
}

@:dox(hide)
private class VirtualCacheItem {
	public function new(itemWidth:Float) {
		this.itemWidth = itemWidth;
	}

	public var itemWidth:Float;
}
