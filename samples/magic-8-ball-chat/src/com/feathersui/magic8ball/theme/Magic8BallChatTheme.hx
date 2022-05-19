package com.feathersui.magic8ball.theme;

import feathers.controls.dataRenderers.ItemRenderer;
import feathers.themes.ClassVariantTheme;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Magic8BallChatTheme extends ClassVariantTheme {
	public static final THEME_VARIANT_OUTGOING_CHAT_MESSAGE_ITEM_RENDERER = "magic8ball_outgoingChatMessageItemRenderer";
	public static final THEME_VARIANT_INCOMING_CHAT_MESSAGE_ITEM_RENDERER = "magic8ball_incomingChatMessageItemRenderer";

	public function new() {
		super();

		styleProvider.setStyleFunction(ItemRenderer, THEME_VARIANT_OUTGOING_CHAT_MESSAGE_ITEM_RENDERER, setOutgoingChatMessageItemRendererStyles);
		styleProvider.setStyleFunction(ItemRenderer, THEME_VARIANT_INCOMING_CHAT_MESSAGE_ITEM_RENDERER, setIncomingChatMessageItemRendererStyles);
	}

	private function createChatIcon(color:UInt, text:String):DisplayObject {
		var icon = new Sprite();
		icon.graphics.beginFill(color);
		icon.graphics.drawCircle(20.0, 20.0, 20.0);
		icon.graphics.endFill();

		var textField = new TextField();
		textField.selectable = false;
		textField.autoSize = LEFT;
		textField.defaultTextFormat = new TextFormat("_sans", 30, 0xffffff, true);
		textField.text = text;
		textField.x = (icon.width - textField.width) / 2.0;
		textField.y = (icon.height - textField.height) / 2.0;
		icon.addChild(textField);

		return icon;
	}

	private function setOutgoingChatMessageItemRendererStyles(itemRenderer:ItemRenderer):Void {
		itemRenderer.icon = createChatIcon(0x2424ff, "?");
		itemRenderer.iconPosition = RIGHT;
		itemRenderer.horizontalAlign = RIGHT;
		itemRenderer.wordWrap = true;
		itemRenderer.gap = 6.0;
		itemRenderer.setPadding(6.0);
		itemRenderer.textFormat = new TextFormat("_sans", 14, 0x1f1f1f);
		itemRenderer.secondaryTextFormat = new TextFormat("_sans", 12, 0x1f1f1f);
	}

	private function setIncomingChatMessageItemRendererStyles(itemRenderer:ItemRenderer):Void {
		itemRenderer.icon = createChatIcon(0xff2424, "8");
		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.wordWrap = true;
		itemRenderer.gap = 4.0;
		itemRenderer.setPadding(6.0);
		itemRenderer.textFormat = new TextFormat("_sans", 14, 0x1f1f1f);
		itemRenderer.secondaryTextFormat = new TextFormat("_sans", 12, 0x1f1f1f);
	}
}
