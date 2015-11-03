import python.*;
import python.lib.Builtins.*;
import python.lib.Codecs.encode;
import pandas.*;
import pandas.Pandas_Module as Pandas;
using PyHelpers;
using python.Lib;
using Lambda;
using StringTools;

class Main {
	var data:DataFrame;
	function new():Void {}

	function analyse():Void {
	}

	function load(dataPath:String):Void {
		data = Pandas.read_csv.call(
			dataPath,
			sep => "\t",
			parse_dates => [0],
			header => 0,
			names => colNames.slice(0, -2)
		);
		Sys.println("number of records: " + len(data.index));

		trace(data.head());
	}

	function loadRaw(dataPath:String):Void {
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
			subset => "email",
			keep => "last"
		) & data.get("email").notnull();

		// Only retain the non-duplicated ones.
		data = data.get(duped.__neg__());

		Sys.println("number of records (deduplicated): " + len(data.index));

		// Remove columns that may contain personal data.
		data.drop.call(labels=>["email", "comment"], inplace=>true, axis=>1);

		var out_path = haxe.io.Path.withoutExtension(dataPath) + "_processed.tsv";
		data.to_csv.call(path_or_buf => out_path, sep => "\t", index=>false);
	}

	static var colNames(default, never) = [
		"time",          // Timestamp
		"exp",           // Do you use Haxe?
		"what",          // What are you creating, or want to use Haxe to create?
		"version",       // Which version(s) of Haxe are you using, or want to use / test?
		"target",        // Which Haxe targets are you using, or want to use / test?
		"install_haxe",  // How did you obtain Haxe?
		"install_pref",  // Which is your preferred way to obtain development software (not necessarily Haxe)?
		"os_win",        // Which Windows version(s) do you use, or want to use, for Haxe development?
		"os_mac",        // Which Mac version(s) do you use, or want to use, for Haxe development?
		"os_linux",      // Which Linux / BSD distros(s) do you use, or want to use, for Haxe development?
		"os_mobile",     // Which mobile OS(es) do you use, or want to use, for Haxe development?
		"comment",       // Anything else you want to tell me?
		"email",         // If you want to be notified when the survey result is ready, give me an email address
	];

	static function main():Void {
		var main = new Main();
		// main.loadRaw(Sys.args()[0]);
		main.load(Sys.args()[0]);
		main.analyse();
	}
}