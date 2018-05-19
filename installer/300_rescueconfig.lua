--
-- Copyright (c) 2009 Scott Ullrich <sullrich@gmail.com>
-- Copyright (c) 2014-2018 Franco Fichtner <franco@opnsense.org>
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
	id = "rescue_config",
	name = _("Import configuration"),
	req_state = { "configure" },
	short_desc = _("Import the previous configuration from hard disk"),
	effect = function()
	local dd = StorageUI.select_disk({
		sd = App.state.storage,
		short_desc = _(
			"This tool will help you import the configuration of " ..
			"a previous hard disk installation including backups. " ..
			"Please select a disk:"),
		cancel_desc = _("Cancel")
	})

	if not dd then
		return Menu.CONTINUE
	end

	local disk1 = dd:get_name()

	if not disk1 then
		return Menu.CONTINUE
	end

	local cmds = CmdChain.new()

	cmds:add("${root}usr/local/sbin/opnsense-importer " .. disk1);

	if not cmds:execute() then
		App.ui:inform(_("The configuration import was aborted internally."))
		return Menu.CONTINUE
	end 

	App.ui:inform(_(
		"The configuration has been sucessfully restored. You " ..
		"may now choose to continue the installation or bring " ..
		"up a live system by exiting this installer."
	))

	return Menu.CONTINUE

	end
}
