/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.events.ScrollEvent;
import feathers.layout.IVirtualLayout.VirtualLayoutRange;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

/**
	A simple list layout that positions items from top to bottom, in a single
	column, where every item fills the entire width of the container.

	If all items in the container should have the same height, consider using
	`VerticalListFixedRowLayout` instead. When a fixed height for items is
	known, that layout offers better performance optimization.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class VerticalListLayout extends EventDispatcher implements IVirtualLayout implements IKeyboardNavigationLayout implements IDragDropLayout {
	/**
		Creates a new `VerticalListLayout` object.

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

	private var _requestedRowCount:Null<Float> = null;

	/**
		The exact number of rows to render, if the height of the container has
		not been set explicitly. If `null`, falls back to `requestedMinRowCount`
		and `requestedMaxRowCount`.

		In the following example, the layout's requested row count is set to 2
		complete items:

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

	private var _widthResetEnabled:Bool = true;

	/**
		Indicates if the width of items should be reset if the explicit width of
		the parent container is not set.

		@since 1.0.0
	**/
	@:bindable("change")
	public var widthResetEnabled(get, set):Bool;

	private function get_widthResetEnabled():Bool {
		return this._widthResetEnabled;
	}

	private function set_widthResetEnabled(value:Bool):Bool {
		if (this._widthResetEnabled == value) {
			return this._widthResetEnabled;
		}
		this._widthResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._widthResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `VerticalListLayout.paddingTop`
		@see `VerticalListLayout.paddingRight`
		@see `VerticalListLayout.paddingBottom`
		@see `VerticalListLayout.paddingLeft`

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
		if (minItemWidth < 0.0) {
			minItemWidth = 0.0;
		}
		var itemWidth = maxItemWidth;
		if (!this._contentJustify || itemWidth < minItemWidth) {
			itemWidth = minItemWidth;
		}
		var virtualRowHeight = this.calculateVirtualRowHeight(items, itemWidth);
		var positionY = this._paddingTop;
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				var itemHeight = virtualRowHeight;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemHeight != null) {
						itemHeight = cacheItem.itemHeight;
					}
				}
				positionY += itemHeight + adjustedGap;
				continue;
			}
			if ((item is ILayoutObject)) {
				if (!(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = this._paddingLeft;
			item.y = positionY;
			item.width = itemWidth;
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && (cacheItem.itemHeight == null || cacheItem.itemHeight != itemHeight)) {
					var cachedHeight = cacheItem.itemHeight;
					cacheItem.itemHeight = itemHeight;
					if (cachedHeight == null && positionY < scrollY) {
						// attempt to adjust the scroll position so that it
						// appears that we're scrolling smoothly after this
						// item resizes
						var offsetY = itemHeight - virtualRowHeight;
						ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, 0.0, offsetY);
					}
					// if there was no cached height, and the new height matches
					// the estimated height, no need to dispatch Event.CHANGE
					if (cachedHeight != null || itemHeight != virtualRowHeight) {
						// this new measurement may cause the number of visible
						// items to change, so we need to notify the container
						FeathersEvent.dispatch(this, Event.CHANGE);
					}
				}
			}
			positionY += itemHeight + adjustedGap;
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
				viewPortHeight = this._paddingTop + this._paddingBottom + ((this._requestedRowCount * (virtualRowHeight + adjustedGap)) - adjustedGap);
			} else {
				if (this._requestedMinRowCount != null && items.length < this._requestedMinRowCount) {
					viewPortHeight = this._paddingTop + this._paddingBottom + ((this._requestedMinRowCount * (virtualRowHeight + adjustedGap)) - adjustedGap);
				} else if (this._requestedMaxRowCount != null && items.length > this._requestedMaxRowCount) {
					viewPortHeight = this._paddingTop + this._paddingBottom + ((this._requestedMaxRowCount * (virtualRowHeight + adjustedGap)) - adjustedGap);
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
			result.contentMinHeight = this._paddingTop + this._paddingBottom + ((this._requestedMinRowCount * (virtualRowHeight + adjustedGap)) - adjustedGap);
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
				if (!(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
			}
			if (this._widthResetEnabled && measurements.width == null && (item is IMeasureObject)) {
				(cast item : IMeasureObject).resetWidth();
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (maxItemWidth < itemWidth) {
				maxItemWidth = itemWidth;
			}
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					if ((item is IValidating)) {
						(cast item : IValidating).validateNow();
					}
					// save the original measured width in the cache to be used
					// again in future calculations
					cacheItem = new VirtualCacheItem(itemWidth, null);
					this._virtualCache[i] = cacheItem;
				}
			}
		}
		if (measurements.maxWidth != null) {
			var maxJustifyWidth = measurements.maxWidth - this._paddingLeft - this._paddingRight;
			if (maxJustifyWidth < 0.0) {
				maxJustifyWidth = 0.0;
			}
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

	private function calculateVirtualRowHeight(items:Array<DisplayObject>, itemWidth:Float):Float {
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				if (this._virtualCache == null || this._virtualCache.length <= i) {
					continue;
				}
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null || cacheItem.itemHeight == null) {
					continue;
				}
				// use the last known row height, if available
				return cacheItem.itemHeight;
			}
			if ((item is ILayoutObject)) {
				if (!(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.width = itemWidth;
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && (cacheItem.itemHeight == null || cacheItem.itemHeight != itemHeight)) {
					cacheItem.itemHeight = itemHeight;
					// this new measurement may cause the number of visible
					// items to change, so we need to notify the container
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			return itemHeight;
		}
		return 0.0;
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

		var startIndex = -1;
		var endIndex = -1;
		var estimatedItemHeight:Null<Float> = null;
		var positionY = this._paddingTop;
		var scrollY = this._scrollY;
		if (scrollY < 0.0) {
			scrollY = 0.0;
		}
		var minItems = 0;
		var maxY = scrollY + height;
		var skippedMissingItems = 0;
		for (i in 0...itemCount) {
			var itemHeight = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemHeight != null) {
					itemHeight = cacheItem.itemHeight;
					if (estimatedItemHeight == null) {
						estimatedItemHeight = itemHeight;
						minItems = Math.ceil(height / (estimatedItemHeight + adjustedGap)) + 1;
						if (skippedMissingItems > 0) {
							// include the heights of any items that were missing
							for (j in 0...skippedMissingItems) {
								positionY += estimatedItemHeight + adjustedGap;
								if (startIndex == -1 && positionY >= scrollY) {
									startIndex = j;
								}
								if (startIndex != -1) {
									endIndex = j;
									if (positionY >= maxY && (endIndex - startIndex + 1) >= minItems) {
										break;
									}
								}
							}
							skippedMissingItems = 0;
						}
					}
				} else if (estimatedItemHeight != null) {
					itemHeight = estimatedItemHeight;
				} else {
					// to avoid performance issues, we should avoid looping
					// through all items, because there could be hundreds,
					// thousands, or even millions of them. we need a limit.
					// the limit should be greater than 1, to avoid an expensive
					// recovery when the height of the first item is cleared
					// from the cache by dataProvider.updateAt() or something.
					if (skippedMissingItems < 5) {
						skippedMissingItems++;
						continue;
					}
					// if we can't find an estimated height, we return a range
					// where only the first item is visible. this allows the
					// first item to be measured, and the container can
					// request the visible items again using that measurement
					startIndex = 0;
					endIndex = 0;
					break;
				}
			}
			positionY += itemHeight + adjustedGap;
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
		if (startIndex == -1 && this._verticalAlign != TOP) {
			// if we're not aligned to the top, scrolling beyond the end might
			// make some items disappear prematurely, so back-fill from here
			startIndex = itemCount - 1;
			endIndex = startIndex;
		}
		// if we reached the end with extra space, try back-filling so that the
		// number of visible items remains mostly stable
		if ((positionY < maxY || (endIndex - startIndex + 1) < minItems) && startIndex > 0) {
			do {
				startIndex--;
				var itemHeight = 0.0;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[startIndex], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemHeight != null) {
						itemHeight = cacheItem.itemHeight;
						if (estimatedItemHeight == null) {
							estimatedItemHeight = itemHeight;
							minItems = Math.ceil(height / (estimatedItemHeight + adjustedGap)) + 1;
						}
					} else if (estimatedItemHeight != null) {
						itemHeight = estimatedItemHeight;
					}
				}
				positionY += itemHeight + adjustedGap;
				if (positionY >= maxY && (endIndex - startIndex + 1) >= minItems) {
					break;
				}
			} while (startIndex > 0);
		}
		if (startIndex < 0) {
			startIndex = 0;
		}
		if (estimatedItemHeight == null) {
			// if we don't have a good height yet, just return one index for
			// performance reasons. this will force one item to be measured, and
			// then we'll have an estimate.
			// the alternative is making every single item visible, which is
			// terrible for performance.
			endIndex = startIndex;
		} else if (endIndex < 0) {
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
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var estimatedItemHeight:Null<Float> = null;
		var minY = 0.0;
		var maxY = 0.0;
		var positionY = this._paddingTop;
		for (i in 0...itemCount) {
			var itemHeight = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemHeight != null) {
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
			positionY += itemHeight + adjustedGap;
		}

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
		@see `feathers.layout.IDragDropLayout.getDragDropIndex()`

		@since 1.3.0
	**/
	public function getDragDropIndex(items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Int {
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var estimatedItemHeight:Null<Float> = null;
		var positionY = this._paddingTop;
		for (i in 0...items.length) {
			var item = items[i];
			var itemHeight = estimatedItemHeight;
			if (item == null) {
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemHeight != null) {
						itemHeight = cacheItem.itemHeight;
						if (estimatedItemHeight == null) {
							estimatedItemHeight = itemHeight;
						}
					} else if (estimatedItemHeight != null) {
						itemHeight = estimatedItemHeight;
					}
				}
			} else {
				itemHeight = item.height;
			}
			if (y < (positionY + (itemHeight / 2.0))) {
				return i;
			}
			positionY += itemHeight + adjustedGap;
		}
		return items.length;
	}

	/**
		@see `feathers.layout.IDragDropLayout.getDragDropRegion()`

		@since 1.3.0
	**/
	public function getDragDropRegion(items:Array<DisplayObject>, dropIndex:Int, x:Float, y:Float, width:Float, height:Float,
			result:Rectangle = null):Rectangle {
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var maxIndex = dropIndex;
		if (maxIndex < 0) {
			maxIndex = 0;
		} else if (maxIndex > items.length) {
			maxIndex = items.length;
		}

		var estimatedItemHeight:Null<Float> = null;
		var positionY = this._paddingTop;
		for (i in 0...maxIndex) {
			var item = items[i];
			var itemHeight = 0.0;
			if (item == null) {
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemHeight != null) {
						itemHeight = cacheItem.itemHeight;
						if (estimatedItemHeight == null) {
							estimatedItemHeight = itemHeight;
						}
					} else if (estimatedItemHeight != null) {
						itemHeight = estimatedItemHeight;
					}
				}
			} else {
				itemHeight = item.height;
			}
			positionY += itemHeight + adjustedGap;
		}

		if (result == null) {
			result = new Rectangle(0.0, positionY, width, 0.0);
		} else {
			result.setTo(0.0, positionY, width, 0.0);
		}
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

		var estimatedItemHeight:Null<Float> = null;
		for (i in 0...items.length) {
			var itemHeight = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemHeight != null) {
					itemHeight = cacheItem.itemHeight;
					if (estimatedItemHeight == null) {
						estimatedItemHeight = itemHeight;
						break;
					}
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
						var item = items[i];
						var itemHeight = estimatedItemHeight;
						if (item == null) {
							if (this._virtualCache != null) {
								var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
								if (cacheItem != null && cacheItem.itemHeight != null) {
									itemHeight = cacheItem.itemHeight;
								}
							}
						} else {
							itemHeight = item.height;
						}
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
						var item = items[i];
						var itemHeight = estimatedItemHeight;
						if (item == null) {
							if (this._virtualCache != null) {
								var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
								if (cacheItem != null && cacheItem.itemHeight != null) {
									itemHeight = cacheItem.itemHeight;
								}
							}
						} else {
							itemHeight = item.height;
						}
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
		if (maxAlignmentHeight < 0.0) {
			maxAlignmentHeight = 0.0;
		}
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
				layoutObject = cast item;
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
	public function new(itemWidth:Float, itemHeight:Null<Float>) {
		this.itemWidth = itemWidth;
		this.itemHeight = itemHeight;
	}

	public var itemWidth:Float;
	public var itemHeight:Null<Float>;
}
