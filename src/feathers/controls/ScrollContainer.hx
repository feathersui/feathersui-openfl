/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelScrollContainerStyles;
import feathers.layout.IScrollLayout;
import feathers.layout.Direction;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.ILayout;
import feathers.layout.ILayoutObject;
import feathers.layout.Measurements;
import feathers.utils.Scroller;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Rectangle;

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
	yesButton.label = "Yes";
	container.addChild(yesButton);

	var noButton = new Button();
	noButton.label = "No";
	container.addChild(noButton);
	```

	@see [Tutorial: How to use the ScrollContainer component](https://feathersui.com/learn/haxe-openfl/scroll-container/)
	@see `feathers.controls.LayoutGroup` is a lighter weight layout container without scrolling

	@since 1.0.0
**/
@:styleContext
class ScrollContainer extends BaseScrollContainer {
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

	override private function get_primaryDirection():Direction {
		if (Std.is(this.layout, IScrollLayout)) {
			return cast(this.layout, IScrollLayout).primaryDirection;
		}
		return Direction.NONE;
	}

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
		var result = this.layoutViewPort.addChildAt(child, index);
		this.items.insert(index, child);
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

	private function setRawChildIndex(child:DisplayObject, index:Int):Void {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		this.setChildIndex(child, index);
		this._displayListBypassEnabled = oldBypass;
	}

	private function initializeScrollContainerTheme():Void {
		SteelScrollContainerStyles.initialize();
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
