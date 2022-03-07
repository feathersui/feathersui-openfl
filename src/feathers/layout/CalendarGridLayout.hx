/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
	Positions weekday label and date buttons in a `DatePicker` component.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see `feathers.controls.DatePicker`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class CalendarGridLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `CalendarGridLayout` object.

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

	/**
		Sets all four padding properties to the same value.

		@see `CalendarGridLayout.paddingTop`
		@see `CalendarGridLayout.paddingRight`
		@see `CalendarGridLayout.paddingBottom`
		@see `CalendarGridLayout.paddingLeft`

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

		@see `CalendarGridLayout.horizontalGap`
		@see `CalendarGridLayout.verticalGap`

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

		var horizontalTileCount = 7;
		var verticalTileCount = Math.ceil(items.length / horizontalTileCount);

		var viewPortWidth = measurements.width;
		if (viewPortWidth != null) {
			var availableWidth = viewPortWidth
				- this._paddingLeft
				- this._paddingRight
				- (this._horizontalGap * horizontalTileCount)
				+ this._horizontalGap;
			tileWidth = availableWidth / horizontalTileCount;
		} else {
			viewPortWidth = this._paddingLeft + this._paddingRight + horizontalTileCount * (tileWidth + this._horizontalGap) - this._horizontalGap;
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}

		var viewPortHeight = measurements.height;
		if (viewPortHeight != null) {
			var availableHeight = viewPortHeight - this._paddingTop - this._paddingBottom - (this._verticalGap * verticalTileCount) + this._verticalGap;
			tileHeight = availableHeight / verticalTileCount;
		} else {
			viewPortHeight = this._paddingTop + this._paddingBottom + verticalTileCount * (tileHeight + this._verticalGap) - this._verticalGap;
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		var currentColumnCount = 0;
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
				xPosition = this._paddingLeft;
				yPosition += tileHeight + this._verticalGap;
				currentColumnCount = 0;
			}

			item.x = xPosition;
			item.y = yPosition;

			xPosition += tileWidth + this._horizontalGap;
			currentColumnCount++;
		}
		yPosition += tileHeight + this.paddingBottom;

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = viewPortWidth;
		result.contentHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
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
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}
}
