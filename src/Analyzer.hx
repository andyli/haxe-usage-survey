import python.*;
import pandas.*;
import python.lib.Builtins.*;
import textwrap.*;
import matplotlib.pyplot.Pyplot as Plt;
import seaborn.Seaborn as Sns;
import Main;
using PyHelpers;
using Lambda;

class Analyzer {
	static public function make_autopct<T:Float>(values:Array<T>):T->String {
		return function my_autopct(pct:Float):String {
			var total = values.fold(function(a,b) return a+b, 0);
			var val = Std.int(Math.round(pct*total/100.0));
			var pc = Math.round(pct);
			return '$pc% ($val)';
		}
	}
	static public function analyzeExp(data:DataFrame):Void {
		var group:pandas.core.groupby.GroupBy = data.groupby(k_exp);
		var groups:Dict<String,Dynamic> = group.groups;
		var groupKeys = [v_pro_main, v_pro_occ, v_use, v_interested];
		var values = [for (k in groupKeys) len(groups.get(k))];
		Plt.axes.call(aspect=>1);
		Plt.title.call(
			Main.colQuestions[k_exp],
			fontsize => "large"
		);
		Plt.pie.call(
			values,
			labels => [for (k in groupKeys) {
				var l = Main.values[k_exp][k][0];
				(Textwrap.wrap(l, 25):Array<String>).join("\n");
			}],
			labeldistance => 1.2,
			autopct => make_autopct(values),
			pctdistance => 0.7,
			colors => Sns.color_palette("muted", groupKeys.length),
			textprops => Lib.anonAsDict({
				backgroundcolor: [1.0,1.0,1.0,0.9],
			}),
			wedgeprops => Lib.anonAsDict({
				linewidth: 2,
				edgecolor: [1.0,1.0,1.0],
			})
		);
		// Plt.legend.call(
		// 	labels => [for (k in groupKeys) Main.values[k_exp][k][0]],
		// 	loc => "best"
		// );
		Plt.savefig.call("out/fig_exp.png");
		Plt.savefig.call("out/fig_exp.svg");
	}
}