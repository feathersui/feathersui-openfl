/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.IVirtualLayout.VirtualLayoutRange;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;

/**
	A simple list layout that positions items from top to bottom, in a single
	column, where every item has the same width and height. The items fill the
	entire width of the container. The height of items is determined by the
	measured height of the first item, or it may be overridden using the
	`rowHeight` property.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class VerticalListFixedRowLayout extends EventDispatcher implements IVirtualLayout implements IKeyboardNavigationLayout {
	/**
		Creates a new `VerticalListFixedRowLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _scrollX:Float = 0.0;

	/**
		@see `feathers.layout.IScrollLayout.scrollX`
	**/
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		this._scrollX = value;
		return this._scrollX;
	}

	private var _scrollY:Float = 0.0;

	/**
		@see `feathers.layout.IScrollLayout.scrollY`
	**/
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		return this._scrollY;
	}

	private function set_scrollY(value:Float):Float {
		this._scrollY = value;
		return this._scrollY;
	}

	private var _virtualCache:Array<Dynamic>;

	/**
		@see `feathers.layout.IVirtualLayout.virtualCache`
	**/
	public var virtualCache(get, set):Array<Dynamic>;

	private function get_virtualCache():Array<Dynamic> {
		return this._virtualCache;
	}

	private function set_virtualCache(value:Array<Dynamic>):Array<Dynamic> {
		this._virtualCache = value;
		return this._virtualCache;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticTop`
	**/
	public var elasticTop(get, never):Bool;

	private function get_elasticTop():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticRight`
	**/
	public var elasticRight(get, never):Bool;

	private function get_elasticRight():Bool {
		return false;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticBottom`
	**/
	public var elasticBottom(get, never):Bool;

	private function get_elasticBottom():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticLeft`
	**/
	public var elasticLeft(get, never):Bool;

	private function get_elasticLeft():Bool {
		return false;
	}

	private var _rowHeight:Null<Float> = null;

	/**
		The height to set on each item, or `null`, if the row height should be
		calculated automatically.

		In the following example, the layout's row height is set to 20 pixels:

		```haxe
		layout.rowHeight = 20.0;
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var rowHeight(get, set):Null<Float>;

	private function get_rowHeight():Null<Float> {
		return this._rowHeight;
	}

	private function set_rowHeight(value:Null<Float>):Null<Float> {
		if (this._rowHeight == value) {
			return this._rowHeight;
		}
		this._rowHeight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._rowHeight;
	}

	private var _requestedRowCount:Null<Float> = null;

	/**
		The exact number of rows to render, if the height of the container has
		not been set explicitly. If `null`, falls back to `requestedMinRowCount`
		and `requestedMaxRowCount`.

		In the following example, the layout's requested row count is set to 2 items:

		```haxe
		layout.requestedRowCount = 2.0;
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var requestedRowCount(get, set):Null<Float>;

	private function get_requestedRowCount():Null<Float> {
		return this._requestedRowCount;
	}

	private function set_requestedRowCount(value:Null<Float>):Null<Float> {
		if (this._requestedRowCount == value) {
			return this._requestedRowCount;
		}
		this._requestedRowCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedRowCount;
	}

	private var _requestedMinRowCount:Null<Float> = null;

	/**
		The minimum number of rows to render, if the height of the container has
		not been set explicitly. If `null`, this property is ignored.

		If `requestedRowCount` is also set, this property is ignored.

		In the following example, the layout's requested minimum row count is
		set to 2 complete items:

		```haxe
		layout.requestedMinRowCount = 2.0;
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var requestedMinRowCount(get, set):Null<Float>;

	private function get_requestedMinRowCount():Null<Float> {
		return this._requestedMinRowCount;
	}

	private function set_requestedMinRowCount(value:Null<Float>):Null<Float> {
		if (this._requestedMinRowCount == value) {
			return this._requestedMinRowCount;
		}
		this._requestedMinRowCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMinRowCount;
	}

	private var _requestedMaxRowCount:Null<Float> = null;

	/**
		The maximum number of rows to render, if the height of the container has
		not been set explicitly. If `null`, the maximum number of rows is the
		total number of items displayed by the layout.

		If `requestedRowCount` is also set, this property is ignored.

		In the following example, the layout's requested maximum row count is
		set to 5 complete items:

		```haxe
		layout.requestedMaxRowCount = 5.0;
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var requestedMaxRowCount(get, set):Null<Float>;

	private function get_requestedMaxRowCount():Null<Float> {
		return this._requestedMaxRowCount;
	}

	private function set_requestedMaxRowCount(value:Null<Float>):Null<Float> {
		if (this._requestedMaxRowCount == value) {
			return this._requestedMaxRowCount;
		}
		this._requestedMaxRowCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMaxRowCount;
	}

	private var _paddingTop:Float = 0.0;

	/**
		The space, in pixels, between the parent container's top edge and its
		content.

		In the following example, the layout's top padding is set to 20 pixels:

		```haxe
		layout.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingTop(get, set):Float;

	private function get_paddingTop():Float {
		return this._paddingTop;
	}

	private function set_paddingTop(value:Float):Float {
		if (this._paddingTop == value) {
			return this._paddingTop;
		}
		this._paddingTop = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingTop;
	}

	private var _paddingRight:Float = 0.0;

	/**
		The space, in pixels, between the parent container's right edge and its
		content.

		In the following example, the layout's right padding is set to 20 pixels:

		```haxe
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingRight(get, set):Float;

	private function get_paddingRight():Float {
		return this._paddingRight;
	}

	private function set_paddingRight(value:Float):Float {
		if (this._paddingRight == value) {
			return this._paddingRight;
		}
		this._paddingRight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingRight;
	}

	private var _paddingBottom:Float = 0.0;

	/**
		The space, in pixels, between the parent container's bottom edge and its
		content.

		In the following example, the layout's bottom padding is set to 20 pixels:

		```haxe
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingBottom(get, set):Float;

	private function get_paddingBottom():Float {
		return this._paddingBottom;
	}

	private function set_paddingBottom(value:Float):Float {
		if (this._paddingBottom == value) {
			return this._paddingBottom;
		}
		this._paddingBottom = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingBottom;
	}

	private var _paddingLeft:Float = 0.0;

	/**
		The space, in pixels, between the parent container's left edge and its
		content.

		In the following example, the layout's left padding is set to 20 pixels:

		```haxe
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var paddingLeft(get, set):Float;

	private function get_paddingLeft():Float {
		return this._paddingLeft;
	}

	private function set_paddingLeft(value:Float):Float {
		if (this._paddingLeft == value) {
			return this._paddingLeft;
		}
		this._paddingLeft = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingLeft;
	}

	private var _gap:Float = 0.0;

	/**
		The space, in pixels, between each two adjacent items in the layout.

		If the `gap` is set to `Math.POSITIVE_INFINITY`, the items will be
		positioned as far apart as possible. In this case, the gap will never be
		smaller than `minGap`.

		In the following example, the layout's gap is set to 20 pixels:

		```haxe
		layout.gap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var gap(get, set):Float;

	private function get_gap():Float {
		return this._gap;
	}

	private function set_gap(value:Float):Float {
		if (this._gap == value) {
			return this._gap;
		}
		this._gap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._gap;
	}

	private var _minGap:Float = 0.0;

	/**
		If the value of the `gap` property is `Math.POSITIVE_INFINITY`, meaning
		that the gap will fill as much space as possible and position the items
		as far from each other as they can go without going outside of the view
		port bounds, the final calculated value of the gap will not be smaller
		than the value of the `minGap` property.

		In the following example, the layout's minimum gap is set to 4 pixels:

		```haxe
		layout.minGap = 4.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var minGap(get, set):Float;

	private function get_minGap():Float {
		return this._minGap;
	}

	private function set_minGap(value:Float):Float {
		if (this._minGap == value) {
			return this._minGap;
		}
		this._minGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._minGap;
	}

	private var _verticalAlign:VerticalAlign = TOP;

	/**
		How the content is positioned vertically (along the y-axis) within the
		container. If the total height of the content is larger than the
		available height within the container, then the positioning of the items
		will always start from the top.

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the bottom:

		```haxe
		layout.verticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	@:bindable("change")
	public var verticalAlign(get, set):VerticalAlign;

	private function get_verticalAlign():VerticalAlign {
		return this._verticalAlign;
	}

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this._verticalAlign == value) {
			return this._verticalAlign;
		}
		this._verticalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._verticalAlign;
	}

	private var _contentJustify:Bool = false;

	/**
		When `contentJustify` is `true`, the width of the items is set to
		either the explicit width of the container, or the maximum width of
		all items, whichever is larger. When `false`, the width of the items
		is set to the explicit width of the container, even if the items are
		measured to be larger.

		@since 1.0.0
	**/
	@:bindable("change")
	public var contentJustify(get, set):Bool;

	private function get_contentJustify():Bool {
		return this._contentJustify;
	}

	private function set_contentJustify(value:Bool):Bool {
		if (this._contentJustify == value) {
			return this._contentJustify;
		}
		this._contentJustify = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._contentJustify;
	}

	/**
		Sets all four padding properties to the same value.

		@see `VerticalListFixedRowLayout.paddingTop`
		@see `VerticalListFixedRowLayout.paddingRight`
		@see `VerticalListFixedRowLayout.paddingBottom`
		@see `VerticalListFixedRowLayout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var maxItemWidth = this.calculateMaxItemWidth(items, measurements);
		var viewPortWidth = this.calculateViewPortWidth(maxItemWidth, measurements);
		var minItemWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		var itemWidth = maxItemWidth;
		if (!this._contentJustify || itemWidth < minItemWidth) {
			itemWidth = minItemWidth;
		}
		var actualRowHeight = this.calculateRowHeight(items, itemWidth);
		var positionY = this._paddingTop;
		for (item in items) {
			if (item != null) {
				if ((item is ILayoutObject)) {
					if (!cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
				}
				item.x = this._paddingLeft;
				item.y = positionY;
				item.width = itemWidth;
				item.height = actualRowHeight;
			}
			positionY += actualRowHeight + adjustedGap;
		}
		if (items.length > 0) {
			positionY -= adjustedGap;
		}
		positionY += this._paddingBottom;

		var viewPortHeight = positionY;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (this._requestedRowCount != null) {
				viewPortHeight = this._paddingTop + this._paddingBottom + ((this._requestedRowCount * (actualRowHeight + adjustedGap)) - adjustedGap);
			} else {
				if (this._requestedMinRowCount != null && items.length < this._requestedMinRowCount) {
					viewPortHeight = this._paddingTop + this._paddingBottom + ((this._requestedMinRowCount * (actualRowHeight + adjustedGap)) - adjustedGap);
				} else if (this._requestedMaxRowCount != null && items.length > this._requestedMaxRowCount) {
					viewPortHeight = this._paddingTop + this._paddingBottom + ((this._requestedMaxRowCount * (actualRowHeight + adjustedGap)) - adjustedGap);
				}
			}
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyVerticalAlign(items, positionY - this._paddingTop - this._paddingBottom, viewPortHeight);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = itemWidth + this._paddingLeft + this._paddingRight;
		result.contentHeight = positionY;
		if (this._requestedMinRowCount != null) {
			result.contentMinHeight = this._paddingTop + this._paddingBottom + ((this._requestedMinRowCount * (actualRowHeight + adjustedGap)) - adjustedGap);
		}
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private function calculateMaxItemWidth(items:Array<DisplayObject>, measurements:Measurements):Float {
		var maxItemWidth = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if (this._virtualCache != null && this._virtualCache.length > i) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					// prefer the cached width because that's the original
					// measured width and not the justified width
					var itemWidth = cacheItem.itemWidth;
					if (maxItemWidth < itemWidth) {
						maxItemWidth = itemWidth;
					}
					continue;
				}
			}
			if (item == null) {
				continue;
			}
			if ((item is ILayoutObject)) {
				if (!cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (maxItemWidth < itemWidth) {
				maxItemWidth = itemWidth;
			}
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					if ((item is IValidating)) {
						cast(item, IValidating).validateNow();
					}
					// save the original measured width in the cache to be used
					// again in future calculations
					cacheItem = new VirtualCacheItem(itemWidth, 0.0);
					this._virtualCache[i] = cacheItem;
				}
			}
		}
		if (measurements.maxWidth != null) {
			var maxJustifyWidth = measurements.maxWidth - this._paddingLeft - this._paddingRight;
			if (maxItemWidth > maxJustifyWidth) {
				maxItemWidth = maxJustifyWidth;
			}
		}
		return maxItemWidth;
	}

	private function calculateViewPortWidth(maxItemWidth:Float, measurements:Measurements):Float {
		if (measurements.width != null) {
			return measurements.width;
		}
		return maxItemWidth + this._paddingLeft + this._paddingRight;
	}

	private function calculateRowHeight(items:Array<DisplayObject>, itemWidth:Float):Float {
		var actualRowHeight = 0.0;
		if (this._rowHeight != null) {
			actualRowHeight = this._rowHeight;
		} else {
			// find the height of the first existing item
			for (i in 0...items.length) {
				var item = items[i];
				if (item == null) {
					if (this._virtualCache == null || this._virtualCache.length <= i) {
						continue;
					}
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem == null) {
						continue;
					}
					// use the last known row height, if available
					actualRowHeight = cacheItem.itemHeight;
					break;
				}
				if ((item is ILayoutObject)) {
					if (!cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
				}
				item.width = itemWidth;
				if ((item is IValidating)) {
					cast(item, IValidating).validateNow();
				}
				actualRowHeight = item.height;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemHeight != actualRowHeight) {
						cacheItem.itemHeight = actualRowHeight;
						this._virtualCache[i] = cacheItem;
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
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var itemHeight = 0.0;
		if (this._rowHeight != null) {
			itemHeight = this._rowHeight;
		} else if (this._virtualCache != null) {
			for (cacheItem in this._virtualCache) {
				if (cacheItem != null) {
					itemHeight = cacheItem.itemHeight;
					break;
				}
			}
		}
		itemHeight += adjustedGap;
		var startIndex = 0;
		var endIndex = 0;
		if (itemHeight > 0.0) {
			startIndex = Math.floor((this._scrollY - this._paddingTop) / itemHeight);
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
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var itemHeight = 0.0;
		if (this._rowHeight != null) {
			itemHeight = this._rowHeight;
		} else if (this._virtualCache != null) {
			for (cacheItem in this._virtualCache) {
				if (cacheItem != null) {
					itemHeight = cacheItem.itemHeight;
					break;
				}
			}
		}
		itemHeight += adjustedGap;

		var maxY = this._paddingTop + (itemHeight * index);
		var minY = maxY + itemHeight - height;

		var targetY = this._scrollY;
		if (targetY < minY) {
			targetY = minY;
		} else if (targetY > maxY) {
			targetY = maxY;
		}
		if (result == null) {
			result = new Point();
		}
		result.x = this._scrollX;
		result.y = targetY;
		return result;
	}

	/**
		@see `feathers.layout.IKeyboardNavigationLayout.findNextKeyboardIndex()`
	**/
	public function findNextKeyboardIndex(startIndex:Int, event:KeyboardEvent, wrapArrowKeys:Bool, items:Array<DisplayObject>, indicesToSkip:Array<Int>,
			viewPortWidth:Float, viewPortHeight:Float):Int {
		if (items.length == 0) {
			return -1;
		}

		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var itemHeight = 0.0;
		if (this._rowHeight != null) {
			itemHeight = this._rowHeight;
		} else if (this._virtualCache != null) {
			for (cacheItem in this._virtualCache) {
				if (cacheItem != null) {
					itemHeight = cacheItem.itemHeight;
					break;
				}
			}
		}

		var maxIndex = items.length - 1;
		var result = startIndex;
		if (result == -1) {
			result = switch (event.keyCode) {
				case Keyboard.UP: wrapArrowKeys ? maxIndex : -1;
				case Keyboard.DOWN: 0;
				default: -1;
			}
			if (result == -1) {
				return result;
			}
			if (indicesToSkip == null || indicesToSkip.indexOf(result) == -1) {
				return result;
			}
			// otherwise, keep looking for the first valid index
		}

		var needsAnotherPass = true;
		var nextKeyCode = event.keyCode;
		var lastResult = result;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			switch (nextKeyCode) {
				case Keyboard.UP:
					result = result - 1;
				case Keyboard.DOWN:
					result = result + 1;
				case Keyboard.PAGE_UP:
					var yPosition = 0.0;
					var i = startIndex;
					while (i >= 0) {
						yPosition += itemHeight;
						if (indicesToSkip != null && indicesToSkip.indexOf(i) != -1) {
							yPosition += adjustedGap;
							i--;
							continue;
						}
						if (yPosition > viewPortHeight) {
							break;
						}
						yPosition += adjustedGap;
						result = i;
						i--;
					}
					nextKeyCode = Keyboard.UP;
				case Keyboard.PAGE_DOWN:
					var yPosition = 0.0;
					for (i in startIndex...items.length) {
						yPosition += itemHeight;
						if (indicesToSkip != null && indicesToSkip.indexOf(i) != -1) {
							yPosition += adjustedGap;
							continue;
						}
						if (yPosition > viewPortHeight) {
							break;
						}
						yPosition += adjustedGap;
						result = i;
					}
					nextKeyCode = Keyboard.DOWN;
				case Keyboard.HOME:
					for (i in 0...startIndex) {
						if (indicesToSkip == null || indicesToSkip.indexOf(i) == -1) {
							result = i;
							break;
						}
					}
				case Keyboard.END:
					var i = maxIndex;
					while (i > startIndex) {
						if (indicesToSkip == null || indicesToSkip.indexOf(i) == -1) {
							result = i;
							break;
						}
						i--;
					}
				default:
					// not keyboard navigation
					return startIndex;
			}
			if (result < 0) {
				if (wrapArrowKeys) {
					result = maxIndex;
				} else {
					result = 0;
				}
			} else if (result > maxIndex) {
				if (wrapArrowKeys) {
					result = 0;
				} else {
					result = maxIndex;
				}
			}
			if (indicesToSkip != null && indicesToSkip.indexOf(result) != -1) {
				// keep going until we reach a valid index
				if (result == lastResult) {
					// but don't keep trying if we got the same result more than
					// once because it means that we got stuck
					return startIndex;
				}
				needsAnotherPass = true;
			}
			lastResult = result;
		}
		return result;
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, contentHeight:Float, viewPortHeight:Float):Void {
		var alignOffset = 0.0;
		var gapOffset = 0.0;
		var maxAlignmentHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
			if (items.length > 1 && maxAlignmentHeight > contentHeight) {
				adjustedGap += (maxAlignmentHeight - contentHeight) / (items.length - 1);
			}
			gapOffset = adjustedGap - this._minGap;
		} else {
			alignOffset = switch (this._verticalAlign) {
				case TOP: 0.0;
				case BOTTOM: maxAlignmentHeight - contentHeight;
				case MIDDLE: (maxAlignmentHeight - contentHeight) / 2.0;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
			}
			if (alignOffset < 0.0) {
				alignOffset = 0.0;
			}
		}
		if (alignOffset == 0.0 && gapOffset == 0.0) {
			return;
		}

		var totalOffset = alignOffset;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if (item != null) {
				item.y = Math.max(this._paddingTop, item.y + totalOffset);
			}
			totalOffset += gapOffset;
		}
	}
}

@:dox(hide)
private class VirtualCacheItem {
	public function new(itemWidth:Float, itemHeight:Float) {
		this.itemWidth = itemWidth;
		this.itemHeight = itemHeight;
	}

	public var itemWidth:Float;
	public var itemHeight:Float;
}
