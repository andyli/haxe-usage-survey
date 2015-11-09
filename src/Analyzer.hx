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
			colQuestions[k_exp],
			fontsize => "large"
		);
		Plt.pie.call(
			values,
			labels => [for (k in expKeys) {
				var l = SurveyInfo.values[k_exp][k][0];
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

	static public function analyzeMCQuestion(data:DataFrame, config:{
		col:ColNames,
		vnames:Array<Values>
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
		for (exp in expKeys) {
			df.__setitem__(exp, [
				for (vname in config.vnames)
				data.get(data.get(k_exp) == exp).get(config.col + "_" + vname).sum() / total * 100
			]);
		}
		df.__setitem__("total", [
			for (vname in config.vnames)
			data.get(config.col + "_" + vname).sum() / total * 100
		]);
		df.to_csv.call(path_or_buf => 'out/${config.col}.tsv', sep => "\t", index=>false);
		Plt.figure();
		var ax:matplotlib.axes.Axes = Plt.subplot();
		for (i in 0...expKeys.length) {
			var i = expKeys.length - i - 1;
			Sns.barplot.call(
				x => [
					for (_i in 0...i+1)
					df.get(expKeys[_i])
				].fold(function(a,b) return a + b, 0),
				y => config.col,
				data => df,
				color => expColors[i],
				linewidth => 0,
				label => SurveyInfo.values[k_exp][expKeys[i]][0]
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
		var vnames = [v_game, v_web_front, v_web_back, v_app_desktop, v_app_mobile, v_lib, v_hardware, v_art, v_not_sure, v_others];
		// vnames.sort(function(a,b) return Std.int(data.get(k_create + "_" + b).sum()) - Std.int(data.get(k_create + "_" + a).sum()));
		analyzeMCQuestion(data, {
			col: k_create,
			vnames: vnames
		});
	}

	static public function analyzeTarget(data:DataFrame):Void {
		var vnames = [v_cpp, v_js, v_python, v_swf, v_as3, v_neko, v_java, v_cs, v_php, v_interp];
		vnames.sort(function(a,b) return Std.int(data.get(k_target + "_" + b).sum()) - Std.int(data.get(k_target + "_" + a).sum()));
		analyzeMCQuestion(data, {
			col: k_target,
			vnames: vnames
		});
	}

	static public function analyzeVersion(data:DataFrame):Void {
		var vnames = [v_v3_2, v_v3_1, v_v3_0, v_v2, v_git, v_not_sure];
		analyzeMCQuestion(data, {
			col: k_version,
			vnames: vnames
		});
	}

	static public function analyzeInstallHaxe(data:DataFrame):Void {
		var vnames = [v_preinstall, v_official, v_thirdparty, v_brew, v_linux_package, v_choco, v_source, v_not_sure, v_others];
		analyzeMCQuestion(data, {
			col: k_install_haxe,
			vnames: vnames
		});
	}

	static public function analyzeInstallPref(data:DataFrame):Void {
		var vnames = [v_preinstall, v_official, v_package, v_source, v_others];
		analyzeMCQuestion(data, {
			col: k_install_pref,
			vnames: vnames
		});
	}

	static public function analyzeOsWin(data:DataFrame):Void {
		var vnames = [v_no_win, v_win10, v_win8, v_win7, v_winxp, v_others];
		analyzeMCQuestion(data, {
			col: k_os_win,
			vnames: vnames
		});
	}

	static public function analyzeOsMac(data:DataFrame):Void {
		var vnames = [v_no_mac, v_mac1011, v_mac1010, v_mac1009, v_mac1008, v_others];
		analyzeMCQuestion(data, {
			col: k_os_mac,
			vnames: vnames
		});
	}

	static public function analyzeOsLinux(data:DataFrame):Void {
		var vnames = [
			v_no_linux,
			v_ubuntu,
			v_debian,
			v_fedora,
			v_opensuse,
			v_gentoo,
			v_mandriva,
			v_redhat,
			v_oracle,
			v_solaris,
			v_turbolinux,
			v_arch,
			v_freebsd,
			v_openbsd,
			v_netbsd,
			v_mint,
			v_elementary,
			v_others,
		];
		analyzeMCQuestion(data, {
			col: k_os_linux,
			vnames: vnames
		});
	}

	static public function analyzeOsMobile(data:DataFrame):Void {
		var vnames = [v_no_mobile, v_android, v_ios, v_windows, v_firefox, v_tizen, v_blackberry, v_others];
		analyzeMCQuestion(data, {
			col: k_os_mobile,
			vnames: vnames
		});
	}
}