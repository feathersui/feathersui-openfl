/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import openfl.display.Stage;
import openfl.display.DisplayObjectContainer;
import feathers.core.FeathersControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.AutoSizeMode;
import feathers.layout.ILayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.ExclusivePointer;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.errors.RangeError;
import openfl.errors.TypeError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
#if air
import openfl.ui.Multitouch;
#end

/**
	Base class for divided box components.

	@see `feathers.controls.HDividedBox`
	@see `feathers.controls.VDividedBox`

	@since 1.0.0
**/
@:meta(DefaultProperty("xmlContent"))
@defaultXmlProperty("xmlContent")
class BaseDividedBox extends FeathersControl {
	private function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, baseDividedBox_addedToStageHandler);
	}

	private var resizeCursor:MouseCursor;
	private var _oldDividerMouseCursor:MouseCursor;
	private var _resizingTouchID = -1;
	private var _resizingDividerIndex = -1;

	private var _autoSizeMode:AutoSizeMode = CONTENT;

	/**
		Determines how the container will set its own size when its dimensions
		(width and height) aren't set explicitly.

		In the following example, the container will be sized to match the
		stage:

		```hx
		drawer.autoSizeMode = STAGE;
		```

		@default feathers.layout.AutoSizeMode.STAGE`

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
				this.stage.addEventListener(Event.RESIZE, baseDividedBox_stage_resizeHandler);
				this.addEventListener(Event.REMOVED_FROM_STAGE, baseDividedBox_removedFromStageHandler);
			} else {
				this.stage.removeEventListener(Event.RESIZE, baseDividedBox_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, baseDividedBox_removedFromStageHandler);
			}
		}
		return this._autoSizeMode;
	}

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the container's content.

		The following example passes a bitmap for the container to use as a
		background skin:

		```hx
		container.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `BaseDividedBox.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the container's content when the
		container is disabled.

		The following example gives the container a disabled background skin:

		```hx
		container.disabledBackgroundSkin = new Bitmap(bitmapData);
		container.enabled = false;
		```

		@default null

		@see `BaseDividedBox.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _currentResizeDraggingSkin:DisplayObject;

	/**
		The skin to display when a resize gesture is active and `liveDragging`
		is `false`.

		@see `BaseDividedBox.liveDragging`

		@since 1.0.0
	**/
	@:style
	public var resizeDraggingSkin:DisplayObject = null;

	/**
		Determines if the children are resized immediately as a divider moves
		while dragging, or only after the user stops dragging.

		In the following example, live dragging is disabled:

		```hx
		container.liveDragging = false;
		```

		@default true

		@see `BaseDividedBox.resizeDraggingSkin`

		@since 1.0.0
	**/
	public var liveDragging:Bool = true;

	private static function defaultDividerFactory():InteractiveObject {
		var divider = new Sprite();
		divider.graphics.beginFill(0xff00ff, 0.0);
		divider.graphics.drawRect(0.0, 0.0, 6.0, 6.0);
		divider.graphics.endFill();
		return divider;
	}

	private var _dividerFactory:() -> InteractiveObject;

	/**
		Creates the dividers, which must be of type `openfl.display.InteractiveObject`.

		In the following example, a custom divider factory is provided:

		```hx
		dividedBox.dividerFactory = () ->
		{
			return new Button();
		};
		```

		@since 1.0.0
	**/
	@:flash.property
	public var dividerFactory(get, set):() -> InteractiveObject;

	private function get_dividerFactory():() -> InteractiveObject {
		return this._dividerFactory;
	}

	private function set_dividerFactory(value:() -> InteractiveObject):() -> InteractiveObject {
		if (this._dividerFactory == value) {
			return this._dividerFactory;
		}
		this._dividerFactory = value;
		if (this.items.length > 1) {
			for (i in 1...this.items.length) {
				var layoutIndex = i * 2;
				var childIndex = layoutIndex + ((this._currentBackgroundSkin != null) ? 1 : 0);
				var oldDivider = this.removeRawChildAt(childIndex - 1);
				this.destroyDivider(cast(oldDivider, InteractiveObject));

				var newDivider = this.createDivider();
				this.addRawChildAt(newDivider, childIndex - 1);
				this.dividers[i - 1] = newDivider;
				this._layoutItems[layoutIndex - 1] = newDivider;
			}
		}
		this.setInvalid(LAYOUT);
		return this._dividerFactory;
	}

	private var items:Array<DisplayObject> = [];
	private var dividers:Array<InteractiveObject> = [];
	private var _layoutItems:Array<DisplayObject> = [];
	private var _displayListBypassEnabled = true;
	private var _ignoreChildChanges = false;
	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var layout:ILayout = null;
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
		return this.items.length;
	}

	override public function addChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.addChild(child);
		}
		return this.addChildAt(child, this.items.length);
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
			this.removeItem(child);
		}
		// insert into the array before adding as a child, so that display list
		// APIs work in an Event.ADDED listener
		var result = this.addItemAt(child, index);
		// add listeners or access properties after adding a child
		// because adding the child may result in better errors (like for null)
		child.addEventListener(Event.RESIZE, baseDividedBox_child_resizeHandler);
		this.setInvalid(LAYOUT);
		return result;
	}

	override public function removeChild(child:DisplayObject):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChild(child);
		}
		if (child == null || child.parent != this) {
			return child;
		}
		var result = this.removeItem(child);
		// remove listeners or access properties after removing a child
		// because removing the child may result in better errors (like for null)
		child.removeEventListener(Event.RESIZE, baseDividedBox_child_resizeHandler);
		this.setInvalid(LAYOUT);
		return result;
	}

	override public function removeChildAt(index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChildAt(index);
		}
		return this.removeChild(this.items[index]);
	}

	override public function getChildAt(index:Int):DisplayObject {
		if (!this._displayListBypassEnabled) {
			return super.removeChildAt(index);
		}
		return this.items[index];
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

	private function removeRawChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		var oldBypass = this._displayListBypassEnabled;
		this._displayListBypassEnabled = false;
		this.removeRawChildren(beginIndex, endIndex);
		this._displayListBypassEnabled = oldBypass;
	}

	private function addItemAt(child:DisplayObject, index:Int):DisplayObject {
		this.items.insert(index, child);
		var layoutIndex = index * 2;
		var childIndex = layoutIndex + ((this._currentBackgroundSkin != null) ? 1 : 0);
		if (index != 0) {
			var divider = this.createDivider();
			super.addChildAt(divider, childIndex - 1);
			this.dividers.insert(index - 1, divider);
			this._layoutItems.insert(layoutIndex - 1, divider);
		}
		this._layoutItems.insert(layoutIndex, child);
		return super.addChildAt(child, childIndex);
	}

	private function removeItem(child:DisplayObject):DisplayObject {
		this.items.remove(child);
		var index = this.getRawChildIndex(child);
		if (index != 0) {
			var divider = super.getChildAt(index - 1);
			this.dividers.splice(index - 1, 1);
			this._layoutItems.remove(divider);
			this.destroyDivider(cast(divider, InteractiveObject));
		}
		this._layoutItems.remove(child);
		return super.removeChild(child);
	}

	override private function update():Void {
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshResizeDraggingSkin();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();
		this.refreshBackgroundLayout();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();
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
		this.addRawChildAt(skin, 0);
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
			this.removeRawChild(skin);
		}
	}

	private function refreshResizeDraggingSkin():Void {
		var oldSkin = this._currentResizeDraggingSkin;
		this._currentResizeDraggingSkin = this.getCurrentResizeDraggingSkin();
		if (this._currentResizeDraggingSkin == oldSkin) {
			return;
		}
		this.removeCurrentResizeDraggingSkin(oldSkin);
		if (this._currentResizeDraggingSkin == null) {
			return;
		}
		if ((this._currentResizeDraggingSkin is IUIControl)) {
			cast(this._currentResizeDraggingSkin, IUIControl).initializeNow();
		}
		if ((this._currentResizeDraggingSkin is IProgrammaticSkin)) {
			cast(this._currentResizeDraggingSkin, IProgrammaticSkin).uiContext = this;
		}
		this._currentResizeDraggingSkin.visible = false;
		if ((this._currentResizeDraggingSkin is InteractiveObject)) {
			cast(this._currentResizeDraggingSkin, InteractiveObject).mouseEnabled = false;
		}
		if ((this._currentResizeDraggingSkin is DisplayObjectContainer)) {
			cast(this._currentResizeDraggingSkin, DisplayObjectContainer).mouseChildren = false;
		}
		this.addRawChild(this._currentResizeDraggingSkin);
	}

	private function getCurrentResizeDraggingSkin():DisplayObject {
		return this.resizeDraggingSkin;
	}

	private function removeCurrentResizeDraggingSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeRawChild(skin);
		}
	}

	private function createDivider():InteractiveObject {
		var dividerFactory = (this._dividerFactory != null) ? this._dividerFactory : defaultDividerFactory;
		var divider = dividerFactory();
		divider.addEventListener(MouseEvent.ROLL_OVER, baseDividedBox_divider_rollOverHandler);
		divider.addEventListener(MouseEvent.ROLL_OUT, baseDividedBox_divider_rollOutHandler);
		divider.addEventListener(MouseEvent.MOUSE_DOWN, baseDividedBox_divider_mouseDownHandler);
		divider.addEventListener(TouchEvent.TOUCH_BEGIN, baseDividedBox_divider_touchBeginHandler);
		return divider;
	}

	private function destroyDivider(divider:InteractiveObject):Void {
		divider.removeEventListener(MouseEvent.ROLL_OVER, baseDividedBox_divider_rollOverHandler);
		divider.removeEventListener(MouseEvent.ROLL_OUT, baseDividedBox_divider_rollOutHandler);
		divider.removeEventListener(MouseEvent.MOUSE_DOWN, baseDividedBox_divider_mouseDownHandler);
		divider.removeEventListener(TouchEvent.TOUCH_BEGIN, baseDividedBox_divider_touchBeginHandler);
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
			viewPortMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround
		}
		var viewPortMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround
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

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._layoutResult.reset();
		this.layout.layout(this._layoutItems, this._layoutMeasurements, this._layoutResult);
		this._ignoreChildChanges = oldIgnoreChildChanges;
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
		if ((this._currentBackgroundSkin is IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function validateChildren():Void {
		for (layoutItem in this._layoutItems) {
			if ((layoutItem is IValidating)) {
				cast(layoutItem, IValidating).validateNow();
			}
		}
	}

	private function prepareResize(dividerIndex:Int, stageX:Float, stageY:Float):Void {
		throw new TypeError("Missing override for 'prepareResize' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function commitResize(dividerIndex:Int, stageX:Float, stageY:Float, live:Bool):Void {
		throw new TypeError("Missing override for 'commitResize' in type " + Type.getClassName(Type.getClass(this)));
	}

	private function resizeTouchBegin(touchID:Int, divider:InteractiveObject, stageX:Float, stageY:Float):Void {
		if (!this._enabled || this._resizingDividerIndex != -1 || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimPointer(touchID, divider);
		if (!result) {
			return;
		}

		this._resizingTouchID = touchID;
		this._resizingDividerIndex = this.dividers.indexOf(divider);
		this.prepareResize(this._resizingDividerIndex, stageX, stageY);
		if (!this.liveDragging && this._currentResizeDraggingSkin != null) {
			this._currentResizeDraggingSkin.visible = true;
		}
		if (touchID == ExclusivePointer.POINTER_ID_MOUSE) {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, baseDividedBox_divider_stage_mouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, baseDividedBox_divider_stage_mouseUpHandler, false, 0, true);
		} else {
			this.stage.addEventListener(TouchEvent.TOUCH_MOVE, baseDividedBox_divider_stage_touchMoveHandler, false, 0, true);
			this.stage.addEventListener(TouchEvent.TOUCH_END, baseDividedBox_divider_stage_touchEndHandler, false, 0, true);
		}
	}

	private function resizeTouchMove(touchID:Int, stageX:Float, stageY:Float):Void {
		if (this._resizingTouchID != touchID) {
			return;
		}
		this.commitResize(this._resizingDividerIndex, stageX, stageY, true);
	}

	private function resizeTouchEnd(touchID:Int, stageX:Float, stageY:Float):Void {
		if (this._resizingTouchID != touchID) {
			return;
		}

		if (touchID == ExclusivePointer.POINTER_ID_MOUSE) {
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, baseDividedBox_divider_stage_mouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, baseDividedBox_divider_stage_mouseUpHandler);
		} else {
			this.stage.removeEventListener(TouchEvent.TOUCH_MOVE, baseDividedBox_divider_stage_touchMoveHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_END, baseDividedBox_divider_stage_touchEndHandler);
		}

		if (!this.liveDragging) {
			this.commitResize(this._resizingDividerIndex, stageX, stageY, false);
		}
		if (this._currentResizeDraggingSkin != null) {
			this._currentResizeDraggingSkin.visible = false;
		}

		this._resizingTouchID = -1;
		this._resizingDividerIndex = -1;

		if (this._oldDividerMouseCursor != null) {
			Mouse.cursor = this._oldDividerMouseCursor;
			this._oldDividerMouseCursor = null;
		}
	}

	private function baseDividedBox_child_resizeHandler(event:Event):Void {
		if (this._ignoreChildChanges) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function baseDividedBox_addedToStageHandler(event:Event):Void {
		if (this._autoSizeMode == STAGE) {
			// if we validated before being added to the stage, or if we've
			// been removed from stage and added again, we need to be sure
			// that the new stage dimensions are accounted for.
			this.setInvalid(SIZE);
			this.stage.addEventListener(Event.RESIZE, baseDividedBox_stage_resizeHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, baseDividedBox_removedFromStageHandler);
		}
	}

	private function baseDividedBox_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, baseDividedBox_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, baseDividedBox_stage_resizeHandler);
	}

	private function baseDividedBox_stage_resizeHandler(event:Event):Void {
		this.setInvalid(SIZE);
	}

	private function baseDividedBox_divider_rollOverHandler(event:MouseEvent):Void {
		if (!this._enabled || this._resizingDividerIndex != -1 || Mouse.cursor != MouseCursor.AUTO) {
			// already has the resize cursor
			return;
		}
		#if (lime && !flash)
		this._oldDividerMouseCursor = Mouse.cursor;
		Mouse.cursor = this.resizeCursor;
		#end
	}

	private function baseDividedBox_divider_rollOutHandler(event:MouseEvent):Void {
		if (!this._enabled || this._resizingDividerIndex != -1 || this._oldDividerMouseCursor == null) {
			// keep the cursor until mouse up
			return;
		}
		Mouse.cursor = this._oldDividerMouseCursor;
		this._oldDividerMouseCursor = null;
	}

	private function baseDividedBox_divider_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		var divider = cast(event.currentTarget, InteractiveObject);
		this.resizeTouchBegin(event.touchPointID, divider, event.stageX, event.stageY);
	}

	private function baseDividedBox_divider_mouseDownHandler(event:MouseEvent):Void {
		var divider = cast(event.currentTarget, InteractiveObject);
		this.resizeTouchBegin(ExclusivePointer.POINTER_ID_MOUSE, divider, this.stage.mouseX, this.stage.mouseY);
	}

	private function baseDividedBox_divider_stage_mouseMoveHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.resizeTouchMove(ExclusivePointer.POINTER_ID_MOUSE, stage.mouseX, stage.mouseY);
	}

	private function baseDividedBox_divider_stage_touchMoveHandler(event:TouchEvent):Void {
		this.resizeTouchMove(event.touchPointID, event.stageX, event.stageY);
	}

	private function baseDividedBox_divider_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.resizeTouchEnd(ExclusivePointer.POINTER_ID_MOUSE, stage.mouseX, stage.mouseY);
	}

	private function baseDividedBox_divider_stage_touchEndHandler(event:TouchEvent):Void {
		this.resizeTouchEnd(event.touchPointID, event.stageX, event.stageY);
	}
}
