package com.feathersui.todomvc;

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.TabBar;
import feathers.controls.TextInput;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalListLayout;
import feathers.skins.CircleSkin;
import feathers.skins.HorizontalLineSkin;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.text.TextFormat;
import feathers.themes.ClassVariantTheme;
import openfl.display.Shape;
import openfl.filters.DropShadowFilter;

class TodoTheme extends ClassVariantTheme {
	public function new() {
		super();

		styleProvider.setStyleFunction(TextInput, Main.CHILD_VARIANT_NEW_TODO_TEXT_INPUT, setNewTodoTextInputStyles);
		styleProvider.setStyleFunction(Label, null, setLabelStyles);
		styleProvider.setStyleFunction(Label, Main.CHILD_VARIANT_TITLE_LABEL, setTitleLabelStyles);
		styleProvider.setStyleFunction(ToggleButton, Main.CHILD_VARIANT_SELECT_ALL_TOGGLE, setSelectAllToggleButtonStyles);
		styleProvider.setStyleFunction(Button, null, setButtonStyles);
		styleProvider.setStyleFunction(Button, TodoItemRenderer.CHILD_VARIANT_DELETE_BUTTON, setTodoItemRendererDeleteButtonStyles);
		styleProvider.setStyleFunction(ListView, null, setListViewStyles);
		styleProvider.setStyleFunction(Check, null, setCheckStyles);
		styleProvider.setStyleFunction(ItemRenderer, null, setItemRendererStyles);
		styleProvider.setStyleFunction(LayoutGroup, Main.CHILD_VARIANT_BOTTOM_BAR, setBottomBarStyles);
		styleProvider.setStyleFunction(Label, Main.CHILD_VARIANT_FOOTER_TEXT, setFooterTextStyles);
		styleProvider.setStyleFunction(TabBar, null, setTabBarStyles);
		styleProvider.setStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB, setTabStyles);
		styleProvider.setStyleFunction(Panel, null, setPanelStyles);
	}

	private function getTitleFormat():TextFormat {
		return new TextFormat("_sans", 70, 0xaf2f2f, false, false, false, null, null, CENTER);
	}

	private function getTextFormat():TextFormat {
		return new TextFormat("_sans", 14, 0x777777);
	}

	private function getActiveLinkTextFormat():TextFormat {
		return new TextFormat("_sans", 14, 0x4d4d4d, false, false, true);
	}

	private function getLargeTextFormat():TextFormat {
		return new TextFormat("_sans", 24, 0x4d4d4d);
	}

	private function getLargeSelectedTextFormat():TextFormat {
		return new TextFormat("_sans", 24, 0xd9d9d9);
	}

	private function getLargePromptTextFormat():TextFormat {
		return new TextFormat("_sans", 24, 0xd9d9d9, false, true);
	}

	private function getFooterTextFormat():TextFormat {
		return new TextFormat("_sans", 10, 0xbfbfbf, false, false, false, null, null, CENTER, null, null, null, 10);
	}

	private function setTitleLabelStyles(label:Label):Void {
		label.textFormat = getTitleFormat();
		label.alpha = 0.2;
	}

	private function setButtonStyles(button:Button):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = None;
		button.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.border = SolidColor(1.0, 0xa7d3fc);
		focusRectSkin.fill = None;
		button.focusRectSkin = focusRectSkin;
		button.setFocusPadding(4.0);

		button.textFormat = getTextFormat();
		button.setTextFormatForState(HOVER, getActiveLinkTextFormat());
	}

	private function setLabelStyles(label:Label):Void {
		label.textFormat = getTextFormat();
	}

	private function setFooterTextStyles(label:Label):Void {
		label.textFormat = getFooterTextFormat();
	}

	private function setNewTodoTextInputStyles(textInput:TextInput):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = None;
		backgroundSkin.width = 100.0;
		backgroundSkin.height = 50.0;
		textInput.backgroundSkin = backgroundSkin;

		textInput.textFormat = getLargeTextFormat();
		textInput.promptTextFormat = getLargePromptTextFormat();

		textInput.leftViewGap = 10.0;
		textInput.setPadding(16.0);
	}

	private function setSelectAllToggleButtonStyles(button:ToggleButton):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = None;
		backgroundSkin.width = 30.0;
		backgroundSkin.height = 30.0;
		button.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.border = SolidColor(1.0, 0xa7d3fc);
		focusRectSkin.fill = None;
		button.focusRectSkin = focusRectSkin;
		button.setFocusPadding(4.0);

		var icon = new TriangleSkin();
		icon.border = SolidColor(4.0, 0xe6e6e6, null, null, null, NONE);
		icon.selectedBorder = SolidColor(4.0, 0x4d4d4d, null, null, null, NONE);
		icon.fill = SolidColor(0xffffff, 0.0);
		icon.pointPosition = BOTTOM;
		icon.drawBaseBorder = false;
		icon.width = 20.0;
		icon.height = 10.0;
		button.icon = icon;
	}

	private function setListViewStyles(listView:ListView):Void {
		var backgroundSkin = new HorizontalLineSkin();
		backgroundSkin.fill = SolidColor(0xffffff);
		backgroundSkin.border = SolidColor(1.0, 0xe6e6e6);
		backgroundSkin.verticalAlign = TOP;
		listView.backgroundSkin = backgroundSkin;

		listView.layout = new VerticalListLayout();
	}

	private function setItemRendererStyles(itemRenderer:ItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = None;
		itemRenderer.backgroundSkin = backgroundSkin;

		itemRenderer.textFormat = getLargeTextFormat();
		itemRenderer.selectedTextFormat = getLargeSelectedTextFormat();

		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.gap = 20.0;
		itemRenderer.paddingTop = 6.0;
		itemRenderer.paddingRight = 10.0;
		itemRenderer.paddingBottom = 6.0;
		itemRenderer.paddingLeft = 10.0;
	}

	private function setCheckStyles(check:Check):Void {
		var backgroundSkin = new CircleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = SolidColor(1.0, 0xededed);
		backgroundSkin.selectedBorder = SolidColor(1.0, 0xbddad5);
		backgroundSkin.width = 30.0;
		backgroundSkin.height = 30.0;
		check.backgroundSkin = backgroundSkin;

		var selectedIcon = new Shape();
		selectedIcon.graphics.lineStyle(2.0, 0x5dc2af);
		selectedIcon.graphics.moveTo(15.0, 1.0);
		selectedIcon.graphics.lineTo(6.0, 15.0);
		selectedIcon.graphics.lineTo(1.0, 10.0);
		selectedIcon.graphics.lineStyle();
		selectedIcon.graphics.beginFill(0xffffff, 0.0);
		selectedIcon.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
		check.selectedIcon = selectedIcon;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.border = SolidColor(1.0, 0xa7d3fc);
		focusRectSkin.fill = None;
		check.focusRectSkin = focusRectSkin;
		check.setFocusPadding(4.0);
	}

	private function setTodoItemRendererDeleteButtonStyles(button:Button):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = None;
		backgroundSkin.width = 30.0;
		backgroundSkin.height = 30.0;
		button.backgroundSkin = backgroundSkin;

		var icon = new Shape();
		icon.graphics.lineStyle(2.0, 0xcc9a9a);
		icon.graphics.moveTo(1.0, 1.0);
		icon.graphics.lineTo(15.0, 15.0);
		icon.graphics.moveTo(1.0, 15.0);
		icon.graphics.lineTo(15.0, 1.0);
		icon.graphics.lineStyle();
		icon.graphics.beginFill(0xffffff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
		icon.graphics.endFill();
		button.icon = icon;

		var hoverIcon = new Shape();
		hoverIcon.graphics.lineStyle(2.0, 0xaf5b5e);
		hoverIcon.graphics.moveTo(1.0, 1.0);
		hoverIcon.graphics.lineTo(15.0, 15.0);
		hoverIcon.graphics.moveTo(1.0, 15.0);
		hoverIcon.graphics.lineTo(15.0, 1.0);
		hoverIcon.graphics.lineStyle();
		hoverIcon.graphics.beginFill(0xffffff, 0.0);
		hoverIcon.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
		hoverIcon.graphics.endFill();
		button.setIconForState(HOVER, hoverIcon);
	}

	private function setTabBarStyles(tabBar:TabBar):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		tabBar.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.border = SolidColor(1.0, 0xa7d3fc);
		focusRectSkin.fill = None;
		tabBar.focusRectSkin = focusRectSkin;
		tabBar.setFocusPadding(4.0);

		var layout = new HorizontalLayout();
		layout.verticalAlign = MIDDLE;
		layout.gap = 10.0;
		tabBar.layout = layout;
	}

	private function setTabStyles(tab:ToggleButton):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = SolidColor(1.0, 0xffffff, 0.0);
		backgroundSkin.selectedBorder = SolidColor(1.0, 0xaf2f2f, 0.2);
		backgroundSkin.setBorderForState(ToggleButtonState.HOVER(false), SolidColor(1.0, 0xaf2f2f, 0.15));
		backgroundSkin.setBorderForState(ToggleButtonState.DOWN(false), SolidColor(1.0, 0xaf2f2f, 0.15));
		backgroundSkin.cornerRadius = 3.0;
		tab.backgroundSkin = backgroundSkin;

		tab.textFormat = getTextFormat();

		tab.paddingTop = 4.0;
		tab.paddingRight = 6.0;
		tab.paddingBottom = 4.0;
		tab.paddingLeft = 6.0;
	}

	private function setBottomBarStyles(bottomBar:LayoutGroup):Void {
		var backgroundSkin = new HorizontalLineSkin();
		backgroundSkin.fill = SolidColor(0xffffff, 0.0);
		backgroundSkin.border = SolidColor(1.0, 0xe6e6e6);
		backgroundSkin.verticalAlign = TOP;
		bottomBar.backgroundSkin = backgroundSkin;

		var layout = new HorizontalLayout();
		layout.verticalAlign = MIDDLE;
		layout.gap = Math.POSITIVE_INFINITY;
		layout.minGap = 10.0;
		layout.paddingTop = 10.0;
		layout.paddingRight = 16.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 16.0;
		bottomBar.layout = layout;
	}

	private function setPanelStyles(panel:Panel):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff);
		backgroundSkin.border = None;
		backgroundSkin.filters = [new DropShadowFilter(2, 90.0, 0x000000, 0.2)];
		panel.backgroundSkin = backgroundSkin;
	}
}
