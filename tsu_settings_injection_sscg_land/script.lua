function onCreate(is_world_create)
    if is_world_create then
        server.command("?m geologic waters false")
        server.command("?m geologic islands false")
        server.command("?m recurrent-cpa 0")
    end
end

