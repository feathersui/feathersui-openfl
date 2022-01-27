package com.feathersui.hn.views.controls;

import feathers.layout.HorizontalLayoutData;
import com.feathersui.hn.vo.FeedItem;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.VerticalLayout;

@:styleContext
class FeedItemRenderer extends LayoutGroupItemRenderer implements ILayoutIndexObject {
	public function new() {
		super();
	}

	private var _indexLabel:Label;
	private var _titleLabel:Label;
	private var _secondaryLabel:Label;

	@:isVar
	public var pageIndex(default, set):Int;

	private function set_pageIndex(value:Int):Int {
		if (pageIndex == value) {
			return pageIndex;
		}
		pageIndex = value;
		setInvalid(DATA);
		return pageIndex;
	}

	@:isVar
	public var maxPerPage:Int;

	private function set_maxPerPage(value:Int):Int {
		if (maxPerPage == value) {
			return maxPerPage;
		}
		maxPerPage = value;
		setInvalid(DATA);
		return maxPerPage;
	}

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new HorizontalLayout();
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.gap = 4.0;
		viewLayout.paddingTop = 2.0;
		viewLayout.paddingRight = 4.0;
		viewLayout.paddingBottom = 2.0;
		viewLayout.paddingLeft = 4.0;
		layout = viewLayout;

		_indexLabel = new Label();
		_indexLabel.variant = Label.VARIANT_HEADING;
		addChild(_indexLabel);

		var contentContainer = new LayoutGroup();
		var contentLayout = new VerticalLayout();
		contentLayout.horizontalAlign = JUSTIFY;
		contentContainer.layout = contentLayout;
		contentContainer.layoutData = HorizontalLayoutData.fillHorizontal();
		addChild(contentContainer);

		_titleLabel = new Label();
		_titleLabel.wordWrap = true;
		contentContainer.addChild(_titleLabel);

		_secondaryLabel = new Label();
		_secondaryLabel.variant = Label.VARIANT_DETAIL;
		_secondaryLabel.wordWrap = true;
		contentContainer.addChild(_secondaryLabel);
	}

	override private function update():Void {
		var feedItem = (data : FeedItem);
		if (feedItem != null) {
			_indexLabel.text = Std.string(((pageIndex - 1) * maxPerPage) + layoutIndex + 1);

			var primaryHtmlText = '<a href="${feedItem.url}">${feedItem.title}</a>';
			if (feedItem.domain != null) {
				primaryHtmlText += ' (<a href="https://news.ycombinator.com/from?site=${feedItem.domain}">${feedItem.domain}</a>)';
			}
			_titleLabel.htmlText = primaryHtmlText;

			var secondaryHtmlText = "";
			if (feedItem.points != null) {
				secondaryHtmlText += '${feedItem.points} points ';
			}
			if (feedItem.user != null) {
				secondaryHtmlText += 'by <u><a href="event:router:/user/${feedItem.user}">${feedItem.user}</a></u> ';
			}
			if (feedItem.time_ago != null) {
				secondaryHtmlText += '${feedItem.time_ago} ';
			}
			if (secondaryHtmlText.length > 0) {
				secondaryHtmlText += '| ';
			}
			secondaryHtmlText += '<u><a href="event:router:/item/${feedItem.id}">${feedItem.comments_count} comments</a></u>';
			_secondaryLabel.htmlText = secondaryHtmlText;
		}
		super.update();
	}
}
