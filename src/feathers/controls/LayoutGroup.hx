/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.MeasurementsUtil;
import feathers.themes.steel.components.SteelLayoutGroupStyles;
import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.AutoSizeMode;
import feathers.layout.ILayout;
import feathers.layout.ILayoutObject;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Point;

/**
	A generic container that supports layouts and automatically sizes itself
	based on its content.

	The following example creates a layout group with a horizontal layout and
	adds two buttons to it:

	```hx
	var group = new LayoutGroup();
	var layout = new HorizontalLayout();
	layout.gap = 20.0;
	layout.padding = 20.0;
	group.layout = layout;
	this.addChild(group);

	var yesButton = new Button();
	yesButton.text = "Yes";
	group.addChild(yesButton);

	var noButton = new Button();
	noButton.text = "No";
	group.addChild(noButton);
	```

	@see [Tutorial: How to use the LayoutGroup component](https://feathersui.com/learn/haxe-openfl/layout-group/)
	@see `feathers.controls.ScrollContainer` is a layout container that supports scrolling

	@since 1.0.0
**/
@defaultXmlProperty("xmlContent")
@:styleContext
class LayoutGroup extends FeathersControl {
	/**
		A variant used to style the group as a tool bar. Variants allow themes
		to provide an assortment of different appearances for the same type of
		UI component.

		The following example uses this variant:

		```hx
		var group = new LayoutGroup();
		group.variant = LayoutGroup.VARIANT_TOOL_BAR;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_TOOL_BAR = "toolBar";

	/**
		Creates a new `LayoutGroup` object.

		@since 1.0.0
	**/
	public function new() {
		initializeLayoutGroupTheme();

		super();
		this.addEventListener(Event.ADDED_TO_STAGE, layoutGroup_addedToStageHandler);
	}

	private var items:Array<DisplayObject> = [];

	/**
		The layout algorithm used to position and size the group's items.

		The following example tells the group to use a vertical layout:

		```hx
		var layout = new VerticalLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		layout.horizontalAlign = CENTER;
		group.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
	private var _layoutMeasurements:Measurements = new Measurements();
	private var _ignoreChildChanges:Bool = false;
	private var _ignoreChildChangesButSetFlags:Bool = false;
	private var _ignoreLayoutChanges:Bool = false;
	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example passes a bitmap for the layout group to use as a
		background skin:

		```hx
		group.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `LayoutGroup.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a disabled background skin:

		```hx
		group.disabledBackgroundSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@default null

		@see `LayoutGroup.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		Determines how the layout group will set its own size when its
		dimensions (width and height) aren't set explicitly.

		In the following example, the layout group will be sized to match the
		stage:

		```hx
		group.autoSizeMode = STAGE;
		```

		Usually defaults to `AutoSizeMode.CONTENT`. However, if this component
		is the root of the OpenFL display list, defaults to `AutoSizeMode.STAGE`
		instead.

		@see `feathers.layout.AutoSizeMode.STAGE`
		@see `feathers.layout.AutoSizeMode.CONTENT`

		@since 1.0.0
	**/
	public var autoSizeMode(default, set):AutoSizeMode = CONTENT;

	private function set_autoSizeMode(value:AutoSizeMode):AutoSizeMode {
		if (this.autoSizeMode == value) {
			return this.autoSizeMode;
		}
		this.autoSizeMode = value;
		this.setInvalid(InvalidationFlag.SIZE);
		if (this.stage != null) {
			if (this.autoSizeMode == STAGE) {
				this.stage.addEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
				this.addEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			} else {
				this.stage.removeEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			}
		}
		return this.autoSizeMode;
	}

	private var _currentLayout:ILayout;

	@:getter(numChildren)
	#if !flash override #end private function get_numChildren():Int {
		return this.items.length;
	}

	private var _numChildren(get, never):Int;

	private function get__numChildren():Int {
		return super.numChildren;
	}

	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		var oldIndex = this.items.indexOf(child);
		if (oldIndex == index) {
			return child;
		}
		child.addEventListener(Event.RESIZE, layoutGroup_child_resizeHandler);
		if (Std.is(child, ILayoutObject)) {
			child.addEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, layoutGroup_child_layoutDataChangeHandler, false, 0, true);
		}
		if (oldIndex >= 0) {
			this.items.remove(child);
		}
		index = this.getPrivateIndexForPublicIndex(index);
		// insert into the array first, so that display list APIs work in an
		// Event.ADDED listener
		this.items.insert(index, child);
		var result = this._addChildAt(child, index);
		this.setInvalid(InvalidationFlag.LAYOUT);
		return result;
	}

	#if flash
	override public function addChild(child:DisplayObject):DisplayObject {
		return this.addChildAt(child, this.numChildren);
	}
	#end

	private function _addChild(child:DisplayObject):DisplayObject {
		return super.addChildAt(child, this._numChildren);
	}

	private function _addChildAt(child:DisplayObject, index:Int):DisplayObject {
		return super.addChildAt(child, index);
	}

	override public function removeChild(child:DisplayObject):DisplayObject {
		if (child == null || child.parent != this) {
			return child;
		}
		child.removeEventListener(Event.RESIZE, layoutGroup_child_resizeHandler);
		if (Std.is(child, ILayoutObject)) {
			child.removeEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, layoutGroup_child_layoutDataChangeHandler);
		}
		this.items.remove(child);
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this._removeChild(child);
	}

	private function _removeChild(child:DisplayObject):DisplayObject {
		return super.removeChild(child);
	}

	override public function removeChildAt(index:Int):DisplayObject {
		if (index >= 0 && index < this.items.length) {
			return this.removeChild(this.items[index]);
		}
		return null;
	}

	private function _removeChildAt(index:Int):DisplayObject {
		return super.removeChildAt(index);
	}

	override public function getChildIndex(child:DisplayObject):Int {
		return this.items.indexOf(child);
	}

	private function _getChildIndex(child:DisplayObject):Int {
		return super.getChildIndex(child);
	}

	override public function setChildIndex(child:DisplayObject, index:Int):Void {
		var oldIndex = this.getChildIndex(child);
		if (oldIndex == index) {
			// nothing to change
			return;
		}
		this._setChildIndex(child, this.getPrivateIndexForPublicIndex(index));
		this.items.remove(child);
		this.items.insert(index, child);
		this.setInvalid(InvalidationFlag.LAYOUT);
	}

	private function _setChildIndex(child:DisplayObject, index:Int):Void {
		super.setChildIndex(child, index);
	}

	override public function getChildAt(index:Int):DisplayObject {
		return this.items[index];
	}

	private function _getChildAt(index:Int):DisplayObject {
		return super.getChildAt(index);
	}

	private function initializeLayoutGroupTheme():Void {
		SteelLayoutGroupStyles.initialize();
	}

	private function getPrivateIndexForPublicIndex(publicIndex:Int):Int {
		if (this.items.length > 0) {
			return publicIndex + this._getChildIndex(this.items[0]);
		} else if (this._numChildren > 0) {
			return publicIndex + this._numChildren;
		}
		return publicIndex;
	}

	@:dox(hide)
	@:noCompletion
	public var xmlContent(default, set):Array<DisplayObject> = null;

	private function set_xmlContent(value:Array<DisplayObject>):Array<DisplayObject> {
		if (this.xmlContent == value) {
			return this.xmlContent;
		}
		if (this.xmlContent != null) {
			for (child in this.xmlContent) {
				this.removeChild(child);
			}
		}
		this.xmlContent = value;
		if (this.xmlContent != null) {
			for (child in this.xmlContent) {
				this.addChild(child);
			}
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.xmlContent;
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChildChangesButSetFlags = false;

		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid) {
			this.refreshLayout();
		}

		if (sizeInvalid || layoutInvalid || stylesInvalid || stateInvalid) {
			this.refreshViewPortBounds();
			if (this._currentLayout != null) {
				this.handleCustomLayout();
			} else {
				this.handleManualLayout();
			}
			this.handleLayoutResult();
			this.refreshBackgroundLayout();

			// final invalidation to avoid juggler next frame issues
			this.validateChildren();
		}
	}

	private function refreshLayout():Void {
		var newLayout = this.layout;
		if (this._currentLayout == newLayout) {
			return;
		}
		if (this._currentLayout != null) {
			this._currentLayout.removeEventListener(Event.CHANGE, layoutGroup_layout_changeHandler);
		}
		this._currentLayout = newLayout;
		if (this._currentLayout != null) {
			this._currentLayout.addEventListener(Event.CHANGE, layoutGroup_layout_changeHandler);
		}
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this, IStateContext) && Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext<Dynamic>);
		}
		this._addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this._removeChild(skin);
		}
	}

	private function refreshViewPortBounds():Void {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
			if (Std.is(this._currentBackgroundSkin, IValidating)) {
				cast(this._currentBackgroundSkin, IValidating).validateNow();
			}
		}

		var needsToMeasureContent = this.autoSizeMode == CONTENT || this.stage == null;
		var stageWidth:Float = 0.0;
		var stageHeight:Float = 0.0;
		if (!needsToMeasureContent) {
			// TODO: see if this can be done without allocations
			var topLeft = this.globalToLocal(new Point());
			var bottomRight = this.globalToLocal(new Point(this.stage.stageWidth, this.stage.stageHeight));
			stageWidth = bottomRight.x - topLeft.x;
			stageHeight = bottomRight.y - topLeft.y;
		}

		if (needsWidth && !needsToMeasureContent) {
			this._layoutMeasurements.width = stageWidth;
		} else {
			this._layoutMeasurements.width = this.explicitWidth;
		}

		if (needsHeight && !needsToMeasureContent) {
			this._layoutMeasurements.height = stageHeight;
		} else {
			this._layoutMeasurements.height = this.explicitHeight;
		}

		var viewPortMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			viewPortMinWidth = 0.0;
		}
		var viewPortMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			viewPortMinHeight = 0.0;
		}
		var viewPortMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			viewPortMaxWidth = Math.POSITIVE_INFINITY;
		}
		var viewPortMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = Math.POSITIVE_INFINITY;
		}
		if (this._currentBackgroundSkin != null) {
			// because the layout might need it, we account for the
			// dimensions of the background skin when determining the minimum
			// dimensions of the view port.
			// we can't use the minimum dimensions of the background skin
			if (this._currentBackgroundSkin.width > viewPortMinWidth) {
				viewPortMinWidth = this._currentBackgroundSkin.width;
			}
			if (this._currentBackgroundSkin.height > viewPortMinHeight) {
				viewPortMinHeight = this._currentBackgroundSkin.height;
			}
		}
		this._layoutMeasurements.minWidth = viewPortMinWidth;
		this._layoutMeasurements.minHeight = viewPortMinHeight;
		this._layoutMeasurements.maxWidth = viewPortMaxWidth;
		this._layoutMeasurements.maxHeight = viewPortMaxHeight;
	}

	private function handleCustomLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._currentLayout.layout(this.items, this._layoutMeasurements, this._layoutResult);
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}

	private function handleManualLayout():Void {
		var maxX = this._layoutMeasurements.width;
		if (maxX == null) {
			maxX = 0.0;
		}
		var maxY = this._layoutMeasurements.height;
		if (maxY == null) {
			maxY = 0.0;
		}
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		for (item in this.items) {
			if (Std.is(item, ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
				continue;
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemMaxX = item.x + item.width;
			var itemMaxY = item.y + item.height;
			if (maxX < itemMaxX) {
				maxX = itemMaxX;
			}
			if (maxY < itemMaxY) {
				maxY = itemMaxY;
			}
		}
		this._ignoreChildChanges = oldIgnoreChildChanges;
		this._layoutResult.contentX = 0.0;
		this._layoutResult.contentY = 0.0;
		this._layoutResult.contentWidth = maxX;
		this._layoutResult.contentHeight = maxY;
		if (this._layoutMeasurements.width != null) {
			this._layoutResult.viewPortWidth = this._layoutMeasurements.width;
		} else {
			if (this._layoutMeasurements.minWidth != null && maxX < this._layoutMeasurements.minWidth) {
				maxX = this._layoutMeasurements.minWidth;
			} else if (this._layoutMeasurements.maxWidth != null && maxX > this._layoutMeasurements.maxWidth) {
				maxX = this._layoutMeasurements.maxWidth;
			}
			this._layoutResult.viewPortWidth = maxX;
		}
		if (this._layoutMeasurements.height != null) {
			this._layoutResult.viewPortHeight = this._layoutMeasurements.height;
		} else {
			if (this._layoutMeasurements.minHeight != null && maxY < this._layoutMeasurements.minHeight) {
				maxY = this._layoutMeasurements.minHeight;
			} else if (this._layoutMeasurements.maxHeight != null && maxY > this._layoutMeasurements.maxHeight) {
				maxY = this._layoutMeasurements.maxHeight;
			}
			this._layoutResult.viewPortHeight = maxY;
		}
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function refreshBackgroundLayout():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function validateChildren():Void {
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
		for (item in this.items) {
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private function layoutGroup_addedToStageHandler(event:Event):Void {
		if (this.autoSizeMode == STAGE) {
			// if we validated before being added to the stage, or if we've
			// been removed from stage and added again, we need to be sure
			// that the new stage dimensions are accounted for.
			this.setInvalid(InvalidationFlag.SIZE);

			this.addEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			this.stage.addEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
		}
	}

	private function layoutGroup_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
	}

	private function layoutGroup_stage_resizeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.SIZE);
	}

	private function layoutGroup_child_resizeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChildChangesButSetFlags) {
			this.setInvalidationFlag(InvalidationFlag.LAYOUT);
			return;
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
	}

	private function layoutGroup_child_layoutDataChangeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChildChangesButSetFlags) {
			this.setInvalidationFlag(InvalidationFlag.LAYOUT);
			return;
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
	}

	private function layoutGroup_layout_changeHandler(event:Event):Void {
		if (this._ignoreLayoutChanges) {
			return;
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
	}
}
