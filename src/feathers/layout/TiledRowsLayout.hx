/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Positions items as tiles (all items have equal dimensions) in one or more
	rows.

	@event openfl.events.Event.CHANGE

	@see [Tutorial: How to use TiledRowsLayout with layout containers](https://feathersui.com/learn/haxe-openfl/tiled-rows-layout/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class TiledRowsLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `TiledRowsLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
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

		If the `verticalGap` is set to `Math.POSITIVE_INFINITY`, the items
		will be positioned as far apart as possible. In this case, the
		vertical gap will never be smaller than `minVerticalGap`.

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

	private var _alignEmptyHorizontalTiles:Bool = false;

	/**
		Indicates if empty tiles should be included when positioning items with
		the `horizontalAlign` property. For instance, if the
		`requestedColumnCount` is `3`, but the total number of tiles in a row is
		`2`, that row can be aligned as if it contained all `3` items.

		@since 1.0.0

		@see `PagedTiledRowsListLayout.horizontalAlign`
	**/
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

		@see `TiledRowsLayout.requestedMinColumnCount`
		@see `TiledRowsLayout.requestedMaxColumnCount`

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

		@see `TiledRowsLayout.requestedColumnCount`
		@see `TiledRowsLayout.requestedMaxColumnCount`

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

		@see `TiledRowsLayout.requestedColumnCount`
		@see `TiledRowsLayout.requestedMinColumnCount`

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

	/**
		Sets all four padding properties to the same value.

		@see `TiledRowsLayout.paddingTop`
		@see `TiledRowsLayout.paddingRight`
		@see `TiledRowsLayout.paddingBottom`
		@see `TiledRowsLayout.paddingLeft`

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

		@see `TiledRowsLayout.horizontalGap`
		@see `TiledRowsLayout.verticalGap`

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
			result.contentX = 0;
			result.contentY = 0;
			result.contentWidth = this._paddingLeft + this._paddingRight;
			result.contentHeight = this._paddingTop + this._paddingBottom;
			result.viewPortWidth = result.contentWidth;
			result.viewPortHeight = result.contentHeight;
			return result;
		}

		this.validateItems(items, measurements);

		var tileWidth = 0.0;
		var tileHeight = 0.0;
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			tileWidth = Math.max(tileWidth, item.width);
			tileHeight = Math.max(tileHeight, item.height);
		}
		if (tileWidth < 0.0) {
			tileWidth = 0.0;
		}
		if (tileHeight < 0.0) {
			tileHeight = 0.0;
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
		if (hasFlexHorizontalGap) {
			var maxContentWidth = horizontalTileCount * (tileWidth + adjustedHorizontalGap) - adjustedHorizontalGap;
			if (availableRowWidth > maxContentWidth) {
				adjustedHorizontalGap += (availableRowWidth - maxContentWidth) / (horizontalTileCount - 1);
			}
		}

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
			if (item.width != tileWidth) {
				item.width = tileWidth;
			}
			if (item.height != tileHeight) {
				item.height = tileHeight;
			}

			if (currentColumnCount >= horizontalTileCount) {
				this.applyHorizontalAlignToRow(items, i - currentColumnCount, currentColumnCount, horizontalTileCount, availableRowWidth, tileWidth);
				xPosition = this._paddingLeft;
				yPosition += tileHeight;
				rowCount++;
				maxColumnCount = Std.int(Math.max(maxColumnCount, currentColumnCount));
				currentColumnCount = 0;
			}

			item.x = xPosition;
			item.y = yPosition;

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

		var viewPortHeight = measurements.height;
		if (viewPortHeight == null) {
			viewPortHeight = this._paddingTop + this._paddingBottom + rowCount * (tileHeight + adjustedVerticalGap) - adjustedVerticalGap;
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
		result.contentWidth = viewPortWidth;
		result.contentHeight = yPosition;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
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
			var rowContentWidth = numItemsInRow * (tileWidth + adjustedHorizontalGap) - adjustedHorizontalGap;
			if (numItemsInRow > 0) {
				rowContentWidth -= adjustedHorizontalGap;
			}
			if (numItemsInRow > 1 && availableRowWidth > rowContentWidth) {
				adjustedHorizontalGap += (availableRowWidth - rowContentWidth) / (numItemsInRow - 1);
			}
			gapOffset = adjustedHorizontalGap - this._minHorizontalGap;
		} else {
			var contentWidth = numItemsInRow * (tileWidth + adjustedHorizontalGap) - adjustedHorizontalGap;
			alignOffset = switch (this._horizontalAlign) {
				case LEFT: 0.0;
				case RIGHT: availableRowWidth - contentWidth;
				case CENTER: (availableRowWidth - contentWidth) / 2.0;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
			}
			if (alignOffset < 0) {
				alignOffset = 0.0;
			}
		}
		if (alignOffset == 0.0 && gapOffset == 0.0) {
			return;
		}
		var totalOffset = alignOffset;
		for (i in startIndex...(startIndex + numItemsInRow)) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			item.x += totalOffset;
			totalOffset += gapOffset;
		}
	}

	private function applyVerticalAlignAndGap(items:Array<DisplayObject>, availableHeight:Float, tileHeight:Float, rowCount:Int, columnCount:Int,
			adjustedVerticalGap:Float):Void {
		var alignOffset = 0.0;
		var gapOffset = 0.0;
		var hasFlexVerticalGap = this._verticalGap == (1.0 / 0.0);
		if (hasFlexVerticalGap) {
			gapOffset = adjustedVerticalGap;
		} else {
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
		var totalOffset = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if (i > 0 && (i % columnCount) == 0) {
				totalOffset += gapOffset;
			}
			item.y += totalOffset;
		}
	}

	private inline function validateItems(items:Array<DisplayObject>, measurements:Measurements) {
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
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
}
