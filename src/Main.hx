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

		trace(data.head());
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
				(data.get("exp") == values["exp"]["_uninterested_"]) |
				(data.get("exp") == values["exp"]["_no_idea_"])
			)
		);

		Sys.println("number of records (valid): " + len(data.index));

		// Remove columns that may contain personal data.
		data.drop.call(labels=>["email", "comment"], inplace=>true, axis=>1);

		/*
			Rename values to their short forms.
		*/
		renameValues();

		/*
			Save it.
		*/
		var out_path = haxe.io.Path.withoutExtension(dataPath) + "_processed.tsv";
		data.to_csv.call(path_or_buf => out_path, sep => "\t", index=>false);
	}

	function renameValues():Void {
		for (name in colNames.slice(1, -2)) {
			for (kv in list((data.get(name):Series).iteritems())) {
				var idx = kv[0];
				var item:String = kv[1];
				var item_s = new Map<String,String>();
				var kvalues = [for (k in values[name].keys()) {k:k, v:values[name][k]}];
				kvalues.sort(function(a,b) return b.v.length - a.v.length);
				for (kv in kvalues) {
					var value = kv.v;
					if (item.indexOf(value) >= 0) {
						item_s[kv.k] = kv.k;
						item = item
							.replace(value + ", ", "")
							.replace(value, "");
					}
				}
				if (values_other.exists(name)) {
					var kvalues = [for (k in values_other[name].keys()) {k:k, v:values_other[name][k]}];
					for (kv in kvalues)
					for (value in kv.v)
					if (item.indexOf(value) >= 0) {
						item_s[kv.k] = kv.k;
						item = item
							.replace(value + ", ", "")
							.replace(value, "");
					}
				}
				if (item != "") {
					Sys.println('other value: $name $item');
					item_s["others"] = "others";
				}

				data.set_value(idx, name, item_s.array().join(","));
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
			"_lib_" => ["JS modules (to be integrated in existing js ecosystem)"]
		],
		"install_haxe" => [
			"_thirdparty_" => ["Use this one:https://github.com/jasononeil/OneLineHaxe", "Stencyl", "Hvm"],
			"_linux_package_" => ["Arch Linux AUR"],
			"_binary_archive_" => ["on linux by hand from compiled haxe/neko archuves", "nightly binaries", "linux binary packages / nightly builds", "nightly builds", "download a ZIP"],
		],
		"install_pref" => [
			"_package_" => ["npm", "brew", "Using official package manager to install official package"]
		],
		"os_linux" => [
			"_mint_"       => ["Mint mate version", "Linux Mint", "Mint 17", "Mint", "mint"],
			"_elementary_" => ["elementary OS"],
		],
		"os_mobile" => [
			"_blackberry_" => ["Blackberry OS7", "Blackberry"],
		]
	];

	static public var values(default, never) = [
		"exp" => [
			"_pro_main_"     => "Haxe is one of the main tools I used for professional works.",
			"_pro_occ_"      => "I use Haxe occasionally for professional works.",
			"_use_"          => "I use Haxe but I'm not paid for that.",
			"_interested_"   => "I do not use Haxe but I'm interested in using it.",
			"_uninterested_" => "I do not use and I am not interested in using Haxe.",
			"_no_idea_"      => "I do not know what is Haxe.",
		],
		"what" => [
			"_game_"        => "Games",
			"_web_front_"   => "Web sites (front end)",
			"_web_back_"    => "Web sites (back end)",
			"_app_desktop_" => "Desktop applications",
			"_app_mobile_"  => "Mobile applications",
			"_lib_"         => "Software libraries / frameworks",
			"_hardware_"    => "Hardware stuffs",
			"_art_"         => "Art",
			"_not_sure_"    => "I'm not sure yet.",
		],
		"version" => [
			"_v3_2_"      => "3.2.*",
			"_v3_1_"      => "3.1.*",
			"_v3_0_"      => "3.0.*",
			"_v2_"        => "2.*",
			"_git_"       => "Git development build",
			"_not_sure_"  => "I'm not sure.",
		],
		"target" => [
			"_swf_"    => "Flash (SWF)",
			"_as3_"    => "AS3 (source code)",
			"_cpp_"    => "C++",
			"_java_"   => "Java",
			"_cs_"     => "C#",
			"_js_"     => "JS",
			"_php_"    => "PHP",
			"_python_" => "Python",
			"_neko_"   => "Neko",
			"_interp_" => "compiler interpeter (--interp / --run)",
		],
		"install_haxe" => [
			"_preinstall_"    => "It was pre-installed (e.g. on a customised VM / container image, or by IT staff of your company).",
			"_official_"      => "Using the official installer provided in haxe.org / build.haxe.org.",
			"_thirdparty_"    => "Using 3rd party installer / script (e.g. the OpenFL Linux install script, or the FlashDevelop Haxe management tool).",
			"_brew_"          => "Homebrew",
			"_linux_package_" => "Apt-get (including the use of PPA), yum, dnf, or any other Linux / BSD package manager.",
			"_choco_"         => "Chocolatey",
			"_source_"        => "Building from source.",
			"_not_sure_"      => "Cannot remember...",
		],
		"install_pref" => [
			"_preinstall_" => "It is pre-installed (e.g. on a customised VM / container image, or by IT support of your company).",
			"_official_"   => "Using the official installer.",
			"_package_"    => "Using a package manager (apt-get, homebrew, etc.).",
			"_source_"     => "Building from source.",
		],
		"os_win" => [
			"_no_win_" => "I do not use Windows for Haxe development.",
			"_win10_"  => "Windows 10",
			"_win8_"   => "Windows 8 / 8.1",
			"_win7_"   => "Windows 7",
			"_winxp_"  => "Windows XP",
		],
		"os_mac" => [
			"_no_mac_"  => "I do not use Mac for Haxe development.",
			"_mac1011_" => 'OSX 10.11: "El Capitan"',
			"_mac1010_" => 'OSX 10.10: "Yosemite"',
			"_mac1009_" => 'OSX 10.9: "Mavericks"',
			"_mac1008_" => 'OSX 10.8: "Mountain Lion"',
		],
		"os_linux" => [
			"_no_linux_"   => "I do not use Linux / BSD for Haxe development.",
			"_ubuntu_"     => "Ubuntu",
			"_debian_"     => "Debian",
			"_fedora_"     => "Fedora",
			"_opensuse_"   => "openSUSE",
			"_gentoo_"     => "Gentoo",
			"_mandriva_"   => "Mandriva",
			"_redhat_"     => "Red Hat",
			"_oracle_"     => "Oracle",
			"_solaris_"    => "Solaris",
			"_turbolinux_" => "Turbolinux",
			"_arch_"       => "Arch Linux",
			"_freebsd_"    => "FreeBSD",
			"_openbsd_"    => "OpenBSD",
			"_netbsd_"     => "NetBSD",
		],
		"os_mobile" => [
			"_no_mobile_" => "I do not use mobile for Haxe development.",
			"_android_"   => "Android",
			"_ios_"       => "iOS",
			"_windows_"   => "Windows",
			"_firefox_"   => "Firefox OS",
			"_tizen_"     => "Tizen",
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