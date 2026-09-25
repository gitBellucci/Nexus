local faction = UnitFactionGroup("player")
if faction and faction == "Alliance" then return end

SBG.RegisterGuide([[
#name 1-10 Warrior
#displayname Warrior 1-10
#subtitle Horde · Durotar · Valley to Razor Hill
#icon Interface/Icons/INV_Sword_27
#group Sweat Beta Guide
<< Horde Warrior

step
    +This is a Durotar warrior route, Valley of Trials through Razor Hill to level 10. Built for Orc and Troll. If you started in Mulgore or Tirisfal, pick another zone. Click to start.
step
    .goto 1411/1,-4251.46,-607.35
    >>Talk to |cRXP_FRIENDLY_Kaltunk|r at the Valley of Trials gate.
    .accept 4641 >>Accept Your Place In The World
    .target Kaltunk
step
    .goto 1411/1,-4299.05,-494.9
    >>Kill |cRXP_ENEMY_Mottled Boars|r until you have about 10 copper of vendor trash, including your starting gear.
    +Click once you have the copper.
    .mob Mottled Boar
step
    .goto 1411/1,-4214.45,-565.75
    >>Vendor at |cRXP_FRIENDLY_Duokna|r.
    .vendor >> Vendor trash
    .target Duokna
step
    .goto 1411/1,-4186.42,-599.95
    >>Talk to |cRXP_FRIENDLY_Gornek|r in the den.
    .turnin 4641 >>Turn in Your Place In The World
    .accept 788 >>Accept Cutting Teeth
    .accept 97279 >>Accept Wayward Weapons
    .target Gornek
step
    .goto 1411/1,-4230.31,-639.43
    >>Talk to |cRXP_FRIENDLY_Frang|r and train |T132333:0|t[Battle Shout].
    .train 6673 >>Train Battle Shout
    .target Frang
step
    .goto 1411/1,-4299.05,-494.9
    >>Kill 10 |cRXP_ENEMY_Mottled Boars|r south of the den. Loot any stray weapons on the ground for Wayward Weapons.
    .complete 788,1
    .mob Mottled Boar
step
    .goto 1411/1,-4108.70,-397.96
    >>Talk to |cRXP_FRIENDLY_Hana'zua|r on the ridge north of the valley.
    .accept 790 >>Accept Sarkoth
    .target Hana'zua
step
    .goto 1411/1,-4109.22,-546.370
    >>Kill |cRXP_ENEMY_Sarkoth|r on the slope below Hana'zua. Loot |cRXP_LOOT_Sarkoth's Mangled Claw|r.
    .complete 790,1
    .mob Sarkoth
step
    .goto 1411/1,-4108.70,-397.96
    >>Return to |cRXP_FRIENDLY_Hana'zua|r.
    .turnin 790 >>Turn in Sarkoth
    .accept 804 >>Accept Sarkoth
    .target Hana'zua
step
    .goto 1411/1,-4186.42,-599.95
    >>Back to |cRXP_FRIENDLY_Gornek|r.
    .turnin 788 >>Turn in Cutting Teeth
    .turnin 804 >>Turn in Sarkoth
    .turnin 97279 >>Turn in Wayward Weapons
    .accept 789 >>Accept Sting of the Scorpid
    .accept 2383 >>Accept Simple Parchment << Orc
    .accept 3065 >>Accept Simple Tablet << Troll
    .target Gornek
step
    .goto 1411/1,-4230.31,-639.43
    >>Turn the parchment in at |cRXP_FRIENDLY_Frang|r if you still have it, then train anything new.
    .turnin 2383 >>Turn in Simple Parchment << Orc
    .turnin 3065 >>Turn in Simple Tablet << Troll
    .target Frang
step
    .goto 1411/1,-4221.85,-561.52
    >>Talk to |cRXP_FRIENDLY_Galgar|r by the cactus.
    .accept 4402 >>Accept Galgar's Cactus Apple Surprise
    .target Galgar
step
    .goto 1411/1,-4228.19,-629.20
    >>Talk to |cRXP_FRIENDLY_Zureetha Fargaze|r.
    .accept 792 >>Accept Vile Familiars
    .target Zureetha Fargaze
step
    .goto 1411/1,-4322.31,-611.58
    >>Talk to |cRXP_FRIENDLY_Foreman Thazz'ril|r.
    .accept 5441 >>Accept Lazy Peons
    .target Foreman Thazz'ril
step
    .goto 1411/1,-4375.71,-507.590
    >>Wake 5 |cRXP_FRIENDLY_Lazy Peons|r with the |T133486:0|t[Foreman's Blackjack]. Loot |cRXP_LOOT_Cactus Apples|r off the cacti. Kill |cRXP_ENEMY_Scorpid Workers|r for tails. Kill |cRXP_ENEMY_Vile Familiars|r at the cave mouth.
    .complete 5441,1
    .complete 4402,1
    .complete 789,1
    .complete 792,1
    .use 16114
    .mob Scorpid Worker
    .mob Vile Familiar
step
    .goto 1411/1,-4322.31,-611.58
    >>Talk to |cRXP_FRIENDLY_Thazz'ril|r.
    .turnin 5441 >>Turn in Lazy Peons
    .accept 6394 >>Accept Thazz'ril's Pick
    .target Foreman Thazz'ril
step
    .goto 1411/1,-4221.85,-561.52
    >>Talk to |cRXP_FRIENDLY_Galgar|r.
    .turnin 4402 >>Turn in Galgar's Cactus Apple Surprise
    .target Galgar
step
    .goto 1411/1,-4186.42,-599.95
    >>Talk to |cRXP_FRIENDLY_Gornek|r.
    .turnin 789 >>Turn in Sting of the Scorpid
    .target Gornek
step
    .goto 1411/1,-4228.19,-629.20
    >>Talk to |cRXP_FRIENDLY_Zureetha|r.
    .turnin 792 >>Turn in Vile Familiars
    .accept 794 >>Accept Burning Blade Medallion
    .target Zureetha Fargaze
step
    .goto 1411/1,-4274.19,-87.76
    >>Back into the cave. Loot |cRXP_LOOT_Thazz'ril's Pick|r against the wall, then kill |cRXP_ENEMY_Yarrog Baneshadow|r deeper in for the medallion.
    .complete 6394,1
    .complete 794,1
    .mob Yarrog Baneshadow
step
    .goto 1411/1,-4322.31,-611.58
    >>Leave the cave and talk to |cRXP_FRIENDLY_Thazz'ril|r.
    .turnin 6394 >>Turn in Thazz'ril's Pick
    .target Foreman Thazz'ril
step
    .goto 1411/1,-4228.19,-629.20
    >>Talk to |cRXP_FRIENDLY_Zureetha|r.
    .turnin 794 >>Turn in Burning Blade Medallion
    .accept 805 >>Accept Report to Sen'jin Village
    .target Zureetha Fargaze
step
    .goto 1411/1,-4230.31,-639.43
    >>Train at |cRXP_FRIENDLY_Frang|r if you dinged 6.
    .train 284 >>Train class spells
    .target Frang
step
    .goto 1411/1,-4715.17,-599.240
    >>Leave the valley on the road east. Talk to |cRXP_FRIENDLY_Ukor|r.
    .accept 2161 >>Accept A Peon's Burden
    .target Ukor
step
    .goto 1411/1,-4920.33,-825.55
    >>Sen'jin Village. Talk to |cRXP_FRIENDLY_Master Gadrin|r.
    .turnin 805 >>Turn in Report to Sen'jin Village
    .accept 808 >>Accept Minshina's Skull
    .accept 826 >>Accept Zalazane
    .accept 823 >>Accept Report to Orgnil
    .target Master Gadrin
step
    .goto 1411/1,-4920.33,-814.270
    >>Talk to |cRXP_FRIENDLY_Master Vornal|r.
    .accept 818 >>Accept A Solvent Spirit
    .target Master Vornal
step
    .goto 1411/1,-4920.86,-797.70
    >>Talk to |cRXP_FRIENDLY_Vel'rin Fang|r.
    .accept 817 >>Accept Practical Prey
    .target Vel'rin Fang
step
    .goto 1411/1,-4828.32,-777.61
    >>Talk to |cRXP_FRIENDLY_Lar Prowltusk|r. He patrols just north of the village.
    .accept 786 >>Accept Thwarting Kolkar Aggression
    .target Lar Prowltusk
step
    .goto 1411/1,-4686.09,340.52
    >>Run north to Razor Hill |cRXP_WARN_(Tranchecolline)|r. Talk to |cRXP_FRIENDLY_Innkeeper Grosk|r in the inn.
    .turnin 2161 >>Turn in A Peon's Burden
    .home >> Set your Hearthstone to Razor Hill
    .vendor >> Buy meat if you need food
    .target Innkeeper Grosk
    .bindlocation 362
step
    .goto 1411/1,-4724.69,287.30
    >>Talk to |cRXP_FRIENDLY_Orgnil Soulscar|r by the bonfire.
    .turnin 823 >>Turn in Report to Orgnil
    .target Orgnil Soulscar
step
    .goto 1411/1,-4709.36,274.960
    >>Talk to |cRXP_FRIENDLY_Gar'thok|r in the bunker. You can talk from the door.
    .accept 784 >>Accept Vanquish the Betrayers
    .target Gar'thok
step
    .goto 1411/1,-4600.43,384.59
    >>Climb the watchtower. Talk to |cRXP_FRIENDLY_Furl Scornbrow|r.
    .accept 791 >>Accept Carry Your Weight
    .target Furl Scornbrow
step
    .goto 1411/1,-4827.27,311.62
    >>Train at |cRXP_FRIENDLY_Tarshaw Jaggedscar|r in the barracks if you are 6+.
    .train 284 >>Train class spells
    .target Tarshaw Jaggedscar
step
    .goto Durotar,58.0,58.0
    >>Kill Kul Tiras sailors and marines on the east coast. Loot |cRXP_LOOT_Canvas Scraps|r off them as well.
    .complete 784,1
    .complete 784,2
    .complete 784,3
    .complete 791,1
step
    .goto 1411/1,-4709.36,274.960
    >>Back to |cRXP_FRIENDLY_Gar'thok|r.
    .turnin 784 >>Turn in Vanquish the Betrayers
    .accept 825 >>Accept From The Wreckage....
    .accept 837 >>Accept Encroachment
    .target Gar'thok
step
    .goto 1411/1,-4600.43,384.59
    >>Turn in at |cRXP_FRIENDLY_Furl|r up the tower.
    .turnin 791 >>Turn in Carry Your Weight
    .target Furl Scornbrow
step
    .goto Durotar,62.0,58.0
    >>Loot Gnomish Toolboxes in the wrecked ships off the east coast. Stay in the water.
    .complete 825,1
step
    .goto Durotar,50.0,49.0
    >>Kill Razormane quilboar west of Razor Hill for Encroachment. The south camp first, then the west camp if you still need kills.
    .complete 837,1
    .complete 837,2
    .complete 837,3
    .complete 837,4
step
    .goto Durotar,48.0,79.0
    >>Burn the three Kolkar attack plans. The camps sit west of Sen'jin, inland from the coast.
    .complete 786,1
    .complete 786,2
    .complete 786,3
step
    .goto Durotar,67.2,87.0
    >>Echo Isles. Kill tigers for |cRXP_LOOT_Durotar Tiger Fur|r, crawlers and makrura for |cRXP_LOOT_Crawler Mucus|r and |cRXP_LOOT_Intact Makrura Eyes|r. Loot |cRXP_LOOT_Minshina's Skull|r from the ritual circle, then kill |cRXP_ENEMY_Zalazane|r and the trolls with him.
    .complete 817,1
    .complete 818,1
    .complete 818,2
    .complete 808,1
    .complete 826,1
    .complete 826,2
    .complete 826,3
step
    .goto 1411/1,-4828.32,-777.61
    >>Back to Sen'jin. Talk to |cRXP_FRIENDLY_Lar Prowltusk|r.
    .turnin 786 >>Turn in Thwarting Kolkar Aggression
    .target Lar Prowltusk
step
    .goto 1411/1,-4920.86,-797.70
    >>Talk to |cRXP_FRIENDLY_Vel'rin Fang|r.
    .turnin 817 >>Turn in Practical Prey
    .target Vel'rin Fang
step
    .goto 1411/1,-4920.33,-814.270
    >>Talk to |cRXP_FRIENDLY_Master Vornal|r.
    .turnin 818 >>Turn in A Solvent Spirit
    .target Master Vornal
step
    .goto 1411/1,-4920.33,-825.55
    >>Talk to |cRXP_FRIENDLY_Master Gadrin|r.
    .turnin 808 >>Turn in Minshina's Skull
    .turnin 826 >>Turn in Zalazane
    .target Master Gadrin
step
    .hs >> Hearth to Razor Hill
    .use 6948
    .zoneskip Durotar
    .bindlocation 362,1
step
    .goto 1411/1,-4709.36,274.960
    >>Talk to |cRXP_FRIENDLY_Gar'thok|r.
    .turnin 825 >>Turn in From The Wreckage....
    .turnin 837 >>Turn in Encroachment
    .target Gar'thok
step
    .goto 1411/1,-4827.27,311.62
    >>Ding 10 if you are not there yet: grind quilboar west of town. Then train everything at |cRXP_FRIENDLY_Tarshaw|r, including |T132337:0|t[Rend] if it is in his list.
    .train 6546 >>Train level 10 warrior spells
    .target Tarshaw Jaggedscar
step
    +Warrior 1-10 is done. Razor Hill is your hub. Barrens at 10, or stay here for leftover quests. Type |cRXP_LOOT_/sbg|r to open the library books guide next. Click to finish.
]])
