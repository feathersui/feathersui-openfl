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
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Positions items of different dimensions from left to right in multiple rows.
	When the width of a row reaches the width of the container, a new row will
	be started. Constrained to the suggested width, the content's total height
	will change as the number of items increases or decreases.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use FlowRowsLayout with layout containers](https://feathersui.com/learn/haxe-openfl/flow-rows-layout/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class FlowRowsLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `FlowRowsLayout` object.

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
		How each row is positioned horizontally (along the x-axis) within the
		container.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by
		this layout.

		The following example aligns each row's content to the right:

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

	private var _rowVerticalAlign:VerticalAlign = TOP;

	/**
		How items in a row are positioned vertically (along the y-axis) within
		that row.

		The following example aligns each row's content to the bottom:

		```haxe
		layout.rowVerticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`
		@see `FlowRowsLayout.justifyResetEnabled`

		@since 1.0.0
	**/
	@:bindable("change")
	public var rowVerticalAlign(get, set):VerticalAlign;

	private function get_rowVerticalAlign():VerticalAlign {
		return this._rowVerticalAlign;
	}

	private function set_rowVerticalAlign(value:VerticalAlign):VerticalAlign {
		if (this._rowVerticalAlign == value) {
			return this._rowVerticalAlign;
		}
		this._rowVerticalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._rowVerticalAlign;
	}

	private var _justifyResetEnabled:Bool = false;

	/**
		Indicates if the height of items should be reset if the
		`rowVerticalAlign` property is set to `VerticalAlign.JUSTIFY`.

		@see `HorizontalLayout.rowVerticalAlign`

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

		@see `FlowRowsLayout.paddingTop`
		@see `FlowRowsLayout.paddingRight`
		@see `FlowRowsLayout.paddingBottom`
		@see `FlowRowsLayout.paddingLeft`

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

		@see `FlowRowsLayout.horizontalGap`
		@see `FlowRowsLayout.verticalGap`

		@since 1.0.0
	**/
	public function setGap(value:Float):Void {
		this.horizontalGap = value;
		this.verticalGap = value;
	}

	private var _rowItems:Array<DisplayObject> = [];

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

		// let's figure out if we can show multiple rows
		var supportsMultipleRows = true;
		var availableRowWidth = measurements.width;
		var needsWidth = availableRowWidth == null;
		if (needsWidth) {
			availableRowWidth = measurements.maxWidth;
			if (availableRowWidth == null) {
				availableRowWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
			if (availableRowWidth == (1.0 / 0.0)) // Math.POSITIVE_INFINITY bug workaround for swf
			{
				supportsMultipleRows = false;
			}
		}

		var i = 0;
		var itemCount = items.length;
		var positionY = this._paddingTop;
		var maxRowWidth = 0.0;
		var maxItemHeight = 0.0;
		do {
			if (i > 0) {
				positionY += maxItemHeight + verticalGap;
			}
			// this section prepares some variables needed for the following loop
			maxItemHeight = 0.0;
			var positionX = this._paddingLeft;
			// we save the items in this row to align them later.
			#if hl
			this._rowItems.splice(0, this._rowItems.length);
			#else
			this._rowItems.resize(0);
			#end

			// this first loop sets the x position of items, and it calculates
			// the total width of all items
			while (i < itemCount) {
				var item = items[i];
				if ((item is ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
				var itemWidth = item.width;
				var itemHeight = item.height;
				if (supportsMultipleRows
					&& this._rowItems.length > 0
					&& (positionX + itemWidth) > (availableRowWidth - this._paddingRight)) {
					// we've reached the end of the row, so go to next
					break;
				}
				this._rowItems.push(item);
				item.x = positionX;
				positionX += itemWidth + this._horizontalGap;
				// we compare with > instead of Math.max() because the rest
				// arguments on Math.max() cause extra garbage collection and
				// hurt performance
				if (itemHeight > maxItemHeight) {
					// we need to know the maximum height of the items in the
					// case where the height of the view port needs to be
					// calculated by the layout.
					maxItemHeight = itemHeight;
				}
				i++;
			}

			// this is the total width of all items in the row
			var totalRowWidth = positionX - this._horizontalGap + this._paddingRight;
			if (totalRowWidth > maxRowWidth) {
				maxRowWidth = totalRowWidth;
			}

			if (supportsMultipleRows) {
				// in this section, we handle horizontal alignment for the
				// current row. however, we may need to adjust it later if
				// the maxRowWidth is smaller than the availableRowWidth.
				var horizontalAlignOffsetX = switch (this._horizontalAlign) {
					case RIGHT: availableRowWidth - totalRowWidth;
					case CENTER: (availableRowWidth - totalRowWidth) / 2.0;
					case LEFT: 0.0;
					default:
						throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
				}
				if (horizontalAlignOffsetX != 0.0) {
					for (item in this._rowItems) {
						if ((item is ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
							continue;
						}
						item.x += horizontalAlignOffsetX;
					}
				}
			}

			for (item in this._rowItems) {
				if ((item is ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
					continue;
				}
				// handle all other vertical alignment values. the y position
				// of all items is set here.
				switch (this._rowVerticalAlign) {
					case JUSTIFY:
						item.y = positionY;
						if (item.height != maxItemHeight) {
							item.height = maxItemHeight;
						}
					case BOTTOM:
						item.y = positionY + maxItemHeight - item.height;
					case MIDDLE:
						item.y = positionY + ((maxItemHeight - item.height) / 2.0);
					case TOP:
						item.y = positionY;
					default:
						throw new ArgumentError("Unknown row vertical align: " + this._rowVerticalAlign);
				}
			}
		} while (i < itemCount);
			// we don't want to keep a reference to any of the items, so clear
			// this cache
		#if hl
		this._rowItems.splice(0, this._rowItems.length);
		#else
		this._rowItems.resize(0);
		#end

		var contentRowWidth = maxRowWidth;
		if (supportsMultipleRows && (needsWidth || measurements.width < maxRowWidth)) {
			// if the maxRowWidth has changed since any row was aligned, the
			// items in those rows may need to be shifted a bit
			var contentRowWidth = maxRowWidth;
			if (measurements.minWidth != null && contentRowWidth < measurements.minWidth) {
				contentRowWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && contentRowWidth > measurements.maxWidth) {
				contentRowWidth = measurements.maxWidth;
			}
			var horizontalAlignOffsetX = switch (this._horizontalAlign) {
				case RIGHT: availableRowWidth - contentRowWidth;
				case CENTER: (availableRowWidth - contentRowWidth) / 2.0;
				case LEFT: 0.0;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
			}
			if (horizontalAlignOffsetX != 0.0) {
				for (item in items) {
					if ((item is ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
					// previously, we used the maxWidth for alignment,
					// but the max row width may be smaller, so we need
					// to account for the difference
					item.x -= horizontalAlignOffsetX;
				}
			}
		}
		if (needsWidth) {
			availableRowWidth = contentRowWidth;
		}

		var totalHeight = positionY + maxItemHeight + this._paddingBottom;
		// the available height is the height of the viewport. if the explicit
		// height is NaN, we need to calculate the viewport height ourselves
		// based on the total height of all items.
		var availableHeight = measurements.height;
		if (availableHeight == null) {
			availableHeight = totalHeight;
			if (measurements.minHeight != null && availableHeight < measurements.minHeight) {
				availableHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && availableHeight > measurements.maxHeight) {
				availableHeight = measurements.maxHeight;
			}
		}

		if (totalHeight < availableHeight) {
			var verticalAlignOffset = switch (this._verticalAlign) {
				case BOTTOM: availableHeight - totalHeight;
				case MIDDLE: (availableHeight - totalHeight) / 2.0;
				case TOP: 0.0;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
			}
			if (verticalAlignOffset != 0.0) {
				for (item in items) {
					if ((item is ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
						continue;
					}
					item.y += verticalAlignOffset;
				}
			}
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = availableRowWidth;
		result.contentHeight = totalHeight;
		result.viewPortWidth = availableRowWidth;
		result.viewPortHeight = availableHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>, measurements:Measurements) {
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if (this._rowVerticalAlign == JUSTIFY && this._justifyResetEnabled && (item is IMeasureObject)) {
				cast(item, IMeasureObject).resetHeight();
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}
}
