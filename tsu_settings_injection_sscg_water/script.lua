function onCreate(is_world_create)
    if is_world_create then
        server.command("?m geologic mainlands false")
        server.command("?m range-max 8000")
    end
end

