/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.IVirtualLayout.VirtualLayoutRange;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;

/**
	Positions items as tiles (all items have equal dimensions) in one or more
	rows.

	@event openfl.events.Event.CHANGE

	@see [Tutorial: How to use TiledRowsListLayout with layout containers](https://feathersui.com/learn/haxe-openfl/tiled-rows-list-layout/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class TiledRowsListLayout extends EventDispatcher implements IVirtualLayout implements IKeyboardNavigationLayout {
	/**
		Creates a new `TiledRowsListLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _scrollX:Float = 0.0;

	/**
		@see `feathers.layout.IScrollLayout.scrollX`
	**/
	@:flash.property
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
	@:flash.property
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
	@:flash.property
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
	@:flash.property
	public var elasticTop(get, never):Bool;

	private function get_elasticTop():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticRight`
	**/
	@:flash.property
	public var elasticRight(get, never):Bool;

	private function get_elasticRight():Bool {
		return false;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticBottom`
	**/
	@:flash.property
	public var elasticBottom(get, never):Bool;

	private function get_elasticBottom():Bool {
		return true;
	}

	/**
		@see `feathers.layout.IScrollLayout.elasticLeft`
	**/
	@:flash.property
	public var elasticLeft(get, never):Bool;

	private function get_elasticLeft():Bool {
		return false;
	}

	private var _alignEmptyHorizontalTiles:Bool = false;

	/**
		Indicates if empty tiles should be included when positioning items with
		the `horizontalAlign` property. For instance, if the
		`requestedColumnCount` is `3`, but the total number of tiles in a row is
		`2`, that row can be aligned as if it contained all `3` items.

		@since 1.0.0

		@see `PagedTiledRowsListLayout.horizontalAlign`
	**/
	@:flash.property
	public var alignEmptyHorizontalTiles(get, set):Bool;

	private function get_alignEmptyHorizontalTiles():Bool {
		return this._alignEmptyHorizontalTiles;
	}

	private function set_alignEmptyHorizontalTiles(value:Bool):Bool {
		if (this._alignEmptyHorizontalTiles == value) {
			return this._alignEmptyHorizontalTiles;
		}
		this._alignEmptyHorizontalTiles = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._alignEmptyHorizontalTiles;
	}

	private var _horizontalAlign:HorizontalAlign = LEFT;

	/**
		How each row is positioned horizontally (along the x-axis) within the
		container.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by
		this layout.

		The following example aligns each row's content to the right:

		```hx
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:flash.property
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

	private var _verticalAlign:VerticalAlign = TOP;

	/**
		How the content is positioned vertically (along the y-axis) within the
		container. If the total height of the content is larger than the
		available height within the container, then the positioning of the items
		will always start from the top.

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
	@:flash.property
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

	private var _paddingTop:Float = 0.0;

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
	@:flash.property
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

		```hx
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
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

		```hx
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
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

		```hx
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
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

	private var _horizontalGap:Float = 0.0;

	/**
		The horizontal space, in pixels, between each two adjacent items in the
		layout.

		If the `horizontalGap` is set to `Math.POSITIVE_INFINITY`, the items
		will be positioned as far apart as possible. In this case, the
		horizontal gap will never be smaller than `minHorizontalGap`.

		In the following example, the layout's horizontal gap is set to 20 pixels:

		```hx
		layout.horizontalGap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var horizontalGap(get, set):Float;

	private function get_horizontalGap():Float {
		return this._horizontalGap;
	}

	private function set_horizontalGap(value:Float):Float {
		if (this._horizontalGap == value) {
			return this._horizontalGap;
		}
		this._horizontalGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._horizontalGap;
	}

	private var _minHorizontalGap:Float = 0.0;

	/**
		If the value of the `horizontalGap` property is
		`Math.POSITIVE_INFINITY`, meaning that the gap will fill as much space
		as possible and position the items as far from each other as they can go
		without going outside of the view port bounds, the final calculated
		value of the horizontal gap will not be smaller than the value of the
		`minHorizontalGap` property.

		In the following example, the layout's horizontal gap is set to 4 pixels:

		```hx
		layout.minHorizontalGap = 4.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var minHorizontalGap(get, set):Float;

	private function get_minHorizontalGap():Float {
		return this._minHorizontalGap;
	}

	private function set_minHorizontalGap(value:Float):Float {
		if (this._minHorizontalGap == value) {
			return this._minHorizontalGap;
		}
		this._minHorizontalGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._minHorizontalGap;
	}

	private var _verticalGap:Float = 0.0;

	/**
		The vertical space, in pixels, between each two adjacent items in the
		layout.

		In the following example, the layout's vertical gap is set to 20 pixels:

		```hx
		layout.verticalGap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var verticalGap(get, set):Float;

	private function get_verticalGap():Float {
		return this._verticalGap;
	}

	private function set_verticalGap(value:Float):Float {
		if (this._verticalGap == value) {
			return this._verticalGap;
		}
		this._verticalGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._verticalGap;
	}

	private var _minVerticalGap:Float = 0.0;

	/**
		If the value of the `verticalGap` property is
		`Math.POSITIVE_INFINITY`, meaning that the gap will fill as much space
		as possible and position the items as far from each other as they can go
		without going outside of the view port bounds, the final calculated
		value of the vertical gap will not be smaller than the value of the
		`minVerticalGap` property.

		In the following example, the layout's vertical gap is set to 4 pixels:

		```hx
		layout.minVerticalGap = 4.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var minVerticalGap(get, set):Float;

	private function get_minVerticalGap():Float {
		return this._minVerticalGap;
	}

	private function set_minVerticalGap(value:Float):Float {
		if (this._minVerticalGap == value) {
			return this._minVerticalGap;
		}
		this._minVerticalGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._minVerticalGap;
	}

	private var _requestedColumnCount:Null<Int> = null;

	/**
		The exact number of columns to render, if space allows. If set to
		`null`, the number of columns will be the total number of items that can
		be displayed within the container's width.

		In the following example, the layout's requested column count is set to
		2 items:

		```hx
		layout.requestedColumnCount = 2;
		```

		@default null

		@see `TiledRowsListLayout.requestedMinColumnCount`
		@see `TiledRowsListLayout.requestedMaxColumnCount`

		@since 1.0.0
	**/
	@:flash.property
	public var requestedColumnCount(get, set):Null<Int>;

	private function get_requestedColumnCount():Null<Int> {
		return this._requestedColumnCount;
	}

	private function set_requestedColumnCount(value:Null<Int>):Null<Int> {
		if (this._requestedColumnCount == value) {
			return this._requestedColumnCount;
		}
		this._requestedColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedColumnCount;
	}

	private var _requestedMinColumnCount:Null<Int> = null;

	/**
		The minimum number of columns to render, if space allows. If set to
		`null`, the minimum number of columns will be 1.

		If `requestedColumnCount` is also set, this property is ignored.

		In the following example, the layout's requested minimum column count is
		set to 3 items:

		```hx
		layout.requestedMinColumnCount = 3;
		```

		@default null

		@see `TiledRowsListLayout.requestedColumnCount`
		@see `TiledRowsListLayout.requestedMaxColumnCount`

		@since 1.0.0
	**/
	@:flash.property
	public var requestedMinColumnCount(get, set):Null<Int>;

	private function get_requestedMinColumnCount():Null<Int> {
		return this._requestedMinColumnCount;
	}

	private function set_requestedMinColumnCount(value:Null<Int>):Null<Int> {
		if (this._requestedMinColumnCount == value) {
			return this._requestedMinColumnCount;
		}
		this._requestedMinColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMinColumnCount;
	}

	private var _requestedMaxColumnCount:Null<Int> = null;

	/**
		The maximum number of columns to render, if space allows. If set to
		`null`, the maximum number of columns will be the total number of items
		that can be displayed within the container's width.

		If `requestedColumnCount` is also set, this property is ignored.

		In the following example, the layout's requested maximum column count is
		set to 5 items:

		```hx
		layout.requestedMaxColumnCount = 5.0;
		```

		@default null

		@see `TiledRowsListLayout.requestedColumnCount`
		@see `TiledRowsListLayout.requestedMinColumnCount`

		@since 1.0.0
	**/
	@:flash.property
	public var requestedMaxColumnCount(get, set):Null<Int>;

	private function get_requestedMaxColumnCount():Null<Int> {
		return this._requestedMaxColumnCount;
	}

	private function set_requestedMaxColumnCount(value:Null<Int>):Null<Int> {
		if (this._requestedMaxColumnCount == value) {
			return this._requestedMaxColumnCount;
		}
		this._requestedMaxColumnCount = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._requestedMaxColumnCount;
	}

	private var _requestedRowCount:Null<Float> = null;

	/**
		The exact number of rows to render, if the height of the container has
		not been set explicitly. If `null`, falls back to `requestedMinRowCount`
		and `requestedMaxRowCount`.

		In the following example, the layout's requested row count is set to 2
		complete items:

		```hx
		layout.requestedRowCount = 2.0;
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
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

		```hx
		layout.requestedMinRowCount = 2.0;
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
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

		```hx
		layout.requestedMaxRowCount = 5.0;
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
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

	/**
		Sets all four padding properties to the same value.

		@see `TiledRowsListLayout.paddingTop`
		@see `TiledRowsListLayout.paddingRight`
		@see `TiledRowsListLayout.paddingBottom`
		@see `TiledRowsListLayout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		Sets both horizontal and vertical gap properties to the same value.

		@see `TiledRowsListLayout.horizontalGap`
		@see `TiledRowsListLayout.verticalGap`

		@since 1.0.0
	**/
	public function setGap(value:Float):Void {
		this.horizontalGap = value;
		this.verticalGap = value;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		if (items.length == 0) {
			result.contentX = 0.0;
			result.contentY = 0.0;
			result.contentWidth = this._paddingLeft + this._paddingRight;
			result.contentHeight = this._paddingTop + this._paddingBottom;
			result.viewPortWidth = result.contentWidth;
			result.viewPortHeight = result.contentHeight;
			return result;
		}

		var tileWidth = 0.0;
		var tileHeight = 0.0;
		if (this._virtualCache != null && this._virtualCache.length != 0) {
			var cacheItem = Std.downcast(this._virtualCache[0], VirtualCacheItem);
			if (cacheItem != null) {
				// use the last known dimensions, if available
				tileWidth = cacheItem.itemWidth;
				tileHeight = cacheItem.itemHeight;
			}
		}
		if (tileWidth == 0.0 && tileHeight == 0.0) {
			for (item in items) {
				if (item == null) {
					continue;
				} else {
					if ((item is ILayoutObject)) {
						if (!cast(item, ILayoutObject).includeInLayout) {
							continue;
						}
					}
					if ((item is IValidating)) {
						cast(item, IValidating).validateNow();
					}
					tileWidth = item.width;
					tileHeight = item.height;
					if (this._virtualCache != null) {
						// since all items are the same size, we can store just
						// one value as an optimization
						var cacheItem = Std.downcast(this._virtualCache[0], VirtualCacheItem);
						if (cacheItem == null || cacheItem.itemWidth != tileWidth || cacheItem.itemHeight != tileHeight) {
							if (cacheItem == null) {
								cacheItem = new VirtualCacheItem(tileWidth, tileHeight);
							} else {
								cacheItem.itemWidth = tileWidth;
								cacheItem.itemHeight = tileHeight;
							}
							this._virtualCache[0] = cacheItem;
							FeathersEvent.dispatch(this, Event.CHANGE);
						}
						// changing the item height in the cache may affect the
						// number of items that are visible, so we dispatch
						// Event.CHANGE need to check that again
					}
					break;
				}
			}
		}

		var adjustedHorizontalGap = this._horizontalGap;
		var hasFlexHorizontalGap = this._horizontalGap == (1.0 / 0.0);
		if (hasFlexHorizontalGap) {
			adjustedHorizontalGap = this._minHorizontalGap;
		}

		var horizontalTileCount = this.calculateHorizontalTileCount(tileWidth, measurements.width, measurements.maxWidth, adjustedHorizontalGap, items.length);

		var viewPortWidth = measurements.width;
		if (viewPortWidth == null) {
			viewPortWidth = this._paddingLeft
				+ this._paddingRight
				+ horizontalTileCount * (tileWidth + adjustedHorizontalGap)
				- adjustedHorizontalGap;
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}

		var availableRowWidth = viewPortWidth - this.paddingLeft - this.paddingRight;

		var maxColumnCount = 0;
		var currentColumnCount = 0;
		var rowCount = 1;
		var xPosition = this._paddingLeft;
		var yPosition = this._paddingTop;
		for (i in 0...items.length) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}

			if (currentColumnCount >= horizontalTileCount) {
				this.applyHorizontalAlignToRow(items, i - currentColumnCount, currentColumnCount, horizontalTileCount, availableRowWidth, tileWidth);
				xPosition = this._paddingLeft;
				yPosition += tileHeight;
				rowCount++;
				maxColumnCount = Std.int(Math.max(maxColumnCount, currentColumnCount));
				currentColumnCount = 0;
			}

			if (item != null) {
				item.x = xPosition;
				item.y = yPosition;
				item.width = tileWidth;
				item.height = tileHeight;
			}

			xPosition += tileWidth + adjustedHorizontalGap;
			currentColumnCount++;
		}
		this.applyHorizontalAlignToRow(items, items.length - currentColumnCount, currentColumnCount, horizontalTileCount, availableRowWidth, tileWidth);
		maxColumnCount = Std.int(Math.max(maxColumnCount, currentColumnCount));
		yPosition += tileHeight + this.paddingBottom;

		var adjustedVerticalGap = this._verticalGap;
		var hasFlexVerticalGap = this._verticalGap == (1.0) / 0.0;
		if (hasFlexVerticalGap) {
			adjustedVerticalGap = this._minVerticalGap;
		}

		var verticalTileCount = this.calculateVerticalTileCount(tileHeight, measurements.height, measurements.maxHeight, adjustedVerticalGap, items.length,
			horizontalTileCount);

		var viewPortHeight = measurements.height;
		if (viewPortHeight == null) {
			viewPortHeight = this._paddingTop + this._paddingBottom + (verticalTileCount * tileHeight) + (Std.int(verticalTileCount) * adjustedVerticalGap)
				- adjustedVerticalGap;
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		var availableContentHeight = viewPortHeight - this.paddingTop - this.paddingBottom;
		if (hasFlexVerticalGap) {
			var maxContentHeight = rowCount * (tileHeight + adjustedVerticalGap) - adjustedVerticalGap;
			if (availableContentHeight > maxContentHeight) {
				adjustedVerticalGap += (availableContentHeight - maxContentHeight) / (rowCount - 1);
			}
		}
		yPosition += (rowCount - 1) * adjustedVerticalGap;

		this.applyVerticalAlignAndGap(items, viewPortHeight - this.paddingTop - this.paddingBottom, tileHeight, rowCount, maxColumnCount, adjustedVerticalGap);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = viewPortWidth;
		result.contentHeight = yPosition;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	/**
		@see `feathers.layout.IVirtualLayout.getVisibleIndices()`
	**/
	public function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange {
		var tileWidth = 0.0;
		var tileHeight = 0.0;
		if (this._virtualCache != null && this._virtualCache.length != 0) {
			var cacheItem = Std.downcast(this._virtualCache[0], VirtualCacheItem);
			if (cacheItem != null) {
				tileWidth = cacheItem.itemWidth;
				tileHeight = cacheItem.itemHeight;
			}
		}

		if (tileWidth == 0.0 || tileHeight == 0.0) {
			if (result == null) {
				result = new VirtualLayoutRange(0, 0);
			} else {
				result.start = 0;
				result.end = 0;
			}
			return result;
		}

		var adjustedHorizontalGap = this._horizontalGap;
		var hasFlexHorizontalGap = this._horizontalGap == (1.0 / 0.0);
		if (hasFlexHorizontalGap) {
			var availableRowWidth = width - this.paddingLeft - this.paddingRight;
			adjustedHorizontalGap = this._minHorizontalGap;
			var maxContentWidth = itemCount * (tileWidth + adjustedHorizontalGap);
			if (itemCount > 0) {
				maxContentWidth -= adjustedHorizontalGap;
			}
			if (availableRowWidth > maxContentWidth) {
				adjustedHorizontalGap += (availableRowWidth - maxContentWidth) / (itemCount - 1);
			}
		}

		var adjustedVerticalGap = this._verticalGap;
		var hasFlexVerticalGap = this._verticalGap == (1.0) / 0.0;
		if (hasFlexVerticalGap) {
			adjustedVerticalGap = this._minVerticalGap;
		}

		var horizontalTileCount = this.calculateHorizontalTileCount(tileWidth, width, null, adjustedHorizontalGap, itemCount);
		var verticalTileCount = Math.ceil((height - this._paddingTop - this._paddingBottom + adjustedVerticalGap) / (tileHeight + adjustedVerticalGap)) + 1;
		var minimumItemCount = Math.ceil(verticalTileCount * horizontalTileCount);
		if (minimumItemCount > itemCount) {
			minimumItemCount = itemCount;
		}
		var rowIndexOffset = 0;
		var totalRowHeight = Math.fceil(itemCount / horizontalTileCount) * (tileHeight + adjustedVerticalGap) - adjustedVerticalGap;
		if (totalRowHeight < height) {
			if (this._verticalAlign == VerticalAlign.BOTTOM) {
				rowIndexOffset = Math.ceil((height - totalRowHeight) / (tileHeight + adjustedVerticalGap));
			} else if (this._verticalAlign == VerticalAlign.MIDDLE) {
				rowIndexOffset = Math.ceil((height - totalRowHeight) / (tileHeight + adjustedVerticalGap) / 2.0);
			}
		}
		var rowIndex = -rowIndexOffset + Std.int((scrollY - this._paddingTop + adjustedVerticalGap) / (tileHeight + adjustedVerticalGap));
		var minimum = rowIndex * horizontalTileCount;
		if (minimum < 0) {
			minimum = 0;
		}
		var maximum = minimum + minimumItemCount;
		if (maximum >= itemCount) {
			maximum = itemCount - 1;
			minimum = maximum - minimumItemCount;
			if (minimum < 0) {
				minimum = 0;
			}
		}

		if (result == null) {
			result = new VirtualLayoutRange(minimum, maximum);
			return result;
		}
		result.start = minimum;
		result.end = maximum;
		return result;
	}

	/**
		@see `feathers.layout.IScrollLayout.getNearestScrollPositionForIndex()`
	**/
	public function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point {
		var tileWidth = 0.0;
		var tileHeight = 0.0;
		if (this._virtualCache != null && this._virtualCache.length != 0) {
			var cacheItem = Std.downcast(this._virtualCache[0], VirtualCacheItem);
			if (cacheItem != null) {
				tileWidth = cacheItem.itemWidth;
				tileHeight = cacheItem.itemHeight;
			}
		}

		var adjustedHorizontalGap = this._horizontalGap;
		var hasFlexHorizontalGap = this._horizontalGap == (1.0 / 0.0);
		if (hasFlexHorizontalGap) {
			var availableRowWidth = width - this.paddingLeft - this.paddingRight;
			adjustedHorizontalGap = this._minHorizontalGap;
			var maxContentWidth = itemCount * (tileWidth + adjustedHorizontalGap);
			if (itemCount > 0) {
				maxContentWidth -= adjustedHorizontalGap;
			}
			if (availableRowWidth > maxContentWidth) {
				adjustedHorizontalGap += (availableRowWidth - maxContentWidth) / (itemCount - 1);
			}
		}

		var adjustedVerticalGap = this._verticalGap;
		var hasFlexVerticalGap = this._verticalGap == (1.0) / 0.0;
		if (hasFlexVerticalGap) {
			adjustedVerticalGap = this._minVerticalGap;
		}

		var horizontalTileCount = this.calculateHorizontalTileCount(tileWidth, width, null, adjustedHorizontalGap, itemCount);

		var resultY = this._paddingTop + ((tileHeight + adjustedVerticalGap) * Std.int(index / horizontalTileCount));
		var bottomPosition = resultY - (height - tileHeight);
		if (scrollY >= bottomPosition && scrollY <= resultY) {
			// keep the current scroll position because the item is already
			// fully visible
			resultY = scrollY;
		} else {
			var topDifference = Math.abs(resultY - scrollY);
			var bottomDifference = Math.abs(bottomPosition - scrollY);
			if (bottomDifference < topDifference) {
				resultY = bottomPosition;
			}
		}
		if (result == null) {
			result = new Point();
		}
		result.x = 0.0;
		result.y = resultY;
		return result;
	}

	/**
		@see `feathers.layout.IKeyboardNavigationLayout.findNextKeyboardIndex()`
	**/
	public function findNextKeyboardIndex(startIndex:Int, event:KeyboardEvent, wrapArrowKeys:Bool, items:Array<DisplayObject>, indicesToSkip:Array<Int>,
			viewPortWidth:Float, viewPortHeight:Float):Int {
		var itemCount = items.length;
		if (itemCount == 0) {
			return -1;
		}

		var tileWidth = 0.0;
		var tileHeight = 0.0;
		if (this._virtualCache != null && this._virtualCache.length != 0) {
			var cacheItem = Std.downcast(this._virtualCache[0], VirtualCacheItem);
			if (cacheItem != null) {
				tileWidth = cacheItem.itemWidth;
				tileHeight = cacheItem.itemHeight;
			}
		}

		if (tileWidth == 0.0 || tileHeight == 0.0) {
			return startIndex;
		}

		var adjustedHorizontalGap = this._horizontalGap;
		var hasFlexHorizontalGap = this._horizontalGap == (1.0 / 0.0);
		if (hasFlexHorizontalGap) {
			var availableRowWidth = viewPortWidth - this.paddingLeft - this.paddingRight;
			adjustedHorizontalGap = this._minHorizontalGap;
			var maxContentWidth = itemCount * (tileWidth + adjustedHorizontalGap);
			if (itemCount > 0) {
				maxContentWidth -= adjustedHorizontalGap;
			}
			if (availableRowWidth > maxContentWidth) {
				adjustedHorizontalGap += (availableRowWidth - maxContentWidth) / (itemCount - 1);
			}
		}

		var adjustedVerticalGap = this._verticalGap;
		var hasFlexVerticalGap = this._verticalGap == (1.0) / 0.0;
		if (hasFlexVerticalGap) {
			adjustedVerticalGap = this._minVerticalGap;
		}

		var result = startIndex;
		var horizontalTileCount = this.calculateHorizontalTileCount(tileWidth, viewPortWidth, null, adjustedHorizontalGap, itemCount);
		var verticalTileCount = Std.int(this.calculateVerticalTileCount(tileHeight, viewPortHeight, null, adjustedVerticalGap, itemCount,
			horizontalTileCount));
		var numRows = Math.ceil(itemCount / horizontalTileCount);
		var rowIndex = Std.int(startIndex / horizontalTileCount);
		var columnIndex = Std.int(startIndex % horizontalTileCount);

		if (result == -1) {
			result = switch (event.keyCode) {
				case Keyboard.LEFT: wrapArrowKeys ? itemCount - 1 : -1;
				case Keyboard.UP: wrapArrowKeys ? itemCount - 1 : -1;
				case Keyboard.RIGHT: 0;
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
					rowIndex--;
				case Keyboard.DOWN:
					rowIndex++;
				case Keyboard.LEFT:
					columnIndex--;
				case Keyboard.RIGHT:
					columnIndex++;
				case Keyboard.PAGE_UP:
					rowIndex -= verticalTileCount;
					nextKeyCode = Keyboard.UP;
				case Keyboard.PAGE_DOWN:
					rowIndex += verticalTileCount;
					nextKeyCode = Keyboard.DOWN;
				case Keyboard.HOME:
					rowIndex = 0;
					columnIndex = 0;
				case Keyboard.END:
					rowIndex = numRows - 1;
					columnIndex = horizontalTileCount - 1;
			}
			if (rowIndex < 0) {
				if (wrapArrowKeys) {
					rowIndex = numRows - 1;
				} else {
					rowIndex = 0;
				}
			} else if (rowIndex >= numRows) {
				if (wrapArrowKeys) {
					rowIndex = 0;
				} else {
					rowIndex = numRows - 1;
				}
			}
			if (columnIndex < 0) {
				if (wrapArrowKeys) {
					columnIndex = horizontalTileCount - 1;
				} else {
					columnIndex = 0;
				}
			} else if (columnIndex >= horizontalTileCount) {
				if (wrapArrowKeys) {
					columnIndex = 0;
				} else {
					columnIndex = horizontalTileCount - 1;
				}
			}

			result = rowIndex * horizontalTileCount + columnIndex;
			if (result >= itemCount) {
				// nothing at this column on the next row
				result = itemCount - 1;
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

	private function calculateHorizontalTileCount(tileWidth:Float, explicitWidth:Null<Float>, explicitMaxWidth:Null<Float>, horizontalGap:Float,
			totalItemCount:Int):Int {
		if (explicitWidth != null) {
			// in this case, the exact width is known
			final maxHorizontalTileCount = Std.int((explicitWidth - this._paddingLeft - this._paddingRight + horizontalGap) / (tileWidth + horizontalGap));
			if (this._requestedColumnCount != null) {
				if (this._requestedColumnCount > maxHorizontalTileCount) {
					return maxHorizontalTileCount;
				}
				return Std.int(Math.max(1, this._requestedColumnCount));
			}
			var horizontalTileCount = maxHorizontalTileCount;
			if (horizontalTileCount < 1) {
				// we must have at least one tile per row
				horizontalTileCount = 1;
			} else if (horizontalTileCount > totalItemCount) {
				horizontalTileCount = totalItemCount;
			}
			if (this._requestedMinColumnCount != null) {
				if (this._requestedMinColumnCount < horizontalTileCount) {
					return horizontalTileCount;
				}
				return Std.int(Math.max(1, this._requestedMinColumnCount));
			}
			if (this._requestedMaxColumnCount != null) {
				if (this._requestedMaxColumnCount > horizontalTileCount) {
					return horizontalTileCount;
				}
				return Std.int(Math.max(1, this._requestedMaxColumnCount));
			}
			return horizontalTileCount;
		}

		// in this case, the width is not known, but it may have a maximum

		// prefer the total number of items
		// unless some other bound takes precendence
		var horizontalTileCount = totalItemCount;
		if (this._requestedColumnCount != null) {
			// requestedColumnCount has the highest precedence!
			// requestedMinColumnCount and requestedMaxColumnCount should be
			// ignored if it is set
			horizontalTileCount = Std.int(Math.max(1, this._requestedColumnCount));
		} else if (this._requestedMinColumnCount != null) {
			if (horizontalTileCount < this._requestedMinColumnCount) {
				horizontalTileCount = this._requestedMinColumnCount;
			}
		} else if (this._requestedMaxColumnCount != null) {
			if (horizontalTileCount > this._requestedMaxColumnCount) {
				horizontalTileCount = this._requestedMaxColumnCount;
			}
		}
		var maxHorizontalTileCount = 0x7FFFFFFF;
		if (explicitMaxWidth != null && explicitMaxWidth < Math.POSITIVE_INFINITY) {
			maxHorizontalTileCount = Std.int((explicitMaxWidth - this._paddingLeft - this._paddingRight + horizontalGap) / (tileWidth + horizontalGap));
			if (maxHorizontalTileCount < 1) {
				// we must have at least one tile per row
				maxHorizontalTileCount = 1;
			}
		}
		if (horizontalTileCount > maxHorizontalTileCount) {
			horizontalTileCount = maxHorizontalTileCount;
		}
		if (horizontalTileCount < 1) {
			// we must have at least one tile per row
			horizontalTileCount = 1;
		}
		return horizontalTileCount;
	}

	private function calculateVerticalTileCount(tileHeight:Float, explicitHeight:Null<Float>, explicitMaxHeight:Null<Float>, verticalGap:Float,
			totalItemCount:Int, horizontalTileCount:Int):Float {
		// using the horizontal tile count, calculate how many rows would be
		// required for the total number of items if there were no restrictions.
		final defaultVerticalTileCount = Math.fceil(totalItemCount / horizontalTileCount);

		if (explicitHeight != null) {
			// in this case, the exact height is known
			final maxVerticalTileCount = (explicitHeight - this._paddingTop - this._paddingBottom + verticalGap) / (tileHeight + verticalGap);
			if (this._requestedRowCount != null && this._requestedRowCount >= 0.0) {
				if (this._requestedRowCount > maxVerticalTileCount) {
					return maxVerticalTileCount;
				}
				return this._requestedRowCount;
			}
			var verticalTileCount = maxVerticalTileCount;
			if (verticalTileCount > defaultVerticalTileCount) {
				verticalTileCount = defaultVerticalTileCount;
			}
			if (verticalTileCount < 1.0) {
				// we must have at least one tile per row
				verticalTileCount = 1.0;
			}
			if (this._requestedMinRowCount != null && this._requestedMinRowCount >= 1.0) {
				if (this._requestedMinRowCount < verticalTileCount) {
					return verticalTileCount;
				}
				return this._requestedMinRowCount;
			}
			if (this._requestedMaxRowCount != null && this._requestedMaxRowCount >= 1.0) {
				if (this._requestedMaxRowCount > verticalTileCount) {
					return verticalTileCount;
				}
				return this._requestedMaxRowCount;
			}
			return verticalTileCount;
		}

		// in this case, the height is not known, but it may have a maximum
		var verticalTileCount = defaultVerticalTileCount;
		if (this._requestedRowCount > 0.0) {
			verticalTileCount = this._requestedRowCount;
		}
		if (this._requestedMinRowCount != null && this._requestedMinRowCount >= 1.0 && verticalTileCount < this._requestedMinRowCount) {
			return this._requestedMinRowCount;
		}

		var maxVerticalTileCount:Float = Math.POSITIVE_INFINITY;
		if (explicitMaxHeight != null && explicitMaxHeight < Math.POSITIVE_INFINITY) {
			maxVerticalTileCount = Std.int((explicitMaxHeight - this._paddingTop - this._paddingBottom + verticalGap) / (tileHeight + verticalGap));
			if (maxVerticalTileCount < 1) {
				// we must have at least one tile per row
				maxVerticalTileCount = 1;
			}
		}
		if (verticalTileCount > maxVerticalTileCount) {
			verticalTileCount = maxVerticalTileCount;
		}
		if (this._requestedMaxRowCount != null && this._requestedMaxRowCount >= 1.0 && verticalTileCount > this._requestedMaxRowCount) {
			verticalTileCount = this._requestedMaxRowCount;
		}
		if (verticalTileCount < 1.0) {
			// we must have at least one tile per row
			verticalTileCount = 1.0;
		}
		return verticalTileCount;
	}

	private function applyHorizontalAlignToRow(items:Array<DisplayObject>, startIndex:Int, numItemsInRow:Int, horizontalTileCount:Int,
			availableRowWidth:Float, tileWidth:Float):Void {
		if (this._alignEmptyHorizontalTiles && horizontalTileCount > numItemsInRow) {
			numItemsInRow = horizontalTileCount;
		}
		var alignOffset = 0.0;
		var gapOffset = 0.0;
		var adjustedHorizontalGap = this._horizontalGap;
		var hasFlexHorizontalGap = this._horizontalGap == (1.0 / 0.0);
		if (hasFlexHorizontalGap) {
			adjustedHorizontalGap = this._minHorizontalGap;
			var rowContentWidth = numItemsInRow * (tileWidth + adjustedHorizontalGap);
			if (numItemsInRow > 0) {
				rowContentWidth -= adjustedHorizontalGap;
			}
			if (numItemsInRow > 1 && availableRowWidth > rowContentWidth) {
				adjustedHorizontalGap += (availableRowWidth - rowContentWidth) / (numItemsInRow - 1);
			}
			gapOffset = adjustedHorizontalGap - this._minHorizontalGap;
		} else {
			var rowContentWidth = numItemsInRow * (tileWidth + adjustedHorizontalGap);
			if (numItemsInRow > 0) {
				rowContentWidth -= adjustedHorizontalGap;
			}
			alignOffset = switch (this._horizontalAlign) {
				case LEFT: 0.0;
				case RIGHT: availableRowWidth - rowContentWidth;
				case CENTER: (availableRowWidth - rowContentWidth) / 2.0;
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
		var endIndex = startIndex + numItemsInRow;
		if (endIndex > items.length) {
			endIndex = items.length;
		}
		for (i in startIndex...endIndex) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if (item != null) {
				item.x += totalOffset;
			}
			totalOffset += gapOffset;
		}
	}

	private function applyVerticalAlignAndGap(items:Array<DisplayObject>, availableHeight:Float, tileHeight:Float, rowCount:Int, columnCount:Int,
			adjustedVerticalGap:Float):Void {
		var alignOffset = 0.0;
		var gapOffset = adjustedVerticalGap;
		var hasFlexVerticalGap = this._verticalGap == (1.0 / 0.0);
		if (!hasFlexVerticalGap) {
			var contentHeight = rowCount * (tileHeight + adjustedVerticalGap) - adjustedVerticalGap;
			alignOffset = switch (this._verticalAlign) {
				case TOP: 0.0;
				case BOTTOM: availableHeight - contentHeight;
				case MIDDLE: (availableHeight - contentHeight) / 2.0;
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
		var layoutIndex = 0;
		for (i in 0...items.length) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if (layoutIndex > 0 && (layoutIndex % columnCount) == 0) {
				totalOffset += gapOffset;
			}
			if (item != null) {
				item.y += totalOffset;
			}
			layoutIndex++;
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
