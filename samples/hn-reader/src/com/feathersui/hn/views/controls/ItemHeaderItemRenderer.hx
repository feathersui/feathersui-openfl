package com.feathersui.hn.views.controls;

import com.feathersui.hn.vo.Item;
import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.VerticalLayout;
import feathers.skins.UnderlineSkin;

class ItemHeaderItemRenderer extends LayoutGroupItemRenderer {
	public function new() {
		super();
		themeEnabled = false;
	}

	private var _title:Label;
	private var _meta:Label;
	private var _description:Label;
	#if !html5
	private var _homeLink:Label;
	#end

	override private function initialize():Void {
		super.initialize();

		backgroundSkin = new UnderlineSkin(None, SolidColor(1.0, 0xCCCCCC));

		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.gap = 8.0;
		viewLayout.setPadding(8.0);
		layout = viewLayout;

		#if !html5
		_homeLink = new Label();
		_homeLink.htmlText = '<u><a href="event:router:/">Return Home</a></u>';
		addChild(_homeLink);
		#end

		_title = new Label();
		_title.variant = Label.VARIANT_HEADING;
		_title.wordWrap = true;
		addChild(_title);

		_meta = new Label();
		_meta.variant = Label.VARIANT_DETAIL;
		_meta.wordWrap = true;
		addChild(_meta);

		_description = new Label();
		_description.wordWrap = true;
		_description.selectable = true;
		addChild(_description);
	}

	override private function update():Void {
		var item = (data : Item);
		if (item != null) {
			_title.htmlText = '<a href="${item.url}">${item.title}</a>';

			var metaText = "";
			if (item.points != null) {
				metaText += '${item.points} points';
			}
			if (item.user != null) {
				if (metaText.length > 0) {
					metaText += " ";
				}
				metaText += 'by <u><a href="event:router:/user/${item.user}">${item.user}</a></u>';
			}
			if (item.time_ago != null) {
				if (metaText.length > 0) {
					metaText += " ";
				}
				metaText += '${item.time_ago}';
			}
			_meta.htmlText = metaText;

			_description.htmlText = item.content;
			_description.visible = item.content != null && item.content.length > 0;
			_description.includeInLayout = _description.visible;
		}
		super.update();
	}
}
