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

		var viewPortWidth = measurements.width;
		if (viewPortWidth == null) {
			viewPortWidth = this._paddingLeft + this._paddingRight + items.length * (tileWidth + this._horizontalGap);
			if (items.length > 0) {
				viewPortWidth -= this._horizontalGap;
			}
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}

		var availableRowWidth = viewPortWidth - this.paddingLeft - this.paddingRight;

		var columnCount = 0;
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

			var rowWidthWithItem = xPosition + tileWidth + this.paddingRight;
			if (rowWidthWithItem > viewPortWidth) {
				this.applyHorizontalAlign(items, i - columnCount, columnCount, availableRowWidth, tileWidth);
				xPosition = this._paddingLeft;
				yPosition += tileHeight + this._verticalGap;
				rowCount++;
				columnCount = 0;
			}

			item.x = xPosition;
			item.y = yPosition;

			xPosition += tileWidth + this._horizontalGap;
			columnCount++;
		}
		this.applyHorizontalAlign(items, items.length - columnCount, columnCount, availableRowWidth, tileWidth);
		yPosition += tileHeight + this.paddingBottom;

		var viewPortHeight = measurements.height;
		if (viewPortHeight == null) {
			viewPortHeight = this._paddingTop + this._paddingBottom + rowCount * (tileHeight + this._verticalGap) - this._verticalGap;
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyVerticalAlign(items, viewPortHeight - this.paddingTop - this.paddingBottom, tileHeight, rowCount);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = viewPortWidth;
		result.contentHeight = yPosition;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private function applyHorizontalAlign(items:Array<DisplayObject>, startIndex:Int, count:Int, availableWidth:Float, tileWidth:Float):Void {
		var contentWidth = count * (tileWidth + this._horizontalGap) - this._horizontalGap;
		var xOffset = switch (this._horizontalAlign) {
			case RIGHT: availableWidth - contentWidth;
			case CENTER: (availableWidth - contentWidth) / 2.0;
			default: 0.0;
		}
		if (xOffset <= 0.0) {
			return;
		}
		for (i in startIndex...(startIndex + count)) {
			var item = items[i];
			item.x += xOffset;
		}
	}

	private function applyVerticalAlign(items:Array<DisplayObject>, availableHeight:Float, tileHeight:Float, rowCount:Int):Void {
		var contentHeight = rowCount * (tileHeight + this._verticalGap) - this._verticalGap;
		var yOffset = switch (this._verticalAlign) {
			case BOTTOM: availableHeight - contentHeight;
			case MIDDLE: (availableHeight - contentHeight) / 2.0;
			default: 0.0;
		}
		if (yOffset <= 0.0) {
			return;
		}
		for (item in items) {
			item.y += yOffset;
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
}
