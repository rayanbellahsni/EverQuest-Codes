-- Lua Script: Combat Automation Script

local function echo(message)
    print(message)
end

local function target_npc()
    echo("Searching for an enemy...")
    -- Replace this with the actual targeting function for your game
    local target = FindNearestNPC() -- Custom function to find nearest NPC
    return target
end

local function engage_target(target)
    echo("Engaging " .. target.name .. " in combat...")
    -- Replace with actual attack function
    target:attack()
end

local function move_to_target(target, distance)
    echo("Moving to enemy: " .. target.name .. "...")
    -- Replace with your game’s movement function
    target:move_to(distance)
end

local function is_behind_target(target)
    -- Replace with actual check for being behind the target
    return target:is_behind()
end

local function use_ability(ability)
    echo("Using ability: " .. ability)
    -- Replace with actual ability usage
    UseAbility(ability)
end

local function attack_target(target)
    echo("Using auto-attack on " .. target.name .. "...")
    -- Replace with actual auto-attack function
    target:attack()
end

local function disarm_target(target)
    echo("Attempting to disarm " .. target.name .. "...")
    use_ability("Disarm")
    os.sleep(1)
end

local function loot_corpse(corpse)
    echo("Looting " .. corpse.name .. "'s corpse...")
    -- Replace with actual loot function
    Loot(corpse)
end

local function check_for_enemies()
    echo("Checking for other enemies in range...")
    -- Replace with actual targeting function for radius detection
    return FindNearbyNPCs(50)
end

local function combat_loop(target)
    engage_target(target)
    attack_target(target)
    
    while target.health > 0 do
        if is_behind_target(target) then
            echo("Backstabbing " .. target.name .. "...")
            use_ability("Backstab")
        else
            echo("Moving behind target to backstab...")
            move_to_target(target, "behind")
            use_ability("Backstab")
        end

        if AbilityReady("Disarm") then
            disarm_target(target)
        end

        attack_target(target)
        os.sleep(1)
    end

    echo("Combat complete! Checking for other enemies in range...")
end

local function main()
    local target = target_npc()
    
    if not target then
        echo("No enemy found! Exiting script.")
        return
    end

    move_to_target(target, 10)
    combat_loop(target)
    
    local enemies = check_for_enemies()
    if enemies then
        for _, enemy in ipairs(enemies) do
            if enemy.health > 0 then
                combat_loop(enemy)
            end
        end
    else
        echo("No new enemies found, checking for loot...")
        local corpse = target_corpse()
        
        if corpse then
            loot_corpse(corpse)
        else
            echo("No lootable corpse found.")
        end
    end

    echo("Script finished! Exiting...")
end

main()
