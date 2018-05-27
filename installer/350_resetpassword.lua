--
-- Copyright (c) 2009 Scott Ullrich <sullrich@gmail.com>
-- Copyright (c) 2014-2017 Franco Fichtner <franco@opnsense.org>
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
-- 1. Redistributions of source code must retain the above copyright
--    notices, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notices, this list of conditions, and the following disclaimer in
--    the documentation and/or other materials provided with the
--    distribution.
-- 3. Neither the names of the copyright holders nor the names of their
--    contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
-- FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
-- COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
-- BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

local POSIX = require("posix")

return {
	id = "reset_password",
	name = _("Reset password"),
	req_state = { "configure" },
	short_desc = _("Reset the password on the hard disk"),
	effect = function()
	local dd = StorageUI.select_disk({
		sd = App.state.storage,
		short_desc = _(
			"This tool will help you reset the root password of " ..
			"a previous hard disk installation. Please select a disk:"),
		cancel_desc = _("Cancel")
	})

	-- Maybe abort was selected
	if not dd then
		return Menu.CONTINUE
	end

	local disk1 = dd:get_name()

	-- Make sure source disk containing config.xml is selected
	if not disk1 then
		return Menu.CONTINUE
	end

	-- make sure that we have partition we reference after
	local part1
	if POSIX.stat("/dev/" .. disk1 .."s1a", "type") ~= nil then
		-- MBR layout found
		part1 = "/dev/" .. disk1 .."s1a"
	elseif POSIX.stat("/dev/" .. disk1 .."p3", "type") ~= nil then
		-- GPT layout found
		part1 = "/dev/" .. disk1 .."p3"
	else
		App.ui:inform(_("Disk is not partitioned."))
		return Menu.CONTINUE
	end

	local cmds = CmdChain.new()

	cmds:add("${root}${MKDIR} -p /tmp/hdrescue");
	cmds:add("${root}sbin/fsck -t ufs -y " .. part1 .. " > /dev/null");
	cmds:add("${root}${MOUNT} " .. part1 .. " /tmp/hdrescue");

	if not cmds:execute() then
		return Menu.CONTINUE
	end

	cmds = CmdChain.new()
	message = _("The password was reset successfully.");

	if POSIX.stat("/tmp/hdrescue/conf", "type") == "directory" then
		password = TargetSystemUI.set_root_password(nil)

		if password ~= "" then
			if POSIX.stat("/tmp/hdrescue/usr/local/sbin/opnsense-shell", "type") == "regular" then
				cmds:add("${root}${MOUNT_DEVFS} /tmp/hdrescue/dev")
				cmds:add("${root}${CHROOT} /tmp/hdrescue " ..
					      "/bin/sh /etc/rc.d/ldconfig start")
				cmds:add({
				    cmdline = "${root}${CHROOT} /tmp/hdrescue " ..
					      "/usr/local/sbin/opnsense-shell password root -x 0",
				    input = password .. "\n",
				    sensitive = password
				})
			else
				message = _("The installed version does not yet support recovery.")
			end
			cmds:add("${root}${UMOUNT} /tmp/hdrescue/dev")
		else
			message = _("The previous password was kept.")
		end
	else
		message = _("No previous installation was found on this disk.")
	end

	cmds:add("${root}${UMOUNT} /tmp/hdrescue");
	if not cmds:execute() then
		return Menu.CONTINUE
	end

	App.ui:inform(message)

	return Menu.CONTINUE

	end
}
