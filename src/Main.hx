import python.*;
import python.lib.Builtins.*;
import python.lib.Codecs.encode;
import pandas.*;
import pandas.Pandas_Module as Pandas;
import SurveyInfo;
import SurveyInfo.*;
using PyHelpers;
using python.Lib;
using Lambda;
using StringTools;
using Reflect;

class Main extends mcli.CommandLine {
	var data:DataFrame;

	/**
		Analyze the data and plot graphs.
	*/
	public function analyze():Void {
		Analyzer.analyzeExp(data);
		Analyzer.analyzeCreate(data);
		Analyzer.analyzeTarget(data);
		Analyzer.analyzeVersion(data);
		Analyzer.analyzeInstallHaxe(data);
		Analyzer.analyzeInstallPref(data);
		Analyzer.analyzeOsWin(data);
		Analyzer.analyzeOsMac(data);
		Analyzer.analyzeOsLinux(data);
		Analyzer.analyzeOsMobile(data);
	}

	/**
		Load data file in tsv format.
	*/
	public function load(dataPath:String):Void {
		data = Pandas.read_csv.call(
			dataPath,
			sep => "\t",
			parse_dates => [0],
			header => 0
		);
		Sys.println("number of records: " + len(data.index));
	}

	/**
		Load un-processed data file in tsv format, and cleanup the data by:
		 1. removing duplicated records
		 2. removing personal data
		 3. removing invalid records.
		It will also save the processed data as *_processed.tsv.
	*/
	public function loadRaw(dataPath:String):Void {
		// http://stackoverflow.com/questions/10993612/python-removing-xa0-from-string
		sys.io.File.saveContent(dataPath, sys.io.File.getContent(dataPath).replace(chr(160), " "));

		data = Pandas.read_csv.call(
			dataPath,
			sep => "\t",
			parse_dates => [0],
			header => 0,
			names => colNames
		);

		Sys.println("number of records: " + len(data.index));

		/*
			Remove duplicated records. They can be caused by submitting the Google Form multiple times.
		*/

		// Label the rows that email is duplicated as true (keep the last apperance as false).
		// Ignore the entries with blank emails.
		var duped:Series = untyped data.duplicated.call(
			subset => k_email,
			keep => "last"
		) & data.get(k_email).notnull();

		// Only retain the non-duplicated ones.
		data = data.get(untyped ~duped);

		Sys.println("number of records (deduplicated): " + len(data.index));

		/*
			Remove responses those are not interested in or don't know haxe.
		*/

		data = data.get(untyped
			~(
				(data.get(k_exp) == values[k_exp][v_uninterested][0]) |
				(data.get(k_exp) == values[k_exp][v_no_idea][0])
			)
		);

		Sys.println("number of records (valid): " + len(data.index));

		// Remove columns that may contain personal data.
		data.drop.call(labels=>privateCols, inplace=>true, axis=>1);

		/*
			Rename values to their short forms.
			And create extra columns for multiple selection values.
		*/
		renameValues();

		addExtraCols();

		/*
			Save it.
		*/
		var out_path = haxe.io.Path.withoutExtension(dataPath) + "_processed.tsv";
		data.to_csv.call(path_or_buf => out_path, sep => "\t", index=>false);
	}

	function addExtraCols():Void {
		for (col in SurveyInfo.multiSelectionCols) {
			var values = [for (v in values[col].keys()) v];
			if (allowOthersCols.indexOf(col) >= 0)
				values.push(v_others);
			var count = [for (v in values) data.get(col + "_" + v)]
				.fold(function(a, sum) return a + sum, 0);
			data.__setitem__(col + "_count", count);
		}
	}

	function renameValues():Void {
		for (name in colNames)
		if (values.exists(name))
		{
			var isMC = multiSelectionCols.indexOf(name) >= 0;
			var allowOthers = allowOthersCols.indexOf(name) >= 0;
			var kvalues = [
				for (k in values[name].keys())
				for (v in values[name][k])
				{k:k, v:v}
			];
			kvalues.sort(function(a,b) {
				var d = b.v.length - a.v.length;
				return if (d != 0)
					d;
				else
					Reflect.compare(a.v, b.v);
			});
			for (k in values[name].keys()) {
				Syntax.arraySet(data, name + "_" + k, false);
			}
			if (allowOthers) {
				Syntax.arraySet(data, name + "_" + v_others, false);
			}
			
			for (kv in list((data.get(name):Series).iteritems())) {
				var idx = kv[0];
				var item:String = kv[1];
				var item_s = new Map();
				for (kv in kvalues) {
					var hasValue = item.indexOf(kv.v) >= 0;
					if (hasValue) {
						data.set_value(idx, name + "_" + kv.k, true);
						item_s[kv.k] = kv.k;
						item = item
							.replace(kv.v + ", ", "")
							.replace(kv.v, "");
					}
				}

				var hasOther = item != "";
				if (!allowOthers) {
					if (hasOther) throw item;
				} else {
					if (hasOther) {
						Sys.println('other value: $name $item');
						item_s[v_others] = v_others;
						data.set_value(idx, name + "_" + v_others, true);
					}
				}

				var items = item_s.array();
				items.sort(Reflect.compare);
				data.set_value(idx, name, items.join(","));
			}

			// data.drop.call(labels=>name, inplace=>true, axis=>1);
		}
	}

	/**
		Print help message.
	*/
	public function help():Void {
		Sys.println(showUsage());
		Sys.exit(0);
	}

	static function main():Void {
		new mcli.Dispatch(Sys.args())
			.dispatch(new Main());
	}
}