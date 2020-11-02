package feathers.controls;

import feathers.controls.supportClasses.BaseDividedBox;
import feathers.core.IValidating;
import feathers.layout.VDividedBoxLayout;
import feathers.themes.steel.components.SteelVDividedBoxStyles;
import feathers.utils.DisplayUtil;
#if (lime && !flash)
import lime.ui.MouseCursor as LimeMouseCursor;
#end

class VDividedBox extends BaseDividedBox {
	public function new() {
		this.initializeVDividedBoxTheme();

		super();

		#if (lime && !flash)
		this.resizeCursor = LimeMouseCursor.RESIZE_NS;
		#end
	}

	private var _resizeStartStageY:Float;
	private var _resizeStartHeight1:Float;
	private var _resizeStartHeight2:Float;

	private function initializeVDividedBoxTheme():Void {
		SteelVDividedBoxStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this.layout == null) {
			this.layout = new VDividedBoxLayout();
		}
	}

	override private function prepareResize(dividerIndex:Int, stageX:Float, stageY:Float):Void {
		this._resizeStartStageY = stageY;

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		this._resizeStartHeight1 = firstItem.height;
		this._resizeStartHeight2 = secondItem.height;

		if (this._currentResizeDraggingSkin != null) {
			var divider = this.dividers[dividerIndex];
			this._currentResizeDraggingSkin.x = divider.x;
			this._currentResizeDraggingSkin.width = divider.width;
			if (Std.is(this._currentResizeDraggingSkin, IValidating)) {
				cast(this._currentResizeDraggingSkin, IValidating).validateNow();
			}
			this._currentResizeDraggingSkin.y = divider.y + (divider.height - this._currentResizeDraggingSkin.height) / 2.0;
		}
	}

	override private function commitResize(dividerIndex:Int, stageX:Float, stageY:Float, live:Bool):Void {
		var offsetY = stageY - this._resizeStartStageY;
		offsetY *= DisplayUtil.getConcatenatedScaleY(this);

		if (live && !this.liveDragging) {
			if (this._currentResizeDraggingSkin != null) {
				var divider = this.dividers[dividerIndex];
				this._currentResizeDraggingSkin.x = divider.x;
				this._currentResizeDraggingSkin.width = divider.width;
				if (Std.is(this._currentResizeDraggingSkin, IValidating)) {
					cast(this._currentResizeDraggingSkin, IValidating).validateNow();
				}
				this._currentResizeDraggingSkin.y = divider.y + offsetY + (divider.height - this._currentResizeDraggingSkin.height) / 2.0;
			}
			return;
		}

		var totalHeight = this._resizeStartHeight1 + this._resizeStartHeight2;
		var firstItemHeight = this._resizeStartHeight1 + offsetY;
		if (firstItemHeight < 0.0) {
			firstItemHeight = 0.0;
		} else if (firstItemHeight > totalHeight) {
			firstItemHeight = totalHeight;
		}
		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		firstItem.height = firstItemHeight;
		secondItem.height = totalHeight - firstItemHeight;
	}
}
