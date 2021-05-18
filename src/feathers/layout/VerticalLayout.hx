/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

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
	Positions items from top to bottom in a single column.

	@event openfl.events.Event.CHANGE

	@see [Tutorial: How to use VerticalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/vertical-layout/)
	@see `feathers.layout.VerticalLayoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class VerticalLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `VerticalLayout` object.

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

	private var _gap:Float = 0.0;

	/**
		The space, in pixels, between each two adjacent items in the layout.

		In the following example, the layout's gap is set to 20 pixels:

		```hx
		layout.gap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
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

	private var _horizontalAlign:HorizontalAlign = LEFT;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		container.

		The following example aligns the container's content to the right:

		```hx
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
		@see `feathers.layout.HorizontalAlign.JUSTIFY`

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
		container.

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

	private var _justifyResetEnabled:Bool = false;

	/**
		Indicates if the width of items should be reset if the `horizontalAlign`
		property is set to `HorizontalAlign.JUSTIFY` and the explicit width of
		the parent container is not set.

		@see `VerticalLayout.horizontalAlign`

		@since 1.0.0
	**/
	@:flash.property
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

		@see `VerticalLayout.paddingTop`
		@see `VerticalLayout.paddingRight`
		@see `VerticalLayout.paddingBottom`
		@see `VerticalLayout.paddingLeft`

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
		this.validateItems(items, measurements);
		this.applyPercentHeight(items, measurements.height, measurements.minHeight, measurements.maxHeight);

		var contentWidth = 0.0;
		var contentHeight = this._paddingTop;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (contentWidth < item.width) {
				contentWidth = item.width;
			}
			item.y = contentHeight;
			contentHeight += item.height + this._gap;
		}
		var maxItemWidth = contentWidth;
		contentWidth += this._paddingLeft + this._paddingRight;
		contentHeight += this._paddingBottom;
		if (items.length > 0) {
			contentHeight -= this._gap;
		}

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

		this.applyPercentWidth(items, viewPortWidth);
		this.applyHorizontalAlign(items, maxItemWidth, viewPortWidth);
		this.applyVerticalAlign(items, contentHeight - this._paddingTop - this._paddingBottom, viewPortHeight);

		if (contentWidth < viewPortWidth) {
			contentWidth = viewPortWidth;
		}
		if (contentHeight < viewPortHeight) {
			contentHeight = viewPortHeight;
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>, measurements:Measurements) {
		var isJustified = this._horizontalAlign == JUSTIFY;
		var justifyWidth = measurements.width;
		if (justifyWidth != null) {
			justifyWidth -= (this._paddingLeft + this._paddingRight);
		}
		for (item in items) {
			if (isJustified) {
				if (justifyWidth != null) {
					item.width = justifyWidth;
				} else if (this._justifyResetEnabled && (item is IMeasureObject)) {
					cast(item, IMeasureObject).resetWidth();
				}
			} else if (justifyWidth != null) {
				var percentWidth:Null<Float> = null;
				if ((item is ILayoutObject)) {
					var layoutItem = cast(item, ILayoutObject);
					if (!layoutItem.includeInLayout) {
						continue;
					}
					var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
					if (layoutData != null) {
						if (percentWidth < 0.0) {
							percentWidth = 0.0;
						} else if (percentWidth > 100.0) {
							percentWidth = 100.0;
						}
						percentWidth = layoutData.percentWidth;
					}
				}
				if (percentWidth != null) {
					item.width = justifyWidth * (percentWidth / 100.0);
				}
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, maxItemWidth:Float, viewPortWidth:Float):Void {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this._horizontalAlign) {
				case RIGHT:
					item.x = Math.max(this._paddingLeft, this._paddingLeft + (viewPortWidth - this._paddingLeft - this._paddingRight) - item.width);
				case CENTER:
					item.x = Math.max(this._paddingLeft, this._paddingLeft + (viewPortWidth - this._paddingLeft - this._paddingRight - item.width) / 2.0);
				case LEFT:
					item.x = this._paddingLeft;
				case JUSTIFY:
					item.x = this._paddingLeft;
					item.width = viewPortWidth - this._paddingLeft - this._paddingRight;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
			}
		}
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, contentHeight:Float, viewPortHeight:Float):Void {
		if (this._verticalAlign != BOTTOM && this._verticalAlign != MIDDLE) {
			return;
		}
		var maxAlignmentHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		if (contentHeight >= maxAlignmentHeight) {
			return;
		}
		var verticalOffset = 0.0;
		if (this._verticalAlign == BOTTOM) {
			verticalOffset = maxAlignmentHeight - contentHeight;
		} else if (this._verticalAlign == MIDDLE) {
			verticalOffset = (maxAlignmentHeight - contentHeight) / 2.0;
		}
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.y = Math.max(this._paddingTop, item.y + verticalOffset);
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, viewPortWidth:Float):Void {
		var availableWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		for (item in items) {
			if (!(item is ILayoutObject)) {
				continue;
			}
			var layoutItem = cast(item, ILayoutObject);
			if (!layoutItem.includeInLayout) {
				continue;
			}
			var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
			if (layoutData == null) {
				continue;
			}
			var percentWidth = layoutData.percentWidth;
			if (percentWidth == null) {
				continue;
			}
			if (percentWidth < 0.0) {
				percentWidth = 0.0;
			} else if (percentWidth > 100.0) {
				percentWidth = 100.0;
			}
			var itemWidth = availableWidth * percentWidth / 100.0;
			if ((item is IMeasureObject)) {
				var measureItem = cast(item, IMeasureObject);
				var itemMinWidth = measureItem.explicitMinWidth;
				if (itemMinWidth != null) {
					// we try to respect the minWidth, but not
					// when it's larger than 100%
					if (itemMinWidth > availableWidth) {
						itemMinWidth = availableWidth;
					}
					if (itemWidth < itemMinWidth) {
						itemWidth = itemMinWidth;
					}
				}
				var itemMaxWidth = measureItem.explicitMaxWidth;
				if (itemMaxWidth != null && itemWidth > itemMaxWidth) {
					itemWidth = itemMaxWidth;
				}
			}
			item.width = itemWidth;
		}
	}

	private function applyPercentHeight(items:Array<DisplayObject>, explicitHeight:Null<Float>, explicitMinHeight:Null<Float>,
			explicitMaxHeight:Null<Float>):Void {
		var pendingItems:Array<ILayoutObject> = [];
		var totalMeasuredHeight = 0.0;
		var totalMinHeight = 0.0;
		var totalPercentHeight = 0.0;
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
				var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
				if (layoutData != null) {
					var percentHeight = layoutData.percentHeight;
					if (percentHeight != null) {
						if (percentHeight < 0.0) {
							percentHeight = 0.0;
						}
						if ((layoutItem is IMeasureObject)) {
							var measureItem = cast(layoutItem, IMeasureObject);
							totalMinHeight += measureItem.minHeight;
						}
						totalPercentHeight += percentHeight;
						totalMeasuredHeight += this._gap;
						pendingItems.push(layoutItem);
						continue;
					}
				}
			}
			totalMeasuredHeight += item.height + this._gap;
		}
		totalMeasuredHeight -= this._gap;
		totalMeasuredHeight += this._paddingTop + this._paddingBottom;
		if (totalPercentHeight < 100.0) {
			totalPercentHeight = 100.0;
		}
		var remainingHeight = 0.0;
		if (explicitHeight != null) {
			remainingHeight = explicitHeight;
		} else {
			remainingHeight = totalMeasuredHeight + totalMinHeight;
			if (explicitMinHeight != null && remainingHeight < explicitMinHeight) {
				remainingHeight = explicitMinHeight;
			} else if (explicitMaxHeight != null && remainingHeight > explicitMaxHeight) {
				remainingHeight = explicitMaxHeight;
			}
		}
		remainingHeight -= totalMeasuredHeight;
		if (remainingHeight < 0.0) {
			remainingHeight = 0.0;
		}
		var needsAnotherPass = true;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			var percentToPixels = remainingHeight / totalPercentHeight;
			for (layoutItem in pendingItems) {
				var layoutData = cast(layoutItem.layoutData, VerticalLayoutData);
				var percentHeight = layoutData.percentHeight;
				if (percentHeight < 0.0) {
					percentHeight = 0.0;
				}
				var itemHeight = percentToPixels * percentHeight;
				if ((layoutItem is IMeasureObject)) {
					var measureItem = cast(layoutItem, IMeasureObject);
					var itemMinHeight = measureItem.explicitMinHeight;
					if (itemMinHeight != null && itemMinHeight > remainingHeight) {
						// we try to respect the item's minimum height, but
						// if it's larger than the remaining space, we need
						// to force it to fit
						itemMinHeight = remainingHeight;
					}
					if (itemHeight < itemMinHeight) {
						itemHeight = itemMinHeight;
						remainingHeight -= itemHeight;
						totalPercentHeight -= percentHeight;
						pendingItems.remove(layoutItem);
						needsAnotherPass = true;
					}
					// we don't check maxHeight here because it is used in
					// validateItems() for performance optimization, so it
					// isn't a real maximum
				}
				cast(layoutItem, DisplayObject).height = itemHeight;
				if ((layoutItem is IValidating)) {
					// changing the height of the item may cause its width
					// to change, so we need to validate. the width is needed
					// for measurement.
					cast(layoutItem, IValidating).validateNow();
				}
			}
		}
	}
}
