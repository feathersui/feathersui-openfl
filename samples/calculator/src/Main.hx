import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.style.Theme;

class Main extends Application {
	public function new() {
		Theme.setTheme(new CalculatorTheme());

		super();

		var layout = new VerticalLayout();
		layout.gap = 4.0;
		this.layout = layout;

		this.createRows();
		this.createDisplay();
		this.createButtons();

		this.clear();
	}

	private var rows:Array<LayoutGroup> = [];
	private var inputDisplay:Label;
	private var numberButtons:Array<Button> = [];
	private var clearButton:Button;
	private var addButton:Button;
	private var subtractButton:Button;
	private var multiplyButton:Button;
	private var divideButton:Button;
	private var equalsButton:Button;

	private var pendingNewInput:Bool = true;
	private var previousNumber:Int = 0;
	private var currentNumber:Int = 0;
	private var pendingOperation:Operation = null;

	private function clear():Void {
		this.pendingNewInput = true;
		this.pendingOperation = null;
		this.previousNumber = 0;
		this.currentNumber = 0;
		this.refreshDisplay();
	}

	private function equals():Void {
		if (this.pendingOperation == null) {
			return;
		}
		var result = 0;
		switch (this.pendingOperation) {
			case Add:
				result = this.previousNumber + this.currentNumber;
			case Subtract:
				result = this.previousNumber - this.currentNumber;
			case Multiply:
				result = this.previousNumber * this.currentNumber;
			case Divide:
				result = Math.floor(this.previousNumber / this.currentNumber);
		}
		this.currentNumber = result;
		this.previousNumber = result;
		this.pendingOperation = null;
		this.pendingNewInput = true;
		this.refreshDisplay();
	}

	private function refreshDisplay():Void {
		this.inputDisplay.text = Std.string(this.currentNumber);
	}

	private function createRows():Void {
		for (i in 0...5) {
			var layout = new HorizontalLayout();
			layout.verticalAlign = MIDDLE;
			layout.gap = 4.0;
			var row = new LayoutGroup();
			row.layout = layout;
			row.layoutData = new VerticalLayoutData(100, 20);
			this.addChild(row);
			this.rows.push(row);
		}
	}

	private function createDisplay():Void {
		this.inputDisplay = new Label();
		this.inputDisplay.variant = CalculatorTheme.VARIANT_INPUT_DISPLAY_LABEL;
		this.inputDisplay.layoutData = new HorizontalLayoutData(100.0);
		this.rows[0].addChild(this.inputDisplay);
	}

	private function createButtons():Void {
		this.clearButton = new Button();
		this.clearButton.variant = CalculatorTheme.VARIANT_OPERATION_BUTTON;
		this.clearButton.text = "C";
		this.clearButton.layoutData = new HorizontalLayoutData(25, 100);
		this.clearButton.addEventListener(TriggerEvent.TRIGGER, clearButton_triggerHandler);
		this.rows[4].addChild(this.clearButton);

		for (i in 0...10) {
			var button = new Button();
			button.text = Std.string(i);
			button.layoutData = new HorizontalLayoutData(25, 100);
			button.addEventListener(TriggerEvent.TRIGGER, numberButton_triggerHandler);
			this.numberButtons.push(button);
			if (i == 0) {
				this.rows[4].addChild(button);
			} else if (i < 4) {
				this.rows[3].addChild(button);
			} else if (i < 7) {
				this.rows[2].addChild(button);
			} else if (i < 10) {
				this.rows[1].addChild(button);
			}
		}

		this.equalsButton = new Button();
		this.equalsButton.variant = CalculatorTheme.VARIANT_OPERATION_BUTTON;
		this.equalsButton.text = "=";
		this.equalsButton.layoutData = new HorizontalLayoutData(25, 100);
		this.equalsButton.addEventListener(TriggerEvent.TRIGGER, equalsButton_triggerHandler);
		this.rows[4].addChild(this.equalsButton);

		this.divideButton = new Button();
		this.divideButton.variant = CalculatorTheme.VARIANT_OPERATION_BUTTON;
		// not all fonts support ÷
		this.divideButton.text = "/";
		this.divideButton.layoutData = new HorizontalLayoutData(25, 100);
		this.divideButton.addEventListener(TriggerEvent.TRIGGER, divideButton_triggerHandler);
		this.rows[1].addChild(this.divideButton);

		this.multiplyButton = new Button();
		this.multiplyButton.variant = CalculatorTheme.VARIANT_OPERATION_BUTTON;
		// not all fonts support ×
		this.multiplyButton.text = "x";
		this.multiplyButton.layoutData = new HorizontalLayoutData(25, 100);
		this.multiplyButton.addEventListener(TriggerEvent.TRIGGER, multiplyButton_triggerHandler);
		this.rows[2].addChild(this.multiplyButton);

		this.subtractButton = new Button();
		this.subtractButton.variant = CalculatorTheme.VARIANT_OPERATION_BUTTON;
		// not all fonts support −
		this.subtractButton.text = "-";
		this.subtractButton.layoutData = new HorizontalLayoutData(25, 100);
		this.subtractButton.addEventListener(TriggerEvent.TRIGGER, subtractButton_triggerHandler);
		this.rows[3].addChild(this.subtractButton);

		this.addButton = new Button();
		this.addButton.variant = CalculatorTheme.VARIANT_OPERATION_BUTTON;
		this.addButton.text = "+";
		this.addButton.layoutData = new HorizontalLayoutData(25, 100);
		this.addButton.addEventListener(TriggerEvent.TRIGGER, addButton_triggerHandler);
		this.rows[4].addChild(this.addButton);
	}

	private function numberButton_triggerHandler(event:TriggerEvent):Void {
		if (this.pendingNewInput) {
			this.previousNumber = this.currentNumber;
		}

		var newText = (this.pendingNewInput || this.currentNumber == 0) ? "" : Std.string(this.currentNumber);
		this.pendingNewInput = false;

		var index = this.numberButtons.indexOf(event.currentTarget);
		if (index == 0 && this.currentNumber == 0) {
			// the user pressed 0, but the value is already 0, so don't append
			return;
		}
		newText += Std.string(index);

		// max length of input
		if (newText.length >= 10) {
			return;
		}

		this.currentNumber = Std.parseInt(newText);

		this.refreshDisplay();
	}

	private function clearButton_triggerHandler(event:TriggerEvent):Void {
		this.clear();
	}

	private function addButton_triggerHandler(event:TriggerEvent):Void {
		if (this.pendingOperation != null && !this.pendingNewInput) {
			this.equals();
		}
		this.pendingOperation = Add;
		this.pendingNewInput = true;
	}

	private function subtractButton_triggerHandler(event:TriggerEvent):Void {
		if (this.pendingOperation != null && !this.pendingNewInput) {
			this.equals();
		}
		this.pendingOperation = Subtract;
		this.pendingNewInput = true;
	}

	private function multiplyButton_triggerHandler(event:TriggerEvent):Void {
		if (this.pendingOperation != null && !this.pendingNewInput) {
			this.equals();
		}
		this.pendingOperation = Multiply;
		this.pendingNewInput = true;
	}

	private function divideButton_triggerHandler(event:TriggerEvent):Void {
		if (this.pendingOperation != null && !this.pendingNewInput) {
			this.equals();
		}
		this.pendingOperation = Divide;
		this.pendingNewInput = true;
	}

	private function equalsButton_triggerHandler(event:TriggerEvent):Void {
		if (this.pendingNewInput) {
			this.pendingOperation = null;
			return;
		}
		this.equals();
	}
}

enum Operation {
	Add;
	Subtract;
	Multiply;
	Divide;
}
