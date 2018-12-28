--
-- The monolithic default configuration file for the BSD Installer.
--
-- Many of the defaults in here are appropriate to DragonFly BSD,
-- but only because that platform is where the installer is
-- developed, and there is no other "default" for many of these
-- things (except perhaps 4.4BSD-LITE.)
--
-- This file can (and should) be partially overridden by further,
-- operating system- and product-specific configuration files.
--
-- Settings can also be set or overridden from the command line like so:
--    fake_execution=true dir.root=/usr/release/root
--

-------------------------------------------------------------------
-- Application Settings
-------------------------------------------------------------------

--
-- app_name: name of the application.
--

app_name = "BSD Installer"

--
-- log_filename: the file to which logs will be recorded.
-- This exists under dir.tmp.
--

log_filename = "installer.log"

--
-- dir: a table of important directories.
--
-- dir.root is where all commands are assumed to be located, and where
-- all system files are copied from.
--
-- dir.tmp is the temporary directory.
--

dir = {
	root	= "/",
	tmp	= "/tmp/"
}


-------------------------------------------------------------------
-- Installation Parameters
-------------------------------------------------------------------

--
-- os: table which describes the operating system.
-- Required, but no default value is given, so it is necessary
-- that some other configuration file override these entries.

os = {
	name = "FreeBSD",
	version = "11.2"
}


--
-- product: table which describes the product which is being installed;
-- if not given, the product is assumed to be the operating system.
--

product = {
	-- no spaces here, used for disk label
	name = "OPNsense",
	version = "19.1"
}


--
-- Name of the install media in use.  Usually "LiveCD", but could be
-- "CompactFlash card", "install disk", etc.
--
media_name = "LiveCD"


--
-- install_items: description of the set of items that are to be
-- installed.   Each item represents a file or directory to copy,
-- and can be specified with either:
--   o  a string, in which case the source has the same name as the dest, or
--   o  a table, with "src" and "dest" keys, so that the names may differ.
-- (A table is particularly useful with /etc, which may have configuration
-- files which produce significantly different behaviour on the install
-- medium, compared to a standard HDD boot.)
--
-- Either way, no leading root directory is specified in names of files
-- and directories.
--
-- Note that specifying (for example) "usr/local" will only copy all of
-- /usr/local *if* nothing below /usr/local is specified.  For instance,
-- if you want copy all of /usr/local/ *except* for /usr/local/share,
-- you need to specify all subdirs of /usr/local except for /usr/local/share
-- in the table.
--

install_items = {
	".cshrc",
	".profile",
	"COPYRIGHT",
	"bin",
	"boot",
	"boot.config",
	"conf",
	"dev",
	"etc",
	"home",
	"lib",
	"libexec",
	"media",
	"proc",
	"rescue",
	"root",
	"sbin",
	"sys",
	"usr/bin",
	"usr/games",
	"usr/include",
	"usr/lib",
	"usr/lib32",
	"usr/libdata",
	"usr/libexec",
	"usr/local",
	"usr/obj",
	"usr/sbin",
	"usr/share",
	"usr/src",
	"var",
}

--
-- cleanup_items: list of files to remove from the HDD immediately following
-- an installation.  These may be files that are simply unwanted, or may
-- impede the functioning of the system (because they came from the
-- installation system, which may have a different configuration in place.)
--
-- On the DragonFlyBSD LiveCD, for example, /boot/loader.conf contains
--   kernel_options="-C"
-- i.e., boot from CD-ROM.  This is clearly inapplicable to a HDD boot.
--

cleanup_items = { }


--
-- mountpoints: a function which takes two numbers (the capacity
-- of the partition and the capacity of RAM, both in megabytes)
-- and which returns a list of tables, each of which like:
--
-- {
--   mountpoint = "/foo",    -- name of mountpoint
--   capstring  = "123M"     -- suggested capacity
-- }
--
-- Note that the capstring can be "*" to indicate 'use the
-- rest of the partition.')
--
-- Typically this function returns a different list of mountpoint
-- descriptions based on the supported capacity of the device.
--
-- As a somewhat special case, this function may return {}
-- (an empty list) to indicate that there simply is not enough
-- space on the device to install anything at all.
--

mountpoints = function(part_cap, ram_cap)
	-- smaller than 30GB disables swap
	if part_cap < 30720 then
		return {
			{ mountpoint = "/",     capstring = "*" },
		}
	end

	-- calculate the suggested swap size
	local swap = 2 * ram_cap
	if ram_cap > (part_cap / 2) or part_cap < 4096 then
		swap = ram_cap
	end

	-- limit swap partition to 8192
	if swap > 8192 then
		swap = 8192
	end

	swap = tostring(swap) .. "M"

	return {
		{ mountpoint = "/",     capstring = "*" },
		{ mountpoint = "swap",  capstring = swap },
	}
end


--
-- extra_filesystems:
--

extra_filesystems = {
	{
	    desc     = "Process filesystem",
	    dev      = "proc",
	    mtpt     = "/proc",
	    fstype   = "procfs",
	    access   = "rw",
	    selected = "N"
	},
	{
	    desc     = "CD-ROM drive",
	    dev      = "/dev/acd0c",
	    mtpt     = "/cdrom",
	    fstype   = "cd9660",
	    access   = "ro,noauto",
	    selected = "N"
	}
}

--
-- limits: Limiting values specified by the installation; the most
-- significant of these is the minimum disk space required to
-- install the software.
--

limits = {
	part_min =	  "300M",	-- Minimum size of partition or disk.
	subpart_min = {
	    ["/"]	=  "70M",	-- Minimum size of each subpartition.
	    ["/var"]	=   "8M",	-- If a subpartition has no particular
	    ["/usr"]	= "174M"	-- minimum, it can be omitted here.
	},
	waste_max	=   8192	-- Maximum number of sectors to allow
					-- to go to waste when carving out
					-- partitions and subpartitions.
}


--
-- use_cpdup: a boolean which indicates whether the 'cpdup' utility
-- will be used to copy files and directories to the target system.
-- If false, 'tar' and 'cp' will be used instead.
--

use_cpdup = true


-------------------------------------------------------------------
-- User Interface
-------------------------------------------------------------------

--
-- ui_nav_control: a configuration table which allows individual
-- user-interface navigation elements to be configured in broad
-- fashion, globally.
--
-- Extra Flow.Steps and Menu.Items can always be added by adding Lua
-- scriptlets to their container directories; however, it is more awkward to
-- delete existing Steps and Items which may be inapplicable in a particular
-- distribution.  So, this file can be used to globally ignore (or otherwise
-- alter the meaning of) individual Steps and Items.
--
-- This configuration file should return a table.  Each key in this table
-- should be a regular expression which will match the id of the Step or
-- Item; the associated value is a control code which indicates what do
-- with all Steps and Items so matched.
--
-- The only supported control code, at present, is "ignore", indicating
-- that the Step or Item should be skipped; this is, not be executed as
-- part of the Flow, or not be displayed as part of the menu.
--
-- NOTE!  Ignoring Flow.Steps properly is more problematic than ignoring
-- Menu.Items, because Steps often rely on a change of state caused by a
-- previous Step.  Configure this table (and write your own Steps) with
-- that fact in mind.
--

ui_nav_control = {
	["*/configure_installed_system"] = "ignore",
	["*/pit/configure_console"] = "ignore",
	["*/configure/*"] = "ignore"
}


-------------------------------------------------------------------
-- System Settings
-------------------------------------------------------------------

--
-- cmd_names: names and locations of system commands used by the installer.
--
-- Note that some non-command files and directories are configurable
-- here too.
--
-- The main table lists commands apropos for for DragonFly BSD.
-- Conditional overrides for other BSD's are listed below it.
--

cmd_names = {
	CAT		= "bin/cat",
	CHMOD		= "bin/chmod",
	CP		= "bin/cp",
	DATE		= "bin/date",
	DD		= "bin/dd",
	ECHO		= "bin/echo",
	LN		= "bin/ln",
	MKDIR		= "bin/mkdir",
	MV		= "bin/mv",
	RM		= "bin/rm",
	SH		= "bin/sh",
	SYNC		= "bin/sync",
	TEST		= "bin/test",
	TEST_DEV	= "bin/test -c",

	DISKLABEL	= "sbin/bsdlabel",
	DUMPON		= "sbin/dumpon",
	FDISK		= "sbin/fdisk",
	GPART		= "sbin/gpart",
	IFCONFIG	= "sbin/ifconfig",
	KLDLOAD		= "sbin/kldload",
	KLDSTAT		= "sbin/kldstat",
	KLDUNLOAD	= "sbin/kldunload",
	MBRLABEL	= "sbin/mbrlabel",
	MOUNT		= "sbin/mount -o async",
	MOUNT_DEVFS	= "sbin/mount -t devfs devfs",
	MOUNT_MFS	= "sbin/mount_mfs",
	NEWFS		= "sbin/newfs",
	NEWFS_MSDOS	= "sbin/newfs_msdos",
	ROUTE		= "sbin/route",
	SWAPOFF		= "sbin/swapoff",
	SWAPON		= "sbin/swapon",
	SYSCTL		= "sbin/sysctl",
	TUNEFS		= "sbin/tunefs",
	UMOUNT		= "sbin/umount",
	ZPOOL		= "sbin/zpool",

	AWK		= "usr/bin/awk",
	BASENAME	= "usr/bin/basename",
	BC		= "usr/bin/bc",
	BUNZIP2		= "usr/bin/bunzip2",
	CHFLAGS		= "usr/bin/chflags",
	COMM		= "usr/bin/comm",
	FIND		= "usr/bin/find",
	GREP		= "usr/bin/grep",
	KILLALL		= "usr/bin/killall",
	MAKE		= "usr/bin/make",
	SED		= "usr/bin/sed",
	SORT		= "usr/bin/sort",
	TAR		= "usr/bin/tar",
	TOUCH		= "usr/bin/touch",
	TR		= "usr/bin/tr",
	XARGS		= "usr/bin/xargs",
	YES		= "usr/bin/yes",

	BOOT0CFG	= "usr/sbin/boot0cfg",
	CHROOT		= "usr/sbin/chroot",
	FDFORMAT	= "usr/sbin/fdformat",
	INETD		= "usr/sbin/inetd",
	KBDCONTROL	= "usr/sbin/kbdcontrol",
	MOUNTD		= "usr/sbin/mountd",
	MTREE		= "usr/sbin/mtree",
	NFSD		= "usr/sbin/nfsd",
	PW		= "usr/sbin/pw",
	PWD_MKDB	= "usr/sbin/pwd_mkdb",
	RPCBIND		= "usr/sbin/rpcbind",
	SWAPINFO	= "usr/sbin/pstat -s",
	VIDCONTROL	= "usr/sbin/vidcontrol",

	TFTPD		= "usr/libexec/tftpd",

	CPDUP		= "usr/local/bin/cpdup",
	OPNSENSE_IMPORTER = "usr/local/sbin/opnsense-importer",
	OPNSENSE_SHELL	= "usr/local/sbin/opnsense-shell",

	-- These aren't commands, but they're configurable here nonetheless.

	DMESG_BOOT	= "var/run/dmesg.boot",
	SYSCTL_DISKS	= "kern.disks"
}

--
-- mount_info_regexp: A Lua regular expression which describes
-- what the output of the 'mount' command looks like, so that
-- it can be parsed to extract mountpoint and filesystem info.
--

mount_info_regexp = "^([^%s]+)%s+on%s+([^%s]+)%s+%(([^%s]+)"


-------------------------------------------------------------------
-- Static Storage Parameters
-------------------------------------------------------------------

--
-- sysids: Partition identifiers that can be used in the partition
-- editor, and their names.  The order they are listed here are the
-- order they will appear in the partition editor.
--
sysids = {
	{ "FreeBSD",		165 },
	{ "OpenBSD",		166 },
	{ "NetBSD",		169 },
	{ "MS-DOS",		 15 },
	{ "Linux",		131 },
	{ "Plan9",		 57 }
}

--
-- default_sysid: the partition identifier to use by default.
--

default_sysid = 165

--
-- has_raw_devices: true if the platform has "raw" devices whose
-- names begin with "r".
--

has_raw_devices = false

--
-- disklabel_on_disk: true if there is only one disklabel per
-- disk (OpenBSD and NetBSD), false if there is more than one, i.e.
-- one disklabel per BIOS partition (FreeBSD and DragonFly BSD.)
--
-- disklabel_on_disk also implies there are no device nodes for
-- BIOS partitions.
--

disklabel_on_disk = false

--
-- num_subpartitions: number of subpartitions supported per disklabel.
--

num_subpartitions = 8

--
-- offlimits_devices: devices which the installer should not
-- consider installing onto.
-- These are actually Lua regexps.
--

offlimits_devices = { "fd%d+", "md%d+", "cd%d+" }

--
-- window_subpartitions: a list of which subpartitions (BSD partitions)
-- are typically not used for housing filesystems, but rather for
-- representing an entire disk or (BIOS) partition - acting, as it were,
-- as a "window" onto a larger overlapping region of storage.
--

window_subpartitions = { "c" }

-------------------------------------------------------------------
-- Debugging
-------------------------------------------------------------------

--
-- fake_execution: if true, don't actually execute anything.
--

fake_execution = false

--
-- confirm_execution: if true, ask before executing every little thing.
--

confirm_execution = false

--
-- fatal_errors: if true, errors always cause the application to abort.
--

fatal_errors = false

--
-- Offlimits mount points.  BSDInstaller will ignore these mount points
--
-- example: offlimits_mounts  = { "unionfs" }

offlimits_mounts = { }
