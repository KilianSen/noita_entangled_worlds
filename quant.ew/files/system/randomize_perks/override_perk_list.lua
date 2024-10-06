local orig_perk_get_spawn_order = perk_get_spawn_order

function perk_get_spawn_order( ignore_these_ )
    local sx, sy = CrossCall("ew_per_peer_seed")
    SetRandomSeed(1 + sx, 2 + sy)
    local orig_SetRandomSeed = SetRandomSeed
    function SetRandomSeed(x, y) end

    local perks = orig_perk_get_spawn_order( ignore_these_ )

    SetRandomSeed = orig_SetRandomSeed

    return perks
end