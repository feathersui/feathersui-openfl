/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.core.IFocusContainer;
import feathers.events.FeathersEvent;
import feathers.layout.AutoSizeMode;
import feathers.layout.ILayout;
import feathers.layout.ILayoutObject;
import feathers.layout.IScrollLayout;
import feathers.themes.steel.components.SteelScrollContainerStyles;
import openfl.display.DisplayObject;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Point;

/**
	A generic container that supports layout, scrolling, and a background skin.

	The following example creates a scroll container with a horizontal layout
	and adds two buttons to it:

	```hx
	var container = new ScrollContainer();
	var layout = new HorizontalLayout();
	layout.gap = 20.0;
	layout.padding = 20.0;
	container.layout = layout;
	this.addChild(container);

	var yesButton = new Button();
	yesButton.text = "Yes";
	container.addChild(yesButton);

	var noButton = new Button();
	noButton.text = "No";
	container.addChild(noButton);
	```

	@see [Tutorial: How to use the ScrollContainer component](https://feathersui.com/learn/haxe-openfl/scroll-container/)
	@see `feathers.controls.LayoutGroup` is a lighter weight layout container without scrolling

	@since 1.0.0
**/
@:meta(DefaultProperty("xmlContent"))
@defaultXmlProperty("xmlContent")
@:styleContext
class ScrollContainer extends BaseScrollContainer implements IFocusContainer {
	/**
		Creates a new `ScrollContainer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeScrollContainerTheme();

		super();

		if (this.viewPort == null) {
			this.layoutViewPort = new LayoutViewPort();
			this.addRawChild(this.layoutViewPort);
			this.viewPort = this.layoutViewPort;
		}
		this.addEventListener(Event.ADDED_TO_STAGE, scrollContainer_addedToStageHandler);
	}

	private var layoutViewPort:LayoutViewPort;

	private var _ignoreChildChanges:Bool = false;
	private var _ignoreChangesButSetFlags:Bool = false;
	private var _displayListBypassEnabled = true;

	private var items:Array<DisplayObject> = [];

	/**
		The layout algorithm used to position and size the group's items.

		The following example tells the group to use a vertical layout:

		```hx
		var layout = new VerticalLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		layout.horizontalAlign = CENTER;
		container.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _xmlContent:Array<DisplayObject> = null;

	@:dox(hide)
	@:noCompletion
	@:flash.property
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

	private var _childFocusEnabled:Bool = true;

	/**
		@see `feathers.core.IFocusContainer.childFocusEnabled`
	**/
	@:flash.property
	public var childFocusEnabled(get, set):Bool;

	private function get_childFocusEnabled():Bool {
		return this._enabled && this._childFocusEnabled;
	}

	private function set_childFocusEnabled(value:Bool):Bool {
		if (this._childFocusEnabled == value) {
			return this._childFocusEnabled;
		}
		this._childFocusEnabled = value;
		return this._childFocusEnabled;
	}

	private var _autoSizeMode:AutoSizeMode = CONTENT;

	/**
		Determines how the container will set its own size when its dimensions
		(width and height) aren't set explicitly.

		In the following example, the container will be sized to match the
		stage:

		```hx
		container.autoSizeMode = STAGE;
		```

		@see `feathers.layout.AutoSizeMode.STAGE`
		@see `feathers.layout.AutoSizeMode.CONTENT`

		@since 1.0.0
	**/
	@:flash.property
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
				this.stage.addEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler, false, 0, true);
				this.addEventListener(Event.REMOVED_FROM_STAGE, scrollContainer_removedFromStageHandler);
			} else {
				this.stage.removeEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, scrollContainer_removedFromStageHandler);
			}
		}
		return this._autoSizeMode;
	}

	@:flash.property
	public var numRawChildren(get, never):Int;

	private function get_numRawChildren():Int {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.numChildren;
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	@:getter(numChildren)
	#if !flash override #end private function get_numChildren():Int {
		if (!this._displayListBypassEnabled) {
			return super.numChildren;
		}
		return this.layoutViewPort.numChildren;
	}

	override public function addChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.addChild(child);
		}
		return this.addChildAt(child, this.layoutViewPort.numChildren);
	}

	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.addChildAt(child, index);
		}
		var oldIndex = this.items.indexOf(child);
		if (oldIndex == index) {
			return child;
		}
		if (oldIndex >= 0) {
			this.items.remove(child);
		}
		// insert into the array before adding as a child, so that display list
		// APIs work in an Event.ADDED listener
		this.items.insert(index, child);
		var result = this.layoutViewPort.addChildAt(child, index);
		// add listeners or access properties after adding a child
		// because adding the child may result in better errors (like for null)
		child.addEventListener(Event.RESIZE, scrollContainer_child_resizeHandler);
		if ((child is ILayoutObject)) {
			child.addEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, scrollContainer_child_layoutDataChangeHandler, false, 0, true);
		}
		this.setInvalid(LAYOUT);
		return result;
	}

	override public function removeChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChild(child);
		}
		if (child == null || child.parent != this.layoutViewPort) {
			return child;
		}
		this.items.remove(child);
		var result = this.layoutViewPort.removeChild(child);
		// remove listeners or access properties after removing a child
		// because removing the child may result in better errors (like for null)
		child.removeEventListener(Event.RESIZE, scrollContainer_child_resizeHandler);
		if ((child is ILayoutObject)) {
			child.removeEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, scrollContainer_child_layoutDataChangeHandler);
		}
		this.setInvalid(LAYOUT);
		return result;
	}

	override public function removeChildAt(index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChildAt(index);
		}
		return this.removeChild(this.layoutViewPort.getChildAt(index));
	}

	override public function getChildAt(index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChildAt(index);
		}
		return this.layoutViewPort.getChildAt(index);
	}

	override public function getChildIndex(child:DisplayObject):Int {
		if (!this._displayListBypassEnabled) {
			return super.getChildIndex(child);
		}
		return this.items.indexOf(child);
	}

	override public function setChildIndex(child:DisplayObject, index:Int):Void {
		if (!this._displayListBypassEnabled) {
			return super.setChildIndex(child, index);
		}
		this.items.remove(child);
		this.items.insert(index, child);
	}

	override public function getChildByName(name:String):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.getChildByName(name);
		}
		for (child in this.items) {
			if (child.name == name) {
				return child;
			}
		}
		return null;
	}

	private function addRawChild(child:DisplayObject):DisplayObject {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.addChild(child);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function addRawChildAt(child:DisplayObject, index:Int):DisplayObject {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.addChildAt(child, index);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function removeRawChild(child:DisplayObject):DisplayObject {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.removeChild(child);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function removeRawChildAt(index:Int):DisplayObject {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.removeChildAt(index);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function getRawChildByName(name:String):DisplayObject {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.getChildByName(name);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function getRawChildAt(index:Int):DisplayObject {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.getChildAt(index);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function getRawChildIndex(child:DisplayObject):Int {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var result = this.getChildIndex(child);
		this._displayListBypassEnabled = oldBypass;
		return result;
	}

	private function setRawChildIndex(child:DisplayObject, index:Int):Void {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		this.setChildIndex(child, index);
		this._displayListBypassEnabled = oldBypass;
	}

	override public function removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		if (!this._displayListBypassEnabled) {
			return super.removeChildren(beginIndex, endIndex);
		}

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

	private function removeRawChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		this.removeChildren(beginIndex, endIndex);
		this._displayListBypassEnabled = oldBypass;
	}

	private function initializeScrollContainerTheme():Void {
		SteelScrollContainerStyles.initialize();
	}

	override public function dispatchEvent(event:Event):Bool {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = true;
		var result = super.dispatchEvent(event);
		this._displayListBypassEnabled = oldBypass;
		return result;
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
		var stylesInvalid = this.isInvalid(STYLES);

		if (layoutInvalid || stylesInvalid) {
			this.refreshLayout();
		}

		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		super.update();
		this._ignoreChildChanges = oldIgnoreChildChanges;
		this._displayListBypassEnabled = oldBypass;
	}

	override private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}
		if (this._autoSizeMode == STAGE && this.stage != null) {
			// TODO: see if this can be done without allocations
			var topLeft = this.globalToLocal(new Point());
			var bottomRight = this.globalToLocal(new Point(this.stage.stageWidth, this.stage.stageHeight));
			var stageWidth = bottomRight.x - topLeft.x;
			var stageHeight = bottomRight.y - topLeft.y;
			return this.saveMeasurements(stageWidth, stageHeight, stageWidth, stageHeight);
		}
		return super.measure();
	}

	override private function refreshViewPortBoundsForMeasurement():Void {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = true;
		super.refreshViewPortBoundsForMeasurement();
		this._displayListBypassEnabled = oldBypass;
	}

	override private function refreshViewPortBoundsForLayout():Void {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = true;
		super.refreshViewPortBoundsForLayout();
		this._displayListBypassEnabled = oldBypass;
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if ((this.layout is IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
			this.scroller.forceElasticTop = scrollLayout.elasticTop;
			this.scroller.forceElasticRight = scrollLayout.elasticRight;
			this.scroller.forceElasticBottom = scrollLayout.elasticBottom;
			this.scroller.forceElasticLeft = scrollLayout.elasticLeft;
		} else {
			this.scroller.forceElasticTop = false;
			this.scroller.forceElasticRight = false;
			this.scroller.forceElasticBottom = false;
			this.scroller.forceElasticLeft = false;
		}
		this.scroller.snapPositionsX = this.layoutViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.layoutViewPort.snapPositionsY;
	}

	private function refreshLayout():Void {
		this.layoutViewPort.layout = this.layout;
	}

	private function scrollContainer_addedToStageHandler(event:Event):Void {
		if (this._autoSizeMode == STAGE) {
			// if we validated before being added to the stage, or if we've
			// been removed from stage and added again, we need to be sure
			// that the new stage dimensions are accounted for.
			this.setInvalid(SIZE);

			this.addEventListener(Event.REMOVED_FROM_STAGE, scrollContainer_removedFromStageHandler);
			this.stage.addEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler, false, 0, true);
		}
	}

	private function scrollContainer_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, scrollContainer_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler);
	}

	private function scrollContainer_stage_resizeHandler(event:Event):Void {
		this.setInvalid(SIZE);
	}

	private function scrollContainer_child_layoutDataChangeHandler(event:FeathersEvent):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChangesButSetFlags) {
			this.setInvalidationFlag(LAYOUT);
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function scrollContainer_child_resizeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChangesButSetFlags) {
			this.setInvalidationFlag(LAYOUT);
			return;
		}
		this.setInvalid(LAYOUT);
	}
}
