/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.FocusEvent;
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

	@event feathers.events.FeathersEvent.INITIALIZE

	@event feathers.events.FeathersEvent.ENABLE

	@event feathers.events.FeathersEvent.DISABLE

	@event feathers.events.FeathersEvent.CREATION_COMPLETE

	@event feathers.events.FeathersEvent.LAYOUT_DATA_CHANGE

	@event feathers.events.FeathersEvent.STATE_CHANGE

	@since 1.0.0

	@see `feathers.controls.LayoutGroup`
**/
@:event(feathers.events.FeathersEvent.INITIALIZE)
@:event(feathers.events.FeathersEvent.CREATION_COMPLETE)
@:event(feathers.events.FeathersEvent.ENABLE)
@:event(feathers.events.FeathersEvent.DISABLE)
@:event(feathers.events.FeathersEvent.LAYOUT_DATA_CHANGE)
@:event(feathers.events.FeathersEvent.STATE_CHANGE)
@:autoBuild(feathers.macros.StyleContextMacro.build())
@:autoBuild(feathers.macros.StyleMacro.build())
class FeathersControl extends MeasureSprite implements IUIControl implements IVariantStyleObject implements ILayoutObject {
	private function new() {
		super();

		this.tabEnabled = (this is IFocusObject);

		this.addEventListener(Event.ADDED_TO_STAGE, feathersControl_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, feathersControl_removedFromStageHandler);
		this.addEventListener(FocusEvent.FOCUS_IN, feathersControl_focusInHandler);
		this.addEventListener(FocusEvent.FOCUS_OUT, feathersControl_focusOutHandler);
	}

	private var _waitingToApplyStyles:Bool = false;
	private var _initializing:Bool = false;
	private var _initialized:Bool = false;

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
	public var initialized(get, never):Bool;

	private function get_initialized():Bool {
		return this._initialized;
	}

	private var _created:Bool = false;

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
	public var created(get, never):Bool;

	private function get_created():Bool {
		return this._created;
	}

	private var _enabled:Bool = true;

	/**
		@see `feathers.core.IUIControl.enabled`
	**/
	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return this._enabled;
	}

	private function set_enabled(value:Bool):Bool {
		if (this._enabled == value) {
			return this._enabled;
		}
		this._enabled = value;
		if (this._enabled || this.disabledAlpha == null) {
			super.alpha = this._explicitAlpha;
		} else if (!this._enabled && this.disabledAlpha != null) {
			super.alpha = this.disabledAlpha;
		}
		this.setInvalid(STATE);
		if (this._enabled) {
			FeathersEvent.dispatch(this, FeathersEvent.ENABLE);
		} else {
			FeathersEvent.dispatch(this, FeathersEvent.DISABLE);
		}
		return this._enabled;
	}

	private var _toolTip:String = null;

	/**
		@see `feathers.core.IUIControl.toolTip`
	**/
	public var toolTip(get, set):String;

	private function get_toolTip():String {
		return this._toolTip;
	}

	private function set_toolTip(value:String):String {
		if (this._toolTip == value) {
			return this._toolTip;
		}
		this._toolTip = value;
		return this._toolTip;
	}

	private var _themeEnabled:Bool = true;

	/**
		@see `feathers.style.IStyleObject.themeEnabled`
	**/
	public var themeEnabled(get, set):Bool;

	private function get_themeEnabled():Bool {
		return this._themeEnabled;
	}

	private function set_themeEnabled(value:Bool):Bool {
		if (this._themeEnabled == value) {
			return this._themeEnabled;
		}
		this._themeEnabled = value;
		if (this._initialized && this.stage != null) {
			// ignore if we're not initialized yet or we haven't been added to
			// the stage because it will be handled later. otherwise, apply the
			// new styles immediately.
			this.applyStyles();
		} else {
			this._waitingToApplyStyles = true;
		}
		this.setInvalid(STYLES);
		return this._themeEnabled;
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
		if (this._initialized && this.stage != null) {
			// ignore if we're not initialized yet or we haven't been added to
			// the stage because it will be handled later. otherwise, apply the
			// new styles immediately.
			this.applyStyles();
		} else {
			this._waitingToApplyStyles = true;
		}
		this.setInvalid(STYLES);
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

	private var _includeInLayout:Bool = true;

	/**
		@see `feathers.layout.ILayoutObject.includeInLayout`
	**/
	public var includeInLayout(get, set):Bool;

	private function get_includeInLayout():Bool {
		return this._includeInLayout;
	}

	private function set_includeInLayout(value:Bool):Bool {
		if (this._includeInLayout == value) {
			return this._includeInLayout;
		}
		this._includeInLayout = value;
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this._includeInLayout;
	}

	private var _layoutData:ILayoutData;

	/**
		@see `feathers.layout.ILayoutObject.layoutData`
	**/
	@style
	public var layoutData(get, set):ILayoutData;

	private function get_layoutData():ILayoutData {
		return this._layoutData;
	}

	private function set_layoutData(value:ILayoutData):ILayoutData {
		if (!this.setStyle("layoutData")) {
			return this._layoutData;
		}
		// in a -final build, this forces the clearStyle
		// function to be kept if the property is kept
		// otherwise, it would be removed by dce
		this._previousClearStyle = this.clearStyle_layoutData;
		return this.setLayoutDataInternal(value);
	}

	private var _explicitAlpha:Float = 1.0;

	#if flash
	@:setter(alpha)
	private function set_alpha(value:Float):Void {
		this._explicitAlpha = value;
		if (this._enabled || this.disabledAlpha == null) {
			super.alpha = value;
		}
	}
	#else
	override private function set_alpha(value:Float):Float {
		this._explicitAlpha = value;
		if (this._enabled || this.disabledAlpha == null) {
			super.alpha = value;
		}
		return this._explicitAlpha;
	}
	#end

	/**
		When `disabledAlpha` is not `null`, sets the `alpha` property to this
		value when the the `enabled` property is set to `false`.

		@since 1.0.0
	**/
	@:style
	public var disabledAlpha:Null<Float> = null;

	private var _focusManager:IFocusManager = null;

	/**
		@see `feathers.layout.IFocusObject.focusManager`
	**/
	public var focusManager(get, set):IFocusManager;

	private function get_focusManager():IFocusManager {
		return this._focusManager;
	}

	private function set_focusManager(value:IFocusManager):IFocusManager {
		if (this._focusManager == value) {
			return this._focusManager;
		}
		if (this._focusManager != null) {
			this.showFocus(false);
		}
		this._focusManager = value;
		return this._focusManager;
	}

	private var _focusOwner:IFocusObject;

	/**
		@see `feathers.layout.IFocusObject.focusOwner`
	**/
	public var focusOwner(get, set):IFocusObject;

	private function get_focusOwner():IFocusObject {
		return this._focusOwner;
	}

	private function set_focusOwner(value:IFocusObject):IFocusObject {
		if (this._focusOwner == value) {
			return this._focusOwner;
		}
		this._focusOwner = value;
		return this._focusOwner;
	}

	@:dox(hide)
	private var rawTabEnabled(get, never):Bool;

	private function get_rawTabEnabled():Bool {
		return super.tabEnabled;
	}

	private var _focusEnabled:Bool = true;

	/**
		@see `feathers.layout.IFocusObject.focusEnabled`
	**/
	public var focusEnabled(get, set):Bool;

	private function get_focusEnabled():Bool {
		return this._enabled && this._focusEnabled;
	}

	private function set_focusEnabled(value:Bool):Bool {
		if (this._focusEnabled == value) {
			return this._focusEnabled;
		}
		this._focusEnabled = value;
		return this._focusEnabled;
	}

	@:getter(tabEnabled)
	#if !flash override #end private function get_tabEnabled():Bool {
		return this._enabled && super.tabEnabled;
	}

	private var _focusRectSkin:DisplayObject = null;

	/**
		An optional skin to display when an `IFocusObject` component receives
		focus.

		@since 1.0.0
	**/
	@style
	public var focusRectSkin(get, set):DisplayObject;

	private function get_focusRectSkin():DisplayObject {
		return this._focusRectSkin;
	}

	private function set_focusRectSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("focusRectSkin")) {
			return this._focusRectSkin;
		}
		this.showFocus(false);
		// in a -final build, this forces the clearStyle
		// function to be kept if the property is kept
		// otherwise, it would be removed by dce
		this._previousClearStyle = this.clearStyle_focusRectSkin;
		this._focusRectSkin = value;
		return this._focusRectSkin;
	}

	private var _focusPaddingTop:Float = 0.0;

	/**
		Optional padding outside the top edge of this UI component when the
		`focusRectSkin` is visible.

		@since 1.0.0
	**/
	@style
	public var focusPaddingTop(get, set):Float;

	private function get_focusPaddingTop():Float {
		return this._focusPaddingTop;
	}

	private function set_focusPaddingTop(value:Float):Float {
		if (!this.setStyle("focusPaddingTop")) {
			return this._focusPaddingTop;
		}
		// in a -final build, this forces the clearStyle
		// function to be kept if the property is kept
		// otherwise, it would be removed by dce
		this._previousClearStyle = this.clearStyle_focusPaddingTop;
		this._focusPaddingTop = value;
		return this._focusPaddingTop;
	}

	private var _focusPaddingRight:Float = 0.0;

	/**
		Optional padding outside the right edge of this UI component when the
		`focusRectSkin` is visible.

		@since 1.0.0
	**/
	@style
	public var focusPaddingRight(get, set):Float;

	private function get_focusPaddingRight():Float {
		return this._focusPaddingRight;
	}

	private function set_focusPaddingRight(value:Float):Float {
		if (!this.setStyle("focusPaddingRight")) {
			return this._focusPaddingRight;
		}
		// in a -final build, this forces the clearStyle
		// function to be kept if the property is kept
		// otherwise, it would be removed by dce
		this._previousClearStyle = this.clearStyle_focusPaddingRight;
		this._focusPaddingRight = value;
		return this._focusPaddingRight;
	}

	private var _focusPaddingBottom:Float = 0.0;

	/**
		Optional padding outside the bottom edge of this UI component when the
		`focusRectSkin` is visible.

		@since 1.0.0
	**/
	@style
	public var focusPaddingBottom(get, set):Float;

	private function get_focusPaddingBottom():Float {
		return this._focusPaddingBottom;
	}

	private function set_focusPaddingBottom(value:Float):Float {
		if (!this.setStyle("focusPaddingBottom")) {
			return this._focusPaddingBottom;
		}
		// in a -final build, this forces the clearStyle
		// function to be kept if the property is kept
		// otherwise, it would be removed by dce
		this._previousClearStyle = this.clearStyle_focusPaddingBottom;
		this._focusPaddingBottom = value;
		return this._focusPaddingBottom;
	}

	private var _focusPaddingLeft:Float = 0.0;

	/**
		Optional padding outside the left edge of this UI component when the
		`focusRectSkin` is visible.

		@since 1.0.0
	**/
	@style
	public var focusPaddingLeft(get, set):Float;

	private function get_focusPaddingLeft():Float {
		return this._focusPaddingLeft;
	}

	private function set_focusPaddingLeft(value:Float):Float {
		if (!this.setStyle("focusPaddingLeft")) {
			return this._focusPaddingLeft;
		}
		// in a -final build, this forces the clearStyle
		// function to be kept if the property is kept
		// otherwise, it would be removed by dce
		this._previousClearStyle = this.clearStyle_focusPaddingLeft;
		this._focusPaddingLeft = value;
		return this._focusPaddingLeft;
	}

	/**
		Sets all four padding properties to the same value.

		@see `FeathersControl.focusPaddingTop`
		@see `FeathersControl.focusPaddingRight`
		@see `FeathersControl.focusPaddingBottom`
		@see `FeathersControl.focusPaddingLeft`

		@since 1.0.0
	**/
	public function setFocusPadding(value:Float):Void {
		this.focusPaddingTop = value;
		this.focusPaddingRight = value;
		this.focusPaddingBottom = value;
		this.focusPaddingLeft = value;
	}

	/**
		@see `feathers.core.IFocusObject.showFocus()`
	**/
	public function showFocus(show:Bool):Void {
		if (this._focusManager == null || this._focusRectSkin == null) {
			return;
		}
		if (show) {
			this._focusManager.focusPane.addChild(this._focusRectSkin);
			this.addEventListener(Event.ENTER_FRAME, feathersControl_focusRect_enterFrameHandler);
			this.positionFocusRect();
		} else if (this._focusRectSkin.parent != null) {
			this.removeEventListener(Event.ENTER_FRAME, feathersControl_focusRect_enterFrameHandler);
			this._focusRectSkin.parent.removeChild(this._focusRectSkin);
		}
	}

	@:noCompletion
	private function clearStyle_layoutData():ILayoutData {
		return this.setLayoutDataInternal(null);
	}

	@:noCompletion
	private function clearStyle_focusRectSkin():DisplayObject {
		this.showFocus(false);
		this._focusRectSkin = null;
		return this._focusRectSkin;
	}

	@:noCompletion
	private function clearStyle_focusPaddingTop():Float {
		this._focusPaddingTop = 0.0;
		return this._focusPaddingTop;
	}

	@:noCompletion
	private function clearStyle_focusPaddingRight():Float {
		this._focusPaddingRight = 0.0;
		return this._focusPaddingRight;
	}

	@:noCompletion
	private function clearStyle_focusPaddingBottom():Float {
		this._focusPaddingBottom = 0.0;
		return this._focusPaddingBottom;
	}

	@:noCompletion
	private function clearStyle_focusPaddingLeft():Float {
		this._focusPaddingLeft = 0.0;
		return this._focusPaddingLeft;
	}

	private function positionFocusRect():Void {
		if (this._focusManager == null || this._focusRectSkin == null || this._focusRectSkin.parent == null) {
			return;
		}
		var point = new Point(-this._focusPaddingLeft, -this._focusPaddingTop);
		point = this.localToGlobal(point);
		point = this._focusManager.focusPane.globalToLocal(point);
		this._focusRectSkin.x = point.x;
		this._focusRectSkin.y = point.y;
		point.setTo(this.actualWidth + this._focusPaddingRight, this.actualHeight + this._focusPaddingBottom);
		point = this.localToGlobal(point);
		point = this._focusManager.focusPane.globalToLocal(point);
		this._focusRectSkin.width = point.x - this._focusRectSkin.x;
		this._focusRectSkin.height = point.y - this._focusRectSkin.y;
	}

	private function setLayoutDataInternal(value:ILayoutData):ILayoutData {
		if (this._layoutData == value) {
			return this._layoutData;
		}
		if (this._layoutData != null) {
			this._layoutData.removeEventListener(Event.CHANGE, layoutData_changeHandler);
		}
		this._layoutData = value;
		if (this._layoutData != null) {
			this._layoutData.addEventListener(Event.CHANGE, layoutData_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this._layoutData;
	}

	private var _variant:String;

	/**
		May be used to provide multiple different variations of the same UI
		component, each with a different appearance.

		@since 1.0.0
	**/
	public var variant(get, set):String;

	private function get_variant():String {
		return this._variant;
	}

	private function set_variant(value:String):String {
		if (this._variant == value) {
			return this._variant;
		}
		this._variant = value;
		if (this._initialized && this.stage != null) {
			// ignore if we're not initialized yet or we haven't been added to
			// the stage because it will be handled later. otherwise, apply the
			// new styles immediately.
			this.applyStyles();
		} else {
			this._waitingToApplyStyles = true;
		}
		this.setInvalid(STYLES);
		return this._variant;
	}

	private var _applyingStyles:Bool = false;
	private var _clearingStyles:Bool = false;
	private var _styleProviderStyles:Array<StyleDefinition> = [];
	private var _restrictedStyles:Array<StyleDefinition> = [];

	override public function validateNow():Void {
		if (!this._initialized) {
			if (this._initializing) {
				throw new IllegalOperationError("A component cannot validate until after it has finished initializing.");
			}
			this.initializeNow();
		}
		if (this._waitingToApplyStyles) {
			this.applyStyles();
		}
		super.validateNow();
		if (!this._created) {
			this._created = true;
			FeathersEvent.dispatch(this, FeathersEvent.CREATION_COMPLETE);
		}
	}

	/**
		@see `feathers.core.IUIControl.initializeNow`
	**/
	public function initializeNow():Void {
		if (this._initialized || this._initializing) {
			return;
		}
		this._waitingToApplyStyles = true;
		this._initializing = true;
		this.initialize();
		this.setInvalid(); // set everything invalid
		this._initializing = false;
		this._initialized = true;
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
		if (!this._initialized) {
			throw new IllegalOperationError("Cannot apply styles until after a Feathers UI component has initialized.");
		}
		this._waitingToApplyStyles = false;
		var styleProvider = this._customStyleProvider;
		if (styleProvider == null) {
			var theme = Theme.getTheme(this);
			if (theme != null) {
				styleProvider = theme.getStyleProvider(this);
			}
		}
		if (this._themeEnabled && styleProvider == null) {
			var theme = Theme.fallbackTheme;
			if (theme != null) {
				styleProvider = theme.getStyleProvider(this);
			}
		}
		if (styleProvider == null) {
			// fall back to keeping the previous style provider
			styleProvider = this._currentStyleProvider;
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
		if (!this._initialized) {
			this.initializeNow();
		}
		if (this._waitingToApplyStyles) {
			this.applyStyles();
		}
	}

	private function feathersControl_removedFromStageHandler(event:Event):Void {
		this.showFocus(false);
		// since there's no concept of disposing a Feathers UI component, we
		// need to clear the style provider here so that there are no memory
		// leaks. the style provider holds a reference to the component through
		// an event listener.
		this.clearStyleProvider();
	}

	private function feathersControl_focusInHandler(event:FocusEvent):Void {
		var focusThis:IFocusObject = null;
		if ((this is IFocusObject)) {
			focusThis = cast(this, IFocusObject);
		}
		if (this._focusManager == null || !this._focusManager.showFocusIndicator || this._focusManager.focus != focusThis) {
			return;
		}
		this.showFocus(true);
	}

	private function feathersControl_focusOutHandler(event:FocusEvent):Void {
		if (this._focusManager == null) {
			return;
		}
		this.showFocus(false);
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
