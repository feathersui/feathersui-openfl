package com.feathersui.hn.views.controls;

import feathers.controls.dataRenderers.IHierarchicalDepthItemRenderer;
import com.feathersui.hn.vo.Item;
import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.VerticalLayout;

class CommentItemRenderer extends LayoutGroupItemRenderer implements IHierarchicalDepthItemRenderer {
	public function new() {
		super();
		themeEnabled = false;
	}

	private var _meta:Label;
	private var _description:Label;
	private var _viewLayout:VerticalLayout;

	@:isVar
	public var hierarchyDepth(get, set):Int;

	private function get_hierarchyDepth():Int {
		return hierarchyDepth;
	}

	private function set_hierarchyDepth(value:Int):Int {
		if (hierarchyDepth == value) {
			return hierarchyDepth;
		}
		hierarchyDepth = value;
		setInvalid(DATA);
		return hierarchyDepth;
	}

	override private function initialize():Void {
		super.initialize();

		_viewLayout = new VerticalLayout();
		_viewLayout.horizontalAlign = JUSTIFY;
		_viewLayout.gap = 8.0;
		_viewLayout.setPadding(8.0);
		layout = _viewLayout;

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
		var paddingLeft = 8.0 + (16.0 * (hierarchyDepth - 1));
		var maxPaddingLeft = actualWidth / 2.0;
		if (paddingLeft > maxPaddingLeft) {
			paddingLeft = maxPaddingLeft;
		}
		_viewLayout.paddingLeft = paddingLeft;

		var item = (data : Item);
		if (item != null) {
			var metaText = "";
			if (item.user != null) {
				if (metaText.length > 0) {
					metaText += " ";
				}
				metaText += '<u><a href="event:router:/user?id=${item.user}">${item.user}</a></u>';
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
