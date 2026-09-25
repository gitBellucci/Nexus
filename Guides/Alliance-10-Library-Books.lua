SBG.RegisterGuide([[
#name 10 Library Books
#displayname 10 Library Books
#subtitle Alliance · Stormwind start · necklace
#icon Interface/Icons/INV_Misc_Book_09
#group Sweat Beta Guide
<< Alliance

step
    +These are world objects, not mob drops. |cRXP_FRIENDLY_Garion Wendell|r in Stormwind only offers the quests once a book is already in your bags. Each book is its own turn-in. Ten different books unlock Friend of the Library. Click to start.
step
    .goto 1453/0,673.58,-8867.76
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Allison|r in the Trade District
    .home >> Set your Hearthstone to Stormwind City. You will use it after the last book.
    .target Innkeeper Allison
    .bindlocation 16509
step
    .goto 1453/0,489.99,-8835.76
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dungar Longdrink|r
    .fp Stormwind >> Get the Stormwind flight path
    .target Dungar Longdrink
step
    .goto Elwynn Forest,65.4,70.1
    >>Ride east through Elwynn to the Tower of Azora |cRXP_WARN_(Tour d’Azora)|r. Elwynn 65.4, 70.1. Climb to the top.
    +Click the |cRXP_PICK_Library Book|r on the low table at the top of the stairs. That is |cRXP_LOOT_Archmage Theocritus's Research Journal|r |cRXP_WARN_(Journal de recherche de l’archimage Théocritus)|r. Click once the book is in your bags.
step
    .goto Westfall,52.7,53.8
    >>Ride west into Westfall, to Sentinel Hill |cRXP_WARN_(Colline des sentinelles)|r. Westfall 52.7, 53.8.
    +Click the |cRXP_PICK_Gnome Tome|r in town. That is |cRXP_LOOT_Rumi of Gnomeregan: The Collected Works|r |cRXP_WARN_(Rumi de Gnomeregan : Le recueil d’œuvres)|r. Thelsamar has the same book. It only counts once. Click once the book is in your bags.
step
    .goto Westfall,45.4,70.4
    >>Ride south to Moonbrook |cRXP_WARN_(Ruisselune)|r. Westfall 45.4, 70.4.
    +Click the |cRXP_PICK_Grimoire|r. That is |cRXP_LOOT_Bewitchments and Glamours|r |cRXP_WARN_(Envoûtements et glamours)|r. Click once the book is in your bags.
step
    .goto Duskwood,16.6,28.5
    >>Ride east into Duskwood. The Darkened Bank |cRXP_WARN_(La rive Sombre)|r, Duskwood 16.6, 28.5. West shore, not Darkshire.
    +Click the |cRXP_PICK_Grimoire|r. That is |cRXP_LOOT_Crimes Against Anatomy|r |cRXP_WARN_(Crimes contre l’anatomie)|r. Click once the book is in your bags.
step
    .hs >> Hearth to Stormwind
    .use 6948
    .zoneskip Stormwind City
    .bindlocation 16509,1
step
    +If your hearth was on cooldown, ride back through Elwynn to Stormwind. Click once you are in Stormwind.
    .zoneskip Stormwind City
step
    .goto Stormwind City,37.6,80.8
    >>Mage Quarter. |cRXP_FRIENDLY_Garion Wendell|r is in the Wizard's Sanctum, Stormwind 37.6, 80.8. Same tower as |cRXP_FRIENDLY_Jennea Cannon|r.
    +Turn in every book you are carrying to |cRXP_FRIENDLY_Garion Wendell|r. Each book is a separate quest. You should have four. Click once those four are turned in.
    .target Garion Wendell
step
    .goto 1453/0,521.98,-8353.25,20 >> Enter the Deeprun Tram
    .zone Ironforge >> Take the tram to Ironforge
    .zoneskip Ironforge
step
    .goto 1455/0,-1152.32,-4821.18
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryth Thurden|r
    .fp Ironforge >> Get the Ironforge flight path
    .target Gryth Thurden
step
    .goto Ironforge,75.7,10.5
    >>Hall of Explorers, northeast Ironforge. Ironforge 75.7, 10.5. The small room at the back.
    +Click the |cRXP_PICK_Library Book|r on the table. That is |cRXP_LOOT_Archmage Antonidas: The Unabridged Autobiography|r |cRXP_WARN_(Archimage Antonidas : L’autobiographie intégrale)|r. Click once the book is in your bags.
step
    .goto 1455/0,-1152.32,-4821.18
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryth Thurden|r
    .fly Thelsamar >> Fly to Thelsamar
    .target Gryth Thurden
    .zoneskip Loch Modan
step
    .goto 1432/0,-2929.87,-5424.84
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thorgrum Borrelson|r
    .fp Thelsamar >> Get the Thelsamar flight path
    .target Thorgrum Borrelson
step
    .goto Loch Modan,77.4,14.0
    >>Ride northeast to Mo'grosh Stronghold |cRXP_WARN_(Bastion des Mo'grosh)|r. Loch Modan 77.4, 14.0. Ogres.
    +Click the |cRXP_PICK_Scrolls|r. That is |cRXP_LOOT_Runes of the Sorcerer-Kings|r |cRXP_WARN_(Runes des rois-sorciers)|r. Click once the book is in your bags.
step
    .goto 1432/0,-2929.87,-5424.84,80,0
    .goto 1437/0,-1241.48,-4000.12,50,0
    .goto 1437/0,-1121.55,-4013.90,40,0
    .goto 1437/0,-1084.33,-3947.75,40,0
    .goto 1437/0,-1014.03,-3911.92,40 >> Ride back through Thelsamar, then north through Dun Algaz into the Wetlands.
step
    .goto Wetlands,33.6,47.9
    >>Whelgar's Excavation |cRXP_WARN_(Excavations de Whelgar)|r. Wetlands 33.6, 47.9. The scrolls are in the cave up the site.
    +Click the |cRXP_PICK_Scrolls|r. That is |cRXP_LOOT_Goaz Scrolls|r |cRXP_WARN_(Parchemins de Goaz)|r. Click once the book is in your bags.
step
    .goto 1437/0,-889.97,-3809.94,40,0
    .goto 1437/0,-782.45,-3793.40
    >>Ride west to Menethil Harbor. |Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the flight master
    .fp Menethil Harbor >> Get the Menethil Harbor flight path
step
    .goto 1437/0,-583.95,-3727.25,20 >> The dock for Auberdine
    .zone Darkshore >> Take the boat to Darkshore
    .zoneskip Darkshore
step
    .goto 1439/1,561.66,6343.27
    >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caylais Moonfeather|r. Do not rebind. Your hearth is Stormwind.
    .fp Auberdine >> Get the Auberdine flight path
    .target Caylais Moonfeather
step
    .goto Darkshore,59.6,22.2
    >>Ride north to the Ruins of Mathystra |cRXP_WARN_(Ruines de Mathystra)|r. Darkshore 59.6, 22.2.
    +Click the |cRXP_PICK_Scrolls|r. That is |cRXP_LOOT_Nar'thalas Almanac Vol. 74|r |cRXP_WARN_(Almanach de Nar’thalas vol. 74)|r. Click once the book is in your bags.
step
    .goto 1440/1,-12.70,4150.17,60 >> Ride south through Darkshore into Ashenvale
    .zone Ashenvale >> Enter Ashenvale
    .zoneskip Ashenvale
step
    .goto 1440/1,-283.73,2827.92
    >>Ride to Astranaar. |Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Daelyshia|r
    .fp Astranaar >> Get the Astranaar flight path
    .target Daelyshia
step
    .zone The Barrens >> Ride south out of Ashenvale into the Barrens. Leave the road before the Mor'shan guards.
    .zoneskip The Barrens
step
    .goto The Barrens,46.0,36.5,20 >> Lushwater Oasis |cRXP_WARN_(Oasis luxuriante)|r. Cave mouth, Barrens 46.0, 36.5.
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
    .goto The Barrens,62.7,36.3
    >>Ride southeast to Ratchet. Neutral town. Barrens 62.7, 36.3. In front of |cRXP_FRIENDLY_Gazlowe|r |cRXP_WARN_(Gazleu)|r.
    +Click the |cRXP_PICK_Goblin Tome|r at his feet. That is |cRXP_LOOT_Baxtan: On Destructive Magics|r |cRXP_WARN_(Baxtan : Sur les magies destructrices)|r. Click once the book is in your bags.
    .target Gazlowe
step
    .hs >> Hearth to Stormwind
    .use 6948
    .zoneskip Stormwind City
    .bindlocation 16509,1
step
    +If your hearth was on cooldown, take the Ratchet boat to Booty Bay only if you must, then get back to Stormwind however you can. Click once you are in Stormwind.
    .zoneskip Stormwind City
step
    .goto Stormwind City,37.6,80.8
    >>Mage Quarter. |Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Garion Wendell|r in the Wizard's Sanctum. Stormwind 37.6, 80.8.
    +Turn in the last six books. The tenth turn-in unlocks Friend of the Library. Melee: take |cRXP_LOOT_Amulet of the Scholar|r |cRXP_WARN_(Amulette de l’érudit)|r. Caster: take |cRXP_LOOT_Pendant of Erudition|r |cRXP_WARN_(Pendentif d’érudition)|r. Click once the necklace is in your bags.
    .target Garion Wendell
step
    +Twenty different books unlock the ring. The first ten count. Skip Orgrimmar and Brill on this run. Ataeric is listed at the Sepulcher on Wowhead and is not there. Click to finish.
]])
