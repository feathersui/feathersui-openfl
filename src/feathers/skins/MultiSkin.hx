/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.controls.IToggle;
import feathers.core.IMeasureObject;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;

/**
	A skin where each state may display a different display object.

	This skin is useful for UI components that need to dispatch
	`MouseEvent.CLICK` or `TouchEvent.TOUCH_TAP` because these events won't
	normally be dispatched if the object under the pointer changes between
	mouse/touch start and mouse/touch end.

	@since 1.0.0
**/
class MultiSkin extends ProgrammaticSkin {
	/**
		Creates a new `MultiSkin` object.

		@since 1.0.0
	**/
	public function new(?defaultView:DisplayObject) {
		super();
		this.mouseChildren = false;
		this.defaultView = defaultView;
	}

	private var _previousView:DisplayObject;
	private var _currentView:DisplayObject;
	private var _currentViewMeasurements:Measurements;

	private var _stateToView:Map<EnumValue, DisplayObject>;

	private var _defaultView:DisplayObject;

	/**
		The default view that is displayed when no other view is overridden for
		the current state.

		@since 1.0.0
	**/
	public var defaultView(get, set):DisplayObject;

	private function get_defaultView():DisplayObject {
		return this._defaultView;
	}

	private function set_defaultView(value:DisplayObject):DisplayObject {
		if (this._defaultView == value) {
			return this._defaultView;
		}
		this._defaultView = value;
		this.setInvalid(STYLES);
		return this._defaultView;
	}

	private var _disabledView:DisplayObject;

	/**
		The view that is displayed when the state context is disabled. To use
		this skin, the state context must implement the `IUIControl` interface.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	public var disabledView(get, set):DisplayObject;

	private function get_disabledView():DisplayObject {
		return this._disabledView;
	}

	private function set_disabledView(value:DisplayObject):DisplayObject {
		if (this._disabledView == value) {
			return this._disabledView;
		}
		this._disabledView = value;
		this.setInvalid(STYLES);
		return this._disabledView;
	}

	private var _selectedView:DisplayObject;

	/**
		The view that is displayed when the state context is selected. To use
		this skin, the state context must implement the `IToggle` interface.

		@see `feathers.core.IToggle.selected`

		@since 1.0.0
	**/
	public var selectedView(get, set):DisplayObject;

	private function get_selectedView():DisplayObject {
		return this._selectedView;
	}

	private function set_selectedView(value:DisplayObject):DisplayObject {
		if (this._selectedView == value) {
			return this._disabledView;
		}
		this._selectedView = value;
		this.setInvalid(STYLES);
		return this._selectedView;
	}

	/**
		Gets the view to be used by the skin when the context's `currentState`
		property matches the specified state value.

		If a view is not defined for a specific state, returns `null`.

		@see `ProgrammaticSkin.stateContext`
		@see `MultiSkin.defaultView`
		@see `MultiSkin.setViewForState`

		@since 1.0.0
	**/
	public function getViewForState(state:EnumValue):DisplayObject {
		if (this._stateToView == null) {
			return null;
		}
		return this._stateToView.get(state);
	}

	/**
		Sets the view to be used by the skin when the context's `currentState`
		property matches the specified state value.

		If a view is not defined for a specific state, the value of the
		`defaultView` property will be used instead.

		To clear a state's view, pass in `null`.

		@see `ProgrammaticSkin.stateContext`
		@see `MultiSkin.defaultView`
		@see `MultiSkin.getViewForState`

		@since 1.0.0
	**/
	public function setViewForState(state:EnumValue, view:DisplayObject):Void {
		if (this._stateToView == null) {
			this._stateToView = [];
		}
		if (this._stateToView.get(state) == view) {
			return;
		}
		this._stateToView.set(state, view);
		this.setInvalid(STYLES);
	}

	override private function update():Void {
		this.refreshView();
		this.measure();
		this.layoutView();
		this._previousView = this._currentView;
	}

	private function refreshView():Void {
		var oldView = this._currentView;
		this._currentView = this.getCurrentView();
		if (this._currentView == oldView) {
			return;
		}
		this.removeCurrentView(oldView);
		if (this._currentView == null) {
			this._currentViewMeasurements = null;
			return;
		}
		if ((this._currentView is IUIControl)) {
			(cast this._currentView : IUIControl).initializeNow();
		}
		if (this._currentViewMeasurements == null) {
			this._currentViewMeasurements = new Measurements(this._currentView);
		} else {
			this._currentViewMeasurements.save(this._currentView);
		}
		if ((this._currentView is IProgrammaticSkin)) {
			(cast this._currentView : IProgrammaticSkin).uiContext = this._uiContext;
		}
		if ((this._currentView is IStateObserver)) {
			(cast this._currentView : IStateObserver).stateContext = this._stateContext;
		}
		this.addChild(this._currentView);
	}

	private function removeCurrentView(view:DisplayObject):Void {
		if (view == null) {
			return;
		}
		if ((view is IProgrammaticSkin)) {
			(cast view : IProgrammaticSkin).uiContext = null;
		}
		if ((view is IStateObserver)) {
			(cast view : IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._currentViewMeasurements.restore(view);
		if (view.parent == this) {
			this.removeChild(view);
		}
	}

	/**
		Returns the current view based on the state context.

		@see `MultiSkin.defaultView`
		@see `MultiSkin.getViewForState`
		@see `MultiSkin.setViewForState`
		@see `ProgrammaticSkin.uiContext`
		@see `ProgrammaticSkin.stateContext`

		@since 1.0.0
	**/
	@:dox(show)
	private function getCurrentView():DisplayObject {
		if (this._previousView != null) {
			return this._previousView;
		}
		return this.getCurrentViewWithoutCache();
	}

	private function getCurrentViewWithoutCache():DisplayObject {
		var stateContext = this._stateContext;
		if (stateContext == null && (this._uiContext is IStateContext)) {
			stateContext = cast this._uiContext;
		}
		if (this._stateToView != null && stateContext != null) {
			var result = this._stateToView.get(stateContext.currentState);
			if (result != null) {
				return result;
			}
		}
		if (this._uiContext == null) {
			return this._defaultView;
		}
		if (this._disabledView != null) {
			if (!this._uiContext.enabled) {
				return this._disabledView;
			}
		}
		if (this._selectedView != null && (this._uiContext is IToggle)) {
			var toggle:IToggle = cast this._uiContext;
			if (toggle.selected) {
				return this._selectedView;
			}
		}
		return this._defaultView;
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._currentView != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._currentViewMeasurements, this._currentView, this);
		}

		var measureSkin:IMeasureObject = null;
		if ((this._currentView is IMeasureObject)) {
			measureSkin = cast this._currentView;
		}

		if ((this._currentView is IValidating)) {
			(cast this._currentView : IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = 0.0;
			if (this._currentView != null) {
				newWidth = Math.max(this._currentView.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this._currentView != null) {
				newHeight = Math.max(this._currentView.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = 0.0;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._currentViewMeasurements != null && this._currentViewMeasurements.minWidth != null) {
				newMinWidth = Math.max(this._currentViewMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = 0.0;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._currentViewMeasurements != null && this._currentViewMeasurements.minHeight != null) {
				newMinHeight = Math.max(this._currentViewMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._currentViewMeasurements != null && this._currentViewMeasurements.maxWidth != null) {
				newMaxWidth = this._currentViewMeasurements.maxWidth;
			} else {
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._currentViewMeasurements != null && this._currentViewMeasurements.maxHeight != null) {
				newMaxHeight = this._currentViewMeasurements.maxHeight;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function layoutView():Void {
		if (this._currentView == null) {
			return;
		}
		if (this._currentView.width != this.actualWidth) {
			this._currentView.width = this.actualWidth;
		}
		if (this._currentView.height != this.actualHeight) {
			this._currentView.height = this.actualHeight;
		}
	}

	override private function needsStateUpdate():Bool {
		var updated = false;
		if (this._previousView != this.getCurrentViewWithoutCache()) {
			this._previousView = null;
			updated = true;
		}
		return updated;
	}
}
