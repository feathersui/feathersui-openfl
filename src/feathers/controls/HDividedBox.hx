package feathers.controls;

import feathers.controls.supportClasses.BaseDividedBox;
import feathers.core.IValidating;
import feathers.layout.HDividedBoxLayout;
import feathers.themes.steel.components.SteelHDividedBoxStyles;
import feathers.utils.DisplayUtil;
#if (lime && !flash)
import lime.ui.MouseCursor as LimeMouseCursor;
#end

class HDividedBox extends BaseDividedBox {
	public function new() {
		this.initializeHDividedBoxTheme();

		super();

		#if (lime && !flash)
		this.resizeCursor = LimeMouseCursor.RESIZE_WE;
		#end
	}

	private var _resizeStartStageX:Float;
	private var _resizeStartWidth1:Float;
	private var _resizeStartWidth2:Float;

	private function initializeHDividedBoxTheme():Void {
		SteelHDividedBoxStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this.layout == null) {
			this.layout = new HDividedBoxLayout();
		}
	}

	override private function prepareResize(dividerIndex:Int, stageX:Float, stageY:Float):Void {
		this._resizeStartStageX = stageX;

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		this._resizeStartWidth1 = firstItem.width;
		this._resizeStartWidth2 = secondItem.width;

		if (this._currentResizeDraggingSkin != null) {
			var divider = this.dividers[dividerIndex];
			this._currentResizeDraggingSkin.y = divider.y;
			this._currentResizeDraggingSkin.height = divider.height;
			if (Std.is(this._currentResizeDraggingSkin, IValidating)) {
				cast(this._currentResizeDraggingSkin, IValidating).validateNow();
			}
			this._currentResizeDraggingSkin.x = divider.x + (divider.width - this._currentResizeDraggingSkin.width) / 2.0;
		}
	}

	override private function commitResize(dividerIndex:Int, stageX:Float, stageY:Float, live:Bool):Void {
		var offsetX = stageX - this._resizeStartStageX;
		offsetX *= DisplayUtil.getConcatenatedScaleX(this);

		if (live && !this.liveDragging) {
			if (this._currentResizeDraggingSkin != null) {
				var divider = this.dividers[dividerIndex];
				this._currentResizeDraggingSkin.y = divider.y;
				this._currentResizeDraggingSkin.height = divider.height;
				if (Std.is(this._currentResizeDraggingSkin, IValidating)) {
					cast(this._currentResizeDraggingSkin, IValidating).validateNow();
				}
				this._currentResizeDraggingSkin.x = divider.x + offsetX + (divider.width - this._currentResizeDraggingSkin.width) / 2.0;
			}
			return;
		}

		var totalWidth = this._resizeStartWidth1 + this._resizeStartWidth2;
		var firstItemWidth = this._resizeStartWidth1 + offsetX;
		if (firstItemWidth < 0.0) {
			firstItemWidth = 0.0;
		} else if (firstItemWidth > totalWidth) {
			firstItemWidth = totalWidth;
		}
		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		firstItem.width = firstItemWidth;
		secondItem.width = totalWidth - firstItemWidth;
	}
}
