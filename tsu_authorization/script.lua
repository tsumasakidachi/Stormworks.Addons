g_savedata = {}

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
	if not is_auth then
		server.addAuth(peer_id)
	end
end
