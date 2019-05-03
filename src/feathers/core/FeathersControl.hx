/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.Event;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.display.Sprite;
import feathers.events.FeathersEvent;
import feathers.layout.ILayoutData;
import feathers.layout.ILayoutObject;
import feathers.themes.IStyleProvider;
import feathers.themes.Theme;
import feathers.utils.DisplayUtil;

/**
	Base class for all Feathers UI controls. Implements invalidation for changed
	properties and sets up some basic template functions for component
	lifecycle, like [`initialize()`](#initialize) and [`update()`](#upetad).

	This is a base class for Feathers components that isn't meant to be
	instantiated directly. It should only be subclassed. For a simple
	component that will automatically measure itself based on its children
	(including optional support for layouts, see
	`feathers.controls.LayoutGroup`.

	@since 1.0.0

	@see `feathers.controls.LayoutGroup`
**/
class FeathersControl extends Sprite implements IValidating implements IMeasureDisplayObject implements ILayoutObject {
	private function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, feathersControl_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, feathersControl_removedFromStageHandler);
	}

	private var _initializing:Bool = false;

	/**
		Determines if the component has been initialized yet. The `initialize()`
		function is called one time only, when the Feathers UI control is added
		to the display list for the first time.

		In the following example, we check if the component is initialized
		or not, and we listen for an event if it isn't initialized:

		```hx
		if( !control.isInitialized )
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
		if( !control.isCreated )
		{
			control.addEventListener( FeathersEventType.CREATION_COMPLETE, creationCompleteHandler );
		}
		```

		@see `FeathersEvent.CREATION_COMPLETE`
		@see `FeathersControl.update()`
	**/
	public var created(default, null):Bool = false;

	private var _validating:Bool = false;

	/**
		The component's depth in the display list, relative to the stage. If
		the component isn't on the stage, its depth will be `-1`.

		Used by the validation system to validate components from the top down.

		@since 1.0.0
	**/
	public var depth(default, null):Int = -1;

	/**
		Indicates whether the control is interactive or not.

		In the following example, the control is disabled:

		```hx
		component.enabled = false;
		```

		@default true

		@since 1.0.0
	**/
	public var enabled(default, set):Bool = true;

	private function set_enabled(value:Bool):Bool {
		if (this.enabled == value) {
			return this.enabled;
		}
		this.enabled = value;
		this.setInvalid(InvalidationFlag.STATE);
		return this.enabled;
	}

	private var _allInvalid:Bool = false;
	private var _allInvalidDelayed:Bool = false;
	private var _invalidationFlags:Map<String, Bool> = new Map();
	private var _delayedInvalidationFlags:Map<String, Bool> = new Map();
	private var _setInvalidCount:Int = 0;
	private var _validationQueue:ValidationQueue = null;
	private var _styleProvider:IStyleProvider = null;
	private var actualWidth:Float = 0;
	private var actualHeight:Float = 0;
	private var actualMinWidth:Float = 0;
	private var actualMinHeight:Float = 0;
	private var actualMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var actualMaxHeight:Float = Math.POSITIVE_INFINITY;
	private var scaledActualWidth:Float = 0;
	private var scaledActualHeight:Float = 0;
	private var scaledActualMinWidth:Float = 0;
	private var scaledActualMinHeight:Float = 0;
	private var scaledActualMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var scaledActualMaxHeight:Float = Math.POSITIVE_INFINITY;

	override private function get_width():Float {
		return this.scaledActualWidth;
	}

	override private function set_width(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		this.explicitWidth = value;
		return this.scaledActualWidth;
	}

	override private function get_height():Float {
		return this.scaledActualHeight;
	}

	override private function set_height(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		this.explicitHeight = value;
		return this.scaledActualHeight;
	}

	override private function set_scaleX(value:Float):Float {
		super.scaleX = value;
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		// no need to set invalid because the layout will be the same
		return this.scaleX;
	}

	override private function set_scaleY(value:Float):Float {
		super.scaleY = value;
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		// no need to set invalid because the layout will be the same
		return this.scaleY;
	}

	public var explicitWidth(default, set):Null<Float> = null;

	private function set_explicitWidth(value:Null<Float>):Null<Float> {
		if (this.explicitWidth == value) {
			return this.explicitWidth;
		}
		this.explicitWidth = value;
		var result = this.saveMeasurements(value, this.actualHeight, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		if (result) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.explicitWidth;
	}

	public var explicitHeight(default, set):Null<Float> = null;

	private function set_explicitHeight(value:Null<Float>):Null<Float> {
		if (this.explicitHeight == value) {
			return this.explicitHeight;
		}
		this.explicitHeight = value;
		var result = this.saveMeasurements(this.actualWidth, value, this.actualMinWidth, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
		if (result) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.explicitHeight;
	}

	public var explicitMinWidth(default, set):Null<Float> = null;

	private function set_explicitMinWidth(value:Null<Float>):Null<Float> {
		if (this.explicitMinWidth == value) {
			return this.explicitMinWidth;
		}
		var oldValue = this.explicitMinWidth;
		this.explicitMinWidth = value;
		if (value == null) {
			this.actualMinWidth = 0;
			this.scaledActualMinWidth = 0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			// saveMeasurements() might change actualWidth, so keep the old
			// value for the comparisons below
			var actualWidth = this.actualWidth;
			this.saveMeasurements(this.actualWidth, this.actualHeight, value, this.actualMinHeight, this.actualMaxWidth, this.actualMaxHeight);
			if (this.explicitWidth == null && (actualWidth < value || actualWidth == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitMinWidth;
	}

	public var explicitMinHeight(default, null):Null<Float> = null;

	private function set_explicitMinHeight(value:Null<Float>):Null<Float> {
		if (this.explicitMinHeight == value) {
			return this.explicitMinHeight;
		}
		var oldValue = this.explicitMinHeight;
		this.explicitMinHeight = value;
		if (value == null) {
			this.actualMinHeight = 0;
			this.scaledActualMinHeight = 0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			// saveMeasurements() might change actualHeight, so keep the old
			// value for the comparisons below
			var actualHeight = this.actualHeight;
			this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, value, this.actualMaxWidth, this.actualMaxHeight);
			if (this.explicitHeight == null && (actualHeight < value || actualHeight == oldValue)) {
				// only invalidate if this change might affect the width
				// because everything else was handled in saveMeasurements()
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this.explicitMinHeight;
	}

	public var minWidth(default, set):Float = 0;

	private function set_minWidth(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		this.explicitMinWidth = value;
		return this.scaledActualMinWidth;
	}

	public var minHeight(default, set):Float = 0;

	private function set_minHeight(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		this.explicitMinHeight = value;
		return this.scaledActualMinHeight;
	}

	public var explicitMaxWidth(default, null):Null<Float> = null;
	public var explicitMaxHeight(default, null):Null<Float> = null;
	public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;

	private function set_maxWidth(value:Float):Float {
		if (this.scaleX != 1) {
			value /= this.scaleX;
		}
		this.explicitMaxWidth = value;
		return this.scaledActualMaxWidth;
	}

	public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	private function set_maxHeight(value:Float):Float {
		if (this.scaleY != 1) {
			value /= this.scaleY;
		}
		this.explicitMaxHeight = value;
		return this.scaledActualMaxHeight;
	}

	public var includeInLayout(default, set):Bool = true;

	private function set_includeInLayout(value:Bool):Bool {
		if (this.includeInLayout == value) {
			return this.includeInLayout;
		}
		this.includeInLayout = value;
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.includeInLayout;
	}

	@style
	public var layoutData(default, set):ILayoutData;

	private function set_layoutData(value:ILayoutData):ILayoutData {
		if (!this.setStyle("layoutData")) {
			return this.layoutData;
		}
		if (this.layoutData == value) {
			return this.layoutData;
		}
		if (this.layoutData != null) {
			this.layoutData.removeEventListener(Event.CHANGE, layoutData_changeHandler);
		}
		this.layoutData = value;
		if (this.layoutData != null) {
			this.layoutData.addEventListener(Event.CHANGE, layoutData_changeHandler, false, 0, true);
		}
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
		return this.layoutData;
	}

	/**
		Indicates whether the control is pending validation or not. By default,
		returns `true` if any invalidation flag has been set. If you pass in a
		specific flag, returns `true` only if that flag has been set (others may
		be set too, but it checks the specific flag only. If all flags have been
		marked as invalid, always returns `true`.

		@since 1.0.0
	**/
	public function isInvalid(flag:String = null):Bool {
		if (this._allInvalid) {
			return true;
		}
		if (flag == null) {
			// return true if any flag is set
			return this._invalidationFlags.keys().hasNext();
		}
		return this._invalidationFlags.exists(flag);
	}

	/**
		Call this function to tell the UI control that a redraw is pending.
		The redraw will happen immediately before OpenFL renders the UI
		control to the screen. The validation system exists to ensure that
		multiple properties can be set together without redrawing multiple
		times in between each property change.

		If you cannot wait until later for the validation to happen, you
		can call `validate()` to redraw immediately. As an example,
		you might want to validate immediately if you need to access the
		correct `width` or `height` values of the UI
		control, since these values are calculated during validation.

		@since 1.0.0
	**/
	public function setInvalid(flag:String = null):Void {
		var alreadyInvalid = this.isInvalid();
		var alreadyDelayedInvalid = false;
		if (this._validating) {
			for (otherFlag in this._delayedInvalidationFlags.keys()) {
				alreadyDelayedInvalid = true;
				break;
			}
		}
		if (flag == null) {
			if (this._validating) {
				this._allInvalidDelayed = true;
			} else {
				this._allInvalid = true;
			}
		} else {
			if (this._validating) {
				this._delayedInvalidationFlags.set(flag, true);
			} else if (flag != null && !this._invalidationFlags.exists(flag)) {
				this._invalidationFlags.set(flag, true);
			}
		}
		if (this._validationQueue == null || !this.initialized) {
			// we'll add this component to the queue later, after it has been
			// added to the stage.
			return;
		}
		if (this._validating) {
			// if we've already incremented this counter this time, we can
			// return. we're already in queue.
			if (alreadyDelayedInvalid) {
				return;
			}
			this._setInvalidCount++;
			// if setInvalid() is called during validation, we'll be added
			// back to the end of the queue. we'll keep trying this a certain
			// number of times, but at some point, it needs to be considered
			// an infinite loop or a serious bug because it affects
			// performance.
			if (this._setInvalidCount >= 10) {
				throw new Error(Type.getClassName(Type.getClass(this))
					+ " returned to validation queue too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls setInvalid() during validation.");
			}
			this._validationQueue.addControl(this);
			return;
		}
		if (alreadyInvalid) {
			return;
		}
		this._setInvalidCount = 0;
		this._validationQueue.addControl(this);
	}

	private var _applyingStyles:Bool = false;
	private var _restrictedStyles:Array<String> = [];

	/**
		Immediately validates the display object, if it is invalid. The
		validation system exists to postpone updating a display object after
		properties are changed until until the last possible moment the
		display object is rendered. This allows multiple properties to be
		changed at a time without requiring a full update every time.

		@since 1.0.0
	**/
	public function validateNow():Void {
		if (!this.initialized) {
			if (this._initializing) {
				throw new IllegalOperationError("A component cannot validate until after it has finished initializing.");
			}
			this.initializeNow();
		}
		// if we're not actually invalid, there's nothing to do here, so
		// simply return.
		if (!this.isInvalid()) {
			return;
		}
		if (this._validating) {
			// we were already validating, so there's nothing to do here.
			// the existing validation will continue.
			return;
		}
		this._validating = true;
		this.update();
		for (flag in this._invalidationFlags.keys()) {
			this._invalidationFlags.remove(flag);
		}
		this._allInvalid = this._allInvalidDelayed;
		for (flag in this._delayedInvalidationFlags.keys()) {
			if (flag == null) {
				this._allInvalid = true;
			} else {
				this._invalidationFlags.set(flag, true);
			}
			this._delayedInvalidationFlags.remove(flag);
		}
		this._validating = false;
		if (!this.created) {
			this.created = true;
			FeathersEvent.dispatch(this, FeathersEvent.CREATION_COMPLETE);
		}
	}

	/**
		If the component has not yet initialized, initializes immediately. The
		`initialize()` method will be called, and the `FeathersEvent.INITIALIZE`
		event will be dispatched. Then, if the component has a style provider, it
		will be applied. The component will not validate, though. To initialize
		and validate immediately, call `validateNow()` instead.

		@since 1.0.0
	**/
	public function initializeNow():Void {
		if (this.initialized || this._initializing) {
			return;
		}
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
		this.width = x;
		this.height = y;
	}

	/**
		Sets an invalidation flag. This will not add the component to the
		validation queue. It only sets the flag. A subclass might use
		this function during `draw()` to manipulate the flags that
		its superclass sees.

		@see `FeathersControl.setInvalid()`

		@since 1.0.0
	**/
	@:dox(show)
	private function setInvalidationFlag(flag:String):Void {
		if (this._invalidationFlags.exists(flag)) {
			return;
		}
		this._invalidationFlags.set(flag, true);
	}

	/**
		Called the first time that the UI control is added to the stage, and
		you should override this function to customize the initialization
		process. Do things like create children and set up event listeners.
		After this function is called, `Event.INIT` is dispatched.

		@since 1.0.0
	**/
	@:dox(show)
	private function initialize():Void {}

	/**
		Override to customize layout and to adjust properties of children.
		Called when the component validates, if any flags have been marked
		to indicate that validation is pending.

		@since 1.0.0
	**/
	@:dox(show)
	private function update():Void {}

	/**
		Saves the calculated dimensions for the component, replacing any values
		that haven't been set explicitly. Returns `true` if the reported values
		have changed and `Event.RESIZE` was dispatched.

		@since 1.0.0
	**/
	@:dox(show)
	private function saveMeasurements(width:Float, height:Float, minWidth:Float = 0, minHeight:Float = 0, ?maxWidth:Float, ?maxHeight:Float):Bool {
		if (maxWidth == null) {
			maxWidth = Math.POSITIVE_INFINITY;
		}
		if (maxHeight == null) {
			maxHeight = Math.POSITIVE_INFINITY;
		}
		// if any of the dimensions were set explicitly, the explicit values must
		// take precedence over the measured values
		if (this.explicitMinWidth != null) {
			minWidth = this.explicitMinWidth;
		}
		if (this.explicitMinHeight != null) {
			minHeight = this.explicitMinHeight;
		}
		if (this.explicitMaxWidth != null) {
			maxWidth = this.explicitMaxWidth;
		} else if (maxWidth == null) {
			// since it's optional, this is our default
			maxWidth = Math.POSITIVE_INFINITY;
		}
		if (this.explicitMaxHeight != null) {
			maxHeight = this.explicitMaxHeight;
		} else if (maxHeight == null) {
			// since it's optional, this is our default
			maxHeight = Math.POSITIVE_INFINITY;
		}

		// next, we ensure that minimum and maximum measured dimensions are not
		// swapped because we'd prefer to avoid a situation where min > max
		// but don't change anything that's explicit, even if it doesn't meet
		// that preference.
		if (this.explicitMaxWidth == null && maxWidth < minWidth) {
			maxWidth = minWidth;
		}
		if (this.explicitMinWidth == null && minWidth > maxWidth) {
			minWidth = maxWidth;
		}
		if (this.explicitMaxHeight == null && maxHeight < minHeight) {
			maxHeight = minHeight;
		}
		if (this.explicitMinHeight == null && minHeight > maxHeight) {
			minHeight = maxHeight;
		}

		// now, proceed with the final width and height values, based on the
		// measurements passed in, and the adjustments to
		if (this.explicitWidth != null) {
			width = this.explicitWidth;
		} else {
			if (width < minWidth) {
				width = minWidth;
			} else if (width > maxWidth) {
				width = maxWidth;
			}
		}
		if (this.explicitHeight != null) {
			height = this.explicitHeight;
		} else {
			if (height < minHeight) {
				height = minHeight;
			} else if (height > maxHeight) {
				height = maxHeight;
			}
		}

		var scaleX = this.scaleX;
		if (scaleX < 0) {
			scaleX = -scaleX;
		}
		var scaleY = this.scaleY;
		if (scaleY < 0) {
			scaleY = -scaleY;
		}

		var resized = false;
		if (this.actualWidth != width) {
			this.actualWidth = width;
			resized = true;
		}
		if (this.actualHeight != height) {
			this.actualHeight = height;
			resized = true;
		}
		if (this.actualMinWidth != minWidth) {
			this.actualMinWidth = minWidth;
			resized = true;
		}
		if (this.actualMinHeight != minHeight) {
			this.actualMinHeight = minHeight;
			resized = true;
		}
		if (this.actualMaxWidth != maxWidth) {
			this.actualMaxWidth = maxWidth;
			resized = true;
		}
		if (this.actualMaxHeight != maxHeight) {
			this.actualMaxHeight = maxHeight;
			resized = true;
		}

		width = this.scaledActualWidth;
		height = this.scaledActualHeight;
		this.scaledActualWidth = this.actualWidth * scaleX;
		this.scaledActualHeight = this.actualHeight * scaleX;
		this.scaledActualMinWidth = this.actualMinWidth * scaleX;
		this.scaledActualMinHeight = this.actualMinHeight * scaleX;
		this.scaledActualMaxWidth = this.actualMaxWidth * scaleX;
		this.scaledActualMaxHeight = this.actualMaxHeight * scaleX;
		if (width != this.scaledActualWidth || height != this.scaledActualHeight) {
			resized = true;
			FeathersEvent.dispatch(this, Event.RESIZE);
		}
		return resized;
	}

	/**
		Determines if a style may be changed, and restricts the style from being
		changed in the future, if necessary.
	**/
	@:dox(show)
	private function setStyle(styleName:String):Bool {
		var restricted = this._restrictedStyles.indexOf(styleName) != -1;
		if (this._applyingStyles && restricted) {
			return false;
		}
		if (!this._applyingStyles && !restricted) {
			this._restrictedStyles.push(styleName);
		}
		return true;
	}

	private function isStyleRestricted(styleName:String):Bool {
		return this._restrictedStyles.indexOf(styleName) != -1;
	}

	private function applyStyles():Void {
		var styleProvider = Theme.getStyleProvider(this);
		if (this._styleProvider != styleProvider) {
			if (this._styleProvider != null) {
				this._styleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
			}
			this._styleProvider = styleProvider;
			this._styleProvider.addEventListener(Event.CHANGE, styleProvider_changeHandler, false, 0, true);
		}
		if (this._styleProvider == null) {
			return;
		}
		var oldApplyingStyles = this._applyingStyles;
		this._applyingStyles = true;
		this._styleProvider.applyStyles(this);
		this._applyingStyles = oldApplyingStyles;
	}

	private function feathersControl_addedToStageHandler(event:Event):Void {
		// initialize before setting the validation queue to avoid
		// getting added to the validation queue before initialization
		// completes.
		if (!this.initialized) {
			this.initializeNow();
		}
		this.depth = DisplayUtil.getDisplayObjectDepthFromStage(this);
		this._validationQueue = ValidationQueue.forStage(this.stage);
		this.applyStyles();
		if (this.isInvalid()) {
			this._setInvalidCount = 0;
			// add to validation queue, if required
			this._validationQueue.addControl(this);
		}
	}

	private function feathersControl_removedFromStageHandler(event:Event):Void {
		this.depth = -1;
		this._validationQueue = null;
		if (this._styleProvider != null) {
			this._styleProvider.removeEventListener(Event.CHANGE, styleProvider_changeHandler);
			this._styleProvider = null;
		}
	}

	private function styleProvider_changeHandler(event:Event):Void {
		this.applyStyles();
	}

	private function layoutData_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, FeathersEvent.LAYOUT_DATA_CHANGE);
	}
}
