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
		Plt.subplot();
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
		Plt.tight_layout();
		Plt.savefig.call("out/fig_exp.png");
		Plt.savefig.call("out/fig_exp.svg");
	}

	static public function analyzeCreate(data:DataFrame):Void {
		var vnames = [v_game, v_web_front, v_web_back, v_app_desktop, v_app_mobile, v_lib, v_hardware, v_art, v_not_sure, v_others];
		var values = [
			for (vname in vnames)
			data.get(k_create + "_" + vname).sum()
		];
		var df = new DataFrame(Lib.anonAsDict({
			"what": [for (n in vnames) 
				if (n == v_others)
					"Others"
				else
					Main.values[k_create][n][0]
			], 
			"count": values,
		}));
		trace(df);
		// data.get(k_create)
		// var df = new 
		var ax:matplotlib.axes.Axes = Plt.subplot();
		Sns.barplot.call(
			x => "count",
			y => "what",
			data => df,
			color => "b"
		);
		ax.set.call(
			title => Main.colQuestions[k_create],
			ylabel => "",
			xlabel => "count",
			xlim => [0, len(data.index)]
		);
		Plt.tight_layout();
		Plt.savefig.call("out/fig_create.png");
		Plt.savefig.call("out/fig_create.svg");
	}
}