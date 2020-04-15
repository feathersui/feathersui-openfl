/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IValidating;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.EventDispatcher;

/**
	Positions and sizes items by anchoring their edges (or center points) to
	to their parent container or to other items in the same container.

	@see [Tutorial: How to use AnchorLayout with layout containers](https://feathersui.com/learn/haxe-openfl/anchor-layout/)
	@see `feathers.layout.AnchorLayoutData`

	@since 1.0.0
**/
class AnchorLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `AnchorLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
				var layoutData:AnchorLayoutData = null;
				if (layoutObject != null && Std.is(layoutObject.layoutData, AnchorLayoutData)) {
					layoutData = cast(layoutObject.layoutData, AnchorLayoutData);
				}
				if (layoutData != null) {
					// optimization: if width and height are known, set them before
					// validation because measurement could be expensive
					if (measurements.width != null) {
						var leftAnchor:Anchor = layoutData.left;
						var rightAnchor:Anchor = layoutData.right;
						if (leftAnchor != null && rightAnchor != null && leftAnchor.relativeTo == null && rightAnchor.relativeTo == null) {
							item.width = measurements.width - leftAnchor.value - rightAnchor.value;
						}
					}
					if (measurements.height != null) {
						var topAnchor:Anchor = layoutData.top;
						var bottomAnchor:Anchor = layoutData.bottom;
						if (topAnchor != null && bottomAnchor != null && topAnchor.relativeTo == null && bottomAnchor.relativeTo == null) {
							item.height = measurements.height - topAnchor.value - bottomAnchor.value;
						}
					}
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}

		var maxX = 0.0;
		var maxY = 0.0;
		var doneItems:Array<DisplayObject> = [];
		while (doneItems.length < items.length) {
			var oldDoneCount = doneItems.length;
			for (item in items) {
				if (doneItems.indexOf(item) != -1) {
					continue;
				}
				var layoutObject:ILayoutObject = null;
				if (Std.is(item, ILayoutObject)) {
					layoutObject = cast(item, ILayoutObject);
					if (!layoutObject.includeInLayout) {
						doneItems.push(item);
						continue;
					}
				}
				var layoutData:AnchorLayoutData = null;
				if (layoutObject != null && Std.is(layoutObject.layoutData, AnchorLayoutData)) {
					layoutData = cast(layoutObject.layoutData, AnchorLayoutData);
				}

				if (Std.is(item, IValidating)) {
					cast(item, IValidating).validateNow();
				}

				if (layoutData == null) {
					var itemMaxX = item.x + item.width;
					if (maxX < itemMaxX) {
						maxX = itemMaxX;
					}
					var itemMaxY = item.y + item.height;
					if (maxY < itemMaxY) {
						maxY = itemMaxY;
					}
				} else // has AnchorLayoutData
				{
					if (layoutData.top != null) {
						var top:Anchor = layoutData.top;
						var value = top.value;
						var relativeTo = top.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							continue;
						}
						item.y = value;
						if (relativeTo != null) {
							item.y += relativeTo.y + relativeTo.height;
						}
					}
					if (layoutData.left != null) {
						var left:Anchor = layoutData.left;
						var value = left.value;
						var relativeTo = left.relativeTo;
						if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
							continue;
						}
						item.x = value;
						if (relativeTo != null) {
							item.x += relativeTo.x + relativeTo.width;
						}
					}
					if (layoutData.verticalCenter == null) {
						var itemMaxY = item.y + item.height;
						if (layoutData.bottom != null) {
							var bottom:Anchor = layoutData.bottom;
							var value = bottom.value;
							itemMaxY += value;
						}
						if (maxY < itemMaxY) {
							maxY = itemMaxY;
						}
					} else {
						var itemMaxY = item.height;
						if (maxY < itemMaxY) {
							maxY = itemMaxY;
						}
					}
					if (layoutData.horizontalCenter == null) {
						var itemMaxX = item.x + item.width;
						if (layoutData.right != null) {
							var right:Anchor = layoutData.right;
							var value = right.value;
							itemMaxX += value;
						}
						if (maxX < itemMaxX) {
							maxX = itemMaxX;
						}
					} else {
						var itemMaxX = item.width;
						if (maxX < itemMaxX) {
							maxX = itemMaxX;
						}
					}
				}
				doneItems.push(item);
			}
			if (oldDoneCount == doneItems.length) {
				throw new IllegalOperationError("AnchorLayout failed.");
			}
		}
		var viewPortWidth = 0.0;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			viewPortWidth = maxX;
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = 0.0;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			viewPortHeight = maxY;
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}
		doneItems.resize(0);
		while (doneItems.length < items.length) {
			var oldDoneCount = doneItems.length;
			for (item in items) {
				if (doneItems.indexOf(item) != -1) {
					// already done
					continue;
				}
				var layoutObject:ILayoutObject = null;
				if (Std.is(item, ILayoutObject)) {
					layoutObject = cast(item, ILayoutObject);
					if (!layoutObject.includeInLayout) {
						doneItems.push(item);
						continue;
					}
				}
				var layoutData:AnchorLayoutData = null;
				if (layoutObject != null && Std.is(layoutObject.layoutData, AnchorLayoutData)) {
					layoutData = cast(layoutObject.layoutData, AnchorLayoutData);
				}
				if (layoutData == null) {
					doneItems.push(item);
					continue;
				}
				if (layoutData.top != null) {
					var top:Anchor = layoutData.top;
					var relativeTo = top.relativeTo;
					if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
						continue;
					}
					var y = top.value;
					if (relativeTo != null) {
						y += relativeTo.y + relativeTo.height;
					}
					item.y = y;
				}
				if (layoutData.left != null) {
					var left:Anchor = layoutData.left;
					var relativeTo = left.relativeTo;
					if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
						continue;
					}
					var x = left.value;
					if (relativeTo != null) {
						x += relativeTo.x + relativeTo.width;
					}
					item.x = x;
				}
				if (layoutData.bottom != null) {
					var bottom:Anchor = layoutData.bottom;
					var relativeTo = bottom.relativeTo;
					if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
						continue;
					}
					var bottomPixels = bottom.value;
					var bottomEdge = viewPortHeight;
					if (relativeTo != null) {
						bottomEdge = relativeTo.y;
					}
					if (layoutData.top == null) {
						item.y = bottomEdge - bottomPixels - item.height;
					} else {
						var itemHeight = bottomEdge - bottomPixels - item.y;
						if (itemHeight < 0.0) {
							itemHeight = 0.0;
						}
						if (item.height != itemHeight) {
							// to ensure that the item can continue to auto-size
							// itself, don't set the explicit size unless needed
							item.height = itemHeight;
						}
					}
				} else if (layoutData.verticalCenter != null) {
					item.y = layoutData.verticalCenter + (viewPortHeight - item.height) / 2.0;
				}
				if (layoutData.right != null) {
					var right:Anchor = layoutData.right;
					var relativeTo = right.relativeTo;
					if (relativeTo != null && doneItems.indexOf(relativeTo) == -1) {
						continue;
					}
					var rightPixels = right.value;
					var rightEdge = viewPortWidth;
					if (relativeTo != null) {
						rightEdge = relativeTo.x;
					}
					if (layoutData.left == null) {
						item.x = rightEdge - rightPixels - item.width;
					} else {
						var itemWidth = rightEdge - rightPixels - item.x;
						if (itemWidth < 0.0) {
							itemWidth = 0.0;
						}
						if (item.width != itemWidth) {
							// to ensure that the item can continue to auto-size
							// itself, don' t set the explicit size unless needed item.width = itemWidth;
							item.width = itemWidth;
						}
					}
				} else if (layoutData.horizontalCenter != null) {
					item.x = layoutData.horizontalCenter + (viewPortWidth - item.width) / 2.0;
				}
				doneItems.push(item);
			}
			if (oldDoneCount == doneItems.length) {
				throw new IllegalOperationError("AnchorLayout failed.");
			}
		}
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = viewPortWidth;
		result.contentHeight = viewPortHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}
}

class Anchor {
	public function new(value:Float, ?relativeTo:DisplayObject) {
		this.value = value;
		this.relativeTo = relativeTo;
	}

	public var value:Float;
	public var relativeTo:Null<DisplayObject>;
}

abstract AbstractAnchor(Anchor) from Anchor to Anchor {
	/**
		Converts a `Float` value, measured in pixels, to an `Anchor`.

		@since 1.0.0
	**/
	@:from
	public static function fromPixels(pixels:Float):AbstractAnchor {
		return new Anchor(pixels);
	}

	/**
		Converts a `DisplayObject` to an `Anchor`.

		@since 1.0.0
	**/
	@:from
	public static function fromDisplayObject(relativeTo:DisplayObject):AbstractAnchor {
		return new Anchor(0.0, relativeTo);
	}
}
