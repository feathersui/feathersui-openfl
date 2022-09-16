/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseDividedBox;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.layout.VDividedBoxLayout;
import feathers.utils.DisplayUtil;
import openfl.display.DisplayObject;
#if (lime && !flash && !commonjs)
import lime.ui.MouseCursor as LimeMouseCursor;
#end

/**
	A container that displays draggable dividers between each of its children,
	which are positioned from top to bottom in a single column.

	@see [Tutorial: How to use the HDividedBox and VDividedBox components](https://feathersui.com/learn/haxe-openfl/divided-box/)
	@see `feathers.controls.VDividedBox`

	@since 1.0.0
**/
class VDividedBox extends BaseDividedBox {
	/**
		Creates a new `VDividedBox` object.

		@since 1.0.0
	**/
	public function new() {
		this.initializeVDividedBoxTheme();

		super();

		#if (lime && !flash && !commonjs)
		this.resizeCursor = LimeMouseCursor.RESIZE_NS;
		#end
	}

	private var _vDividedBoxLayout:VDividedBoxLayout;
	private var _customItemHeights:Array<Null<Float>> = [];
	private var _fallbackFluidIndex:Int = -1;
	private var _resizeStartStageY:Float;
	private var _resizeStartHeight1:Float;
	private var _resizeStartHeight2:Float;

	override private function addItemAt(child:DisplayObject, index:Int):DisplayObject {
		var result = super.addItemAt(child, index);
		var explicitHeight:Null<Float> = null;
		if ((child is IMeasureObject)) {
			var measureChild = cast(child, IMeasureObject);
			explicitHeight = measureChild.explicitHeight;
		}
		this._customItemHeights.insert(index, explicitHeight);
		var layoutIndex = this._layoutItems.indexOf(child);
		if (explicitHeight == null) {
			if (this._fallbackFluidIndex == -1 || layoutIndex > this._fallbackFluidIndex) {
				this._fallbackFluidIndex = layoutIndex;
			}
		}
		return result;
	}

	override private function removeItem(child:DisplayObject):DisplayObject {
		var index = this.items.indexOf(child);
		var layoutIndex = this._layoutItems.indexOf(child);
		if (this._fallbackFluidIndex == layoutIndex) {
			this._fallbackFluidIndex = -1;
		}
		var result = super.removeItem(child);
		if (index != -1) {
			this._customItemHeights.splice(index, 1);
		}
		return result;
	}

	private function initializeVDividedBoxTheme():Void {
		feathers.themes.steel.components.SteelVDividedBoxStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._vDividedBoxLayout == null) {
			this._vDividedBoxLayout = new VDividedBoxLayout();
		}
		this._vDividedBoxLayout.customItemHeights = this._customItemHeights;
		this.layout = this._vDividedBoxLayout;
	}

	override private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._vDividedBoxLayout.fallbackFluidIndex = this._fallbackFluidIndex;
		this._ignoreChildChanges = oldIgnoreChildChanges;
		super.handleLayout();
	}

	override private function prepareResize(dividerIndex:Int, stageX:Float, stageY:Float):Void {
		this._resizeStartStageY = stageY;

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		this._resizeStartHeight1 = firstItem.height;
		this._resizeStartHeight2 = secondItem.height;

		if (this._currentResizeDraggingSkin != null) {
			var divider = this.dividers[dividerIndex];
			this._currentResizeDraggingSkin.x = divider.x;
			this._currentResizeDraggingSkin.width = divider.width;
			if ((this._currentResizeDraggingSkin is IValidating)) {
				cast(this._currentResizeDraggingSkin, IValidating).validateNow();
			}
			this._currentResizeDraggingSkin.y = divider.y + (divider.height - this._currentResizeDraggingSkin.height) / 2.0;
		}
	}

	override private function commitResize(dividerIndex:Int, stageX:Float, stageY:Float, live:Bool):Void {
		var offsetY = stageY - this._resizeStartStageY;
		offsetY *= DisplayUtil.getConcatenatedScaleY(this);

		if (live && !this.liveDragging) {
			if (this._currentResizeDraggingSkin != null) {
				var divider = this.dividers[dividerIndex];
				this._currentResizeDraggingSkin.x = divider.x;
				this._currentResizeDraggingSkin.width = divider.width;
				if ((this._currentResizeDraggingSkin is IValidating)) {
					cast(this._currentResizeDraggingSkin, IValidating).validateNow();
				}
				this._currentResizeDraggingSkin.y = divider.y + offsetY + (divider.height - this._currentResizeDraggingSkin.height) / 2.0;
			}
			return;
		}

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];

		var totalHeight = this._resizeStartHeight1 + this._resizeStartHeight2;

		var secondItemHeight = this._resizeStartHeight2 - offsetY;
		if ((secondItem is IMeasureObject)) {
			var secondMeasureItem = cast(secondItem, IMeasureObject);
			if (secondMeasureItem.explicitMinHeight != null && secondItemHeight < secondMeasureItem.explicitMinHeight) {
				secondItemHeight = secondMeasureItem.explicitMinHeight;
			} else if (secondMeasureItem.explicitMaxHeight != null && secondItemHeight > secondMeasureItem.explicitMaxHeight) {
				secondItemHeight = secondMeasureItem.explicitMaxHeight;
			}
		}
		if (secondItemHeight < 0.0) {
			secondItemHeight = 0.0;
		} else if (secondItemHeight > totalHeight) {
			secondItemHeight = totalHeight;
		}

		// prefer the first item's restrictions by applying them last
		var firstItemHeight = totalHeight - secondItemHeight;
		if ((firstItem is IMeasureObject)) {
			var firstMeasureItem = cast(firstItem, IMeasureObject);
			if (firstMeasureItem.explicitMinHeight != null && firstItemHeight < firstMeasureItem.explicitMinHeight) {
				firstItemHeight = firstMeasureItem.explicitMinHeight;
			} else if (firstMeasureItem.explicitMaxHeight != null && firstItemHeight > firstMeasureItem.explicitMaxHeight) {
				firstItemHeight = firstMeasureItem.explicitMaxHeight;
			}
		}
		if (firstItemHeight < 0.0) {
			firstItemHeight = 0.0;
		} else if (firstItemHeight > totalHeight) {
			firstItemHeight = totalHeight;
		}

		secondItemHeight = totalHeight - firstItemHeight;

		this._customItemHeights[dividerIndex] = firstItemHeight;
		this._customItemHeights[dividerIndex + 1] = secondItemHeight;
		this.setInvalid(LAYOUT);
	}
}
