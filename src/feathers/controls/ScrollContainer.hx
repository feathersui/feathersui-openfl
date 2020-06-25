/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.core.IFocusContainer;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.Direction;
import feathers.layout.ILayout;
import feathers.layout.ILayoutObject;
import feathers.layout.IScrollLayout;
import feathers.themes.steel.components.SteelScrollContainerStyles;
import openfl.display.DisplayObject;
import openfl.events.Event;

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
	}

	private var layoutViewPort:LayoutViewPort;

	private var _ignoreChildChanges:Bool = false;
	private var _ignoreChildChangesButSetFlags:Bool = false;
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

	/**
		@see `feathers.core.IFocusContainer.childFocusEnabled`
	**/
	@:isVar
	public var childFocusEnabled(get, set):Bool = true;

	private function get_childFocusEnabled():Bool {
		return this.enabled && this.childFocusEnabled;
	}

	private function set_childFocusEnabled(value:Bool):Bool {
		this.childFocusEnabled = value;
		return this.childFocusEnabled;
	}

	public var numRawChildren(get, null):Int;

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
		child.addEventListener(Event.RESIZE, scrollContainer_child_resizeHandler);
		if (Std.is(child, ILayoutObject)) {
			child.addEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, scrollContainer_child_layoutDataChangeHandler, false, 0, true);
		}
		if (oldIndex >= 0) {
			this.items.remove(child);
		}
		// insert into the array first, so that display list APIs work in an
		// Event.ADDED listener
		this.items.insert(index, child);
		var result = this.layoutViewPort.addChildAt(child, index);
		this.setInvalid(InvalidationFlag.LAYOUT);
		return result;
	}

	override public function removeChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChild(child);
		}
		if (child == null || child.parent != this.layoutViewPort) {
			return child;
		}
		child.removeEventListener(Event.RESIZE, scrollContainer_child_resizeHandler);
		if (Std.is(child, ILayoutObject)) {
			child.removeEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, scrollContainer_child_layoutDataChangeHandler);
		}
		this.items.remove(child);
		var result = this.layoutViewPort.removeChild(child);
		this.setInvalid(InvalidationFlag.LAYOUT);
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

	private function initializeScrollContainerTheme():Void {
		SteelScrollContainerStyles.initialize();
	}

	override public function validateNow():Void {
		// for the start of validation, we're going to ignore when children
		// resize or dispatch changes to layout data. this allows subclasses
		// to modify children in draw() before the layout is applied.
		var oldIgnoreChildChanges = this._ignoreChildChangesButSetFlags;
		this._ignoreChildChangesButSetFlags = true;
		super.validateNow();
		// if super.validateNow() returns without calling update(), the flag
		// won't be reset before layout is called, so we need reset manually.
		this._ignoreChildChangesButSetFlags = oldIgnoreChildChanges;
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChildChangesButSetFlags = false;

		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (layoutInvalid || stylesInvalid) {
			this.layoutViewPort.layout = this.layout;
		}

		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		super.update();
		this._ignoreChildChanges = oldIgnoreChildChanges;
		this._displayListBypassEnabled = oldBypass;
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if (Std.is(this.layout, IScrollLayout)) {
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
	}

	private function scrollContainer_child_layoutDataChangeHandler(event:FeathersEvent):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		if (this._ignoreChildChangesButSetFlags) {
			this.setInvalidationFlag(InvalidationFlag.LAYOUT);
			return;
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
	}

	private function scrollContainer_child_resizeHandler(event:Event):Void {
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
