/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
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
import feathers.style.IStyleObject;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Point;

/**
	A generic container that supports layouts and automatically sizes itself
	based on its content.

	The following example creates a layout group with a horizontal layout and
	adds two buttons to it:

	```hx
	var group:LayoutGroup = new LayoutGroup();
	var layout:HorizontalLayout = new HorizontalLayout();
	layout.gap = 20.0;
	layout.padding = 20.0;
	group.layout = layout;
	this.addChild( group );

	var yesButton:Button = new Button();
	yesButton.label = "Yes";
	group.addChild( yesButton );

	var noButton:Button = new Button();
	noButton.label = "No";
	group.addChild( noButton );
	```

	@see [How to use the Feathers `LayoutGroup` component](../../../help/layout-group.html)
	@see `feathers.controls.ScrollContainer` is a layout container that supports scrolling

	@since 1.0.0
**/
class LayoutGroup extends FeathersControl {
	public static final VARIANT_TOOL_BAR = "toolBar";

	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, layoutGroup_addedToStageHandler);
	}

	override private function get_styleContext():Class<IStyleObject> {
		return LayoutGroup;
	}

	private var items:Array<DisplayObject> = [];

	@style
	public var layout(default, set):ILayout = null;

	private function set_layout(value:ILayout):ILayout {
		if (!this.setStyle("layout")) {
			return this.layout;
		}
		if (this.layout == value) {
			return this.layout;
		}
		this.layout = value;
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.layout;
	}

	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
	private var _layoutMeasurements:Measurements = new Measurements();
	private var _ignoreChildChanges:Bool = false;
	private var _ignoreChildChangesButSetFlags:Bool = false;
	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a background skin:

		```hx
		group.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `LayoutGroup.backgroundDisabledSkin`

		@since 1.0.0
	**/
	@style
	public var backgroundSkin(default, set):DisplayObject = null;

	private function set_backgroundSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("backgroundSkin")) {
			return this.backgroundSkin;
		}
		if (this.backgroundSkin == value) {
			return this.backgroundSkin;
		}
		if (this.backgroundSkin != null && this.backgroundSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(this.backgroundSkin);
			this._currentBackgroundSkin = null;
		}
		this.backgroundSkin = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.backgroundSkin;
	}

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a disabled background skin:

		```hx
		group.backgroundDisabledSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@default null

		@see `LayoutGroup.backgroundSkin`

		@since 1.0.0
	**/
	@style
	public var backgroundDisabledSkin(default, set):DisplayObject = null;

	private function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("backgroundDisabledSkin")) {
			return this.backgroundDisabledSkin;
		}
		if (this.backgroundDisabledSkin == value) {
			return this.backgroundDisabledSkin;
		}
		if (this.backgroundDisabledSkin != null && this.backgroundDisabledSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(this.backgroundDisabledSkin);
			this._currentBackgroundSkin = null;
		}
		this.backgroundDisabledSkin = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.backgroundDisabledSkin;
	}

	/**
		Determines how the layout group will set its own size when its
		dimensions (width and height) aren't set explicitly.

		In the following example, the layout group will be sized to match the
		stage:

		```hx
		group.autoSizeMode = AutoSizeMode.STAGE;
		```

		Usually defaults to `AutoSizeMode.CONTENT`. However, if this component
		is the root of the OpenFL display list, defaults to `AutoSizeMode.STAGE`
		instead.

		@see `feathers.layout.AutoSizeMode.STAGE`
		@see `feathers.layout.AutoSizeMode.CONTENT`

		@since 1.0.0
	**/
	public var autoSizeMode(default, set):AutoSizeMode = AutoSizeMode.CONTENT;

	private function set_autoSizeMode(value:AutoSizeMode):AutoSizeMode {
		if (this.autoSizeMode == value) {
			return this.autoSizeMode;
		}
		this.autoSizeMode = value;
		this.setInvalid(InvalidationFlag.SIZE);
		if (this.stage != null) {
			if (this.autoSizeMode == AutoSizeMode.STAGE) {
				this.stage.addEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
				this.addEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			} else {
				this.stage.removeEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			}
		}
		return this.autoSizeMode;
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
		var result = super.addChildAt(child, index);
		this.items.insert(index, child);
		this.setInvalid(InvalidationFlag.LAYOUT);
		return result;
	}

	#if flash
	override public function addChild(child:DisplayObject):DisplayObject {
		return this.addChildAt(child, this.numChildren);
	}
	#end

	private function _addChild(child:DisplayObject, index:Int):DisplayObject {
		return super.addChildAt(child, this.numChildren);
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
		return super.removeChild(child);
	}

	override public function removeChildAt(index:Int):DisplayObject {
		if (index >= 0 && index < this.items.length) {
			return this.removeChild(this.items[index]);
		}
		return null;
	}

	private function _removeChild(child:DisplayObject):DisplayObject {
		return super.removeChild(child);
	}

	private function _removeChildAt(index:Int):DisplayObject {
		return super.removeChildAt(index);
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

		if (sizeInvalid || layoutInvalid || stylesInvalid || stateInvalid) {
			this.refreshViewPortBounds();
			if (this.layout != null) {
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
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext);
		}
		this._addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.backgroundDisabledSkin != null) {
			return this.backgroundDisabledSkin;
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
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var needsToMeasureContent = this.autoSizeMode == AutoSizeMode.CONTENT || this.stage == null;
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
		this.layout.layout(this.items, this._layoutMeasurements, this._layoutResult);
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
		if (this.autoSizeMode == AutoSizeMode.STAGE) {
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
}
