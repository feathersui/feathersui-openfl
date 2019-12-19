package;

import openfl.events.Event;
import feathers.controls.navigators.StackAction;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.motion.transitions.SlideTransitions;
import feathers.controls.Application;
import com.feathersui.components.ScreenID;
import com.feathersui.components.screens.MainMenu;
import com.feathersui.components.screens.AssetLoaderScreen;
import com.feathersui.components.screens.ButtonScreen;
import com.feathersui.components.screens.CalloutScreen;
import com.feathersui.components.screens.CheckScreen;
import com.feathersui.components.screens.ComboBoxScreen;
import com.feathersui.components.screens.LabelScreen;
import com.feathersui.components.screens.ListViewScreen;
import com.feathersui.components.screens.PanelScreen;
import com.feathersui.components.screens.PopUpListScreen;
import com.feathersui.components.screens.PopUpManagerScreen;
import com.feathersui.components.screens.ProgressBarScreen;
import com.feathersui.components.screens.RadioScreen;
import com.feathersui.components.screens.SliderScreen;
import com.feathersui.components.screens.TabBarScreen;
import com.feathersui.components.screens.TextInputScreen;
import com.feathersui.components.screens.ToggleSwitchScreen;

class Main extends Application {
	public function new() {
		super();
	}

	override private function initialize():Void {
		var navigator = new StackNavigator();
		navigator.pushTransition = SlideTransitions.left();
		navigator.popTransition = SlideTransitions.right();
		this.addChild(navigator);

		var mainMenu = StackItem.withClass(MainMenu, [Event.CHANGE => NewAction(createPushAction)]);
		navigator.addItem(ScreenID.MAIN_MENU, mainMenu);

		var assetLoader = StackItem.withClass(AssetLoaderScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.ASSET_LOADER, assetLoader);

		var button = StackItem.withClass(ButtonScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.BUTTON, button);

		var callout = StackItem.withClass(CalloutScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.CALLOUT, callout);

		var check = StackItem.withClass(CheckScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.CHECK, check);

		var comboBox = StackItem.withClass(ComboBoxScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.COMBO_BOX, comboBox);

		var label = StackItem.withClass(LabelScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.LABEL, label);

		var listView = StackItem.withClass(ListViewScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.LIST_VIEW, listView);

		var panel = StackItem.withClass(PanelScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.PANEL, panel);

		var popUpList = StackItem.withClass(PopUpListScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.POP_UP_LIST, popUpList);

		var popUpManager = StackItem.withClass(PopUpManagerScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.POP_UP_MANAGER, popUpManager);

		var progressBar = StackItem.withClass(ProgressBarScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.PROGRESS_BAR, progressBar);

		var radio = StackItem.withClass(RadioScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.RADIO, radio);

		var slider = StackItem.withClass(SliderScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.SLIDER, slider);

		var tabBar = StackItem.withClass(TabBarScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.TAB_BAR, tabBar);

		var textInput = StackItem.withClass(TextInputScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.TEXT_INPUT, textInput);

		var toggleSwitch = StackItem.withClass(ToggleSwitchScreen, [Event.COMPLETE => Pop()]);
		navigator.addItem(ScreenID.TOGGLE_SWITCH, toggleSwitch);

		navigator.rootItemID = ScreenID.MAIN_MENU;
	}

	private function createPushAction(event:Event):StackAction {
		var screen = cast(event.currentTarget, MainMenu);
		return Push(screen.selectedScreenID);
	}
}
