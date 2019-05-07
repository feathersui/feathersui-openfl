/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.scrolling.LayoutViewPort;
import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.ILayout;
import feathers.layout.ILayoutObject;
import feathers.layout.Measurements;
import feathers.style.IStyleObject;
import feathers.utils.Scroller;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
	A generic container that supports layout, scrolling, and a background skin.
	For a lighter weight container without scrolling, see `LayoutGroup`.

	The following example creates a scroll container with a horizontal layout
	and adds two buttons to it:

	```hx
	var container:ScrollContainer = new ScrollContainer();
	var layout:HorizontalLayout = new HorizontalLayout();
	layout.gap = 20;
	layout.padding = 20;
	container.layout = layout;
	this.addChild( container );

	var yesButton:Button = new Button();
	yesButton.label = "Yes";
	container.addChild( yesButton );

	var noButton:Button = new Button();
	noButton.label = "No";
	container.addChild( noButton );
	```

	@see [How to use the Feathers ScrollContainer component](../../../help/scroll-container.html)
	@see `feathers.controls.LayoutGroup`

	@since 1.0.0
**/
class ScrollContainer extends FeathersControl {
	public function new() {
		super();
	}

	override private function get_styleContext():Class<IStyleObject> {
		return ScrollContainer;
	}

	private var viewPort:LayoutViewPort;
	private var scroller:Scroller;
	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();
	private var _ignoreChildChanges:Bool = false;
	private var _ignoreChildChangesButSetFlags:Bool = false;
	private var _displayListBypassEnabled = true;
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

	override private function get_numChildren():Int {
		if (!this._displayListBypassEnabled) {
			return super.numChildren;
		}
		return this.viewPort.numChildren;
	}

	override public function addChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.addChild(child);
		}
		return this.addChildAt(child, this.viewPort.numChildren);
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
		var result = this.viewPort.addChildAt(child, index);
		this.items.insert(index, child);
		this.setInvalid(InvalidationFlag.LAYOUT);
		return result;
	}

	override public function removeChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChild(child);
		}
		if (child == null || child.parent != this.viewPort) {
			return child;
		}
		child.removeEventListener(Event.RESIZE, scrollContainer_child_resizeHandler);
		if (Std.is(child, ILayoutObject)) {
			child.removeEventListener(FeathersEvent.LAYOUT_DATA_CHANGE, scrollContainer_child_layoutDataChangeHandler);
		}
		this.items.remove(child);
		var result = this.viewPort.removeChild(child);
		this.setInvalid(InvalidationFlag.LAYOUT);
		return result;
	}

	override public function removeChildAt(index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChildAt(index);
		}
		return this.removeChild(this.viewPort.getChildAt(index));
	}

	override public function getChildAt(index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChildAt(index);
		}
		return this.viewPort.getChildAt(index);
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

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		if (this.viewPort == null) {
			this.viewPort = new LayoutViewPort();
			this.addRawChild(this.viewPort);
		}
		this.scroller.target = this;
		this.scroller.addEventListener(Event.SCROLL, scrollContainer_scroller_scrollHandler);
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChildChangesButSetFlags = false;

		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);

		if (layoutInvalid) {
			this.viewPort.layout = this.layout;
		}

		if (stylesInvalid) {
			this.refreshBackgroundSkin();
		}

		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this.refreshViewPortLayout();
		this._ignoreChildChanges = oldIgnoreChildChanges;
		this.refreshScrollRect();
		this.refreshScroller();
		this.refreshBackgroundLayout();
	}

	private function refreshViewPortLayout():Void {
		this.viewPort.visibleWidth = this.actualWidth;
		this.viewPort.visibleHeight = this.actualHeight;
		this.viewPort.minVisibleWidth = this.actualMinWidth;
		this.viewPort.minVisibleHeight = this.actualMinHeight;
		this.viewPort.maxVisibleWidth = this.actualMaxWidth;
		this.viewPort.maxVisibleHeight = this.actualMaxHeight;
		this.viewPort.validateNow();
	}

	private function refreshScroller():Void {
		this.scroller.setDimensions(this.viewPort.visibleWidth, this.viewPort.visibleHeight, this.viewPort.width, this.viewPort.height);
	}

	private function autoSizeIfNeeded():Bool {
		return false;
	}

	private function refreshScrollRect():Void {
		// instead of creating a new Rectangle every time, we're going to swap
		// between two of them to avoid excessive garbage collection
		var scrollRect = this._scrollRect1;
		if (this._currentScrollRect == scrollRect) {
			scrollRect = this._scrollRect2;
		}
		this._currentScrollRect = scrollRect;
		scrollRect.setTo(scroller.scrollX, scroller.scrollY, this.actualWidth, this.actualHeight);
		this.viewPort.scrollRect = scrollRect;
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
		this.addRawChildAt(this._currentBackgroundSkin, 0);
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
			this.removeRawChild(skin);
		}
	}

	private function refreshBackgroundLayout():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0;
		this._currentBackgroundSkin.y = 0;

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

	private function scrollContainer_scroller_scrollHandler(event:Event):Void {
		this.refreshScrollRect();
	}
}
