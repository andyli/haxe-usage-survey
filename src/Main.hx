import python.*;
import python.lib.Builtins.*;
import python.lib.Codecs.encode;
import pandas.*;
import pandas.Pandas_Module as Pandas;
using PyHelpers;
using python.Lib;
using Lambda;
using StringTools;
using Reflect;

class Main extends mcli.CommandLine {
	var data:DataFrame;

	function analyse():Void {
	}

	/**
		Load data file in tsv format.
	*/
	public function load(dataPath:String):Void {
		data = Pandas.read_csv.call(
			dataPath,
			sep => "\t",
			parse_dates => [0],
			header => 0,
			names => colNames.slice(0, -2)
		);
		Sys.println("number of records: " + len(data.index));

		// Sys.println(data.head(1));
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
			subset => "email",
			keep => "last"
		) & data.get("email").notnull();

		// Only retain the non-duplicated ones.
		data = data.get(untyped ~duped);

		Sys.println("number of records (deduplicated): " + len(data.index));

		/*
			Remove responses those are not interested in or don't know haxe.
		*/

		data = data.get(untyped
			~(
				(data.get("exp") == values["exp"]["uninterested"]) |
				(data.get("exp") == values["exp"]["no_idea"])
			)
		);

		Sys.println("number of records (valid): " + len(data.index));

		// Remove columns that may contain personal data.
		data.drop.call(labels=>["email", "comment"], inplace=>true, axis=>1);

		/*
			List "others" values.
		*/
		listOthers();

		/*
			Save it.
		*/
		var out_path = haxe.io.Path.withoutExtension(dataPath) + "_processed.tsv";
		data.to_csv.call(path_or_buf => out_path, sep => "\t", index=>false);
	}

	function listOthers():Void {
		for (name in colNames.slice(1, -2)) {
			for (item in (data.get(name):Series)) {
				var item:String = item;
				var values = Lambda.array(values[name]);
				values.sort(function(a,b) return b.length - a.length);
				for (value in values) {
					item = item
						.replace(value + ", ", "")
						.replace(value, "");
				}
				if (values_other.exists(name))
				for (values in values_other[name])
				for (value in values) {
					item = item
						.replace(value + ", ", "")
						.replace(value, "");
				}
				if (item != "")
					Sys.println('other value: $name $item');
			}
		}
	}

	static public var colNames(default, never) = [
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

	static public var values_other(default, never) = [
		"what" => [
			"lib" => ["JS modules (to be integrated in existing js ecosystem)"]
		],
		"install_haxe" => [
			"thirdparty" => ["Use this one:https://github.com/jasononeil/OneLineHaxe", "Stencyl", "Hvm"],
			"linux_package" => ["Arch Linux AUR"],
			"binary_archive" => ["on linux by hand from compiled haxe/neko archuves", "nightly binaries", "linux binary packages / nightly builds", "nightly builds", "download a ZIP"],
		],
		"install_pref" => [
			"package" => ["npm", "brew", "Using official package manager to install official package"]
		],
		"os_linux" => [
			"mint"       => ["Mint mate version", "Linux Mint", "Mint 17", "Mint", "mint"],
			"elementary" => ["elementary OS"],
		],
		"os_mobile" => [
			"blackberry" => ["Blackberry OS7", "Blackberry"],
		]
	];

	static public var values(default, never) = [
		"exp" => [
			"pro_main"     => "Haxe is one of the main tools I used for professional works.",
			"pro_occ"      => "I use Haxe occasionally for professional works.",
			"use"          => "I use Haxe but I'm not paid for that.",
			"interested"   => "I do not use Haxe but I'm interested in using it.",
			"uninterested" => "I do not use and I am not interested in using Haxe.",
			"no_idea"      => "I do not know what is Haxe.",
		],
		"what" => [
			"game"        => "Games",
			"web_front"   => "Web sites (front end)",
			"web_back"    => "Web sites (back end)",
			"app_desktop" => "Desktop applications",
			"app_mobile"  => "Mobile applications",
			"lib"         => "Software libraries / frameworks",
			"hardware"    => "Hardware stuffs",
			"art"         => "Art",
			"not_sure"    => "I'm not sure yet.",
		],
		"version" => [
			"3.2"      => "3.2.*",
			"3.1"      => "3.1.*",
			"3.0"      => "3.0.*",
			"2"        => "2.*",
			"git"      => "Git development build",
			"not_sure" => "I'm not sure.",
		],
		"target" => [
			"swf"    => "Flash (SWF)",
			"as3"    => "AS3 (source code)",
			"cpp"    => "C++",
			"java"   => "Java",
			"cs"     => "C#",
			"js"     => "JS",
			"php"    => "PHP",
			"python" => "Python",
			"neko"   => "Neko",
			"interp" => "compiler interpeter (--interp / --run)",
		],
		"install_haxe" => [
			"preinstall"    => "It was pre-installed (e.g. on a customised VM / container image, or by IT staff of your company).",
			"official"      => "Using the official installer provided in haxe.org / build.haxe.org.",
			"thirdparty"    => "Using 3rd party installer / script (e.g. the OpenFL Linux install script, or the FlashDevelop Haxe management tool).",
			"brew"          => "Homebrew",
			"linux_package" => "Apt-get (including the use of PPA), yum, dnf, or any other Linux / BSD package manager.",
			"choco"         => "Chocolatey",
			"source"        => "Building from source.",
			"not_sure"      => "Cannot remember...",
		],
		"install_pref" => [
			"preinstall" => "It is pre-installed (e.g. on a customised VM / container image, or by IT support of your company).",
			"official"   => "Using the official installer.",
			"package"    => "Using a package manager (apt-get, homebrew, etc.).",
			"source"     => "Building from source.",
		],
		"os_win" => [
			"no_win" => "I do not use Windows for Haxe development.",
			"win10"  => "Windows 10",
			"win8"   => "Windows 8 / 8.1",
			"win7"   => "Windows 7",
			"winxp"  => "Windows XP",
		],
		"os_mac" => [
			"no_mac"  => "I do not use Mac for Haxe development.",
			"mac1011" => 'OSX 10.11: "El Capitan"',
			"mac1010" => 'OSX 10.10: "Yosemite"',
			"mac1009" => 'OSX 10.9: "Mavericks"',
			"mac1008" => 'OSX 10.8: "Mountain Lion"',
		],
		"os_linux" => [
			"no_linux"   => "I do not use Linux / BSD for Haxe development.",
			"ubuntu"     => "Ubuntu",
			"debian"     => "Debian",
			"fedora"     => "Fedora",
			"opensuse"   => "openSUSE",
			"gentoo"     => "Gentoo",
			"mandriva"   => "Mandriva",
			"redhat"     => "Red Hat",
			"oracle"     => "Oracle",
			"solaris"    => "Solaris",
			"turbolinux" => "Turbolinux",
			"arch"       => "Arch Linux",
			"freebsd"    => "FreeBSD",
			"openbsd"    => "OpenBSD",
			"netbsd"     => "NetBSD",
		],
		"os_mobile" => [
			"no_mobile" => "I do not use mobile for Haxe development.",
			"android"   => "Android",
			"ios"       => "iOS",
			"windows"   => "Windows",
			"firefox"   => "Firefox OS",
			"tizen"     => "Tizen",
		],
	];

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