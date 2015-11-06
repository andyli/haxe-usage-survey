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
	static public var expKeys = [v_pro_main, v_pro_occ, v_use, v_interested];
	static public var expColors = Sns.cubehelix_palette.call(expKeys.length, rot=>-.75, reverse=>true);
	static public function analyzeExp(data:DataFrame):Void {
		var group:pandas.core.groupby.GroupBy = data.groupby(k_exp);
		var groups:Dict<String,Dynamic> = group.groups;
		var values = [for (k in expKeys) len(groups.get(k))];
		Plt.figure();
		Plt.subplot();
		Plt.axes.call(aspect=>1);
		Plt.title.call(
			Main.colQuestions[k_exp],
			fontsize => "large"
		);
		Plt.pie.call(
			values,
			labels => [for (k in expKeys) {
				var l = Main.values[k_exp][k][0];
				(Textwrap.wrap(l, 25):Array<String>).join("\n");
			}],
			labeldistance => 1.2,
			autopct => make_autopct(values),
			pctdistance => 0.7,
			colors => expColors, //Sns.color_palette("muted", expKeys.length),
			textprops => Lib.anonAsDict({
				backgroundcolor: [1.0,1.0,1.0,0.9],
			}),
			wedgeprops => Lib.anonAsDict({
				linewidth: 2,
				edgecolor: [1.0,1.0,1.0],
			})
		);
		// Plt.legend.call(
		// 	labels => [for (k in expKeys) Main.values[k_exp][k][0]],
		// 	loc => "best"
		// );
		Plt.tight_layout();
		Plt.savefig.call("out/fig_exp.png");
		Plt.savefig.call("out/fig_exp.svg");
	}

	static public function analyzeCreate(data:DataFrame):Void {
		var vnames = [v_game, v_web_front, v_web_back, v_app_desktop, v_app_mobile, v_lib, v_hardware, v_art, v_not_sure, v_others];
		// vnames.sort(function(a,b) return Std.int(data.get(k_create + "_" + b).sum()) - Std.int(data.get(k_create + "_" + a).sum()));
		var df = new DataFrame(Lib.anonAsDict({
			"what": [for (n in vnames) 
				if (n == v_others)
					"Others"
				else
					Main.values[k_create][n][0]
			]
		}));
		for (exp in expKeys) {
			df.__setitem__(exp, [
				for (vname in vnames)
				data.get(data.get(k_exp) == exp).get(k_create + "_" + vname).sum()
			]);
		}
		df.__setitem__("total", [
			for (vname in vnames)
			data.get(k_create + "_" + vname).sum()
		]);
		trace(df);
		Plt.figure();
		var ax:matplotlib.axes.Axes = Plt.subplot();
		for (i in 0...expKeys.length) {
			var i = expKeys.length - i - 1;
			Sns.barplot.call(
				x => [
					for (_i in 0...i+1)
					df.get(expKeys[_i])
				].fold(function(a,b) return a + b, 0),
				y => "what",
				data => df,
				color => expColors[i],
				linewidth => 0,
				label => Main.values[k_exp][expKeys[i]][0]
			);
		}
		ax.set.call(
			ylabel => "",
			xlabel => "Number of people",
			xlim => [0, len(data.index)]
		);
		ax.set_title.call(
			Main.colQuestions[k_create],
			fontsize => "large"
		);
		var hl:Tuple<Dynamic> = ax.get_legend_handles_labels();
		var legend = ax.legend.call(
			untyped reversed(hl[0]),
			untyped reversed(hl[1]),
			loc => "lower right",
			frameon => true,
			framealpha => 0.8
		);
		var rect:matplotlib.patches.Rectangle = legend.get_frame();
		rect.set_linewidth(1);
		rect.set_edgecolor([1,1,1]);
		rect.set_facecolor([1,1,1]);
		Plt.tight_layout();
		Plt.savefig.call("out/fig_create.png");
		Plt.savefig.call("out/fig_create.svg");
	}

	static public function analyzeTarget(data:DataFrame):Void {
		var vnames = [v_cpp, v_js, v_python, v_swf, v_as3, v_neko, v_java, v_cs, v_php, v_interp];
		vnames.sort(function(a,b) return Std.int(data.get(k_target + "_" + b).sum()) - Std.int(data.get(k_target + "_" + a).sum()));

		var df = new DataFrame(Lib.anonAsDict({
			"target": [for (n in vnames) Main.values[k_target][n][0]]
		}));
		for (exp in expKeys) {
			df.__setitem__(exp, [
				for (vname in vnames)
				data.get(data.get(k_exp) == exp).get(k_target + "_" + vname).sum()
			]);
		}
		df.__setitem__("total", [
			for (vname in vnames)
			data.get(k_target + "_" + vname).sum()
		]);
		trace(df);
		Plt.figure();
		var ax:matplotlib.axes.Axes = Plt.subplot();
		for (i in 0...expKeys.length) {
			var i = expKeys.length - i - 1;
			Sns.barplot.call(
				x => [
					for (_i in 0...i+1)
					df.get(expKeys[_i])
				].fold(function(a,b) return a + b, 0),
				y => "target",
				data => df,
				color => expColors[i],
				linewidth => 0,
				label => Main.values[k_exp][expKeys[i]][0]
			);
		}
		ax.set.call(
			ylabel => "",
			xlabel => "Number of people",
			xlim => [0, len(data.index)]
		);
		ax.set_title.call(
			Main.colQuestions[k_target],
			fontsize => "large"
		);
		var hl:Tuple<Dynamic> = ax.get_legend_handles_labels();
		var legend = ax.legend.call(
			untyped reversed(hl[0]),
			untyped reversed(hl[1]),
			loc => "lower right",
			frameon => true,
			framealpha => 0.8
		);
		var rect:matplotlib.patches.Rectangle = legend.get_frame();
		rect.set_linewidth(1);
		rect.set_edgecolor([1,1,1]);
		rect.set_facecolor([1,1,1]);
		Plt.tight_layout();
		Plt.savefig.call("out/fig_target.png");
		Plt.savefig.call("out/fig_target.svg");
	}
}