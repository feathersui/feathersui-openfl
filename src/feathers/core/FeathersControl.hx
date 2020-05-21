/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.events.FeathersEvent;
import feathers.events.StyleProviderEvent;
import feathers.layout.ILayoutData;
import feathers.layout.ILayoutObject;
import feathers.style.IStyleObject;
import feathers.style.IStyleProvider;
import feathers.style.IVariantStyleObject;
import feathers.style.Theme;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.geom.Point;

/**
	Base class for all Feathers UI controls. Implements invalidation for changed
	properties and sets up some basic template functions for component
	lifecycle, like [`initialize()`](#initialize) and [`update()`](#update).

	This is a base class for Feathers UI components, and it isn't meant to be
	instantiated directly. It should only be subclassed. For a simple
	component that will automatically measure itself based on its children
	(including optional support for layouts), see
	`feathers.controls.LayoutGroup`.

	@since 1.0.0

	@see `feathers.controls.LayoutGroup`
**/
@:autoBuild(feathers.macros.StyleContextMacro.build())
@:autoBuild(feathers.macros.StyleMacro.build())
class FeathersControl extends MeasureSprite implements IUIControl implements IVariantStyleObject implements ILayoutObject {
	private function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, feathersControl_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, feathersControl_removedFromStageHandler);
	}

	private var _waitingToApplyStyles:Bool = false;
	private var _initializing:Bool = false;

	/**
		Determines if the component has been initialized yet. The `initialize()`
		function is called one time only, when the Feathers UI control is added
		to the display list for the first time.

		In the following example, we check if the component is initialized
		or not, and we listen for an event if it isn't initialized:

		```hx
		if(!control.initialized)
		{
			control.addEventListener(FeathersEvent.INITIALIZE, initializeHandler);
		}
		```

		@see `FeathersEvent.INITIALIZE`
		@see `FeathersControl.initialize()`

		@since 1.0.0
	**/
	public var initialized(default, null):Bool = false;

	/**
		Determines if the component has been initialized and validated for the
		first time.

		In the following example, we check if the component is created or not,
		and we listen for an event if it isn't:

		```hx
		if(!control.created)
		{
			control.addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
		}
		```

		@see `FeathersEvent.CREATION_COMPLETE`
		@see `FeathersControl.update()`
	**/
	public var created(default, null):Bool = false;

	/**
		@see `feathers.core.IUIControl.enabled`
	**/
	@:isVar
	public var enabled(get, set):Bool = true;

	private function get_enabled():Bool {
		return this.enabled;
	}

	private function set_enabled(value:Bool):Bool {
		if (this.enabled == value) {
			return this.enabled;
		}
		this.enabled = value;
		this.setInvalid(InvalidationFlag.STATE);
		return this.enabled;
	}

	private var _currentStyleProvider:IStyleProvider = null;
	private var _customStyleProvider:IStyleProvider = null;

	/**
		When a component initializes, a style provider may be used to set
		properties that affect the component's visual appearance.

		You can set or replace an existing style provider at any time before a
		component initializes without immediately affecting the component's
		visual appearance. After the component initializes, the style provider
		may still be changed, and any properties that were set by the previous
		style provider will be reset to their default values before applying the
		new style provider.

		@see `FeathersControl.variant`
		@see [Introduction to Feathers UI themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public var styleProvider(get, set):IStyleProvider;

	private function get_styleProvider():IStyleProvider {
		if (this._customStyleProvider != null) {
			return this._customStyleProvider;
		}
		return this._currentStyleProvider;
	}

	private function set_styleProvider(value:IStyleProvider):IStyleProvider {
		if (this._customStyleProvider == value) {
			return this._customStyleProvider;
		}
		if (this._customStyleProvider != null) {
			this._customStyleProvider.removeEventListener(Event.CLEAR, customStyleProvider_clearHandler);
		}
		this._customStyleProvider = value;
		if (this._customStyleProvider != null) {
			this._customStyleProvider.addEventListener(Event.CLEAR, customStyleProvider_clearHandler, false, 0, true);
		}
		if (this.initialized && this.stage != null) {
			// ignore if we're not initialized yet or we haven't been added to
			// the stage because it will be handled later. otherwise, apply the
			// new styles immediately.
			this.applyStyles();
		} else {
			this._waitingToApplyStyles = true;
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this._customStyleProvider;
	}

	/**
		The class used as the context for styling the component. If a subclass
		of a component should have different styles than its superclass, it
		should override the `get_styleContext` getter. However, if a subclass
		should continue using the same styles as its superclass, it happens
		automatically.

		@since 1.0.0
	**/
	public var styleContext(get, never):Class<IStyleObject>;

	private function get_styleContext():Class<IStyleObject> {
		return null;
	}

	/**
		@see `feathers.layout.ILayoutObject.includeInLayout`
	**/
	public var includeInLayout(default, set):Bool = true;

	private function set_includeInLayout(value:Bool):Bool {
		if (this.includeInLayout == value) {
			return this.includeInLayout;
		}
		this.includeInLayout = value;
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.includeInLayout;
	}

	/**
		@see `feathers.layout.ILayoutObject.layoutData`
	**/
	@style
	public var layoutData(default, set):ILayoutData = null;

	private function set_layoutData(value:ILayoutData):ILayoutData {
		if (!this.setStyle("layoutData")) {
			return this.layoutData;
		}
		return this.setLayoutDataInternal(value);
	}

	/**
		@see `feathers.layout.IFocusObject.focusManager`
	**/
	@:isVar
	public var focusManager(get, set):IFocusManager = null;

	private function get_focusManager():IFocusManager {
		return this.focusManager;
	}

	private function set_focusManager(value:IFocusManager):IFocusManager {
		if (this.focusManager == value) {
			return this.focusManager;
		}
		this.focusManager = value;
		return this.focusManager;
	}

	/**
		@see `feathers.layout.IFocusObject.focusEnabled`
	**/
	@:isVar
	public var focusEnabled(get, set):Bool = true;

	private function get_focusEnabled():Bool {
		return this.focusEnabled;
	}

	private function set_focusEnabled(value:Bool):Bool {
		if (this.focusEnabled == value) {
			return this.focusEnabled;
		}
		this.focusEnabled = value;
		return this.focusEnabled;
	}

	/**
		An optional skin to display when an `IFocusObject` component receives
		focus.

		@since 1.0.0
	**/
	@:isVar
	@style
	public var focusRectSkin(get, set):DisplayObject = null;

	private function get_focusRectSkin():DisplayObject {
		return this.focusRectSkin;
	}

	private function set_focusRectSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("focusRectSkin")) {
			return this.focusRectSkin;
		}
		if (this.focusRectSkin != null) {
			this.showFocus(false);
		}
		this.focusRectSkin = value;
		return this.focusRectSkin;
	}

	/**
		@see `feathers.core.IFocusObject.showFocus()`
	**/
	public function showFocus(show:Bool):Void {
		if (this.focusManager == null || this.focusRectSkin == null) {
			return;
		}
		if (show) {
			this.focusManager.focusPane.addChild(this.focusRectSkin);
			this.addEventListener(Event.ENTER_FRAME, feathersControl_focusRect_enterFrameHandler);
			this.positionFocusRect();
		} else if (this.focusRectSkin.parent != null) {
			this.removeEventListener(Event.ENTER_FRAME, feathersControl_focusRect_enterFrameHandler);
			this.focusRectSkin.parent.removeChild(this.focusRectSkin);
		}
	}

	@:noCompletion
	private function clearStyle_layoutData():ILayoutData {
		return this.setLayoutDataInternal(null);
	}

	@:noCompletion
	private function clearStyle_focusRectSkin():DisplayObject {
		this.focusRectSkin = null;
		return this.focusRectSkin;
	}

	private function positionFocusRect():Void {
		var point = new Point(0, 0);
		point = this.localToGlobal(point);
		point = this.focusManager.focusPane.globalToLocal(point);
		this.focusRectSkin.x = point.x;
		this.focusRectSkin.y = point.y;
		this.focusRectSkin.width = this.actualWidth;
		this.focusRectSkin.height = this.actualHeight;
	}

	private function setLayoutDataInternal(value:ILayoutData):ILayoutData {
		if (this.layoutData == value) {
			return this.layoutData;
		}
		if (this.layoutData != null) {
			this.layoutData.removeEventListener(Event.CHANGE, layoutData_changeHandler);
		}
		@:bypassAccessor this.layoutData = value;
		if (this.layoutData != null) {
			this.layoutData.addEventListener(Event.CHANGE, layoutData_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.layoutData;
	}

	/**
		May be used to provide multiple different variations of the same UI
		component, each with a different appearance.

		@since 1.0.0
	**/
	public var variant(default, set):String = null;

	private function set_variant(value:String):String {
		if (this.variant == value) {
			return this.variant;
		}
		this.variant = value;
		if (this.initialized && this.stage != null) {
			// ignore if we're not initialized yet or we haven't been added to
			// the stage because it will be handled later. otherwise, apply the
			// new styles immediately.
			this.applyStyles();
		} else {
			this._waitingToApplyStyles = true;
		}
		this.setInvalid(InvalidationFlag.STYLES);
		return this.variant;
	}

	private var _applyingStyles:Bool = false;
	private var _clearingStyles:Bool = false;
	private var _styleProviderStyles:Array<StyleDefinition> = [];
	private var _restrictedStyles:Array<StyleDefinition> = [];

	override public function validateNow():Void {
		if (!this.initialized) {
			if (this._initializing) {
				throw new IllegalOperationError("A component cannot validate until after it has finished initializing.");
			}
			this.initializeNow();
		}
		if (this._waitingToApplyStyles) {
			this.applyStyles();
		}
		super.validateNow();
		if (!this.created) {
			this.created = true;
			FeathersEvent.dispatch(this, FeathersEvent.CREATION_COMPLETE);
		}
	}

	/**
		@see `feathers.core.IUIControl.initializeNow`
	**/
	public function initializeNow():Void {
		if (this.initialized || this._initializing) {
			return;
		}
		this._waitingToApplyStyles = true;
		this._initializing = true;
		this.initialize();
		this.setInvalid(); // set everything invalid
		this._initializing = false;
		this.initialized = true;
		FeathersEvent.dispatch(this, FeathersEvent.INITIALIZE);
	}

	/**
		Sets both the `x` and `y` positions of the control in a single function
		call.

		@see `DisplayObject.x`
		@see `DisplayObject.y`

		@since 1.0.0
	**/
	public function move(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}

	/**
		Sets both the `width` and `height` dimensions of the control in a single
		function call.

		@see `DisplayObject.width`
		@see `DisplayObject.height`

		@since 1.0.0
	**/
	public function setSize(width:Float, height:Float):Void {
		this.width = width;
		this.height = height;
	}

	/**
		Called the first time that the UI control is added to the stage, and
		you should override this function to customize the initialization
		process. Do things like create children and set up event listeners.
		After this function is called, `Event.INIT` is dispatched.

		The following example overrides initialization:

		```hx
		override private function initialize():Void {
			super.initialize();

		}
		```

		@since 1.0.0
	**/
	@:dox(show)
	private function initialize():Void {}

	/**
		Determines if a style may be changed, and restricts the style from being
		changed in the future, if necessary.

		@since 1.0.0
	**/
	@:dox(show)
	private function setStyle(styleName:String, ?state:EnumValue):Bool {
		var styleDef = state == null ? Name(styleName) : NameAndState(styleName, state);
		var restricted = containsStyleDef(this._restrictedStyles, styleDef);
		if (this._applyingStyles && restricted) {
			return false;
		}
		if (this._applyingStyles) {
			if (!this._clearingStyles && !containsStyleDef(this._styleProviderStyles, styleDef)) {
				this._styleProviderStyles.push(styleDef);
			}
		} else if (!restricted) {
			if (!this._clearingStyles && containsStyleDef(this._styleProviderStyles, styleDef)) {
				this._styleProviderStyles.remove(styleDef);
			}
			this._restrictedStyles.push(styleDef);
		}
		return true;
	}

	private function isStyleRestricted(styleName:String, ?state:EnumValue):Bool {
		var styleDef = state == null ? Name(styleName) : NameAndState(styleName, state);
		return containsStyleDef(this._restrictedStyles, styleDef);
	}

	private function containsStyleDef(target:Array<StyleDefinition>, styleDef:StyleDefinition):Bool {
		for (other in target) {
			if (styleDef.equals(other)) {
				return true;
			}
		}
		return false;
	}

	private function applyStyles():Void {
		if (!this.initialized) {
			throw new IllegalOperationError("Cannot apply styles until after a Feathers UI component has initialized.");
		}
		this._waitingToApplyStyles = false;
		var styleProvider = this._customStyleProvider;
		if (styleProvider == null) {
			styleProvider = this._currentStyleProvider;
		}
		if (styleProvider == null) {
			var theme = Theme.getTheme(this);
			if (theme != null) {
				styleProvider = theme.getStyleProvider(this);
			}
		}
		if (styleProvider == null) {
			var theme = Theme.fallbackTheme;
			if (theme != null) {
				styleProvider = theme.getStyleProvider(this);
			}
		}
		if (this._currentStyleProvider != styleProvider) {
			if (this._currentStyleProvider != null) {
				this._currentStyleProvider.removeEventListener(StyleProviderEvent.STYLES_CHANGE, styleProvider_stylesChangeHandler);
				this._currentStyleProvider.removeEventListener(Event.CLEAR, styleProvider_clearHandler);
			}
			this._currentStyleProvider = styleProvider;
			if (this._currentStyleProvider != null) {
				this._currentStyleProvider.addEventListener(StyleProviderEvent.STYLES_CHANGE, styleProvider_stylesChangeHandler, false, 0, true);
				this._currentStyleProvider.addEventListener(Event.CLEAR, styleProvider_clearHandler, false, 0, true);
			}
		}

		var oldApplyingStyles = this._applyingStyles;
		// this flag ensures that the styles do not get restricted when the
		// theme sets them
		this._applyingStyles = true;

		// there may have been a different style provider previously, so clear
		// any old styles that may have been set by it
		this.clearStyles();

		// then, set the styles from the main style provider
		if (this._currentStyleProvider != null) {
			this._currentStyleProvider.applyStyles(this);
		}

		this._applyingStyles = oldApplyingStyles;
	}

	private var _previousClearStyle:Dynamic;

	private function clearStyles():Void {
		var oldClearingStyles = this._clearingStyles;
		this._clearingStyles = true;
		for (styleDef in this._styleProviderStyles) {
			switch (styleDef) {
				case Name(name):
					{
						var clearMethodName = "clearStyle_" + name;
						var clearMethod = Reflect.field(this, clearMethodName);
						if (clearMethod == null) {
							throw new ArgumentError("Missing @style method: '" + clearMethodName + "'");
						}
						Reflect.callMethod(this, clearMethod, []);
					}
				case NameAndState(name, state):
					{
						var method = Reflect.field(this, name);
						Reflect.callMethod(this, method, [state, null]);
					}
			}
		}
		this._styleProviderStyles = [];
		this._clearingStyles = oldClearingStyles;
	}

	private function clearStyleProvider():Void {
		if (this._currentStyleProvider == null) {
			return;
		}
		this._currentStyleProvider.removeEventListener(StyleProviderEvent.STYLES_CHANGE, styleProvider_stylesChangeHandler);
		this._currentStyleProvider.removeEventListener(Event.CLEAR, styleProvider_clearHandler);
		this._currentStyleProvider = null;
		this._waitingToApplyStyles = true;
	}

	private function feathersControl_addedToStageHandler(event:Event):Void {
		// initialize before setting the validation queue to avoid
		// getting added to the validation queue before initialization
		// completes.
		if (!this.initialized) {
			this.initializeNow();
		}
		if (this._waitingToApplyStyles) {
			this.applyStyles();
		}
	}

	private function feathersControl_removedFromStageHandler(event:Event):Void {
		// since there's no concept of disposing a Feathers UI component, we
		// need to clear the style provider here so that there are no memory
		// leaks. the style provider holds a reference to the component through
		// an event listener.
		this.clearStyleProvider();
	}

	private function styleProvider_stylesChangeHandler(event:StyleProviderEvent):Void {
		if (!event.affectsTarget(this)) {
			return;
		}
		if (this.stage != null) {
			this.applyStyles();
		} else {
			this._waitingToApplyStyles = true;
		}
	}

	private function customStyleProvider_clearHandler(event:Event):Void {
		this._customStyleProvider.removeEventListener(Event.CLEAR, customStyleProvider_clearHandler);
		this._customStyleProvider = null;
		// no need to call applyStyles() here because another listener will
		// handle it
	}

	private function styleProvider_clearHandler(event:Event):Void {
		// clear it immediately because we don't want it to get reused
		this.clearStyleProvider();
		if (this.stage != null) {
			this.applyStyles();
		}
	}

	private function layoutData_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
	}

	private function feathersControl_focusRect_enterFrameHandler(event:Event):Void {
		this.positionFocusRect();
	}
}

private enum StyleDefinition {
	Name(name:String);
	NameAndState(name:String, state:EnumValue);
}
