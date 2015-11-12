@:enum abstract ColName(String) to String {
	var k_time = "time";                  // Timestamp
	var k_exp = "exp";                    // Do you use Haxe?
	var k_create = "create";              // What are you creating, or want to use Haxe to create?
	var k_version = "version";            // Which version(s) of Haxe are you using, or want to use / test?
	var k_target = "target";              // Which Haxe targets are you using, or want to use / test?
	var k_install_haxe = "install_haxe";  // How did you obtain Haxe?
	var k_install_pref = "install_pref";  // Which is your preferred way to obtain development software (not necessarily Haxe)?
	var k_os_win = "os_win";              // Which Windows version(s) do you use, or want to use, for Haxe development?
	var k_os_mac = "os_mac";              // Which Mac version(s) do you use, or want to use, for Haxe development?
	var k_os_linux = "os_linux";          // Which Linux / BSD distros(s) do you use, or want to use, for Haxe development?
	var k_os_mobile = "os_mobile";        // Which mobile OS(es) do you use, or want to use, for Haxe development?
	var k_comment = "comment";            // Anything else you want to tell me?
	var k_email = "email";                // If you want to be notified when the survey result is ready, give me an email address
}

@:enum abstract Value(String) to String {
	var v_pro_main = "pro_main";
	var v_pro_occ = "pro_occ";
	var v_use = "use";
	var v_interested = "interested";
	var v_uninterested = "uninterested";
	var v_no_idea = "no_idea";
	var v_game = "game";
	var v_web_front = "web_front";
	var v_web_back = "web_back";
	var v_app_desktop = "app_desktop";
	var v_app_mobile = "app_mobile";
	var v_lib = "lib";
	var v_hardware = "hardware";
	var v_art = "art";
	var v_not_sure = "not_sure";
	var v_v3_2 = "v3_2";
	var v_v3_1 = "v3_1";
	var v_v3_0 = "v3_0";
	var v_v2 = "v2";
	var v_git = "git";
	var v_swf = "swf";
	var v_as3 = "as3";
	var v_cpp = "cpp";
	var v_java = "java";
	var v_cs = "cs";
	var v_js = "js";
	var v_php = "php";
	var v_python = "python";
	var v_neko = "neko";
	var v_interp = "interp";
	var v_preinstall = "preinstall";
	var v_official = "official";
	var v_thirdparty = "thirdparty";
	var v_brew = "brew";
	var v_linux_package = "linux_package";
	var v_choco = "choco";
	var v_source = "source";
	var v_package = "package";
	var v_no_win = "no_win";
	var v_win10 = "win10";
	var v_win8 = "win8";
	var v_win7 = "win7";
	var v_winxp = "winxp";
	var v_no_mac = "no_mac";
	var v_mac1011 = "mac1011";
	var v_mac1010 = "mac1010";
	var v_mac1009 = "mac1009";
	var v_mac1008 = "mac1008";
	var v_no_linux = "no_linux";
	var v_ubuntu = "ubuntu";
	var v_debian = "debian";
	var v_fedora = "fedora";
	var v_opensuse = "opensuse";
	var v_gentoo = "gentoo";
	var v_mandriva = "mandriva";
	var v_redhat = "redhat";
	var v_oracle = "oracle";
	var v_solaris = "solaris";
	var v_turbolinux = "turbolinux";
	var v_arch = "arch";
	var v_freebsd = "freebsd";
	var v_openbsd = "openbsd";
	var v_netbsd = "netbsd";
	var v_no_mobile = "no_mobile";
	var v_android = "android";
	var v_ios = "ios";
	var v_windows = "windows";
	var v_firefox = "firefox";
	var v_tizen = "tizen";
	var v_mint = "mint";
	var v_elementary = "elementary";
	var v_blackberry = "blackberry";
	var v_others = "others";
}

class SurveyInfo {
	static public var colNames(default, never) = [
		k_time,
		k_exp,
		k_create,
		k_version,
		k_target,
		k_install_haxe,
		k_install_pref,
		k_os_win,
		k_os_mac,
		k_os_linux,
		k_os_mobile,
		k_comment,
		k_email,
	];
	static public var colQuestions(default, never) = [
		k_time =>          "Timestamp",
		k_exp =>           "Do you use Haxe?",
		k_create =>        "What are you creating, or want to use Haxe to create?",
		k_version =>       "Which version(s) of Haxe are you using, or want to use / test?",
		k_target =>        "Which Haxe targets are you using, or want to use / test?",
		k_install_haxe =>  "How did you obtain Haxe?",
		k_install_pref =>  "Which is your preferred way to obtain development software (not necessarily Haxe)?",
		k_os_win =>        "Which Windows version(s) do you use, or want to use, for Haxe development?",
		k_os_mac =>        "Which Mac version(s) do you use, or want to use, for Haxe development?",
		k_os_linux =>      "Which Linux / BSD distros(s) do you use, or want to use, for Haxe development?",
		k_os_mobile =>     "Which mobile OS(es) do you use, or want to use, for Haxe development?",
		k_comment =>       "Anything else you want to tell me?",
		k_email =>         "If you want to be notified when the survey result is ready, give me an email address",
	];

	static public var privateCols(default, never) = [k_comment, k_email];
	static public var multiSelectionCols(default, never) = [
		k_create, k_version, k_target, k_install_haxe, k_install_pref,
		k_os_win, k_os_mac, k_os_linux, k_os_mobile
	];
	static public var allowOthersCols(default, never) = [
		k_create, k_install_haxe, k_install_pref,
		k_os_win, k_os_mac, k_os_linux, k_os_mobile
	];

	static public var keys(default, never) = [
		k_exp => [v_pro_main, v_pro_occ, v_use, v_interested],
		k_create => [v_game, v_web_front, v_web_back, v_app_desktop, v_app_mobile, v_lib, v_hardware, v_art, v_not_sure, v_others],
		k_target => [v_cpp, v_js, v_python, v_swf, v_as3, v_neko, v_java, v_cs, v_php, v_interp],
		k_version => [v_v3_2, v_v3_1, v_v3_0, v_v2, v_git, v_not_sure],
		k_install_haxe => [v_preinstall, v_official, v_thirdparty, v_brew, v_linux_package, v_choco, v_source, v_not_sure, v_others],
		k_install_pref => [v_preinstall, v_official, v_package, v_source, v_others],
		k_os_win => [v_no_win, v_win10, v_win8, v_win7, v_winxp, v_others],
		k_os_mac => [v_no_mac, v_mac1011, v_mac1010, v_mac1009, v_mac1008, v_others],
		k_os_linux => [
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
		],
		k_os_mobile => [v_no_mobile, v_android, v_ios, v_windows, v_firefox, v_tizen, v_blackberry, v_others],
	];
	static public var values(default, never) = [
		k_exp => [
			v_pro_main     => ["Haxe is one of the main tools I used for professional works."],
			v_pro_occ      => ["I use Haxe occasionally for professional works."],
			v_use          => ["I use Haxe but I'm not paid for that."],
			v_interested   => ["I do not use Haxe but I'm interested in using it."],
			v_uninterested => ["I do not use and I am not interested in using Haxe."],
			v_no_idea      => ["I do not know what is Haxe."],
		],
		k_create => [
			v_game        => ["Games"],
			v_web_front   => ["Web sites (front end)"],
			v_web_back    => ["Web sites (back end)"],
			v_app_desktop => ["Desktop applications"],
			v_app_mobile  => ["Mobile applications"],
			v_lib         => ["Software libraries / frameworks", "JS modules (to be integrated in existing js ecosystem)"],
			v_hardware    => ["Hardware stuffs"],
			v_art         => ["Art"],
			v_not_sure    => ["I'm not sure yet."],
		],
		k_version => [
			v_v3_2      => ["3.2.*"],
			v_v3_1      => ["3.1.*"],
			v_v3_0      => ["3.0.*"],
			v_v2        => ["2.*"],
			v_git       => ["Git development build"],
			v_not_sure  => ["I'm not sure."],
		],
		k_target => [
			v_swf    => ["Flash (SWF)"],
			v_as3    => ["AS3 (source code)"],
			v_cpp    => ["C++"],
			v_java   => ["Java"],
			v_cs     => ["C#"],
			v_js     => ["JS"],
			v_php    => ["PHP"],
			v_python => ["Python"],
			v_neko   => ["Neko"],
			v_interp => ["compiler interpeter (--interp / --run)"],
		],
		k_install_haxe => [
			v_preinstall     => ["It was pre-installed (e.g. on a customised VM / container image, or by IT staff of your company)."],
			v_official       => ["Using the official installer provided in haxe.org / build.haxe.org."],
			v_thirdparty     => ["Using 3rd party installer / script (e.g. the OpenFL Linux install script, or the FlashDevelop Haxe management tool).", "Use this one:https://github.com/jasononeil/OneLineHaxe", "Stencyl", "Hvm"],
			v_brew           => ["Homebrew"],
			v_linux_package  => ["Apt-get (including the use of PPA), yum, dnf, or any other Linux / BSD package manager.", "Arch Linux AUR"],
			v_choco          => ["Chocolatey"],
			v_source         => ["Building from source."],
			v_not_sure       => ["Cannot remember..."],
		],
		k_install_pref => [
			v_preinstall => ["It is pre-installed (e.g. on a customised VM / container image, or by IT support of your company)."],
			v_official   => ["Using the official installer."],
			v_package    => ["Using a package manager (apt-get, homebrew, etc.).", "npm", "brew", "Using official package manager to install official package"],
			v_source     => ["Building from source."],
		],
		k_os_win => [
			v_no_win => ["I do not use Windows for Haxe development."],
			v_win10  => ["Windows 10"],
			v_win8   => ["Windows 8 / 8.1"],
			v_win7   => ["Windows 7"],
			v_winxp  => ["Windows XP"],
		],
		k_os_mac => [
			v_no_mac  => ["I do not use Mac for Haxe development."],
			v_mac1011 => ['OSX 10.11: "El Capitan"'],
			v_mac1010 => ['OSX 10.10: "Yosemite"'],
			v_mac1009 => ['OSX 10.9: "Mavericks"'],
			v_mac1008 => ['OSX 10.8: "Mountain Lion"'],
		],
		k_os_linux => [
			v_no_linux   => ["I do not use Linux / BSD for Haxe development."],
			v_ubuntu     => ["Ubuntu"],
			v_debian     => ["Debian"],
			v_fedora     => ["Fedora"],
			v_opensuse   => ["openSUSE"],
			v_gentoo     => ["Gentoo"],
			v_mandriva   => ["Mandriva"],
			v_redhat     => ["Red Hat"],
			v_oracle     => ["Oracle"],
			v_solaris    => ["Solaris"],
			v_turbolinux => ["Turbolinux"],
			v_arch       => ["Arch Linux"],
			v_freebsd    => ["FreeBSD"],
			v_openbsd    => ["OpenBSD"],
			v_netbsd     => ["NetBSD"],
			v_mint       => ["Mint mate version", "Linux Mint", "Mint 17", "Mint", "mint"],
			v_elementary => ["elementary OS"],
		],
		k_os_mobile => [
			v_no_mobile => ["I do not use mobile for Haxe development."],
			v_android   => ["Android"],
			v_ios       => ["iOS"],
			v_windows   => ["Windows"],
			v_firefox   => ["Firefox OS"],
			v_tizen     => ["Tizen"],
			v_blackberry => ["Blackberry OS7", "Blackberry"],
		],
	];
}