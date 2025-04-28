#zone poknowledge
sub EVENT_SPAWN {
        quest::say("Hello, $name. Come find me for stuff.");
}

sub EVENT_SAY{
        my $item_request_flag = "awaiting_item_$charid";
        if ($text=~/hail/i) {
                quest::say("Hello, $name. Do you want to [pay 10,000p] for a level up? Or pay 1,000p for [alternate advancement] points? If you give me a diamond I can summon any item you want (with a valid item ID). If you want I can also [buff] you with some spells. I can also teleport you to [Antonica], [Faydwer], or [Odus]");

        }
        elsif ($text =~ /Antonica/i) {
                quest::say("In Antonica, I can send you to [Qeynos] or [Freeport]. Where will it be?");
        }
        elsif ($text =~ /Faydwer/i) {
                quest::say("In Faydwer, I can send you to [Greater Faydark]. Shall I proceed?");
        }
        elsif ($text =~ /Odus/i) {
                quest::say("In Odus, I can send you to [Erudin]. Ready to go?");
        }
        elsif ($text =~ /Qeynos/i) {
                quest::say("Off to Qeynos you go!");
                $npc->CastSpell(1374,$userid);
        }
        elsif ($text =~ /Freeport/i) {
                quest::say("Freeport awaits!");
                $npc->CastSpell(1340,$userid);
        }
        elsif ($text =~ /Greater Faydark/i) {
                quest::say("To Greater Faydark!");
                $npc->CastSpell(1336,$userid);
        }
        elsif ($text =~ /Erudin/i) {
                quest::say("Erudin it is!");
                $npc->CastSpell(1337,$userid);
        }
        elsif ($text =~ /buff/i) {
                quest::say("Powerful spells coming your way!");
                $npc->CastSpell(8199,$userid);
                quest::settimer("spell2", 15);
        }
        elsif ($text =~ /pay 10,000p/i) {
                my $cost = 10000000;
                if($client->GetCarriedMoney() >= $cost) {
                        $client->TakeMoneyFromPP($cost, 10000);
                        $client->SetLevel($client->GetLevel() + 1);
                        quest::ding();
                        quest::say("You leveled up");
                }
                else {
                        quest::say("Not enough");
                }
        }
        elsif ($text =~ /alternate advancement/i) {
                my $cost = 1000000;
                if($client->GetLevel() >= 52) {
                        if($client->GetCarriedMoney() >= $cost) {
                                $client->TakeMoneyFromPP($cost, 1);
                                $client->AddAAPoints(10);
                                quest::say("You have gained ALternate Advancement experience!");
                        }
                        else {
                                quest::say("You do not have enough platinum for this transaction.");
                        }

                }
                else {
                        quest::say("You aren't a high enough level");
                }
        }

        else {
                if($client->GetGlobal($item_request_flag) eq "waiting") {
                        my $requested_item = $text;
                        quest::say("DEBUG: Player requested item: $requested_item");
                if ($requested_item =~ /^\d+$/) {
                        quest::summonitem($requested_item);
                }
                else {
                        my $itemid = quest::getitemname($requested_item);
                        if ($itemid) {
                                quest::summonitem($itemid);
                                quest::say("Here's your item.");
                        }
                         else {
                                quest::say("I couldn't find that item. Please give me a valid ID");
                                return;
                        }
                }
                quest::delglobal($item_request_flag);
        }
}
}
sub EVENT_TIMER {
        if ($timer eq "spell2") {
                quest::stoptimer("spell2");
                $npc->CastSpell(3397,$userid);
                quest::settimer("spell3", 20);
        }
        elsif ($timer eq "spell3") {
                quest::stoptimer("spell3");
                $npc->CastSpell(8829,$userid);
        }
}
sub EVENT_ITEM {
        my $level_cost = 10000000;
        my $AA_cost = 1000000;
        my $diamond_id = 10037;
        my $item_request_flag = "awaiting_item_$charid";
        if ($platinum >= 10000) {
                $client->TakeMoneyFromPP($level_cost, 10000);
                $client->SetLevel($client->GetLevel() + 1);
                quest::say("You have gained 1 level.");
                quest::ding();
        }
        elsif ($platinum =~ 1000) {
                if($client->GetLevel() >= 52) {
                        $client->TakeMoneyFromPP($AA_cost, 1000);
                        $client->AddAAPoints(10);
                        quest::say("You have gained Alternate Advancement experience!");
                        quest::ding();
                }
                else {
                        quest::say("You aren't a high enough level or you didn't pay enough.");
                        plugin::return_items(\%itemcount);
                }
        }
        else {
                quest::say("Not enough.");
                plugin::return_items(\%itemcount);
        }
        if (plugin::check_handin(\%itemcount, 10037 => 1)) {
                quest::say("You have given me a Diamond. What item would you like?");
                $client->SetGlobal($item_request_flag, "waiting", 5, "F");
                quest::say("Global allow_summon set to: " . $client->GetGlobal("item_request_flag"));
                return 1;
        } else {
                plugin::return_items(\%itemcount);
                return 1;
        }
}