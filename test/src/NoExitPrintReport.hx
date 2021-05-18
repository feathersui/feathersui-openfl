import utest.ui.common.PackageResult;
import utest.ui.text.PrintReport;

class NoExitPrintReport extends PrintReport {
	override function complete(result:PackageResult) {
		this.result = result;
		if (handler != null) {
			handler(this);
		}
	}
}
