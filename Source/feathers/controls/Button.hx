/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.InvalidationFlag;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
	A push button control that may be triggered when pressed and released.

	The following example creates a button, gives it a label and listens
	for when the button is triggered:

	```hx
	var button:Button = new Button();
	button.text = "Click Me";
	button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
	this.addChild( button );</listing>
	```

	@see [How to use the Feathers Button component](../../../help/button.html)

	@since 1.0.0
**/
class Button extends BasicButton {
	public function new() {
		super();
	}

	private var textField:TextField;

	public var text(default, set):String;

	private function set_text(value:String):String {
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.text;
	}

	public var fontStyles(default, set):TextFormat = new TextFormat("_sans");

	private function set_fontStyles(value:TextFormat):TextFormat {
		if (this.fontStyles == value) {
			return this.fontStyles;
		}
		this.fontStyles = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.fontStyles;
	}

	/**
		The minimum space, in pixels, between the button's top edge and the
		button's content.

		In the following example, the button's top padding is set to 20 pixels:

		```hx
		button.paddingTop = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	public var paddingTop(default, set):Float = 0;

	private function set_paddingTop(value:Float):Float {
		if (this.paddingTop == value) {
			return this.paddingTop;
		}
		this.paddingTop = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingTop;
	}

	/**
		The minimum space, in pixels, between the button's right edge and the
		button's content.

		In the following example, the button's right padding is set to 20
		pixels:

		```hx
		button.paddingRight = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	public var paddingRight(default, set):Float = 0;

	private function set_paddingRight(value:Float):Float {
		if (this.paddingRight == value) {
			return this.paddingRight;
		}
		this.paddingRight = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingRight;
	}

	/**
		The minimum space, in pixels, between the button's bottom edge and the
		button's content.

		In the following example, the button's bottom padding is set to 20
		pixels:

		```hx
		button.paddingBottom = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	public var paddingBottom(default, set):Float = 0;

	private function set_paddingBottom(value:Float):Float {
		if (this.paddingBottom == value) {
			return this.paddingBottom;
		}
		this.paddingBottom = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingBottom;
	}

	/**
		The minimum space, in pixels, between the button's left edge and the
		button's content.

		In the following example, the button's left padding is set to 20
		pixels:

		```hx
		button.paddingLeft = 20;</listing>
		```

		@default 0

		@since 1.0.0
	**/
	public var paddingLeft(default, set):Float = 0;

	private function set_paddingLeft(value:Float):Float {
		if (this.paddingLeft == value) {
			return this.paddingLeft;
		}
		this.paddingLeft = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.paddingLeft;
	}

	/**
		How the content is positioned horizontally (along the x-axis) within the
		button.

		The following example aligns the button's content to the left:

		```hx
		button.verticalAlign = HorizontalAlign.LEFT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@default `feathers.layout.HorizontalAlign.MIDDLE`

		@see `feathers.layout.HorizontalAlign.TOP`
		@see `feathers.layout.HorizontalAlign.MIDDLE`
		@see `feathers.layout.HorizontalAlign.BOTTOM`
	**/
	public var horizontalAlign(default, set):HorizontalAlign = HorizontalAlign.CENTER;

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this.horizontalAlign == value) {
			return this.horizontalAlign;
		}
		this.horizontalAlign = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.horizontalAlign;
	}

	/**
		How the content is positioned vertically (along the y-axis) within the
		button.

		The following example aligns the button's content to the top:

		```hx
		button.verticalAlign = VerticalAlign.TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@default `feathers.layout.VerticalAlign.MIDDLE`

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
	**/
	public var verticalAlign(default, set):VerticalAlign = VerticalAlign.MIDDLE;

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this.verticalAlign == value) {
			return this.verticalAlign;
		}
		this.verticalAlign = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.verticalAlign;
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.autoSize = TextFieldAutoSize.LEFT;
			this.textField.selectable = false;
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);

		if (dataInvalid) {
			this.refreshText();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		super.update();

		if (stylesInvalid || stateInvalid || dataInvalid || sizeInvalid) {
			this.layoutContent();
		}
	}

	private function refreshText() {
		this.textField.text = text;
		this.textField.visible = text != null && text.length > 0;
	}

	private function refreshTextStyles() {
		this.textField.defaultTextFormat = this.fontStyles;
		this.textField.setTextFormat(this.fontStyles);
	}

	private function layoutContent() {
		var maxWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (this.textField.width > maxWidth) {
			this.textField.width = maxWidth;
		}
		if (this.textField.height > maxHeight) {
			this.textField.height = maxHeight;
		}
		switch (this.horizontalAlign) {
			case LEFT:
				this.textField.x = this.paddingLeft;
			case RIGHT:
				this.textField.x = this.actualWidth - this.paddingRight - this.textField.width;
			default: // center
				this.textField.x = this.paddingLeft + (maxWidth - this.textField.width) / 2;
		}
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = this.paddingTop;
			case BOTTOM:
				this.textField.y = this.actualHeight - this.paddingBottom - this.textField.height;
			default: // center
				this.textField.y = this.paddingTop + (maxHeight - this.textField.height) / 2;
		}
	}
}
