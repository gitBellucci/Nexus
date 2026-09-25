local faction = UnitFactionGroup("player")
if faction and faction == "Alliance" then return end

SBG.RegisterGuide([[
#name 10 Library Books
#displayname 10 Library Books
#subtitle Horde · Crossroads start · necklace
#icon Interface/Icons/INV_Misc_Book_09
#group Sweat Beta Guide
<< Horde

step
    +These are world objects, not mob drops. |cRXP_FRIENDLY_Owen Thadd|r in Undercity only offers the quests once a book is already in your bags. Each book is its own turn-in. Ten different books unlock Friend of the Library. Pins use ForeverChanges map percentages. Click to start.
step
    .goto 1413/1,-2645.40,-406.94
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Boorand Plainswind|r
    .home >> Set your Hearthstone to the Crossroads. You will use it after the last book.
    .target Innkeeper Boorand Plainswind
    .bindlocation 380
step
    .goto The Barrens,56.3,8.8
    >>Ride north from the Crossroads to the Sludge Fen |cRXP_WARN_(La Videfange)|r. Barrens 56.3, 8.8. The goblin pump station.
    +Click the |cRXP_PICK_Manual|r inside the building. That is |cRXP_LOOT_Arcanic Systems Manual|r |cRXP_WARN_(Manuel des systèmes arcaniques)|r. Click once the book is in your bags.
step
    .goto The Barrens,62.7,36.3
    >>Ride southeast to Ratchet. Barrens 62.7, 36.3. In front of |cRXP_FRIENDLY_Gazlowe|r |cRXP_WARN_(Gazleu)|r.
    +Click the |cRXP_PICK_Goblin Tome|r. That is |cRXP_LOOT_Baxtan: On Destructive Magics|r |cRXP_WARN_(Baxtan : Sur les magies destructrices)|r. Click once the book is in your bags.
    .target Gazlowe
step
    .goto The Barrens,46.0,36.5,20 >> Ride west to Lushwater Oasis |cRXP_WARN_(Oasis luxuriante)|r. Cave mouth, Barrens 46.0, 36.5.
step
    .goto 1413,45.98,36.39,15,0
    .goto 1414,51.91,55.42,15,0
    .goto 1414,51.98,55.23,15,0
    .goto 1414,51.95,55.11,15,0
    .goto 1414,51.89,54.79,15,0
    .goto 1414,51.94,54.63,15,0
    .goto 1414,52.01,54.57,15,0
    .goto 1414,52.26,54.63,15,0
    .goto 1414,52.48,54.93,15,0
    .goto 1414,52.62,54.94,15,0
    .goto 1414,52.8,54.7
    >>Follow the arrow into the cave, to the Cavern of Mists |cRXP_WARN_(Caverne des brumes)|r, near the instance portal. Do not zone into Wailing Caverns. The scrolls are 52.8, 54.7 on the cave map.
    +Click the |cRXP_PICK_Scrolls|r. That is |cRXP_LOOT_Secrets of the Dreamers|r |cRXP_WARN_(Secrets des Rêveurs)|r. Click once the book is in your bags.
step
    .goto 1413/1,-943.00,-265.06,60,0
    .goto Stonetalon Mountains,74.4,85.7
    >>Leave the cave the way you came. Ride west into Stonetalon, to Grimtotem Post |cRXP_WARN_(Poste Totem-sinistre)|r. Stonetalon 74.4, 85.7.
    +Click the |cRXP_PICK_Scrolls|r in the camp. That is |cRXP_LOOT_Fury of the Land|r |cRXP_WARN_(Fureur de la terre)|r. The Grimtotem will attack. Click once the book is in your bags.
step
    .goto 1413/1,-2595.75,-437.35
    >>Ride back to the Crossroads. |Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Devrak|r
    .fly Orgrimmar >> Fly to Orgrimmar
    .target Devrak
    .zoneskip Orgrimmar
step
    .goto Orgrimmar,38.7,78.4
    >>Valley of Spirits. Orgrimmar 38.7, 78.4. The painted stone in front of the mage building.
    +Click the |cRXP_PICK_Mural of Ta'zo|r |cRXP_WARN_(Fresque de Ta'zo)|r. That is |cRXP_LOOT_The Lessons of Ta'zo|r |cRXP_WARN_(Les leçons de Ta’zo)|r. Click once the book is in your bags.
step
    .zone Durotar >> Leave Orgrimmar through the west gate
    .zoneskip Durotar
step
    .goto 1411/1,-4648.55,1321.88,40 >> Go up the zeppelin tower
    .zone Tirisfal Glades >> Take the zeppelin to Tirisfal Glades. Two zeppelins use this tower. Take the Tirisfal one, not the Stranglethorn one.
    .zoneskip Tirisfal Glades/Undercity/Silverpine Forest
step
    .goto Tirisfal Glades,59.4,52.3
    >>Brill. Tirisfal 59.4, 52.3. The alchemy shop on the west side of town, next to the stables.
    +Click the |cRXP_PICK_Apothecary Society Primer|r. That is |cRXP_LOOT_The Apothecary's Metaphysical Primer|r |cRXP_WARN_(L’abécédaire métaphysique de l’apothicaire)|r. Click once the book is in your bags.
step
    .goto 1420/0,240.75,1877.57,20,0
    .zone Undercity >> Enter Undercity
    .zoneskip Undercity
step
    .goto 1458/0,239.14,1749.54,20,0
    .goto 1458/0,255.64,1724.70,20,0
    .goto 1458/0,240.68,1706.97,10,0
    .goto 1458/0,241.06,1660.12,10,0
    .goto 1458/0,257.08,1623.38,10,0
    .goto 1458/0,244.51,1598.73,15,0
    .goto Undercity,73.4,33.0
    >>Take the lift down. |cRXP_FRIENDLY_Owen Thadd|r is in the Magic Quarter, Undercity 73.4, 33.0.
    +Turn in every book you are carrying to |cRXP_FRIENDLY_Owen Thadd|r. Each book is a separate quest. You should have six. Click once those six are turned in.
    .target Owen Thadd
step
    .goto 1420/0,235.32,1883.89,40 >> Leave Undercity
    .zone Tirisfal Glades >> Exit to Tirisfal Glades
    .zoneskip Tirisfal Glades
step
    .goto 1421/0,1359.66,864.19,50,0
    .goto 1421/0,1359.66,741.27,50,0
    .goto Silverpine Forest,63.5,63.1
    >>Run south into Silverpine, then east to Ambermill |cRXP_WARN_(Moulin-de-l'Ambre)|r. Silverpine 63.5, 63.1. Dalaran mages will attack.
    +Click the |cRXP_PICK_Dalaran Digest|r. That is |cRXP_LOOT_Dalaran Digest Vol. 23|r |cRXP_WARN_(Abrégé de Dalaran vol. 23)|r. Click once the book is in your bags.
step
    .goto 1420/0,278.70,2071.27,12,0
    .goto 1420/0,253.85,2059.82,10,0
    .goto 1420/0,264.70,2053.50,8,0
    .goto 1420/0,271.02,2064.94,8,0
    .goto 1420/0,259.72,2068.86,8,0
    .goto 1420/0,261.53,2055.00,8,0
    .goto 1420/0,299.04,2069.46,8 >> Run north to the Tirisfal zeppelin tower
    .zone Durotar >> Take the zeppelin to Durotar
    .zoneskip Durotar/Orgrimmar/The Barrens/Thunder Bluff
step
    .goto 1411/1,-4648.55,1321.88,40 >> Go up the same zeppelin tower
    .zone Stranglethorn Vale >> Take the zeppelin to Stranglethorn Vale. This is the other zeppelin, the one to Grom'gol, not Tirisfal.
    .zoneskip Stranglethorn Vale
step
    .goto 1434/0,273.91,-12406.71,40,0
    .goto 1434/0,492.15,-12499.03,40,0
    .goto 1434/0,759.53,-12494.77,60,0
    .goto 1434/0,1004.57,-12317.37,60,0
    .goto 1434/0,1178.78,-12166.78,60,0
    .goto 1434/0,1360.00,-11978.74,60,0
    .goto 1436/0,1578.87,-11699.50,60,0
    .goto 1436/0,1718.17,-11480.40,40,0
    .goto 1436/0,1966.32,-11407.13,40 >> Swim west from Grom'gol into the Vile Reef, then north to the Westfall lighthouse. Stay on the arrow. Do not land on the island.
step
    .goto Westfall,45.4,70.4
    >>Moonbrook |cRXP_WARN_(Ruisselune)|r. Westfall 45.4, 70.4. South of the lighthouse.
    +Click the |cRXP_PICK_Grimoire|r. That is |cRXP_LOOT_Bewitchments and Glamours|r |cRXP_WARN_(Envoûtements et glamours)|r. Click once the book is in your bags.
step
    .goto Duskwood,16.6,28.5
    >>Ride east into Duskwood. The Darkened Bank |cRXP_WARN_(La rive Sombre)|r, Duskwood 16.6, 28.5. West shore, not Darkshire.
    +Click the |cRXP_PICK_Grimoire|r. That is |cRXP_LOOT_Crimes Against Anatomy|r |cRXP_WARN_(Crimes contre l’anatomie)|r. Click once the book is in your bags.
step
    .goto Elwynn Forest,65.4,70.1
    >>Ride north into Elwynn, then east. Stay off Goldshire and the Stormwind road. Tower of Azora |cRXP_WARN_(Tour d’Azora)|r, Elwynn 65.4, 70.1.
    +Climb to the top of the tower. Click the |cRXP_PICK_Library Book|r on the low table at the top of the stairs. That is |cRXP_LOOT_Archmage Theocritus's Research Journal|r |cRXP_WARN_(Journal de recherche de l’archimage Théocritus)|r. Click once the book is in your bags.
step
    .hs >> Hearth to the Crossroads
    .use 6948
    .zoneskip The Barrens
    .bindlocation 380,1
step
    +If your hearth was on cooldown, swim back to Grom'gol on the same arrow and take the zeppelin to Orgrimmar, then fly to the Crossroads. Click once you are in the Barrens or Orgrimmar.
    .zoneskip The Barrens/Orgrimmar
step
    .goto 1413/1,-2595.75,-437.35
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Devrak|r
    .fly Orgrimmar >> Fly to Orgrimmar
    .target Devrak
    .zoneskip Orgrimmar
step
    .zone Durotar >> Leave Orgrimmar through the west gate
    .zoneskip Durotar
step
    .goto 1411/1,-4648.55,1321.88,40 >> Go up the zeppelin tower
    .zone Tirisfal Glades >> Take the zeppelin to Tirisfal Glades
    .zoneskip Tirisfal Glades/Undercity
step
    .goto 1420/0,240.75,1877.57,20,0
    .zone Undercity >> Enter Undercity
    .zoneskip Undercity
step
    .goto 1458/0,239.14,1749.54,20,0
    .goto 1458/0,255.64,1724.70,20,0
    .goto 1458/0,240.68,1706.97,10,0
    .goto 1458/0,241.06,1660.12,10,0
    .goto 1458/0,257.08,1623.38,10,0
    .goto 1458/0,244.51,1598.73,15,0
    .goto Undercity,73.4,33.0
    >>Take the lift down. |Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Owen Thadd|r. Undercity 73.4, 33.0.
    +Turn in the last four books. The tenth turn-in unlocks Friend of the Library. Melee: take |cRXP_LOOT_Amulet of the Scholar|r |cRXP_WARN_(Amulette de l’érudit)|r. Caster: take |cRXP_LOOT_Pendant of Erudition|r |cRXP_WARN_(Pendentif d’érudition)|r. Click once the necklace is in your bags.
    .target Owen Thadd
step
    +Twenty different books unlock the ring. The first ten count. Skip Ironforge, Sentinel Hill, and Loch Modan on this run. Ataeric is listed at the Sepulcher on Wowhead and is not there. Click to finish.
]])
