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
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

/**
	Positions items from left to right in a single row, and all items are
	resized to have the same width and height.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use HorizontalDistributedLayout with layout containers](https://feathersui.com/learn/haxe-openfl/horizontal-distributed-layout/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class HorizontalDistributedLayout extends EventDispatcher implements ILayout implements IDragDropLayout {
	/**
		Creates a new `HorizontalDistributedLayout` object.

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

	private var _maxItemWidth:Float = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf

	/**
		The maximum width of an item in the layout.

		In the following example, the layout's maximum item width is set to 20
		pixels:

		```haxe
		layout.maxItemWidth = 20.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var maxItemWidth(get, set):Float;

	private function get_maxItemWidth():Float {
		return this._maxItemWidth;
	}

	private function set_maxItemWidth(value:Float):Float {
		if (this._maxItemWidth == value) {
			return this._maxItemWidth;
		}
		this._maxItemWidth = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._maxItemWidth;
	}

	private var _minItemWidth:Float = 0.0;

	/**
		The minimum width of an item in the layout.

		In the following example, the layout's minimum item width is set to 20
		pixels:

		```haxe
		layout.minItemWidth = 20.0;
		```

		@since 1.0.0
	**/
	@:bindable("change")
	public var minItemWidth(get, set):Float;

	private function get_minItemWidth():Float {
		return this._minItemWidth;
	}

	private function set_minItemWidth(value:Float):Float {
		if (this._minItemWidth == value) {
			return this._minItemWidth;
		}
		this._minItemWidth = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._minItemWidth;
	}

	private var _verticalAlign:VerticalAlign = TOP;

	/**
		How the content is positioned vertically (along the y-axis) within the
		container.

		The following example aligns the container's content to the bottom:

		```haxe
		layout.verticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`

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

	/**
		Sets all four padding properties to the same value.

		@see `HorizontalDistributedLayout.paddingTop`
		@see `HorizontalDistributedLayout.paddingRight`
		@see `HorizontalDistributedLayout.paddingBottom`
		@see `HorizontalDistributedLayout.paddingLeft`

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
		this.applyDistributedWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var contentWidth = this._paddingLeft;
		var contentHeight = 0.0;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			item.x = contentWidth;
			contentWidth += item.width + this._gap;
		}
		contentWidth += this._paddingRight;
		if (items.length > 0) {
			contentWidth -= this._gap;
		}
		contentHeight += this._paddingTop + this._paddingBottom;

		var viewPortWidth = contentWidth;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = contentHeight;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyVerticalAlign(items, viewPortHeight);

		if (contentWidth < viewPortWidth) {
			contentWidth = viewPortWidth;
		}
		if (contentHeight < viewPortHeight) {
			contentHeight = viewPortHeight;
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	/**
		@see `feathers.layout.IDragDropLayout.getDragDropIndex()`

		@since 1.3.0
	**/
	public function getDragDropIndex(items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Int {
		var positionX = this._paddingLeft;
		for (i in 0...items.length) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemWidth = item.width;
			if (x < (positionX + (itemWidth / 2.0))) {
				return i;
			}
			positionX += itemWidth + this._gap;
		}
		return items.length;
	}

	/**
		@see `feathers.layout.IDragDropLayout.getDragDropRegion()`

		@since 1.3.0
	**/
	public function getDragDropRegion(items:Array<DisplayObject>, dropIndex:Int, x:Float, y:Float, width:Float, height:Float,
			result:Rectangle = null):Rectangle {
		var maxIndex = dropIndex;
		if (dropIndex < 0) {
			dropIndex = 0;
		} else if (maxIndex > items.length) {
			maxIndex = items.length;
		}

		var positionX = this._paddingLeft;
		for (i in 0...maxIndex) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			positionX += item.width + this._gap;
		}

		if (result == null) {
			result = new Rectangle(positionX, 0.0, 0.0, height);
		} else {
			result.setTo(positionX, 0.0, 0.0, height);
		}
		return result;
	}

	private function applyDistributedWidth(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>,
			explicitMaxWidth:Null<Float>):Void {
		var maxMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		var itemsInLayoutCount = 0;
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutObject:ILayoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemMinWidth = 0.0;
			if ((item is IMeasureObject)) {
				var measureItem:IMeasureObject = cast item;
				itemMinWidth = measureItem.minWidth;
			} else {
				itemMinWidth = item.width;
			}
			if (maxMinWidth < itemMinWidth) {
				maxMinWidth = itemMinWidth;
			}
			totalPercentWidth += 100.0;
			itemsInLayoutCount++;
		}
		var remainingWidth = 0.0;
		if (explicitWidth != null) {
			remainingWidth = explicitWidth;
		} else {
			remainingWidth = this._paddingLeft + this._paddingRight + ((maxMinWidth + this._gap) * itemsInLayoutCount) - this._gap;
			if (explicitMinWidth != null && remainingWidth < explicitMinWidth) {
				remainingWidth = explicitMinWidth;
			} else if (explicitMaxWidth != null && remainingWidth > explicitMaxWidth) {
				remainingWidth = explicitMaxWidth;
			}
		}
		remainingWidth -= (this._paddingLeft + this._paddingRight + this._gap * (itemsInLayoutCount - 1));
		if (remainingWidth < 0.0) {
			remainingWidth = 0.0;
		}
		var percentToPixels = remainingWidth / totalPercentWidth;
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutObject:ILayoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			var itemWidth = percentToPixels * 100.0;
			if (itemWidth < this._minItemWidth) {
				itemWidth = this._minItemWidth;
			} else if (itemWidth > this._maxItemWidth) {
				itemWidth = this._maxItemWidth;
			}
			item.width = itemWidth;
			if ((item is IValidating)) {
				// changing the width of the item may cause its height
				// to change, so we need to validate. the height is
				// needed for measurement.
				(cast item : IValidating).validateNow();
			}
		}
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		var justifyContentHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		if (justifyContentHeight < 0.0) {
			justifyContentHeight = 0.0;
		}
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this._verticalAlign) {
				case BOTTOM:
					item.y = Math.max(this._paddingTop, this._paddingTop + justifyContentHeight - item.height);
				case MIDDLE:
					item.y = Math.max(this._paddingTop, this._paddingTop + (justifyContentHeight - item.height) / 2.0);
				case TOP:
					item.y = this._paddingTop;
				case JUSTIFY:
					item.y = this._paddingTop;
					item.height = justifyContentHeight;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
			}
		}
	}
}
