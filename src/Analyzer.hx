import python.*;
import pandas.*;
import python.lib.Builtins.*;
import textwrap.*;
import matplotlib.pyplot.Pyplot as Plt;
import seaborn.Seaborn as Sns;
import Main;
import SurveyInfo;
import SurveyInfo.*;
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
	
	static public var expColors = Sns.cubehelix_palette.call(SurveyInfo.keys[k_exp].length, rot=>-.75, reverse=>true);
	static public function analyzeExp(data:DataFrame):Void {
		analyzeSCQuestion(data, {
			col: k_exp,
			colors: expColors
		});
	}

	static public function analyzeTargetCount(data:DataFrame):Void {
		data = data.copy();
		var k_target_count = k_target + "_count";
		var k_target_count_grouped = k_target_count + "_grouped";
		data.__setitem__(k_target_count_grouped, data.get(k_target_count).astype(str));
		data.at.__setitem__(python.Tuple.Tuple2.make(data.get(k_target_count) >= 7, k_target_count_grouped), "7+");

		analyzeSCQuestion(data, {
			col: k_target_count_grouped,
			col_label: "Number of interested targets per respondents",
			vnames: ["1", "2", "3", "4", "5", "6", "7+"],
			colors: Sns.color_palette("Blues", 7)
		});
	}

	static public function analyzeSCQuestion(data:DataFrame, config:{
		col:ColName,
		?col_label:String,
		?vnames:Array<Value>,
		?colors:Dynamic
	}):Void {
		var group:pandas.core.groupby.GroupBy = data.groupby(config.col);
		var groups:Dict<String,Dynamic> = group.groups;
		var vnames = config.vnames != null ? config.vnames : SurveyInfo.keys[config.col];
		var values = [for (k in vnames) len(groups.get(k))];
		Plt.figure();
		Plt.subplot();
		Plt.axes.call(aspect=>1);
		Plt.title.call(
			config.col_label != null ? config.col_label : colQuestions[config.col],
			fontsize => "large"
		);
		Plt.pie.call(
			values,
			labels => [for (k in vnames) {
				var l = if (SurveyInfo.values.exists(config.col))
					SurveyInfo.values[config.col][k][0];
				else
					Std.string(k);
				(Textwrap.wrap(l, 25):Array<String>).join("\n");
			}],
			labeldistance => 1.2,
			autopct => make_autopct(values),
			pctdistance => 0.7,
			colors => (config.colors != null ? config.colors : Sns.color_palette("Set2", vnames.length)),
			textprops => Lib.anonAsDict({
				backgroundcolor: [1.0,1.0,1.0,0.9],
			}),
			wedgeprops => Lib.anonAsDict({
				linewidth: 2,
				edgecolor: [1.0,1.0,1.0],
			})
		);
		Plt.tight_layout();
		Plt.savefig.call('out/fig_${config.col}.png');
		Plt.savefig.call('out/fig_${config.col}.svg');
	}

	static public function analyzeMCQuestion(data:DataFrame, config:{
		col:ColName,
		vnames:Array<Value>,
		sub_col:ColName,
		?sub_vnames:Array<Value>,
	}):Void {
		var dobj = {};
		Reflect.setField(dobj, config.col, [for (n in config.vnames) 
			if (n == v_others)
				"Others"
			else
				(Textwrap.wrap(SurveyInfo.values[config.col][n][0], 40):Array<String>).join("\n")
		]);
		var df = new DataFrame(Lib.anonAsDict(dobj));
		var total = len(data.index);
		var keys = SurveyInfo.keys[config.sub_col];
		for (exp in keys) {
			df.__setitem__(exp, [
				for (vname in config.vnames)
				data.get(data.get(config.sub_col) == exp).get(config.col + "_" + vname).sum() / total * 100
			]);
		}
		df.__setitem__("total", [
			for (vname in config.vnames)
			data.get(config.col + "_" + vname).sum() / total * 100
		]);
		df.to_csv.call(path_or_buf => 'out/${config.col}.tsv', sep => "\t", index=>false);
		Plt.figure();
		var ax:matplotlib.axes.Axes = Plt.subplot();
		for (i in 0...keys.length) {
			var i = keys.length - i - 1;
			Sns.barplot.call(
				x => [
					for (_i in 0...i+1)
					df.get(keys[_i])
				].fold(function(a,b) return a + b, 0),
				y => config.col,
				data => df,
				color => expColors[i],
				linewidth => 0,
				label => SurveyInfo.values[config.sub_col][keys[i]][0]
			);
		}
		ax.set.call(
			ylabel => "",
			xlabel => "Percentage of respondents",
			xlim => [0, 100]
		);
		ax.set_title.call(
			(Textwrap.wrap(SurveyInfo.colQuestions[config.col], 45):Array<String>).join("\n") + "\n(allow multiple selections)",
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
		Plt.savefig.call('out/fig_${config.col}.png');
		Plt.savefig.call('out/fig_${config.col}.svg');
	}

	static public function analyzeCreate(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_create];
		// vnames.sort(function(a,b) return Std.int(data.get(k_create + "_" + b).sum()) - Std.int(data.get(k_create + "_" + a).sum()));
		analyzeMCQuestion(data, {
			col: k_create,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeTarget(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_target];
		vnames.sort(function(a,b) return Std.int(data.get(k_target + "_" + b).sum()) - Std.int(data.get(k_target + "_" + a).sum()));
		analyzeMCQuestion(data, {
			col: k_target,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeVersion(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_version];
		analyzeMCQuestion(data, {
			col: k_version,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeInstallHaxe(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_install_haxe];
		analyzeMCQuestion(data, {
			col: k_install_haxe,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeInstallPref(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_install_pref];
		analyzeMCQuestion(data, {
			col: k_install_pref,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeOsWin(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_os_win];
		analyzeMCQuestion(data, {
			col: k_os_win,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeOsMac(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_os_mac];
		analyzeMCQuestion(data, {
			col: k_os_mac,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeOsLinux(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_os_linux];
		analyzeMCQuestion(data, {
			col: k_os_linux,
			vnames: vnames,
			sub_col: k_exp,
		});
	}

	static public function analyzeOsMobile(data:DataFrame):Void {
		var vnames = SurveyInfo.keys[k_os_mobile];
		analyzeMCQuestion(data, {
			col: k_os_mobile,
			vnames: vnames,
			sub_col: k_exp,
		});
	}
}