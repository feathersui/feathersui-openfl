/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

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

/**
	Positions items of different dimensions from top to bottom in multiple
	columns. When the height of a column reaches the height of the container, a
	new column will be started. Constrained to the suggested height, the
	content's total width will change as the number of items increases or
	decreases.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use FlowRowsLayout with layout containers](https://feathersui.com/learn/haxe-openfl/flow-rows-layout/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class FlowColumnsLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `FlowColumnsLayout` object.

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

	private var _horizontalGap:Float = 0.0;

	/**
		The horizontal space, in pixels, between each two adjacent items in the
		layout.

		In the following example, the layout's horizontal gap is set to 20 pixels:

		```haxe
		layout.horizontalGap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
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

		```haxe
		layout.verticalGap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:bindable("change")
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

	private var _verticalAlign:VerticalAlign = TOP;

	/**
		How each column is positioned vertically (along the y-axis) within the
		container.

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by
		this layout.

		The following example aligns each column's content to the bottom:

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

	private var _columnHorizontalAlign:HorizontalAlign = LEFT;

	/**
		How items in a column are positioned horizontally (along the x-axis) within
		that column.

		The following example aligns each column's content to the right:

		```haxe
		layout.columnHorizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
		@see `feathers.layout.HorizontalAlign.JUSTIFY`
		@see `FlowColumnsLayout.justifyResetEnabled`

		@since 1.0.0
	**/
	@:bindable("change")
	public var columnHorizontalAlign(get, set):HorizontalAlign;

	private function get_columnHorizontalAlign():HorizontalAlign {
		return this._columnHorizontalAlign;
	}

	private function set_columnHorizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this._columnHorizontalAlign == value) {
			return this._columnHorizontalAlign;
		}
		this._columnHorizontalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._columnHorizontalAlign;
	}

	private var _justifyResetEnabled:Bool = false;

	/**
		Indicates if the width of items should be reset if the
		`columnHorizontalAlign` property is set to `HorizontalAlign.JUSTIFY`.

		@see `FlowColumnsLayout.columnHorizontalAlign`

		@since 1.0.0
	**/
	@:bindable("change")
	public var justifyResetEnabled(get, set):Bool;

	private function get_justifyResetEnabled():Bool {
		return this._justifyResetEnabled;
	}

	private function set_justifyResetEnabled(value:Bool):Bool {
		if (this._justifyResetEnabled == value) {
			return this._justifyResetEnabled;
		}
		this._justifyResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._justifyResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `FlowColumnsLayout.paddingTop`
		@see `FlowColumnsLayout.paddingRight`
		@see `FlowColumnsLayout.paddingBottom`
		@see `FlowColumnsLayout.paddingLeft`

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

		@see `FlowColumnsLayout.horizontalGap`
		@see `FlowColumnsLayout.verticalGap`

		@since 1.0.0
	**/
	public function setGap(value:Float):Void {
		this.horizontalGap = value;
		this.verticalGap = value;
	}

	private var _columnItems:Array<DisplayObject> = [];

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

		this.validateItems(items, measurements);

		// let's figure out if we can show multiple columns
		var supportsMultipleColumns = true;
		var availableColumnHeight = measurements.height;
		var needsHeight = availableColumnHeight == null;
		if (needsHeight) {
			availableColumnHeight = measurements.maxHeight;
			if (availableColumnHeight == null) {
				availableColumnHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
			if (availableColumnHeight == (1.0 / 0.0)) // Math.POSITIVE_INFINITY bug workaround for swf
			{
				supportsMultipleColumns = false;
			}
		}

		var i = 0;
		var itemCount = items.length;
		var positionX = this._paddingLeft;
		var maxColumnHeight = 0.0;
		var maxItemWidth = 0.0;
		do {
			if (i > 0) {
				positionX += maxItemWidth + horizontalGap;
			}
			// this section prepares some variables needed for the following loop
			maxItemWidth = 0.0;
			var positionY = this._paddingTop;
			// we save the items in this column to align them later.
			#if (hl && haxe_ver < 4.3)
			this._columnItems.splice(0, this._columnItems.length);
			#else
			this._columnItems.resize(0);
			#end

			// this first loop sets the y position of items, and it calculates
			// the total height of all items
			while (i < itemCount) {
				var item = items[i];
				if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
				var itemWidth = item.width;
				var itemHeight = item.height;
				if (supportsMultipleColumns
					&& this._columnItems.length > 0
					&& (positionY + itemHeight) > (availableColumnHeight - this._paddingBottom)) {
					// we've reached the end of the column, so go to next
					break;
				}
				this._columnItems.push(item);
				item.y = positionY;
				positionY += itemHeight + this._verticalGap;
				// we compare with > instead of Math.max() because the rest
				// arguments on Math.max() cause extra garbage collection and
				// hurt performance
				if (itemWidth > maxItemWidth) {
					// we need to know the maximum width of the items in the
					// case where the width of the view port needs to be
					// calculated by the layout.
					maxItemWidth = itemWidth;
				}
				i++;
			}

			// this is the total height of all items in the column
			var totalColumnHeight = positionY - this._verticalGap + this._paddingBottom;
			if (totalColumnHeight > maxColumnHeight) {
				maxColumnHeight = totalColumnHeight;
			}

			if (supportsMultipleColumns) {
				// in this section, we handle vertical alignment for the
				// current column. however, we may need to adjust it later if
				// the maxColumnHeight is smaller than the availableColumnHeight.
				var verticalAlignOffsetY = switch (this._verticalAlign) {
					case BOTTOM: availableColumnHeight - totalColumnHeight;
					case MIDDLE: (availableColumnHeight - totalColumnHeight) / 2.0;
					case TOP: 0.0;
					default:
						throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
				}
				if (verticalAlignOffsetY != 0.0) {
					for (item in this._columnItems) {
						if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
							continue;
						}
						item.y += verticalAlignOffsetY;
					}
				}
			}

			for (item in this._columnItems) {
				if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
					continue;
				}
				// handle all other horizontal alignment values. the x position
				// of all items is set here.
				switch (this._columnHorizontalAlign) {
					case JUSTIFY:
						item.x = positionX;
						if (item.width != maxItemWidth) {
							item.width = maxItemWidth;
						}
					case RIGHT:
						item.x = positionX + maxItemWidth - item.width;
					case CENTER:
						item.x = positionX + ((maxItemWidth - item.width) / 2.0);
					case LEFT:
						item.x = positionX;
					default:
						throw new ArgumentError("Unknown column horizontal align: " + this._columnHorizontalAlign);
				}
			}
		} while (i < itemCount);
			// we don't want to keep a reference to any of the items, so clear
			// this cache
		#if (hl && haxe_ver < 4.3)
		this._columnItems.splice(0, this._columnItems.length);
		#else
		this._columnItems.resize(0);
		#end

		var contentColumnHeight = maxColumnHeight;
		if (supportsMultipleColumns && (needsHeight || measurements.height < maxColumnHeight)) {
			// if the maxColumnHeight has changed since any column was aligned,
			// the items in those columns may need to be shifted a bit
			var contentColumnHeight = maxColumnHeight;
			if (measurements.minHeight != null && contentColumnHeight < measurements.minHeight) {
				contentColumnHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && contentColumnHeight > measurements.maxHeight) {
				contentColumnHeight = measurements.maxHeight;
			}
			var verticalAlignOffsetY = switch (this._verticalAlign) {
				case BOTTOM: availableColumnHeight - contentColumnHeight;
				case MIDDLE: (availableColumnHeight - contentColumnHeight) / 2.0;
				case TOP: 0.0;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
			}
			if (verticalAlignOffsetY != 0.0) {
				for (item in items) {
					if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
						continue;
					}
					// previously, we used the maxHeight for alignment,
					// but the max column height may be smaller, so we need
					// to account for the difference
					item.y -= verticalAlignOffsetY;
				}
			}
		}
		if (needsHeight) {
			availableColumnHeight = contentColumnHeight;
		}

		var totalWidth = positionX + maxItemWidth + this._paddingRight;
		// the available width is the width of the viewport. if the explicit
		// width is NaN, we need to calculate the viewport width ourselves
		// based on the total width of all items.
		var availableWidth = measurements.width;
		if (availableWidth == null) {
			availableWidth = totalWidth;
			if (measurements.minWidth != null && availableWidth < measurements.minWidth) {
				availableWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && availableWidth > measurements.maxWidth) {
				availableWidth = measurements.maxWidth;
			}
		}

		if (totalWidth < availableWidth) {
			var horizontalAlignOffset = switch (this._horizontalAlign) {
				case RIGHT: availableWidth - totalWidth;
				case CENTER: (availableWidth - totalWidth) / 2.0;
				case LEFT: 0.0;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
			}
			if (horizontalAlignOffset != 0.0) {
				for (item in items) {
					if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
						continue;
					}
					item.x += horizontalAlignOffset;
				}
			}
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = totalWidth;
		result.contentHeight = availableColumnHeight;
		result.viewPortWidth = availableWidth;
		result.viewPortHeight = availableColumnHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>, measurements:Measurements) {
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if (this._columnHorizontalAlign == JUSTIFY && this._justifyResetEnabled && (item is IMeasureObject)) {
				(cast item : IMeasureObject).resetWidth();
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
		}
	}
}
