package com.feathersui.magic8ball;

import com.feathersui.magic8ball.theme.Magic8BallChatTheme;
import com.feathersui.magic8ball.vo.ChatMessage;
import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.TextInput;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayoutData;
import feathers.style.Theme;
import feathers.utils.DisplayObjectRecycler;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class Main extends Application {
	private static final MESSAGES = [
		"It is certain", "It is decidedly so", "Without a doubt", "Yes, definitely", "You may rely on it", "As I see it, yes", "Most likely", "Outlook good",
		"Yes", "Signs point to yes", "Reply hazy try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again",
		"Don't count on it", "My reply is no", "My sources say no", "Outlook not so good", "Very doubtful",
	];

	private static final OUTGOING_BALL_ITEM_RECYCLER_ID = "outgoing";

	public function new() {
		Theme.setTheme(new Magic8BallChatTheme());
		super();
	}

	private var _mainView:Panel;
	private var _footerView:LayoutGroup;
	private var _chatListView:ListView;
	private var _messageInput:TextInput;
	private var _sendButton:Button;

	override private function initialize():Void {
		super.initialize();

		layout = new AnchorLayout();

		_mainView = new Panel();
		_mainView.header = new Header("Magic 8 Ball");
		_mainView.layoutData = AnchorLayoutData.fill();
		_mainView.layout = new AnchorLayout();
		addChild(_mainView);

		_footerView = new LayoutGroup();
		_footerView.variant = LayoutGroup.VARIANT_TOOL_BAR;
		_messageInput = new TextInput();
		_messageInput.prompt = "Have a question?";
		_messageInput.layoutData = HorizontalLayoutData.fillHorizontal();
		_messageInput.addEventListener(KeyboardEvent.KEY_DOWN, messageInput_keyDownHandler);
		_footerView.addChild(_messageInput);
		_sendButton = new Button();
		_sendButton.text = "Ask";
		_sendButton.addEventListener(TriggerEvent.TRIGGER, sendButton_triggerHandler);
		_footerView.addChild(_sendButton);
		_mainView.footer = _footerView;

		_chatListView = new ListView();
		_chatListView.variant = ListView.VARIANT_BORDERLESS;
		_chatListView.dataProvider = new ArrayCollection();
		_chatListView.itemToText = (item:ChatMessage) -> {
			return item.text;
		}
		_chatListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.variant = Magic8BallChatTheme.THEME_VARIANT_INCOMING_CHAT_MESSAGE_ITEM_RENDERER;
			return itemRenderer;
		}, (itemRenderer, state:ListViewItemState) -> {
			var item = (state.data : ChatMessage);
			itemRenderer.secondaryText = item.author;
			itemRenderer.text = item.text;
		});
		_chatListView.setItemRendererRecycler(OUTGOING_BALL_ITEM_RECYCLER_ID, DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.variant = Magic8BallChatTheme.THEME_VARIANT_OUTGOING_CHAT_MESSAGE_ITEM_RENDERER;
			return itemRenderer;
		}, (itemRenderer, state:ListViewItemState) -> {
			var item = (state.data : ChatMessage);
			itemRenderer.secondaryText = item.author;
			itemRenderer.text = state.text;
		}));
		_chatListView.itemRendererRecyclerIDFunction = (state) -> {
			var item = (state.data : ChatMessage);
			if (item.outgoing) {
				return OUTGOING_BALL_ITEM_RECYCLER_ID;
			}
			return null;
		}
		_chatListView.selectable = false;
		_chatListView.layoutData = AnchorLayoutData.fill();
		_mainView.addChild(_chatListView);
	}

	private function sendMessage():Void {
		var message = _messageInput.text;
		if (message.length == 0) {
			_messageInput.errorString = "Please ask a question!";
			return;
		}
		_messageInput.text = "";
		_chatListView.dataProvider.add(new ChatMessage("Me", message, true));

		var index = Math.floor(Math.random() * MESSAGES.length);
		var response = MESSAGES[index];
		_chatListView.dataProvider.add(new ChatMessage("Magic 8 Ball", response, false));

		_chatListView.validateNow();
		_chatListView.scrollToIndex(_chatListView.dataProvider.length - 1);
	}

	private function messageInput_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ENTER) {
			sendMessage();
		}
	}

	private function sendButton_triggerHandler(event:TriggerEvent):Void {
		sendMessage();
	}
}
