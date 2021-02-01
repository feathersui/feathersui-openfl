package views;

import feathers.controls.Header;
import feathers.controls.Panel;

class C extends Panel {
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		var header = new Header();
		header.text = "C";
		this.header = header;
	}
}
