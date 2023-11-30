/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

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
import openfl.ui.Keyboard;

/**
	A simple list layout that positions items from left to right, in a single
	row, where every item fills the entire height of the container.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class HorizontalListLayout extends EventDispatcher implements IVirtualLayout implements IKeyboardNavigationLayout {
	/**
		Creates a new `HorizontalListLayout` object.

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
		return false;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticRight`
	**/
	public var elasticRight(get, never):Bool;

	private function get_elasticRight():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticBottom`
	**/
	public var elasticBottom(get, never):Bool;

	private function get_elasticBottom():Bool {
		return false;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticLeft`
	**/
	public var elasticLeft(get, never):Bool;

	private function get_elasticLeft():Bool {
		return true;
	}

	private var _requestedColumnCount:Null<Float> = null;

	/**
		The exact number of columns to render, if the width of the container has
		not been set explicitly. If `null`, falls back to
		`requestedMinColumnCount` and `requestedMaxColumnCount`.

		In the following example, the layout's requested column count is set to
		2 complete items:

		```haxe
		layout.requestedColumnCount = 2.0;
		```

		@default 5.0

		@since 1.0.0
	**/
	@:bindable("change")
	public var requestedColumnCount(get, set):Null<Float>;

	private function get_requestedColumnCount():Null<Float> {
		return this._requestedColumnCount;
	}

	private function set_requestedColumnCount(value:Null<Float>):Null<Float> {
		if (this._requestedColumnCount == value) {
			return this._requestedColumnCount;
		}
		this._requestedColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedColumnCount;
	}

	private var _requestedMinColumnCount:Null<Float> = null;

	/**
		The minimum number of columns to render, if the width of the container
		has not been set explicitly. If `null`, this property is ignored.

		If `requestedColumnCount` is also set, this property is ignored.

		In the following example, the layout's requested minimum coumn count is
		set to 2 complete items:

		```haxe
		layout.requestedMinColumnCount = 2.0;
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var requestedMinColumnCount(get, set):Null<Float>;

	private function get_requestedMinColumnCount():Null<Float> {
		return this._requestedMinColumnCount;
	}

	private function set_requestedMinColumnCount(value:Null<Float>):Null<Float> {
		if (this._requestedMinColumnCount == value) {
			return this._requestedMinColumnCount;
		}
		this._requestedMinColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMinColumnCount;
	}

	private var _requestedMaxColumnCount:Null<Float> = null;

	/**
		The maximum number of columns to render, if the width of the container
		has not been set explicitly. If `null`, the maximum number of columns is
		the total number of items displayed by the layout.

		If `requestedColumnCount` is also set, this property is ignored.

		In the following example, the layout's requested maximum column count is
		set to 5 complete items:

		```haxe
		layout.requestedMaxColumnCount = 5.0;
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var requestedMaxColumnCount(get, set):Null<Float>;

	private function get_requestedMaxColumnCount():Null<Float> {
		return this._requestedMaxColumnCount;
	}

	private function set_requestedMaxColumnCount(value:Null<Float>):Null<Float> {
		if (this._requestedMaxColumnCount == value) {
			return this._requestedMaxColumnCount;
		}
		this._requestedMaxColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMaxColumnCount;
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

	private var _horizontalAlign:HorizontalAlign = LEFT;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		container. If the total width of the content is larger than the
		available width within the container, then the positioning of the items
		will always start from the left.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the right:

		```haxe
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:bindable("change")
	public var horizontalAlign(get, set):HorizontalAlign;

	private function get_horizontalAlign():HorizontalAlign {
		return this._horizontalAlign;
	}

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this._horizontalAlign == value) {
			return this._horizontalAlign;
		}
		this._horizontalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._horizontalAlign;
	}

	private var _contentJustify:Bool = false;

	/**
		When `contentJustify` is `true`, the height of the items is set to
		either the explicit height of the container, or the maximum height of
		all items, whichever is larger. When `false`, the height of the items
		is set to the explicit height of the container, even if the items are
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

	private var _heightResetEnabled:Bool = true;

	/**
		Indicates if the height of items should be reset if the explicit height
		of the parent container is not set.

		@since 1.0.0
	**/
	@:bindable("change")
	public var heightResetEnabled(get, set):Bool;

	private function get_heightResetEnabled():Bool {
		return this._heightResetEnabled;
	}

	private function set_heightResetEnabled(value:Bool):Bool {
		if (this._heightResetEnabled == value) {
			return this._heightResetEnabled;
		}
		this._heightResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._heightResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `HorizontalListLayout.paddingTop`
		@see `HorizontalListLayout.paddingRight`
		@see `HorizontalListLayout.paddingBottom`
		@see `HorizontalListLayout.paddingLeft`

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

		var maxItemHeight = this.calculateMaxItemHeight(items, measurements);
		var viewPortHeight = this.calculateViewPortHeight(maxItemHeight, measurements);
		var minItemHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		var itemHeight = maxItemHeight;
		if (!this._contentJustify || itemHeight < minItemHeight) {
			itemHeight = minItemHeight;
		}
		var virtualColumnWidth = this.calculateVirtualColumnWidth(items, itemHeight);
		var positionX = this._paddingLeft;
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				var itemWidth = virtualColumnWidth;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemWidth != null) {
						itemWidth = cacheItem.itemWidth;
					}
				}
				positionX += itemWidth + adjustedGap;
				continue;
			}
			if ((item is ILayoutObject)) {
				if (!(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.x = positionX;
			item.y = this._paddingTop;
			item.height = itemHeight;
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemWidth != itemWidth) {
					var cachedWidth = cacheItem.itemWidth;
					cacheItem.itemWidth = itemWidth;
					if (cachedWidth == null && positionX < scrollX) {
						// attempt to adjust the scroll position so that it
						// appears that we're scrolling smoothly after this
						// item resizes
						var offsetX = itemWidth - virtualColumnWidth;
						ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, offsetX, 0.0);
					}
					// if there was no cached width, and the new width matches
					// the estimated width, no need to dispatch Event.CHANGE
					if (cachedWidth != null || itemWidth != virtualColumnWidth) {
						// this new measurement may cause the number of visible
						// items to change, so we need to notify the container
						FeathersEvent.dispatch(this, Event.CHANGE);
					}
				}
			}
			positionX += itemWidth + adjustedGap;
		}
		if (items.length > 0) {
			positionX -= adjustedGap;
		}
		positionX += this._paddingRight;

		var viewPortWidth = positionX;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (this._requestedColumnCount != null) {
				viewPortWidth = this._paddingLeft + this._paddingRight + ((this._requestedColumnCount * (virtualColumnWidth + adjustedGap)) - adjustedGap);
			} else {
				if (this._requestedMinColumnCount != null && items.length < this._requestedMinColumnCount) {
					viewPortWidth = this._paddingLeft
						+ this._paddingRight
						+ ((this._requestedMinColumnCount * (virtualColumnWidth + adjustedGap)) - adjustedGap);
				} else if (this._requestedMaxColumnCount != null && items.length > this._requestedMaxColumnCount) {
					viewPortWidth = this._paddingLeft
						+ this._paddingRight
						+ ((this._requestedMaxColumnCount * (virtualColumnWidth + adjustedGap)) - adjustedGap);
				}
			}
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}

		this.applyHorizontalAlign(items, positionX - this._paddingLeft - this._paddingRight, viewPortWidth);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = positionX;
		result.contentHeight = itemHeight + this._paddingTop + this._paddingBottom;
		if (this._requestedMinColumnCount != null) {
			result.contentMinWidth = this._paddingLeft
				+ this._paddingRight
				+ ((this._requestedMinColumnCount * (virtualColumnWidth + adjustedGap)) - adjustedGap);
		}
		result.viewPortHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
		return result;
	}

	private function calculateMaxItemHeight(items:Array<DisplayObject>, measurements:Measurements):Float {
		var maxItemHeight = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if (this._virtualCache != null && this._virtualCache.length > i) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null) {
					// prefer the cached height because that's the original
					// measured height and not the justified height
					var itemHeight = cacheItem.itemHeight;
					if (maxItemHeight < itemHeight) {
						maxItemHeight = itemHeight;
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
			if (this._heightResetEnabled && measurements.height == null && (item is IMeasureObject)) {
				(cast item : IMeasureObject).resetHeight();
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (maxItemHeight < itemHeight) {
				maxItemHeight = itemHeight;
			}
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null) {
					if ((item is IValidating)) {
						(cast item : IValidating).validateNow();
					}
					// save the original measured height in the cache to be used
					// again in future calculations
					cacheItem = new VirtualCacheItem(null, itemHeight);
					this._virtualCache[i] = cacheItem;
				}
			}
		}
		if (measurements.maxHeight != null) {
			var maxJustifyHeight = measurements.maxHeight - this._paddingTop - this._paddingBottom;
			if (maxItemHeight > maxJustifyHeight) {
				maxItemHeight = maxJustifyHeight;
			}
		}
		return maxItemHeight;
	}

	private function calculateViewPortHeight(maxItemHeight:Float, measurements:Measurements):Float {
		if (measurements.height != null) {
			return measurements.height;
		}
		return maxItemHeight + this._paddingTop + this._paddingBottom;
	}

	private function calculateVirtualColumnWidth(items:Array<DisplayObject>, itemHeight:Float):Float {
		for (i in 0...items.length) {
			var item = items[i];
			if (item == null) {
				if (this._virtualCache == null || this._virtualCache.length <= i) {
					continue;
				}
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem == null || cacheItem.itemWidth == null) {
					continue;
				}
				// use the last known column width, if available
				return cacheItem.itemWidth;
			}
			if ((item is ILayoutObject)) {
				if (!(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
			}
			item.height = itemHeight;
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && (cacheItem.itemWidth == null || cacheItem.itemWidth != itemWidth)) {
					cacheItem.itemWidth = itemWidth;
					// this new measurement may cause the number of visible
					// items to change, so we need to notify the container
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
			return itemWidth;
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
		var estimatedItemWidth:Null<Float> = null;
		var positionX = this._paddingLeft;
		var scrollX = this._scrollX;
		if (scrollX < 0.0) {
			scrollX = 0.0;
		}
		var minItems = 0;
		var maxX = scrollX + width;
		var skippedMissingItems = 0;
		for (i in 0...itemCount) {
			var itemWidth = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemWidth != null) {
					itemWidth = cacheItem.itemWidth;
					if (estimatedItemWidth == null) {
						estimatedItemWidth = itemWidth;
						minItems = Math.ceil(width / (estimatedItemWidth) + adjustedGap) + 1;
						if (skippedMissingItems > 0) {
							// include the heights of any items that were missing
							for (j in 0...skippedMissingItems) {
								positionX += estimatedItemWidth + adjustedGap;
								if (startIndex == -1 && positionX >= scrollX) {
									startIndex = j;
								}
								if (startIndex != -1) {
									endIndex = j;
									if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
										break;
									}
								}
							}
							skippedMissingItems = 0;
						}
					}
				} else if (estimatedItemWidth != null) {
					itemWidth = estimatedItemWidth;
				} else {
					// to avoid performance issues, we should avoid looping
					// through all items, because there could be hundreds,
					// thousands, or even millions of them. we need a limit.
					// the limit should be greater than 1, to avoid an expensive
					// recovery when the width of the first item is cleared
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
			positionX += itemWidth + adjustedGap;
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
		if (startIndex == -1 && this._horizontalAlign != LEFT) {
			// if we're not aligned to the top, scrolling beyond the end might
			// make some items disappear prematurely, so back-fill from here
			startIndex = itemCount - 1;
			endIndex = startIndex;
		}
		// if we reached the end with extra space, try back-filling so that the
		// number of visible items remains mostly stable
		if ((positionX < maxX || (endIndex - startIndex + 1) < minItems) && startIndex > 0) {
			do {
				startIndex--;
				var itemWidth = 0.0;
				if (this._virtualCache != null) {
					var cacheItem = Std.downcast(this._virtualCache[startIndex], VirtualCacheItem);
					if (cacheItem != null && cacheItem.itemWidth != null) {
						itemWidth = cacheItem.itemWidth;
						if (estimatedItemWidth == null) {
							estimatedItemWidth = itemWidth;
							minItems = Math.ceil(width / (estimatedItemWidth) + adjustedGap) + 1;
						}
					} else if (estimatedItemWidth != null) {
						itemWidth = estimatedItemWidth;
					}
				}
				positionX += itemWidth + adjustedGap;
				if (positionX >= maxX && (endIndex - startIndex + 1) >= minItems) {
					break;
				}
			} while (startIndex > 0);
		}
		if (startIndex < 0) {
			startIndex = 0;
		}
		if (estimatedItemWidth == null) {
			// if we don't have a good width yet, just return one index for
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

		var estimatedItemWidth:Null<Float> = null;
		var minX = 0.0;
		var maxX = 0.0;
		var positionX = this._paddingLeft;
		for (i in 0...itemCount) {
			var itemWidth = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemWidth != null) {
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
			positionX += itemWidth + adjustedGap;
		}

		var targetX = this._scrollX;
		if (targetX < minX) {
			targetX = minX;
		} else if (targetX > maxX) {
			targetX = maxX;
		}
		if (result == null) {
			result = new Point();
		}
		result.x = targetX;
		result.y = this._scrollY;
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

		var estimatedItemWidth:Null<Float> = null;
		for (i in 0...items.length) {
			var itemWidth = 0.0;
			if (this._virtualCache != null) {
				var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
				if (cacheItem != null && cacheItem.itemWidth != null) {
					itemWidth = cacheItem.itemWidth;
					if (estimatedItemWidth == null) {
						estimatedItemWidth = itemWidth;
						break;
					}
				}
			}
		}

		var maxIndex = items.length - 1;
		var result = startIndex;
		if (result == -1) {
			result = switch (event.keyCode) {
				case Keyboard.LEFT: wrapArrowKeys ? maxIndex : -1;
				case Keyboard.RIGHT: 0;
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
				case Keyboard.LEFT:
					result = result - 1;
				case Keyboard.RIGHT:
					result = result + 1;
				case Keyboard.PAGE_UP:
					var xPosition = 0.0;
					var i = startIndex;
					while (i >= 0) {
						var item = items[i];
						var itemWidth = estimatedItemWidth;
						if (item == null) {
							if (this._virtualCache != null) {
								var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
								if (cacheItem != null && cacheItem.itemWidth != null) {
									itemWidth = cacheItem.itemWidth;
								}
							}
						} else {
							itemWidth = item.width;
						}
						xPosition += itemWidth;
						if (indicesToSkip != null && indicesToSkip.indexOf(i) != -1) {
							xPosition += adjustedGap;
							i--;
							continue;
						}
						if (xPosition > viewPortWidth) {
							break;
						}
						xPosition += adjustedGap;
						result = i;
						i--;
					}
					nextKeyCode = Keyboard.UP;
				case Keyboard.PAGE_DOWN:
					var xPosition = 0.0;
					for (i in startIndex...items.length) {
						var item = items[i];
						var itemWidth = estimatedItemWidth;
						if (item == null) {
							if (this._virtualCache != null) {
								var cacheItem = Std.downcast(this._virtualCache[i], VirtualCacheItem);
								if (cacheItem != null && cacheItem.itemWidth != null) {
									itemWidth = cacheItem.itemWidth;
								}
							}
						} else {
							itemWidth = item.width;
						}
						xPosition += itemWidth;
						if (indicesToSkip != null && indicesToSkip.indexOf(i) != -1) {
							xPosition += adjustedGap;
							continue;
						}
						if (xPosition > viewPortWidth) {
							break;
						}
						xPosition += adjustedGap;
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

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		var alignOffset = 0.0;
		var gapOffset = 0.0;
		var maxAlignmentWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
			if (items.length > 1 && maxAlignmentWidth > contentWidth) {
				adjustedGap += (maxAlignmentWidth - contentWidth) / (items.length - 1);
			}
			gapOffset = adjustedGap - this._minGap;
		} else {
			alignOffset = switch (this._horizontalAlign) {
				case LEFT: 0.0;
				case RIGHT: maxAlignmentWidth - contentWidth;
				case CENTER: (maxAlignmentWidth - contentWidth) / 2.0;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
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
				item.x = Math.max(this._paddingLeft, item.x + totalOffset);
			}
			totalOffset += gapOffset;
		}
	}
}

@:dox(hide)
private class VirtualCacheItem {
	public function new(itemWidth:Null<Float>, itemHeight:Float) {
		this.itemWidth = itemWidth;
		this.itemHeight = itemHeight;
	}

	public var itemWidth:Null<Float>;
	public var itemHeight:Float;
}
