/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.utils.ExclusivePointer;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end

/**
	Similar to a light switch, with on and off states that may be toggled.
	An alternative to a `Check`, especially on mobile.

	The following example creates a toggle switch, programmatically selects it,
	and listens for when the selection changes:

	```haxe
	var toggleSwitch = new ToggleSwitch();
	toggleSwitch.selected = true;
	toggleSwitch.addEventListener(Event.CHANGE, (event) -> {
		var toggleSwitch = cast(event.currentTarget, ToggleSwitch);
		trace("toggle switch changed: " + toggleSwitch.selected);
	});
	this.addChild(toggleSwitch);
	```

	@event openfl.events.Event.CHANGE Dispatched when `ToggleSwitch.selected`
	changes.

	@see [Tutorial: How to use the ToggleSwitch component](https://feathersui.com/learn/haxe-openfl/toggle-switch/)
	@see `feathers.controls.Check`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:styleContext
class ToggleSwitch extends FeathersControl implements IToggle implements IFocusObject {
	/**
		Creates a new `ToggleSwitch` object.

		@since 1.0.0
	**/
	public function new(selected:Bool = false, ?changeListener:(Event) -> Void) {
		initializeToggleSwitchTheme();

		super();

		this.selected = selected;

		// MouseEvent.CLICK is dispatched only if the same object is under the
		// pointer for both MouseEvent.MOUSE_DOWN and MouseEvent.MOUSE_UP. The
		// thumb/track might change skins between MouseEvent.MOUSE_DOWN and
		// MouseEvent.MOUSE_UP, and this would prevent MouseEvent.CLICK.
		// setting mouseChildren to false keeps the button as the target.
		this.mouseChildren = false;
		// when focused, keyboard space/enter trigger MouseEvent.CLICK
		this.buttonMode = true;
		// a hand cursor only makes sense for hyperlinks
		this.useHandCursor = false;

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;

		this.addEventListener(KeyboardEvent.KEY_DOWN, toggleSwitch_keyDownHandler);
		this.addEventListener(MouseEvent.MOUSE_DOWN, toggleSwitch_mouseDownHandler);
		this.addEventListener(MouseEvent.CLICK, toggleSwitch_clickHandler);
		this.addEventListener(TouchEvent.TOUCH_TAP, toggleSwitch_touchTapHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var onTextField:TextField;
	private var offTextField:TextField;

	private var _selected:Bool = false;

	/**
		Indicates if the toggle switch is selected or not.

		The following example selects the toggle switch:

		```haxe
		toggleSwitch.selected = true;
		```

		Note: When changing the `selected` property programatically, the
		position of the thumb is not animated. To change the selection with
		animation, call the `setSelectionWithAnimation()` method.

		@default false

		@see `ToggleSwitch.setSelectionWithAnimation()`

		@since 1.0.0
	**/
	@:bindable("change")
	@:inspectable(defaultValue = "false")
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return this._selected;
	}

	private function set_selected(value:Bool):Bool {
		this._animateSelectionChange = false;
		if (this._selected == value) {
			return this._selected;
		}
		this._selected = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		this.setInvalid(SELECTION);
		return this._selected;
	}

	private var _onText:String = null;

	/**
		The text displayed by the toggle switch when it is toggled on. If
		`null`, no text is displayed.

		The following example sets the label's on text:

		```haxe
		label.onText = "ON";
		```

		@default null

		@see `Label.offText`
		@see `Label.textFormat`

		@since 1.3.0
	**/
	public var onText(get, set):String;

	private function get_onText():String {
		return this._onText;
	}

	private function set_onText(value:String):String {
		if (this._onText == value) {
			return this._onText;
		}
		this._onText = value;
		this.setInvalid(DATA);
		return this._onText;
	}

	private var _offText:String = null;

	/**
		The text displayed by the toggle switch when it is toggled off. If
		`null`, no text is displayed.

		The following example sets the label's off text:

		```haxe
		label.offText = "OFF";
		```

		@default null

		@see `Label.onText`
		@see `Label.textFormat`

		@since 1.3.0
	**/
	public var offText(get, set):String;

	private function get_offText():String {
		return this._offText;
	}

	private function set_offText(value:String):String {
		if (this._offText == value) {
			return this._offText;
		}
		this._offText = value;
		this.setInvalid(DATA);
		return this._offText;
	}

	private var _previousOnText:String = null;
	private var _previousOffText:String = null;
	private var _previousOnTextFormat:TextFormat = null;
	private var _previousOnSimpleTextFormat:openfl.text.TextFormat = null;
	private var _previousOffTextFormat:TextFormat = null;
	private var _previousOffSimpleTextFormat:openfl.text.TextFormat = null;
	private var _updatedOnTextStyles = false;
	private var _updatedOffTextStyles = false;
	private var _onTextMeasuredWidth = 0.0;
	private var _onTextMeasuredHeight = 0.0;
	private var _offTextMeasuredWidth = 0.0;
	private var _offTextMeasuredHeight = 0.0;

	/**
		The font styles used to render the toggle switch's text.

		In the following example, the toggle switch's text formatting is
		customized:

		```haxe
		toggleSwitch.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `ToggleSwitch.onText`
		@see `ToggleSwitch.offText`
		@see `ToggleSwitch.disabledTextFormat`
		@see `ToggleSwitch.embedFonts`

		@since 1.3.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the toggle switch's text when the toggle
		switch is disabled.

		In the following example, the toggle switch's disabled text formatting
		is customized:

		```haxe
		toggleSwitch.enabled = false;
		toggleSwitch.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `ToggleSwitch.textFormat`

		@since 1.3.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the toggle switch uses embedded fonts:

		```haxe
		toggleSwitch.embedFonts = true;
		```

		@see `ToggleSwitch.textFormat`

		@since 1.3.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		Configures the `alpha` value of the toggle switch's text.

		In the following example, the toggle switch's text alpha is customized:

		```haxe
		toggleSwitch.textAlpha = 0.5;
		```

		@see `ToggleSwitch.textFormat`
		@see `ToggleSwitch.disabledTextAlpha`

		@since 1.4.0
	**/
	@:style
	@:inspectable(minValue = "0.0", maxValue = "1.0", verbose = "1")
	public var textAlpha:Float = 1.0;

	/**
		When `disabledTextAlpha` is not `null`, sets the `alpha` property of the
		text to this value when the the `enabled` property is set to `false`.

		In the following example, the toggle switch's disabled text alpha is customized:

		```haxe
		toggleSwitch.disabledTextAlpha = 0.5;
		```

		@see `ToggleSwitch.textAlpha`

		@since 1.4.0
	**/
	@:style
	@:inspectable(minValue = "0.0", maxValue = "1.0", verbose = "1")
	public var disabledTextAlpha:Null<Float> = null;

	/**
		Determines the type of anti-aliasing used for embedded fonts.

		In the following example, the toggle switch uses advanced anti-aliasing:

		```haxe
		toggleSwitch.embedFonts = true;
		toggleSwitch.antiAliasType = ADVANCED;
		```

		@see `ToggleSwitch.embedFonts`
		@see `ToggleSwitch.gridFitType`

		@since 1.4.0
	**/
	@:style
	public var antiAliasType:AntiAliasType = NORMAL;

	/**
		Determines the type of anti-aliasing used for embedded fonts.

		In the following example, the toggle switch uses sub-pixel grid fitting:

		```haxe
		toggleSwitch.embedFonts = true;
		toggleSwitch.antiAliasType = ADVANCED;
		toggleSwitch.gridFitType = SUBPIXEL;
		```

		@see `ToggleSwitch.antiAliasType`
		@see `ToggleSwitch.embedFonts`

		@since 1.4.0
	**/
	@:style
	public var gridFitType:GridFitType = PIXEL;

	private var _currentThumbSkin:DisplayObject = null;
	private var _thumbSkinMeasurements:Measurements = null;

	/**
		The skin to use for the toggle switch's thumb.

		In the following example, a thumb skin is passed to the toggle switch:

		```haxe
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		toggleSwitch.thumbSkin = skin;
		```

		@see `ToggleSwitch.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var thumbSkin:DisplayObject = null;

	private var _currentTrackSkin:DisplayObject = null;
	private var _trackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the toggle switch's track.

		In the following example, a track skin is passed to the toggle switch:

		```haxe
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		toggleSwitch.trackSkin = skin;
		```

		@see `ToggleSwitch.secondaryTrackSkin`
		@see `ToggleSwitch.thumbSkin`

		@since 1.0.0
	**/
	@:style
	public var trackSkin:DisplayObject = null;

	private var _currentSecondaryTrackSkin:DisplayObject = null;
	private var _secondaryTrackSkinMeasurements:Measurements = null;

	/**
		The skin to use for the toggle switch's optional secondary track. If a
		toggle switch has one track, it will fill the entire length of the
		toggle switch. If a toggle switch has a track and a secondary track, the
		primary track will stretch between the left edge of the toggle switch
		and the location of the slider's thumb, while the secondary track will
		stretch from the location of the toggle switch's thumb to the right edge
		of the toggle switch.

		In the following example, a track skin and a secondary track skin are
		passed to the toggle switch:

		```haxe
		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xaaaaaa);
		toggleSwitch.trackSkin = skin;

		var skin = new RectangleSkin();
		skin.fill = SolidColor(0xcccccc);
		toggleSwitch.secondaryTrackSkin = skin;
		```

		@see `ToggleSwitch.trackSkin`

		@since 1.0.0
	**/
	@:style
	public var secondaryTrackSkin:DisplayObject = null;

	/**
		The minimum space, measured in pixels, between the toggle switch's right
		edge and the right edge of the thumb.

		In the following example, the toggle switch's right padding is set to 20
		pixels:

		```haxe
		toggleSwitch.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, measured in pixels, between the toggle switch's left
		edge and the left edge of the thumb.

		In the following example, the toggle switch's left padding is set to 20
		pixels:

		```haxe
		toggleSwitch.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	private var _toggleTween:SimpleActuator<Dynamic, Dynamic> = null;

	/**
		The duration, measured in seconds, of the animation when the toggle
		switch is clicked or tap and the thumb slides to the other side.

		In the following example, the duration of the animation that toggles the
		thumb is set to 500 milliseconds:

		```haxe
		toggleSwitch.toggleDuration = 0.5;
		```

		@since 1.0.0
	**/
	@:style
	public var toggleDuration:Float = 0.25;

	/**
		The easing function used for the animation when the toggle switch is
		clicked or tap and the thumb slides to the other side.

		In the following example, the ease of the animation that toggles the
		thumb is customized:

		```haxe
		toggleSwitch.toggleEase = Elastic.easeOut;
		```

		@since 1.0.0
	**/
	@:style
	public var toggleEase:IEasing = Quart.easeOut;

	private var _dragStartX:Float;
	private var _ignoreClick:Bool = false;

	private var _animateSelectionChange:Bool = false;

	/**
		Changes the `selected` property and animates the position of the thumb.

		@see `ToggleSwitch.selected`

		@since 1.0.0
	**/
	public function setSelectionWithAnimation(selected:Bool):Bool {
		if (this._selected == selected) {
			return this._selected;
		}
		this.selected = selected;
		this._animateSelectionChange = true;
		return this._selected;
	}

	/**
		Sets all padding properties to the same value.

		@see `ToggleSwitch.paddingRight`
		@see `ToggleSwitch.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingRight = value;
		this.paddingLeft = value;
	}

	private function initializeToggleSwitchTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelToggleSwitchStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		this._updatedOnTextStyles = false;
		this._updatedOffTextStyles = false;

		if (stylesInvalid) {
			this.refreshThumb();
			this.refreshTrack();
			this.refreshSecondaryTrack();
		}

		if (dataInvalid) {
			this.refreshTextFields();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid || sizeInvalid) {
			this.refreshOnText(sizeInvalid);
			this.refreshOffText(sizeInvalid);
		}

		if (selectionInvalid || stylesInvalid) {
			this.refreshSelection();
		}

		if (stateInvalid || stylesInvalid) {
			this.refreshEnabled();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		this.layoutContent();
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

		if (this._currentThumbSkin != null) {
			this._thumbSkinMeasurements.restore(this._currentThumbSkin);
			if ((this._currentThumbSkin is IValidating)) {
				(cast this._currentThumbSkin : IValidating).validateNow();
			}
		}
		if (this._currentTrackSkin != null) {
			this._trackSkinMeasurements.restore(this._currentTrackSkin);
			if ((this._currentTrackSkin is IValidating)) {
				(cast this._currentTrackSkin : IValidating).validateNow();
			}
		}
		if (this._currentSecondaryTrackSkin != null) {
			this._secondaryTrackSkinMeasurements.restore(this._currentSecondaryTrackSkin);
			if ((this._currentSecondaryTrackSkin is IValidating)) {
				(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = 0.0;
			if (this._currentTrackSkin != null) {
				newWidth += this._currentTrackSkin.width;
				if (this._currentSecondaryTrackSkin != null) {
					newWidth += this._currentSecondaryTrackSkin.width;
				}
			}
			if (this.onTextField != null) {
				var onTextAndThumbWidth = this._onTextMeasuredWidth;
				if (this._currentThumbSkin != null) {
					onTextAndThumbWidth += this._currentThumbSkin.width;
				}
				if (newWidth < onTextAndThumbWidth) {
					newWidth = onTextAndThumbWidth;
				}
			}
			if (this.offTextField != null) {
				var offTextAndThumbWidth = this._offTextMeasuredWidth;
				if (this._currentThumbSkin != null) {
					offTextAndThumbWidth += this._currentThumbSkin.width;
				}
				if (newWidth < offTextAndThumbWidth) {
					newWidth = offTextAndThumbWidth;
				}
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this._currentThumbSkin != null) {
				newHeight += this._currentThumbSkin.height;
			}
			if (this._currentTrackSkin != null) {
				if (newHeight < this._currentTrackSkin.height) {
					newHeight = this._currentTrackSkin.height;
				}
				if (this._currentSecondaryTrackSkin != null && newHeight < this._currentSecondaryTrackSkin.height) {
					newHeight = this._currentSecondaryTrackSkin.height;
				}
			}
			if (this.onTextField != null && newHeight < this._onTextMeasuredHeight) {
				newHeight = this._onTextMeasuredHeight;
			}
			if (this.offTextField != null && newHeight < this._offTextMeasuredHeight) {
				newHeight = this._offTextMeasuredHeight;
			}
		}

		// TODO: calculate min and max
		var newMinWidth = newWidth;
		var newMinHeight = newHeight;
		var newMaxWidth = newWidth;
		var newMaxHeight = newHeight;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshTextFields():Void {
		if (this._onText == null) {
			if (this.onTextField != null) {
				this.removeChild(this.onTextField);
				this.onTextField = null;
			}
			this._previousOnText = null;
			this._previousOnTextFormat = null;
			this._previousOnSimpleTextFormat = null;
		} else if (this.onTextField == null) {
			var index = 0;
			if (this._currentSecondaryTrackSkin != null) {
				index = 2;
			} else if (this._currentTrackSkin != null) {
				index = 1;
			}
			this.onTextField = new TextField();
			this.addChildAt(this.onTextField, index);
		}
		if (this._offText == null) {
			if (this.offTextField != null) {
				this.removeChild(this.offTextField);
				this.offTextField = null;
			}
			this._previousOffText = null;
			this._previousOffTextFormat = null;
			this._previousOffSimpleTextFormat = null;
		} else if (this.offTextField == null) {
			var index = 0;
			if (this._currentSecondaryTrackSkin != null) {
				index = 2;
			} else if (this._currentTrackSkin != null) {
				index = 1;
			}
			this.offTextField = new TextField();
			this.addChildAt(this.offTextField, index);
		}
	}

	private function refreshTextStyles():Void {
		var textFormat = this.getCurrentTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (this.offTextField != null) {
			if (this.offTextField.embedFonts != this.embedFonts) {
				this.offTextField.embedFonts = this.embedFonts;
				this._updatedOffTextStyles = true;
			}
			if (this.offTextField.antiAliasType != this.antiAliasType) {
				this.offTextField.antiAliasType = this.antiAliasType;
				this._updatedOffTextStyles = true;
			}
			if (this.offTextField.gridFitType != this.gridFitType) {
				this.offTextField.gridFitType = this.gridFitType;
				this._updatedOffTextStyles = true;
			}
			this.offTextField.alpha = this.getCurrentTextAlpha();
			if (simpleTextFormat != this._previousOffSimpleTextFormat) {
				if (this._previousOffTextFormat != null) {
					this._previousOffTextFormat.removeEventListener(Event.CHANGE, toggleSwitch_offTextFormat_changeHandler);
				}
				// clear the selection before setting defaultTextFormat because any
				// selection seems to prevent the defaultTextFormat from fully applying
				if (this.offTextField.caretIndex != -1 && this.offTextField.selectionBeginIndex != this.offTextField.selectionEndIndex) {
					// check for caretIndex != -1 first due to a bug in OpenFL
					this.offTextField.setSelection(0, 0);
				}
				if (textFormat != null) {
					textFormat.addEventListener(Event.CHANGE, toggleSwitch_offTextFormat_changeHandler, false, 0, true);
					this.offTextField.defaultTextFormat = simpleTextFormat;
					this._updatedOffTextStyles = true;
				}
				this._previousOffTextFormat = textFormat;
				this._previousOffSimpleTextFormat = simpleTextFormat;
			}
		}
		if (this.onTextField != null) {
			if (this.onTextField.embedFonts != this.embedFonts) {
				this.onTextField.embedFonts = this.embedFonts;
				this._updatedOnTextStyles = true;
			}
			if (this.onTextField.antiAliasType != this.antiAliasType) {
				this.onTextField.antiAliasType = this.antiAliasType;
				this._updatedOnTextStyles = true;
			}
			if (this.onTextField.gridFitType != this.gridFitType) {
				this.onTextField.gridFitType = this.gridFitType;
				this._updatedOnTextStyles = true;
			}
			this.onTextField.alpha = this.getCurrentTextAlpha();
			if (simpleTextFormat != this._previousOnSimpleTextFormat) {
				if (this._previousOnTextFormat != null) {
					this._previousOnTextFormat.removeEventListener(Event.CHANGE, toggleSwitch_onTextFormat_changeHandler);
				}
				// clear the selection before setting defaultTextFormat because any
				// selection seems to prevent the defaultTextFormat from fully applying
				if (this.onTextField.caretIndex != -1 && this.onTextField.selectionBeginIndex != this.onTextField.selectionEndIndex) {
					// check for caretIndex != -1 first due to a bug in OpenFL
					this.onTextField.setSelection(0, 0);
				}
				if (textFormat != null) {
					textFormat.addEventListener(Event.CHANGE, toggleSwitch_onTextFormat_changeHandler, false, 0, true);
					this.onTextField.defaultTextFormat = simpleTextFormat;
					this._updatedOnTextStyles = true;
				}
				this._previousOnTextFormat = textFormat;
				this._previousOnSimpleTextFormat = simpleTextFormat;
			}
		}
	}

	private function refreshOnText(forceMeasurement:Bool):Void {
		if (this.onTextField == null) {
			return;
		}
		// usually, hasText doesn't check the length, but TextField height may
		// not be accurate with an empty string
		var hasText = this._onText != null && this._onText.length > 0;
		if (this._onText == this._previousOnText && !this._updatedOnTextStyles && !forceMeasurement) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.onTextField.autoSize = LEFT;
		if (hasText) {
			this.onTextField.text = this._onText;
		} else {
			// zero-width space results in a more accurate height measurement
			// than we'd get with an empty string
			this.onTextField.text = "\u200b";
		}
		this._onTextMeasuredWidth = this.onTextField.textWidth + 4;
		this._onTextMeasuredHeight = this.onTextField.height;
		this.onTextField.autoSize = NONE;
		if (!hasText) {
			this.onTextField.text = "";
		}
		this._previousOnText = this._onText;
	}

	private function refreshOffText(forceMeasurement:Bool):Void {
		if (this.offTextField == null) {
			return;
		}
		// usually, hasText doesn't check the length, but TextField height may
		// not be accurate with an empty string
		var hasText = this._offText != null && this._offText.length > 0;
		if (this._offText == this._previousOffText && !this._updatedOffTextStyles && !forceMeasurement) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.offTextField.autoSize = LEFT;
		if (hasText) {
			this.offTextField.text = this._offText;
		} else {
			// zero-width space results in a more accurate height measurement
			// than we'd get with an empty string
			this.offTextField.text = "\u200b";
		}
		this._offTextMeasuredWidth = this.offTextField.textWidth + 4;
		this._offTextMeasuredHeight = this.offTextField.height;
		this.offTextField.autoSize = NONE;
		if (!hasText) {
			this.offTextField.text = "";
		}
		this._previousOffText = this._offText;
	}

	private function getCurrentTextFormat():TextFormat {
		if (!this._enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		return this.textFormat;
	}

	private function getCurrentTextAlpha():Float {
		if (!this._enabled && this.disabledTextAlpha != null) {
			return this.disabledTextAlpha;
		}
		return this.textAlpha;
	}

	private function refreshThumb():Void {
		var oldSkin = this._currentThumbSkin;
		this._currentThumbSkin = this.thumbSkin;
		if (this._currentThumbSkin == oldSkin) {
			return;
		}
		if (oldSkin != null && oldSkin.parent == this) {
			if ((oldSkin is IProgrammaticSkin)) {
				(cast oldSkin : IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
		}
		if (this._currentThumbSkin != null) {
			if ((this._currentThumbSkin is IUIControl)) {
				(cast this._currentThumbSkin : IUIControl).initializeNow();
			}
			if (this._thumbSkinMeasurements == null) {
				this._thumbSkinMeasurements = new Measurements(this._currentThumbSkin);
			} else {
				this._thumbSkinMeasurements.save(this._currentThumbSkin);
			}
			if ((this._currentThumbSkin is IProgrammaticSkin)) {
				(cast this._currentThumbSkin : IProgrammaticSkin).uiContext = this;
			}
			// add it above the trackSkin and secondaryTrackSkin
			this.addChild(this._currentThumbSkin);
		} else {
			this._thumbSkinMeasurements = null;
		}
	}

	private function refreshTrack():Void {
		var oldSkin = this._currentTrackSkin;
		this._currentTrackSkin = this.trackSkin;
		if (this._currentTrackSkin == oldSkin) {
			return;
		}
		if (oldSkin != null && oldSkin.parent == this) {
			if ((oldSkin is IProgrammaticSkin)) {
				(cast oldSkin : IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
		}
		if (this._currentTrackSkin != null) {
			if ((this._currentTrackSkin is IUIControl)) {
				(cast this._currentTrackSkin : IUIControl).initializeNow();
			}
			if (this._trackSkinMeasurements == null) {
				this._trackSkinMeasurements = new Measurements(this._currentTrackSkin);
			} else {
				this._trackSkinMeasurements.save(this._currentTrackSkin);
			}
			if ((this._currentTrackSkin is IProgrammaticSkin)) {
				(cast this._currentTrackSkin : IProgrammaticSkin).uiContext = this;
			}
			// always on the bottom
			this.addChildAt(this._currentTrackSkin, 0);
		} else {
			this._trackSkinMeasurements = null;
		}
	}

	private function refreshSecondaryTrack():Void {
		var oldSkin = this._currentSecondaryTrackSkin;
		this._currentSecondaryTrackSkin = this.secondaryTrackSkin;
		if (this._currentSecondaryTrackSkin == oldSkin) {
			return;
		}
		if (oldSkin != null && oldSkin.parent == this) {
			if ((oldSkin is IProgrammaticSkin)) {
				(cast oldSkin : IProgrammaticSkin).uiContext = null;
			}
			this.removeChild(oldSkin);
		}
		if (this._currentSecondaryTrackSkin != null) {
			if ((this._currentSecondaryTrackSkin is IUIControl)) {
				(cast this._currentSecondaryTrackSkin : IUIControl).initializeNow();
			}
			if (this._secondaryTrackSkinMeasurements == null) {
				this._secondaryTrackSkinMeasurements = new Measurements(this._currentSecondaryTrackSkin);
			} else {
				this._secondaryTrackSkinMeasurements.save(this._currentSecondaryTrackSkin);
			}
			if ((this._currentSecondaryTrackSkin is IProgrammaticSkin)) {
				(cast this._currentSecondaryTrackSkin : IProgrammaticSkin).uiContext = this;
			}

			// on the bottom or above the trackSkin
			var index = this._currentTrackSkin != null ? 1 : 0;
			this.addChildAt(this._currentSecondaryTrackSkin, index);
		} else {
			this._secondaryTrackSkinMeasurements = null;
		}
	}

	private function refreshSelection():Void {
		if ((this._currentThumbSkin is IToggle)) {
			(cast this._currentThumbSkin : IToggle).selected = this._selected;
		}
		if ((this._currentTrackSkin is IToggle)) {
			(cast this._currentTrackSkin : IToggle).selected = this._selected;
		}
		if ((this._currentSecondaryTrackSkin is IToggle)) {
			(cast this._currentSecondaryTrackSkin : IToggle).selected = this._selected;
		}

		// stop the tween, no matter what
		if (this._toggleTween != null) {
			Actuate.stop(this._toggleTween, null, false, false);
			this._toggleTween = null;
		}
	}

	private function refreshEnabled():Void {
		if ((this._currentThumbSkin is IUIControl)) {
			(cast this._currentThumbSkin : IUIControl).enabled = this._enabled;
		}
		if ((this._currentTrackSkin is IUIControl)) {
			(cast this._currentTrackSkin : IUIControl).enabled = this._enabled;
		}
		if ((this._currentSecondaryTrackSkin is IUIControl)) {
			(cast this._currentSecondaryTrackSkin : IUIControl).enabled = this._enabled;
		}
	}

	private function layoutContent():Void {
		this.layoutThumb();
		if (this._currentTrackSkin != null && this._currentSecondaryTrackSkin != null) {
			this.layoutSplitTrack();
		} else {
			this.layoutSingleTrack();
		}
		this.layoutText();
	}

	private function layoutText():Void {
		if (this.onTextField != null) {
			var availableWidth = this.actualWidth - this._currentThumbSkin.width - this.paddingLeft - this.paddingRight;
			var onWidth = this._onTextMeasuredWidth;
			if (onWidth > availableWidth) {
				onWidth = availableWidth;
			}
			this.onTextField.width = onWidth;
			this.onTextField.x = this.paddingLeft + (availableWidth - onWidth) / 2.0;
			var onY = (this.actualHeight - this._onTextMeasuredHeight) / 2.0;
			if (onY < 0.0) {
				onY = 0.0;
			}
			this.onTextField.y = onY;
			// TODO: not ideal. should probably use scrollRect instead.
			this.onTextField.visible = this._currentThumbSkin.x >= this.onTextField.x;
		}
		if (this.offTextField != null) {
			var availableWidth = this.actualWidth - this._currentThumbSkin.width - this.paddingLeft - this.paddingRight;
			var offWidth = this._offTextMeasuredWidth;
			if (offWidth > availableWidth) {
				offWidth = availableWidth;
			}
			this.offTextField.width = offWidth;
			this.offTextField.x = this.actualWidth - this.paddingRight - availableWidth + (availableWidth - offWidth) / 2.0;
			var offY = (this.actualHeight - this._offTextMeasuredHeight) / 2.0;
			if (offY < 0.0) {
				offY = 0.0;
			}
			this.offTextField.y = offY;
			// TODO: not ideal. should probably use scrollRect instead.
			this.offTextField.visible = (this._currentThumbSkin.x + this._currentThumbSkin.width) <= (this.offTextField.x + offWidth);
		}
	}

	private function layoutThumb():Void {
		if (this._currentThumbSkin == null) {
			return;
		}
		if ((this._currentThumbSkin is IValidating)) {
			(cast this._currentThumbSkin : IValidating).validateNow();
		}

		var xPosition = this.paddingLeft;
		if (this._selected) {
			xPosition = this.actualWidth - this._currentThumbSkin.width - this.paddingRight;
		}

		if (this._animateSelectionChange) {
			var tween = Actuate.update((x:Float) -> {
				this._currentThumbSkin.x = x;
			}, this.toggleDuration, [this._currentThumbSkin.x], [xPosition], true);
			this._toggleTween = cast tween;
			this._toggleTween.ease(this.toggleEase);
			this._toggleTween.onUpdate(this.toggleTween_onUpdate);
			this._toggleTween.onComplete(this.toggleTween_onComplete);
		} else if (this._toggleTween == null) {
			this._currentThumbSkin.x = xPosition;
		}
		this._currentThumbSkin.y = (this.actualHeight - this._currentThumbSkin.height) / 2.0;

		this._animateSelectionChange = false;
	}

	private function layoutSplitTrack():Void {
		if (this._currentTrackSkin == null || this._currentSecondaryTrackSkin == null) {
			return;
		}
		var location = this._currentThumbSkin.x + this._currentThumbSkin.width / 2.0;

		this._currentTrackSkin.x = 0.0;
		this._currentTrackSkin.width = location;

		this._currentSecondaryTrackSkin.x = location;
		this._currentSecondaryTrackSkin.width = this.actualWidth - location;

		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}
		if ((this._currentSecondaryTrackSkin is IValidating)) {
			(cast this._currentSecondaryTrackSkin : IValidating).validateNow();
		}

		this._currentTrackSkin.y = (this.actualHeight - this._currentTrackSkin.height) / 2.0;
		this._currentSecondaryTrackSkin.y = (this.actualHeight - this._currentSecondaryTrackSkin.height) / 2.0;
	}

	private function layoutSingleTrack():Void {
		if (this._currentTrackSkin == null) {
			return;
		}
		this._currentTrackSkin.x = 0.0;
		this._currentTrackSkin.width = this.actualWidth;

		if ((this._currentTrackSkin is IValidating)) {
			(cast this._currentTrackSkin : IValidating).validateNow();
		}

		this._currentTrackSkin.y = (this.actualHeight - this._currentTrackSkin.height) / 2.0;
	}

	private function toggleSwitch_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || (this.buttonMode && this.focusRect == true)) {
			return;
		}
		if (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER) {
			return;
		}
		// ensure that other components cannot use this key event
		event.preventDefault();
		this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	}

	private function toggleSwitch_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || this.stage == null) {
			return;
		}
		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}
		this._dragStartX = this.mouseX;
		this._ignoreClick = false;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, toggleSwitch_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, toggleSwitch_stage_mouseUpHandler, false, 0, true);
	}

	private function toggleSwitch_clickHandler(event:MouseEvent):Void {
		if (!this._enabled || this._ignoreClick) {
			return;
		}
		this.setSelectionWithAnimation(!this._selected);
	}

	private function toggleSwitch_touchTapHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		if (!this._enabled || this._ignoreClick) {
			return;
		}
		this.setSelectionWithAnimation(!this._selected);
	}

	private function toggleSwitch_stage_mouseMoveHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var halfDistance = (this.actualWidth - this.paddingLeft - this.paddingRight) / 2.0;
		var dragOffset = this.mouseX - this._dragStartX;
		var selected = this._selected;
		if (dragOffset >= halfDistance) {
			selected = true;
		} else if (dragOffset <= -halfDistance) {
			selected = false;
		}
		if (this._selected != selected) {
			this._ignoreClick = true;
			this._dragStartX = this.mouseX;
			this.setSelectionWithAnimation(selected);
		}
	}

	private function toggleSwitch_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, toggleSwitch_stage_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, toggleSwitch_stage_mouseUpHandler);
	}

	private function toggleTween_onUpdate():Void {
		this.layoutContent();
	}

	private function toggleTween_onComplete():Void {
		this._toggleTween = null;
	}

	private function toggleSwitch_onTextFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function toggleSwitch_offTextFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}
}
