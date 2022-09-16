/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.AutoSizeMode;
import feathers.layout.ILayout;
import feathers.layout.ILayoutObject;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Point;

/**
	A generic container that supports layouts and automatically sizes itself
	based on its content.

	The following example creates a layout group with a horizontal layout and
	adds two buttons to it:

	```haxe
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

		```haxe
		var group = new LayoutGroup();
		group.variant = LayoutGroup.VARIANT_TOOL_BAR;
		```

		@see `feathers.style.IVariantStyleObject.variant`
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

		```haxe
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
	private var _ignoreChangesButSetFlags:Bool = false;
	private var _ignoreLayoutChanges:Bool = false;
	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example passes a bitmap for the layout group to use as a
		background skin:

		```haxe
		group.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `LayoutGroup.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		The background skin to display behind all content added to the group when
		the group is disabled. The background skin is resized to fill the
		complete width and height of the group.

		The following example gives the group a disabled background skin:

		```haxe
		group.disabledBackgroundSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@default null

		@see `LayoutGroup.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _currentMaskSkin:DisplayObject = null;

	/**
		A skin to mask the content of the layout group. The skin is resized to
		the full dimensions of the layout group. It is passed to the `mask`
		property.

		The following example passes a `RectangleSkin` with a `cornerRadius` for
		the layout group's mask skin:

		```haxe
		var maskSkin = new RectangleSkin();
		maskSkin.fill = SolidColor(0xff0000);
		maskSkin.cornerRadius = 10.0;
		group.maskSkin = maskSkin;
		```

		@default null

		@see [`openfl.display.DisplayObject.mask`](https://api.openfl.org/openfl/display/DisplayObject.html#mask)

		@since 1.0.0
	**/
	@:style
	public var maskSkin:DisplayObject = null;

	private var _autoSizeMode:AutoSizeMode = CONTENT;

	/**
		Determines how the layout group will set its own size when its
		dimensions (width and height) aren't set explicitly.

		In the following example, the layout group will be sized to match the
		stage:

		```haxe
		group.autoSizeMode = STAGE;
		```

		@see `feathers.layout.AutoSizeMode.STAGE`
		@see `feathers.layout.AutoSizeMode.CONTENT`

		@since 1.0.0
	**/
	public var autoSizeMode(get, set):AutoSizeMode;

	private function get_autoSizeMode():AutoSizeMode {
		return this._autoSizeMode;
	}

	private function set_autoSizeMode(value:AutoSizeMode):AutoSizeMode {
		if (this._autoSizeMode == value) {
			return this._autoSizeMode;
		}
		this._autoSizeMode = value;
		this.setInvalid(SIZE);
		if (this.stage != null) {
			if (this._autoSizeMode == STAGE) {
				this.stage.addEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler, false, 0, true);
				this.addEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			} else {
				this.stage.removeEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			}
		}
		return this._autoSizeMode;
	}

	private var _disabledOverlay:Sprite;

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
		if (oldIndex >= 0) {
			this.items.remove(child);
		}
		var privateIndex = this.getPrivateIndexForPublicIndex(index);
		// insert into the array before adding as a child, so that display list
		// APIs work in an Event.ADDED listener
		this.items.insert(index, child);
		var result = this._addChildAt(child, privateIndex);
		// add listeners or access properties after adding a child
		// because adding the child may result in better errors (like for null)
		child.addEventListener(Event.RESIZE, layoutGroup_child_resizeHandler);
		if ((child is ILayoutObject)) {
			child.addEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, layoutGroup_child_layoutDataChangeHandler, false, 0, true);
		}
		this.setInvalid(LAYOUT);
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
		this.items.remove(child);
		var result = this._removeChild(child);
		// remove listeners or access properties after removing a child
		// because removing the child may result in better errors (like for null)
		child.removeEventListener(Event.RESIZE, layoutGroup_child_resizeHandler);
		if ((child is ILayoutObject)) {
			child.removeEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, layoutGroup_child_layoutDataChangeHandler);
		}
		this.setInvalid(LAYOUT);
		return result;
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

	override public function getChildByName(name:String):DisplayObject {
		for (child in this.items) {
			if (child.name == name) {
				return child;
			}
		}
		return null;
	}

	private function _getChildByName(name:String):DisplayObject {
		return super.getChildByName(name);
	}

	override public function removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		if (endIndex == 0x7FFFFFFF) {
			endIndex = this.items.length - 1;

			if (endIndex < 0) {
				return;
			}
		}

		if (beginIndex > this.items.length - 1) {
			return;
		} else if (endIndex < beginIndex || beginIndex < 0 || endIndex > this.items.length) {
			throw new RangeError("The supplied index is out of bounds.");
		}

		var numRemovals = endIndex - beginIndex;
		while (numRemovals >= 0) {
			this.removeChildAt(beginIndex);
			numRemovals--;
		}
	}

	private function _removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		super.removeChildren(beginIndex, endIndex);
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
		this.setInvalid(LAYOUT);
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
		feathers.themes.steel.components.SteelLayoutGroupStyles.initialize();
	}

	private function getPrivateIndexForPublicIndex(publicIndex:Int):Int {
		if (this.items.length > 0) {
			return publicIndex + this._getChildIndex(this.items[0]);
		} else if (this._numChildren > 0) {
			return publicIndex + this._numChildren;
		}
		return publicIndex;
	}

	private var _xmlContent:Array<DisplayObject> = null;

	@:dox(hide)
	@:noCompletion
	public var xmlContent(get, set):Array<DisplayObject>;

	private function get_xmlContent():Array<DisplayObject> {
		return this._xmlContent;
	}

	private function set_xmlContent(value:Array<DisplayObject>):Array<DisplayObject> {
		if (this._xmlContent == value) {
			return this._xmlContent;
		}
		if (this._xmlContent != null) {
			for (child in this._xmlContent) {
				this.removeChild(child);
			}
		}
		this._xmlContent = value;
		if (this._xmlContent != null) {
			for (child in this._xmlContent) {
				this.addChild(child);
			}
		}
		this.setInvalid(STYLES);
		return this._xmlContent;
	}

	override public function validateNow():Void {
		// for the start of validation, we're going to ignore when children
		// resize or dispatch changes to layout data. this allows subclasses
		// to modify children in draw() before the layout is applied.
		var oldIgnoreChildChanges = this._ignoreChangesButSetFlags;
		this._ignoreChangesButSetFlags = true;
		super.validateNow();
		// if super.validateNow() returns without calling update(), the flag
		// won't be reset before layout is called, so we need reset manually.
		this._ignoreChangesButSetFlags = oldIgnoreChildChanges;
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChangesButSetFlags = false;

		var layoutInvalid = this.isInvalid(LAYOUT);
		var sizeInvalid = this.isInvalid(SIZE);
		var stylesInvalid = this.isInvalid(STYLES);
		var stateInvalid = this.isInvalid(STATE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid) {
			this.refreshMaskSkin();
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
			this.refreshDisabledOverlay();
			this.refreshMaskLayout();

			// final invalidation to avoid juggler next frame issues
			this.validateChildren();
		}
	}

	private function refreshDisabledOverlay():Void {
		if (!this._enabled) {
			if (this._disabledOverlay == null) {
				this._disabledOverlay = new Sprite();
				this._disabledOverlay.graphics.beginFill(0xff00ff, 0.0);
				this._disabledOverlay.graphics.drawRect(0.0, 0.0, 1.0, 1.0);
				this._disabledOverlay.graphics.endFill();
				this._addChild(this._disabledOverlay);
			} else {
				this._setChildIndex(this._disabledOverlay, this._numChildren - 1);
			}
		}
		if (this._disabledOverlay != null) {
			this._disabledOverlay.visible = !this._enabled;
			this._disabledOverlay.x = 0.0;
			this._disabledOverlay.y = 0.0;
			this._disabledOverlay.width = this.actualWidth;
			this._disabledOverlay.height = this.actualHeight;
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
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this._addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this._removeChild(skin);
		}
	}

	private function refreshMaskSkin():Void {
		var oldSkin = this._currentMaskSkin;
		this._currentMaskSkin = this.getCurrentMaskSkin();
		if (this._currentMaskSkin == oldSkin) {
			return;
		}
		this.removeCurrentMaskSkin(oldSkin);
		this.addCurrentMaskSkin(this._currentMaskSkin);
	}

	private function getCurrentMaskSkin():DisplayObject {
		return this.maskSkin;
	}

	private function addCurrentMaskSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this._addChild(skin);
		this.mask = skin;
	}

	private function removeCurrentMaskSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this._removeChild(skin);
		}
		this.mask = null;
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
			if ((this._currentBackgroundSkin is IValidating)) {
				cast(this._currentBackgroundSkin, IValidating).validateNow();
			}
		}

		var needsToMeasureContent = this._autoSizeMode == CONTENT || this.stage == null;
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
			viewPortMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		var viewPortMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		if (this._backgroundSkinMeasurements != null) {
			// because the layout might need it, we account for the
			// dimensions of the background skin when determining the minimum
			// dimensions of the view port.
			if (this._backgroundSkinMeasurements.width != null) {
				if (this._backgroundSkinMeasurements.width > viewPortMinWidth) {
					viewPortMinWidth = this._backgroundSkinMeasurements.width;
				}
			} else if (this._backgroundSkinMeasurements.minWidth != null) {
				if (this._backgroundSkinMeasurements.minWidth > viewPortMinWidth) {
					viewPortMinWidth = this._backgroundSkinMeasurements.minWidth;
				}
			}
			if (this._backgroundSkinMeasurements.height != null) {
				if (this._backgroundSkinMeasurements.height > viewPortMinHeight) {
					viewPortMinHeight = this._backgroundSkinMeasurements.height;
				}
			} else if (this._backgroundSkinMeasurements.minHeight != null) {
				if (this._backgroundSkinMeasurements.minHeight > viewPortMinHeight) {
					viewPortMinHeight = this._backgroundSkinMeasurements.minHeight;
				}
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
		this._layoutResult.reset();
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
			if ((item is ILayoutObject) && !cast(item, ILayoutObject).includeInLayout) {
				continue;
			}
			if ((item is IValidating)) {
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

	private function refreshMaskLayout():Void {
		if (this._currentMaskSkin == null) {
			return;
		}

		this._currentMaskSkin.x = 0.0;
		this._currentMaskSkin.y = 0.0;
		this._currentMaskSkin.width = this.actualWidth;
		this._currentMaskSkin.height = this.actualHeight;
		if ((this._currentMaskSkin is IValidating)) {
			cast(this._currentMaskSkin, IValidating).validateNow();
		}
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
		if ((this._currentBackgroundSkin is IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function validateChildren():Void {
		if ((this._currentBackgroundSkin is IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
		for (item in this.items) {
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private function layoutGroup_addedToStageHandler(event:Event):Void {
		if (this._autoSizeMode == STAGE) {
			// if we validated before being added to the stage, or if we've
			// been removed from stage and added again, we need to be sure
			// that the new stage dimensions are accounted for.
			this.setInvalid(SIZE);

			this.addEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
			this.stage.addEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler, false, 0, true);
		}
	}

	private function layoutGroup_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, layoutGroup_stage_resizeHandler);
	}

	private function layoutGroup_stage_resizeHandler(event:Event):Void {
		this.setInvalid(SIZE);
	}

	private function layoutGroup_child_resizeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChangesButSetFlags) {
			this.setInvalidationFlag(LAYOUT);
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function layoutGroup_child_layoutDataChangeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChangesButSetFlags) {
			this.setInvalidationFlag(LAYOUT);
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function layoutGroup_layout_changeHandler(event:Event):Void {
		if (this._ignoreLayoutChanges) {
			return;
		}
		if (this._ignoreChangesButSetFlags) {
			this.setInvalidationFlag(LAYOUT);
			return;
		}
		this.setInvalid(LAYOUT);
	}
}
