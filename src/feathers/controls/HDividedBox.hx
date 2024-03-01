/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseDividedBox;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.layout.HDividedBoxLayout;
import feathers.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.events.Event;
#if (lime && !flash && !commonjs)
import lime.ui.MouseCursor as LimeMouseCursor;
#end

/**
	A container that displays draggable dividers between each of its children,
	which are positioned from left to right in a single row.

	@see [Tutorial: How to use the HDividedBox and VDividedBox components](https://feathersui.com/learn/haxe-openfl/divided-box/)
	@see `feathers.controls.VDividedBox`

	@since 1.0.0
**/
class HDividedBox extends BaseDividedBox {
	/**
		Creates a new `HDividedBox` object.

		@since 1.0.0
	**/
	public function new() {
		this.initializeHDividedBoxTheme();

		super();

		#if (lime && !flash && !commonjs)
		this.resizeCursor = LimeMouseCursor.RESIZE_WE;
		#end
	}

	private var _hDividedBoxLayout:HDividedBoxLayout;
	private var _customItemWidths:Array<Null<Float>> = [];
	private var _fallbackFluidIndex:Int = -1;
	private var _resizeStartStageX:Float;
	private var _resizeStartWidth1:Float;
	private var _resizeStartWidth2:Float;

	private function initializeHDividedBoxTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelHDividedBoxStyles.initialize();
		#end
	}

	override private function addItemAt(child:DisplayObject, index:Int):DisplayObject {
		var result = super.addItemAt(child, index);
		var explicitWidth:Null<Float> = null;
		if ((child is IMeasureObject)) {
			var measureChild:IMeasureObject = cast child;
			explicitWidth = measureChild.explicitWidth;
		}
		this._customItemWidths.insert(index, explicitWidth);
		var layoutIndex = this._layoutItems.indexOf(child);
		if (explicitWidth == null) {
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
			this._customItemWidths.splice(index, 1);
		}
		return result;
	}

	override private function initialize():Void {
		super.initialize();

		if (this._hDividedBoxLayout == null) {
			this._hDividedBoxLayout = new HDividedBoxLayout();
		}
		this._hDividedBoxLayout.customItemWidths = this._customItemWidths;
		this.layout = this._hDividedBoxLayout;
	}

	override private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._hDividedBoxLayout.fallbackFluidIndex = this._fallbackFluidIndex;
		this._ignoreChildChanges = oldIgnoreChildChanges;
		super.handleLayout();
	}

	override private function prepareResize(dividerIndex:Int, stageX:Float, stageY:Float):Void {
		this._resizeStartStageX = stageX;

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		this._resizeStartWidth1 = firstItem.width;
		this._resizeStartWidth2 = secondItem.width;

		if (this._currentResizeDraggingSkin != null) {
			var divider = this.dividers[dividerIndex];
			this._currentResizeDraggingSkin.y = divider.y;
			this._currentResizeDraggingSkin.height = divider.height;
			if ((this._currentResizeDraggingSkin is IValidating)) {
				(cast this._currentResizeDraggingSkin : IValidating).validateNow();
			}
			this._currentResizeDraggingSkin.x = divider.x + (divider.width - this._currentResizeDraggingSkin.width) / 2.0;
		}
	}

	override private function commitResize(dividerIndex:Int, stageX:Float, stageY:Float, live:Bool):Void {
		var offsetX = stageX - this._resizeStartStageX;
		offsetX *= DisplayUtil.getConcatenatedScaleX(this);

		if (live && !this.liveDragging) {
			if (this._currentResizeDraggingSkin != null) {
				var divider = this.dividers[dividerIndex];
				this._currentResizeDraggingSkin.y = divider.y;
				this._currentResizeDraggingSkin.height = divider.height;
				if ((this._currentResizeDraggingSkin is IValidating)) {
					(cast this._currentResizeDraggingSkin : IValidating).validateNow();
				}
				this._currentResizeDraggingSkin.x = divider.x + offsetX + (divider.width - this._currentResizeDraggingSkin.width) / 2.0;
			}
			return;
		}

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];

		var totalWidth = this._resizeStartWidth1 + this._resizeStartWidth2;

		var secondItemWidth = this._resizeStartWidth2 - offsetX;
		if ((secondItem is IMeasureObject)) {
			var secondMeasureItem:IMeasureObject = cast secondItem;
			if (secondMeasureItem.explicitMinWidth != null && secondItemWidth < secondMeasureItem.explicitMinWidth) {
				secondItemWidth = secondMeasureItem.explicitMinWidth;
			} else if (secondMeasureItem.explicitMaxWidth != null && secondItemWidth > secondMeasureItem.explicitMaxWidth) {
				secondItemWidth = secondMeasureItem.explicitMaxWidth;
			}
		}
		if (secondItemWidth < 0.0) {
			secondItemWidth = 0.0;
		} else if (secondItemWidth > totalWidth) {
			secondItemWidth = totalWidth;
		}

		// prefer the first item's restrictions by applying them last
		var firstItemWidth = totalWidth - secondItemWidth;
		if ((firstItem is IMeasureObject)) {
			var firstMeasureItem:IMeasureObject = cast firstItem;
			if (firstMeasureItem.explicitMinWidth != null && firstItemWidth < firstMeasureItem.explicitMinWidth) {
				firstItemWidth = firstMeasureItem.explicitMinWidth;
			} else if (firstMeasureItem.explicitMaxWidth != null && firstItemWidth > firstMeasureItem.explicitMaxWidth) {
				firstItemWidth = firstMeasureItem.explicitMaxWidth;
			}
		}
		if (firstItemWidth < 0.0) {
			firstItemWidth = 0.0;
		} else if (firstItemWidth > totalWidth) {
			firstItemWidth = totalWidth;
		}

		secondItemWidth = totalWidth - firstItemWidth;

		this._customItemWidths[dividerIndex] = firstItemWidth;
		this._customItemWidths[dividerIndex + 1] = secondItemWidth;
		this.setInvalid(LAYOUT);
	}

	override private function baseDividedBox_child_resizeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		var child:DisplayObject = cast event.currentTarget;
		var index = this.items.indexOf(child);
		if (index == -1) {
			return;
		}
		var explicitWidth:Null<Float> = null;
		if ((child is IMeasureObject)) {
			var measureChild:IMeasureObject = cast child;
			explicitWidth = measureChild.explicitWidth;
		}
		this._customItemWidths[index] = explicitWidth;
		var layoutIndex = this._layoutItems.indexOf(child);
		if (explicitWidth == null) {
			if (this._fallbackFluidIndex == -1 || layoutIndex > this._fallbackFluidIndex) {
				this._fallbackFluidIndex = layoutIndex;
			}
		}
		this.setInvalid(LAYOUT);
	}
}
