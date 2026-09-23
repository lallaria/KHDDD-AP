local ItemDefs = {}

function ItemDefs:DefineItems()
  items = {
    --Events
    { ID = 2639999, Name = "Victory", Usefulness = item_usefulness.progression_useful, Type="Goal"},
    { ID = 2640000, Name = "Victory", Usefulness = item_usefulness.progression_useful, Type="Goal"},

    --Traps
    { ID = 2621001, Name = "Instant Drop", Usefulness = item_usefulness.trap, Type="Trap"},

    --Key Items
    { ID = 2801001, Name = "Recusant Sigil", Usefulness = item_usefulness.progression_useful, Type="Key", Bytes = {0x1D, 0x04}, Offset=58}, --28
    { ID = 2801002, Name = "Lucky Emblem", Usefulness = item_usefulness.progression_useful, Type="Key", Bytes = {0x0D, 0x08}},

    --Worlds
    --Itemized Versions
    { ID = 2691106, Name = "TWTNW Sora", Type="World Item", Bytes={0x01, 0x04}, Offset=2}, --Key Item 2
    { ID = 2691112, Name = "TWTNW Riku", Type="World Item", Bytes={0x03, 0x04}, Offset=6}, --Key Item 4
    { ID = 2691113, Name = "TT Sora", Type="World Item", Bytes={0x05, 0x04}, Offset=10}, --Key Item 6
    { ID = 2691114, Name = "TT Riku", Type="World Item", Bytes={0x07, 0x04}, Offset=14}, --Key Item 8
    { ID = 2691101, Name = "LCdC Sora", Type="World Item", Bytes={0x09, 0x04}, Offset=18}, --Key Item 10
    { ID = 2691107, Name = "LCdC Riku", Type="World Item", Bytes={0x0B, 0x04}, Offset=22}, --Key Item 12
    { ID = 2691102, Name = "TG Sora", Type="World Item", Bytes={0x0D, 0x04}, Offset=26}, --Key Item 14
    { ID = 2691108, Name = "TG Riku", Type="World Item", Bytes={0x0F, 0x04}, Offset=30}, --Key Item 16
    { ID = 2691103, Name = "PP Sora", Type="World Item", Bytes={0x11, 0x04}, Offset=34},
    { ID = 2691109, Name = "PP Riku", Type="World Item", Bytes={0x13, 0x04}, Offset=38},
    { ID = 2691104, Name = "CotM Sora", Type="World Item", Bytes={0x15, 0x04}, Offset=42},
    { ID = 2691110, Name = "CotM Riku", Type="World Item", Bytes={0x17, 0x04}, Offset=46},
    { ID = 2691105, Name = "SoS Sora", Type="World Item", Bytes={0x19, 0x04}, Offset=50},
    { ID = 2691111, Name = "SoS Riku", Type="World Item", Bytes={0x1B, 0x04}, Offset=54},

    --Traverse Town 2; Only exists itemized
    --{ ID = 2691112, Name = "TT2 Sora", Type="World Item", Bytes={0x1F, 0x04}, Offset=30},
    --{ ID = 2691113, Name = "TT2 Riku", Type="World Item", Bytes={0x21, 0x04}, Offset=32},

    --Full World Data
    { ID = 2691001, Name = "La Cite des Cloches [Sora]", Type="World", Bytes={
      WorldFlags.laCiteDesCloches.sora.unlocked[gameVer],
      WorldFlags.laCiteDesCloches.sora.story[gameVer],
      WorldFlags.laCiteDesCloches.worldNo,
      WorldFlags.laCiteDesCloches.sora.startRoom,
      WorldFlags.laCiteDesCloches.sora.battle[gameVer],
      WorldFlags.laCiteDesCloches.sora.selectable[gameVer]
      }},
    { ID = 2691002, Name = "The Grid [Sora]", Type="World", Bytes={
      WorldFlags.theGrid.sora.unlocked[gameVer],
      WorldFlags.theGrid.sora.story[gameVer],
      WorldFlags.theGrid.worldNo,
      WorldFlags.theGrid.sora.startRoom,
      WorldFlags.theGrid.sora.battle[gameVer],
      WorldFlags.theGrid.sora.selectable[gameVer]
      }},
    { ID = 2691003, Name = "Prankster's Paradise [Sora]", Type="World", Bytes={
      WorldFlags.prankstersParadise.sora.unlocked[gameVer],
      WorldFlags.prankstersParadise.sora.story[gameVer],
      WorldFlags.prankstersParadise.worldNo,
      WorldFlags.prankstersParadise.sora.startRoom,
      WorldFlags.prankstersParadise.sora.battle[gameVer],
      WorldFlags.prankstersParadise.sora.selectable[gameVer]
      
    }},
    { ID = 2691004, Name = "Country of Musketeers [Sora]", Type="World", Bytes={
      WorldFlags.countryOfMusketeers.sora.unlocked[gameVer],
    WorldFlags.countryOfMusketeers.sora.story[gameVer],
    WorldFlags.countryOfMusketeers.worldNo,
    WorldFlags.countryOfMusketeers.sora.startRoom,
    WorldFlags.countryOfMusketeers.sora.battle[gameVer],
    WorldFlags.countryOfMusketeers.sora.selectable[gameVer]
    }},
    { ID = 2691005, Name = "Symphony of Sorcery [Sora]", Type="World", Bytes={
      WorldFlags.symphonyOfSorcery.sora.unlocked[gameVer],
    WorldFlags.symphonyOfSorcery.sora.story[gameVer],
    WorldFlags.symphonyOfSorcery.worldNo,
    WorldFlags.symphonyOfSorcery.sora.startRoom,
    WorldFlags.symphonyOfSorcery.sora.battle[gameVer],
    WorldFlags.symphonyOfSorcery.sora.selectable[gameVer],
    WorldFlags.symphonyOfSorcery.sora.dockPoint[gameVer]
    }},
    { ID = 2691006, Name = "The World That Never Was [Sora]", Type="World", Bytes={
      WorldFlags.theWorldThatNeverWas.sora.unlocked[gameVer],
    WorldFlags.theWorldThatNeverWas.sora.story[gameVer],
    WorldFlags.theWorldThatNeverWas.worldNo,
    WorldFlags.theWorldThatNeverWas.sora.startRoom,
    WorldFlags.theWorldThatNeverWas.sora.battle[gameVer],
    WorldFlags.theWorldThatNeverWas.sora.selectable[gameVer],
    WorldFlags.theWorldThatNeverWas.sora.dockPoint[gameVer]
    }},
    { ID = 2691007, Name = "La Cite des Cloches [Riku]", Type="World", Bytes={
      WorldFlags.laCiteDesCloches.riku.unlocked[gameVer],
      WorldFlags.laCiteDesCloches.riku.story[gameVer],
      WorldFlags.laCiteDesCloches.worldNo,
      WorldFlags.laCiteDesCloches.riku.startRoom,
      WorldFlags.laCiteDesCloches.riku.battle[gameVer],
      WorldFlags.laCiteDesCloches.riku.selectable[gameVer]
      }},
      { ID = 2691008, Name = "The Grid [Riku]", Type="World", Bytes={
      WorldFlags.theGrid.riku.unlocked[gameVer],
      WorldFlags.theGrid.riku.story[gameVer],
      WorldFlags.theGrid.worldNo,
      WorldFlags.theGrid.riku.startRoom,
      WorldFlags.theGrid.riku.battle[gameVer],
      WorldFlags.theGrid.riku.selectable[gameVer]
      }},
      { ID = 2691009, Name = "Prankster's Paradise [Riku]", Type="World", Bytes={
      WorldFlags.prankstersParadise.riku.unlocked[gameVer],
      WorldFlags.prankstersParadise.riku.story[gameVer],
      WorldFlags.prankstersParadise.worldNo,
      WorldFlags.prankstersParadise.riku.startRoom,
      WorldFlags.prankstersParadise.riku.battle[gameVer],
      WorldFlags.prankstersParadise.riku.selectable[gameVer]
    }},
    { ID = 2691010, Name = "Country of Musketeers [Riku]", Type="World", Bytes={
      WorldFlags.countryOfMusketeers.riku.unlocked[gameVer],
    WorldFlags.countryOfMusketeers.riku.story[gameVer],
    WorldFlags.countryOfMusketeers.worldNo,
    WorldFlags.countryOfMusketeers.riku.startRoom,
    WorldFlags.countryOfMusketeers.riku.battle[gameVer],
    WorldFlags.countryOfMusketeers.riku.selectable[gameVer]
    }},
    { ID = 2691011, Name = "Symphony of Sorcery [Riku]", Type="World", Bytes={
      WorldFlags.symphonyOfSorcery.riku.unlocked[gameVer],
    WorldFlags.symphonyOfSorcery.riku.story[gameVer],
    WorldFlags.symphonyOfSorcery.worldNo,
    WorldFlags.symphonyOfSorcery.riku.startRoom,
    WorldFlags.symphonyOfSorcery.riku.battle[gameVer],
    WorldFlags.symphonyOfSorcery.riku.selectable[gameVer]
    }},
    { ID = 2691012, Name = "The World That Never Was [Riku]", Type="World", Bytes={
      WorldFlags.theWorldThatNeverWas.riku.unlocked[gameVer],
    WorldFlags.theWorldThatNeverWas.riku.story[gameVer],
    WorldFlags.theWorldThatNeverWas.worldNo,
    WorldFlags.theWorldThatNeverWas.riku.startRoom,
    WorldFlags.theWorldThatNeverWas.riku.battle[gameVer],
    WorldFlags.theWorldThatNeverWas.riku.selectable[gameVer],
    WorldFlags.theWorldThatNeverWas.riku.dockPoint[gameVer]
    }},

    --Traverse Towns
    { ID = 2691013, Name = "Traverse Town [Sora]", Type="World", Bytes={
      WorldFlags.traverseTown.sora.unlocked[gameVer],
      WorldFlags.traverseTown.sora.story[gameVer],
      WorldFlags.traverseTown.worldNo,
      WorldFlags.traverseTown.sora.startRoom,
      WorldFlags.traverseTown.sora.battle[gameVer],
      WorldFlags.traverseTown.sora.selectable[gameVer]
      }},
    { ID = 2691014, Name = "Traverse Town [Riku]", Type="World", Bytes={
      WorldFlags.traverseTown.riku.unlocked[gameVer],
      WorldFlags.traverseTown.riku.story[gameVer],
      WorldFlags.traverseTown.worldNo,
      WorldFlags.traverseTown.riku.startRoom,
      WorldFlags.traverseTown.riku.battle[gameVer],
      WorldFlags.traverseTown.riku.selectable[gameVer]
      }},


    --{ ID = 2691007, Name = "Traverse Town [Sora]", Type="World", Bytes={0x00}},

    --Training Food
    { ID = 2641002, Name = "Ice Dream Cone", Type="Food", Bytes={0x03, 0x07}},
    { ID = 2641003, Name = "Confetti Candy", Type="Food", Bytes={0x00, 0x07}},
    { ID = 2641007, Name = "Block-It Chocolate", Type="Food", Bytes={0x02, 0x07}},
    { ID = 2641008, Name = "Shield Cookie", Type="Food", Bytes={0x01, 0x07}},
    { ID = 2641019, Name = "Royal Cake", Type="Food", Bytes={0x04, 0x07}},
    { ID = 2641020, Name = "Confetti Candy 2", Type="Food", Bytes={0x05, 0x07}},
    { ID = 2641021, Name = "Shield Cookie 2", Type="Food", Bytes={0x06, 0x07}},
    { ID = 2641022, Name = "Block-It Chocolate 2", Type="Food", Bytes={0x07, 0x07}},
    { ID = 2641023, Name = "Ice Dream Cone 2", Type="Food", Bytes={0x08, 0x07}},

    --Training Toy
    { ID = 2641004, Name = "Balloon (Toy)", Type="Toy", Bytes={0x00, 0x08}},
    { ID = 2641009, Name = "Candy Goggles", Type="Toy", Bytes={0x03, 0x08}},
    { ID = 2641010, Name = "Water Barrel", Type="Toy", Bytes={0x04, 0x08}},
    { ID = 2641011, Name = "Paint Gun: Red", Type="Toy", Bytes={0x05, 0x08}},
    { ID = 2641012, Name = "Paint Gun: Blue", Type="Toy", Bytes={0x06, 0x08}},
    { ID = 2641013, Name = "Paint Gun: Green", Type="Toy", Bytes={0x07, 0x08}},
    { ID = 2641014, Name = "Paint Gun: Yellow", Type="Toy", Bytes={0x08, 0x08}},
    { ID = 2641015, Name = "Paint Gun: White", Type="Toy", Bytes={0x09, 0x08}},
    { ID = 2641016, Name = "Paint Gun: Black", Type="Toy", Bytes={0x0A, 0x08}},
    { ID = 2641017, Name = "Paint Gun: Purple", Type="Toy", Bytes={0x0B, 0x08}},
    { ID = 2641018, Name = "Paint Gun: Sky Blue", Type="Toy", Bytes={0x0C, 0x08}},

    --Recipes
    {ID = 2701001, Name = "Meow Wow Recipe", Type="Recipe", Bytes={0x00, 0x03}},
    {ID = 2701002, Name = "Tama Sheep Recipe", Type="Recipe", Bytes={0x01, 0x03}},
    {ID = 2701003, Name = "Yoggy Ram Recipe", Type="Recipe", Bytes={0x02, 0x03}},
    {ID = 2701004, Name = "Komory Bat Recipe", Type="Recipe", Bytes={0x03, 0x03}},
    {ID = 2701005, Name = "Pricklemane Recipe", Type="Recipe", Bytes={0x04, 0x03}},
    {ID = 2701006, Name = "Hebby Repp Recipe", Type="Recipe", Bytes={0x05, 0x03}},
    {ID = 2701007, Name = "Sir Kyroo Recipe", Type="Recipe", Bytes={0x06, 0x03}},
    {ID = 2701008, Name = "Toximander Recipe", Type="Recipe", Bytes={0x07, 0x03}},
    {ID = 2701009, Name = "Fin Fatale Recipe", Type="Recipe", Bytes={0x08, 0x03}},
    {ID = 2701010, Name = "Tatsu Steed Recipe", Type="Recipe", Bytes={0x09, 0x03}},
    {ID = 2701011, Name = "Necho Cat Recipe", Type="Recipe", Bytes={0x0A, 0x03}},
    {ID = 2701012, Name = "Thunderaffe Recipe", Type="Recipe", Bytes={0x0B, 0x03}},
    {ID = 2701013, Name = "Kooma Panda Recipe", Type="Recipe", Bytes={0x0C, 0x03}},
    {ID = 2701014, Name = "Pegaslick Recipe", Type="Recipe", Bytes={0x0D, 0x03}},
    {ID = 2701015, Name = "Icequin Ace Recipe", Type="Recipe", Bytes={0x0E, 0x03}},
    {ID = 2701016, Name = "Peepsta Hoo Recipe", Type="Recipe", Bytes={0x0F, 0x03}},
    {ID = 2701017, Name = "Escarglow Recipe", Type="Recipe", Bytes={0x10, 0x03}},
    {ID = 2701018, Name = "KO Kabuto Recipe", Type="Recipe", Bytes={0x11, 0x03}},
    {ID = 2701019, Name = "Wheeflower Recipe", Type="Recipe", Bytes={0x12, 0x03}},
    {ID = 2701020, Name = "Ghostabocky Recipe", Type="Recipe", Bytes={0x13, 0x03}},
    {ID = 2701021, Name = "Zolephant Recipe", Type="Recipe", Bytes={0x14, 0x03}},
    {ID = 2701022, Name = "Juggle Pup Recipe", Type="Recipe", Bytes={0x15, 0x03}},
    {ID = 2701023, Name = "Halbird Recipe", Type="Recipe", Bytes={0x16, 0x03}},
    {ID = 2701024, Name = "Staggerceps Recipe", Type="Recipe", Bytes={0x17, 0x03}},
    {ID = 2701025, Name = "Fishbone Recipe", Type="Recipe", Bytes={0x18, 0x03}},
    {ID = 2701026, Name = "Flowbermeow Recipe", Type="Recipe", Bytes={0x19, 0x03}},
    {ID = 2701027, Name = "Cyber Yog Recipe", Type="Recipe", Bytes={0x1A, 0x03}},
    {ID = 2701028, Name = "Chef Kyroo Recipe", Type="Recipe", Bytes={0x1B, 0x03}},
    {ID = 2701029, Name = "Lord Kyroo Recipe", Type="Recipe", Bytes={0x1C, 0x03}},
    {ID = 2701030, Name = "Tatsu Blaze Recipe", Type="Recipe", Bytes={0x1D, 0x03}},
    {ID = 2701031, Name = "Electricorn Recipe", Type="Recipe", Bytes={0x1E, 0x03}},
    {ID = 2701032, Name = "Woeflower Recipe", Type="Recipe", Bytes={0x1F, 0x03}},
    {ID = 2701033, Name = "Jestabocky Recipe", Type="Recipe", Bytes={0x20, 0x03}},
    {ID = 2701034, Name = "Eaglider Recipe", Type="Recipe", Bytes={0x21, 0x03}},
    {ID = 2701035, Name = "Me Me Bunny Recipe", Type="Recipe", Bytes={0x22, 0x03}},
    {ID = 2701036, Name = "Drill Sye Recipe", Type="Recipe", Bytes={0x23, 0x03}},
    {ID = 2701037, Name = "Tyranto Rex Recipe", Type="Recipe", Bytes={0x24, 0x03}},
    {ID = 2701038, Name = "Majik Lapin Recipe", Type="Recipe", Bytes={0x25, 0x03}},
    {ID = 2701039, Name = "Cera Terror Recipe", Type="Recipe", Bytes={0x26, 0x03}},
    {ID = 2701040, Name = "Skelterwild Recipe", Type="Recipe", Bytes={0x27, 0x03}},
    {ID = 2701041, Name = "Ducky Goose Recipe", Type="Recipe", Bytes={0x28, 0x03}},
    {ID = 2701042, Name = "Aura Lion Recipe", Type="Recipe", Bytes={0x29, 0x03}},
    {ID = 2701043, Name = "Ryu Dragon Recipe", Type="Recipe", Bytes={0x2A, 0x03}},
    {ID = 2701044, Name = "Drak Quack Recipe", Type="Recipe", Bytes={0x2B, 0x03}},
    {ID = 2701045, Name = "Keeba Tiger Recipe", Type="Recipe", Bytes={0x2C, 0x03}},
    {ID = 2701046, Name = "Meowjesty Recipe", Type="Recipe", Bytes={0x2D, 0x03}},
    {ID = 2701047, Name = "Sudo Neku Recipe", Type="Recipe", Bytes={0x2E, 0x03}},
    {ID = 2701048, Name = "Frootz Cat Recipe", Type="Recipe", Bytes={0x2F, 0x03}},
    {ID = 2701049, Name = "Ursa Circus Recipe", Type="Recipe", Bytes={0x30, 0x03}},
    {ID = 2701050, Name = "Kab Kannon Recipe", Type="Recipe", Bytes={0x31, 0x03}},
    {ID = 2701051, Name = "R & R Seal Recipe", Type="Recipe", Bytes={0x32, 0x03}},
    {ID = 2701052, Name = "Catanuki Recipe", Type="Recipe", Bytes={0x33, 0x03}},
    {ID = 2701053, Name = "Beatalike Recipe", Type="Recipe", Bytes={0x34, 0x03}},
    {ID = 2701054, Name = "Tubguin Ace Recipe", Type="Recipe", Bytes={0x35, 0x03}},
    
    --Keyblades
    --Sora
    { ID = 2651001, Name = "Skull Noise [Sora]", Type="Keyblades [Sora]", Bytes={0x01, 0x02}, Offset=2},
    { ID = 2651002, Name = "Ultima Weapon [Sora]", Type="Keyblades [Sora]", Bytes={0x08, 0x02}, Offset=16},
    { ID = 2651003, Name = "Guardian Bell [Sora]", Type="Keyblades [Sora]", Bytes={0x02, 0x02}, Offset=4},
    { ID = 2651004, Name = "Ferris Gear [Sora]", Type="Keyblades [Sora]", Bytes={0x03, 0x02}, Offset=6},
    { ID = 2651005, Name = "Dual Disc [Sora]", Type="Keyblades [Sora]", Bytes={0x04, 0x02}, Offset=8},
    { ID = 2651006, Name = "All for One [Sora]", Type="Keyblades [Sora]", Bytes={0x05, 0x02}, Offset=10},
    { ID = 2651007, Name = "Counterpoint [Sora]", Type="Keyblades [Sora]", Bytes={0x06, 0x02}, Offset=12},
    { ID = 2651008, Name = "Sweet Dreams [Sora]", Type="Keyblades [Sora]", Bytes={0x07, 0x02}, Offset=14},
    { ID = 2651009, Name = "Unbound [Sora]", Type="Keyblades [Sora]", Bytes={0x09, 0x02}, Offset=18},
    { ID = 2651010, Name = "Divewing [Sora]", Type="Keyblades [Sora]", Bytes={0x0A, 0x02}, Offset=20},
    { ID = 2651011, Name = "End of Pain [Sora]", Type="Keyblades [Sora]", Bytes={0x0B, 0x02}, Offset=22},
    { ID = 2651012, Name = "Knockout Punch [Sora]", Type="Keyblades [Sora]", Bytes={0x0C, 0x02}, Offset=24},
    --Riku
    { ID = 2651013, Name = "Skull Noise [Riku]", Type="Keyblades [Riku]", Bytes={0x11, 0x02}, Offset=2},
    { ID = 2651014, Name = "Guardian Bell [Riku]", Type="Keyblades [Riku]", Bytes={0x12, 0x02}, Offset=4},
    { ID = 2651015, Name = "Ocean's Rage [Riku]", Type="Keyblades [Riku]", Bytes={0x13, 0x02}, Offset=6},
    { ID = 2651016, Name = "Dual Disc [Riku]", Type="Keyblades [Riku]", Bytes={0x14, 0x02}, Offset=8},
    { ID = 2651017, Name = "All for One [Riku]", Type="Keyblades [Riku]", Bytes={0x15, 0x02}, Offset=10},
    { ID = 2651018, Name = "Counterpoint [Riku]", Type="Keyblades [Riku]", Bytes={0x16, 0x02}, Offset=12},
    { ID = 2651019, Name = "Sweet Dreams [Riku]", Type="Keyblades [Riku]", Bytes={0x17, 0x02}, Offset=14},
    { ID = 2651020, Name = "Ultima Weapon [Riku]", Type="Keyblades [Riku]", Bytes={0x18, 0x02}, Offset=16},
    { ID = 2651021, Name = "Unbound [Riku]", Type="Keyblades [Riku]", Bytes={0x19, 0x02}, Offset=18},
    { ID = 2651022, Name = "Divewing [Riku]", Type="Keyblades [Riku]", Bytes={0x1A, 0x02}, Offset=20},
    { ID = 2651023, Name = "End of Pain [Riku]", Type="Keyblades [Riku]", Bytes={0x1B, 0x02}, Offset=22},
    { ID = 2651024, Name = "Knockout Punch [Riku]", Type="Keyblades [Riku]", Bytes={0x1C, 0x02}, Offset=24},

    --Stats
    { ID = 2631001, Name = "Max HP Up [S]", Type="Stats [Sora]", Bytes={0x14}},
    { ID = 2631002, Name = "Deck Cap Up [S]", Type="Stats [Sora]", Bytes={0x01}},
    { ID = 2631003, Name = "Strength Up [S]", Type="Stats [Sora]", Bytes={0x02}},
    { ID = 2631004, Name = "Magic Up [S]", Type="Stats [Sora]", Bytes={0x02}},
    { ID = 2631005, Name = "Defense Up [S]", Type="Stats [Sora]", Bytes={0x02}},
    { ID = 2631006, Name = "Max HP Up [R]", Type="Stats [Riku]", Bytes={0x14}},
    { ID = 2631007, Name = "Deck Cap Up [R]", Type="Stats [Riku]", Bytes={0x01}},
    { ID = 2631008, Name = "Strength Up [R]", Type="Stats [Riku]", Bytes={0x02}},
    { ID = 2631009, Name = "Magic Up [R]", Type="Stats [Riku]", Bytes={0x02}},
    { ID = 2631010, Name = "Defense Up [R]", Type="Stats [Riku]", Bytes={0x02}},

    --Itemized Stats (for chests)
    { ID = 2631101, Name = "HP Up [Sora]", Type="Stats [Sora]", Bytes={0x23, 0x04}},
    { ID = 2631102, Name = "Deck Up [Sora]", Type="Stats [Sora]", Bytes={0x24, 0x04}},
    { ID = 2631103, Name = "Str Up [Sora]", Type="Stats [Sora]", Bytes={0x25, 0x04}},
    { ID = 2631104, Name = "Mag Up [Sora]", Type="Stats [Sora]", Bytes={0x26, 0x04}},
    { ID = 2631105, Name = "Def Up [Sora]", Type="Stats [Sora]", Bytes={0x27, 0x04}},
    { ID = 2631106, Name = "HP Up [Riku]", Type="Stats [Riku]", Bytes={0x0F, 0x07}},
    { ID = 2631107, Name = "Deck Up [Riku]", Type="Stats [Riku]", Bytes={0x10, 0x07}},
    { ID = 2631108, Name = "Str Up [Riku]", Type="Stats [Riku]", Bytes={0x11, 0x07}},
    { ID = 2631109, Name = "Mag Up [Riku]", Type="Stats [Riku]", Bytes={0x12, 0x07}},
    { ID = 2631110, Name = "Def Up [Riku]", Type="Stats [Riku]", Bytes={0x13, 0x07}},

    --Food itemization (for detailed rewards)
    --{ ID = 2631201, Name = "HP Up [S]", Type="Stats [Sora]", Bytes={0x0F, 0x07}, Addr=ItemOverwrite.food16NameAddr[gameVer]},
    --{ ID = 2631202, Name = "Deck Up [S]", Type="Stats [Sora]", Bytes={0x10, 0x07}, Addr=ItemOverwrite.food17NameAddr[gameVer]},
    --{ ID = 2631203, Name = "Str Up [S]", Type="Stats [Sora]", Bytes={0x11, 0x07}, Addr=ItemOverwrite.food18NameAddr[gameVer]},
    --{ ID = 2631204, Name = "Mag Up [S]", Type="Stats [Sora]", Bytes={0x12, 0x07}, Addr=ItemOverwrite.food19NameAddr[gameVer]},
    --{ ID = 2631205, Name = "Def Up [S]", Type="Stats [Sora]", Bytes={0x13, 0x07}, Addr=ItemOverwrite.food20NameAddr[gameVer]},
    --{ ID = 2631206, Name = "HP Up [R]", Type="Stats [Sora]", Bytes={0x0F, 0x07}, Addr=ItemOverwrite.food16NameAddr[gameVer]},
    --{ ID = 2631207, Name = "Deck Up [R]", Type="Stats [Sora]", Bytes={0x10, 0x07}, Addr=ItemOverwrite.food17NameAddr[gameVer]},
    --{ ID = 2631208, Name = "Str Up [R]", Type="Stats [Sora]", Bytes={0x11, 0x07}, Addr=ItemOverwrite.food18NameAddr[gameVer]},
    --{ ID = 2631209, Name = "Mag Up [R]", Type="Stats [Sora]", Bytes={0x12, 0x07}, Addr=ItemOverwrite.food19NameAddr[gameVer]},
    --{ ID = 2631210, Name = "Def Up [R]", Type="Stats [Sora]", Bytes={0x13, 0x07}, Addr=ItemOverwrite.food20NameAddr[gameVer]},

    --Flowmotion
    { ID = 2661001, Name = "Pole Spin", Type="Flowmotion", Bytes={0x04}},
    { ID = 2661002, Name = "Wall Kick", Type="Flowmotion", Bytes = {0x02}},
    { ID = 2661003, Name = "Super Jump", Type="Flowmotion", Bytes = {0x40}},
    { ID = 2661005, Name = "Rail Slide", Type="Flowmotion", Bytes = {0x10}},
    { ID = 2661004, Name = "Pole Swing", Type="Flowmotion", Bytes = {0x08}},
    { ID = 2661006, Name = "Flowmotion", Type="Flowmotion", Bytes = {0xDE}},

    --Flowmotion Itemized
    { ID = 2661007, Name = "Pole Spin", Type="Flowmotion Item", Bytes={0x1D}},
    { ID = 2661008, Name = "Wall Kick", Type="Flowmotion Item", Bytes={0x1C}},
    { ID = 2661009, Name = "Super Jump", Type="Flowmotion Item", Bytes={0x21}},
    { ID = 2661011, Name = "Rail Slide", Type="Flowmotion Item", Bytes={0x1F}},
    { ID = 2661010, Name = "Pole Swing", Type="Flowmotion Item", Bytes={0x1E}},
    { ID = 2661012, Name = "Flowmotion", Type="Flowmotion Item", Bytes={0x36, 0x03}},

    --Movement
    { ID = 2681080, Name = "High Jump", Type="Command", Usefulness=item_usefulness.progression_useful, Bytes={0x02}},
    { ID = 2681081, Name = "Dodge Roll", Type="Command", Bytes={0x03}},
    { ID = 2681082, Name = "Slide Roll", Type="Command", Usefulness=item_usefulness.normal, Bytes={0x04}},
    { ID = 2681083, Name = "Dark Roll", Type="Command", Usefulness=item_usefulness.normal, Bytes={0x05}},
    { ID = 2681084, Name = "Air Slide", Type="Command", Usefulness=item_usefulness.progression_useful, Bytes={0x06}},
    { ID = 2681085, Name = "Sonic Impact", Type="Command", Usefulness=item_usefulness.normal, Bytes={0x07}},
    { ID = 2681086, Name = "Double Impact", Type="Command", Usefulness=item_usefulness.normal, Bytes={0x08}},
    { ID = 2681087, Name = "Glide", Type="Command", Usefulness=item_usefulness.progression_useful, Bytes={0x09}},
    { ID = 2681088, Name = "Superglide", Type="Command", Usefulness=item_usefulness.progression_useful, Bytes={0x0A}},
    { ID = 2681089, Name = "Shadow Slide", Type="Command", Usefulness=item_usefulness.normal, Bytes={0x0B}},
    { ID = 2681090, Name = "Double Flight", Type="Command", Usefulness=item_usefulness.progression_useful, Bytes={0x0C}},

    --Defense
    { ID = 2681091, Name = "Block", Type="Command", Bytes={0x0D}},
    { ID = 2681092, Name = "Wake-Up Block", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x0E}},
    { ID = 2681093, Name = "Link Block", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x0F}},
    { ID = 2681094, Name = "Sliding Block", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x10}},
    { ID = 2681095, Name = "Dark Barrier", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x11}},
    { ID = 2681096, Name = "Counter Rush", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x12}},
    { ID = 2681097, Name = "Counter Aura", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x13}},
    { ID = 2681098, Name = "Shadow Strike", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x14}},
    { ID = 2681099, Name = "Payback Raid", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x15}},
    { ID = 2681100, Name = "Payback Blast", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x16}},
    { ID = 2681101, Name = "Aerial Recovery", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x17}},
    { ID = 2681102, Name = "Steep Climb", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x18}},
    { ID = 2681103, Name = "Rapid Descent", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x19}},
    { ID = 2681104, Name = "Sliding Sidewinder", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x1A}},
    { ID = 2681105, Name = "Sliding Crescent", Usefulness=item_usefulness.normal, Type="Command", Bytes={0x1B}},


    --Commands
    { ID = 2681001, Name = "Quick Blitz", Type="Command", Bytes={0x28}},
    { ID = 2681002, Name = "Blizzard Edge", Type="Command", Bytes={0x29}},
    { ID = 2681003, Name = "Dark Break", Type="Command", Bytes={0x2A}},
    { ID = 2681004, Name = "Slot Edge", Type="Command", Bytes={0x2B}},
    { ID = 2681005, Name = "Blitz", Type="Command", Bytes={0x2C}},
    { ID = 2681006, Name = "Meteor Crash", Type="Command", Bytes={0x2D}},
    { ID = 2681007, Name = "Spark Dive", Type="Command", Bytes={0x2E}},
    { ID = 2681008, Name = "Poison Dive", Type="Command", Bytes={0x2F}},
    { ID = 2681009, Name = "Drain Dive", Type="Command", Bytes={0x30}},
    { ID = 2681010, Name = "Sliding Dash", Type="Command", Bytes={0x31}},
    { ID = 2681011, Name = "Thunder Dash", Type="Command", Bytes={0x32}},
    { ID = 2681012, Name = "Sonic Blade", Type="Command", Bytes={0x33}},
    { ID = 2681013, Name = "Dark Aura", Type="Command", Bytes={0x34}},
    { ID = 2681014, Name = "Zantetsuken", Type="Command", Bytes={0x35}},
    { ID = 2681015, Name = "Strike Raid", Type="Command", Bytes={0x36}},
    { ID = 2681016, Name = "Spark Raid", Type="Command", Bytes={0x37}},
    { ID = 2681017, Name = "Circle Raid", Type="Command", Bytes={0x38}},
    { ID = 2681018, Name = "Aerial Slam", Type="Command", Bytes={0x39}},
    { ID = 2681019, Name = "Ars Arcanum", Type="Command", Bytes={0x3A}},
    { ID = 2681020, Name = "Dark Splicer", Type="Command", Bytes={0x3B}},
    { ID = 2681021, Name = "Gravity Strike", Type="Command", Bytes={0x3C}},
    { ID = 2681022, Name = "Confusing Strike", Type="Command", Bytes={0x3D}},
    { ID = 2681023, Name = "Tornado Strike", Type="Command", Bytes={0x3E}},
    { ID = 2681024, Name = "Prism Windmill", Type="Command", Bytes={0x3F}},
    { ID = 2681025, Name = "Timestorm", Type="Command", Bytes={0x40}},
    { ID = 2681026, Name = "Fire Windmill", Type="Command", Bytes={0x41}},
    { ID = 2681027, Name = "Icebreaker", Type="Command", Bytes={0x42}},
    { ID = 2681028, Name = "Shadowbreaker", Type="Command", Bytes={0x43}},
    { ID = 2681029, Name = "Magnet Spiral", Type="Command", Bytes={0x44}},
    { ID = 2681030, Name = "Salvation", Type="Command", Bytes={0x45}},
    { ID = 2681031, Name = "Limit Storm", Type="Command", Bytes={0x46}},
    { ID = 2681032, Name = "Collision Magnet", Type="Command", Bytes={0x47}},
    { ID = 2681033, Name = "Sacrifice", Type="Command", Bytes={0x48}},
    { ID = 2681034, Name = "Break Time", Type="Command", Bytes={0x49}},
    { ID = 2681035, Name = "Fire", Type="Command", Bytes={0x4A}},
    { ID = 2681036, Name = "Fira", Type="Command", Bytes={0x4B}},
    { ID = 2681037, Name = "Firaga", Type="Command", Bytes={0x4C}},
    { ID = 2681038, Name = "Dark Firaga", Type="Command", Bytes={0x4D}},
    { ID = 2681039, Name = "Firaga Burst", Type="Command", Bytes={0x4E}},
    { ID = 2681040, Name = "Mega Flare", Type="Command", Bytes={0x4F}},
    { ID = 2681041, Name = "Blizzard", Type="Command", Bytes={0x50}},
    { ID = 2681042, Name = "Blizzara", Type="Command", Bytes={0x51}},
    { ID = 2681043, Name = "Blizzaga", Type="Command", Bytes={0x52}},
    { ID = 2681044, Name = "Icicle Splitter", Type="Command", Bytes={0x53}},
    { ID = 2681045, Name = "Deep Freeze", Type="Command", Bytes={0x54}},
    { ID = 2681046, Name = "Ice Barrage", Type="Command", Bytes={0x55}},
    { ID = 2681047, Name = "Thunder", Type="Command", Bytes={0x56}},
    { ID = 2681048, Name = "Thundara", Type="Command", Bytes={0x57}},
    { ID = 2681049, Name = "Thundaga", Type="Command", Bytes={0x58}},
    { ID = 2681050, Name = "Triple Plasma", Type="Command", Bytes={0x59}},
    { ID = 2681051, Name = "Cure", Type="Command", Bytes={0x5A}},
    { ID = 2681052, Name = "Cura", Type="Command", Bytes={0x5B}},
    { ID = 2681053, Name = "Curaga", Type="Command", Bytes={0x5C}},
    { ID = 2681054, Name = "Esuna", Type="Command", Bytes={0x5D}},
    { ID = 2681055, Name = "Zero Gravity", Type="Command", Bytes={0x5E}},
    { ID = 2681056, Name = "Zero Gravira", Type="Command", Bytes={0x5F}},
    { ID = 2681057, Name = "Zero Graviga", Type="Command", Bytes={0x60}},
    { ID = 2681058, Name = "Zero Graviza", Type="Command", Bytes={0x61}},
    { ID = 2681059, Name = "Balloon (Command)", Type="Command", Bytes={0x62}},
    { ID = 2681060, Name = "Balloonra", Type="Command", Bytes={0x63}},
    { ID = 2681061, Name = "Balloonga", Type="Command", Bytes={0x64}},
    { ID = 2681062, Name = "Spark", Type="Command", Bytes={0x65}},
    { ID = 2681063, Name = "Sparkra", Type="Command", Bytes={0x66}},
    { ID = 2681064, Name = "Sparkga", Type="Command", Bytes={0x67}},
    { ID = 2681065, Name = "Faith", Type="Command", Bytes={0x68}},
    { ID = 2681066, Name = "Tornado", Type="Command", Bytes={0x69}},
    { ID = 2681067, Name = "Meteor", Type="Command", Bytes={0x6A}},
    { ID = 2681068, Name = "Mini", Type="Command", Bytes={0x6B}},
    { ID = 2681069, Name = "Blackout", Type="Command", Bytes={0x6C}},
    { ID = 2681070, Name = "Time Bomb", Type="Command", Bytes={0x6D}},
    { ID = 2681071, Name = "Confuse", Type="Command", Bytes={0x6E}},
    { ID = 2681072, Name = "Bind", Type="Command", Bytes={0x6F}},
    { ID = 2681073, Name = "Poison", Type="Command", Bytes={0x70}},
    { ID = 2681074, Name = "Slow", Type="Command", Bytes={0x71}},
    { ID = 2681075, Name = "Sleep", Type="Command", Bytes={0x72}},
    { ID = 2681076, Name = "Sleepra", Type="Command", Bytes={0x73}},
    { ID = 2681077, Name = "Sleepga", Type="Command", Bytes={0x74}},
    { ID = 2681078, Name = "Stop", Type="Command", Bytes={0x75}},
    { ID = 2681079, Name = "Vanish", Type="Command", Bytes={0x76}},

    { ID = 2641001, Name = "Potion", Type="Consumable", Bytes={0x77} },
    { ID = 2641005, Name = "Hi-Potion", Type="Consumable", Bytes={0x78}},

  }

  return items
end

function ItemDefs:DefineAbilities()
  abilities = {
    --Stat Abilities
    {ID = 2671001, Name = "HP Boost", Stacks=5, Offset = -0x54, Type="Stat", Bytes={0xEC}},
    {ID = 2671002, Name = "Fire Boost", Stacks=3, Offset = -0x51, Type="Stat", Bytes={0xED}},
    {ID = 2671003, Name = "Blizzard Boost", Stacks=3, Offset = -0x4E, Type="Stat", Bytes={0xEE}},
    {ID = 2671004, Name = "Thunder Boost", Stacks=3, Offset = -0x4B, Type="Stat", Bytes={0xEF}},
    {ID = 2671005, Name = "Water Boost", Stacks=3, Offset = -0x48, Type="Stat", Bytes={0xF0}},
    {ID = 2671006, Name = "Cure Boost", Stacks=3, Offset = -0x45, Type="Stat", Bytes={0xF1}},
    {ID = 2671007, Name = "Item Boost", Stacks=3, Offset = -0x42, Type="Stat", Bytes={0xF2}},
    {ID = 2671008, Name = "Attack Haste", Stacks=5, Offset = -0x3F, Type="Stat", Bytes={0xF3}},
    {ID = 2671009, Name = "Magic Haste", Stacks=5, Offset = -0x3C, Type="Stat", Bytes={0xF4}},
    {ID = 2671010, Name = "Attack Boost", Stacks=3, Offset = -0x39, Type="Stat", Bytes={0xF5}},
    {ID = 2671011, Name = "Magic Boost", Stacks=3, Offset = -0x36, Type="Stat", Bytes={0xF6}},
    {ID = 2671012, Name = "Defense Boost", Stacks=3, Offset = -0x33, Type="Stat", Bytes={0xF7}},
    {ID = 2671013, Name = "Fire Screen", Stacks=5, Offset = -0x30, Type="Stat", Bytes={0xF8}},
    {ID = 2671014, Name = "Blizzard Screen", Stacks=5, Offset = -0x2D, Type="Stat", Bytes={0xF9}},
    {ID = 2671015, Name = "Thunder Screen", Stacks=5, Offset = -0x2A, Type="Stat", Bytes={0xFA}},
    {ID = 2671016, Name = "Water Screen", Stacks=5, Offset = -0x27, Type="Stat", Bytes={0xFB}},
    {ID = 2671017, Name = "Dark Screen", Stacks=5, Offset = -0x24, Type="Stat", Bytes={0xFC}},
    {ID = 2671018, Name = "Light Screen", Stacks=5, Offset = -0x21, Type="Stat", Bytes={0xFD}},
    {ID = 2671019, Name = "Mini Block", Stacks=1, Offset = -0x1E, Type="Stat", Bytes={0xFE}},
    {ID = 2671020, Name = "Blindness Block", Stacks=1, Offset = -0x1B, Type="Stat", Bytes={0xFF}},
    {ID = 2671021, Name = "Confusion Block", Stacks=1, Offset = -0x18, Type="Stat", Bytes={0x00, 0x01}},
    {ID = 2671022, Name = "Bind Block", Stacks=1, Offset = -0x15, Type="Stat", Bytes={0x01, 0x01}},
    {ID = 2671023, Name = "Poison Block", Stacks=1, Offset = -0x12, Type="Stat", Bytes={0x02, 0x01}},
    {ID = 2671024, Name = "Slow Block", Stacks=1, Offset = -0x0F, Type="Stat", Bytes={0x03, 0x01}},
    {ID = 2671025, Name = "Sleep Block", Stacks=1, Offset = -0x0C, Type="Stat", Bytes={0x04, 0x01}},
    {ID = 2671026, Name = "Stop Block", Stacks=1, Offset = -0x09, Type="Stat", Bytes={0x05, 0x01}},
    {ID = 2671027, Name = "Reload Boost", Stacks=1, Offset = -0x06, Type="Stat", Bytes={0x06, 0x01}},
    {ID = 2671028, Name = "Defender", Stacks=1, Offset = -0x03, Type="Stat", Bytes={0x07, 0x01}},

    --Support Abilities
    {ID = 2671029, Name = "Combo Plus", Stacks=3, Offset = 0x00, Type="Support", Bytes={0x08, 0x01}},
    {ID = 2671030, Name = "Air Combo Plus", Stacks=3, Offset = 0x03, Type="Support", Bytes={0x09, 0x01}},
    {ID = 2671031, Name = "Combo Master", Stacks=1, Offset = 0x06, Type="Support", Bytes={0x0A, 0x01}},
    {ID = 2671032, Name = "EXP Boost", Stacks=1, Offset = 0x09, Type="Support", Bytes={0x0B, 0x01}},
    {ID = 2671033, Name = "EXP Walker", Stacks=1, Offset = 0x0C, Type="Support", Bytes={0x0C, 0x01}},
    {ID = 2671034, Name = "EXP Zero", Stacks=1, Offset = 0x0F, Type="Support", Bytes={0x0D, 0x01}},
    {ID = 2671035, Name = "Damage Syphon", Stacks=1, Offset = 0x12, Type="Support", Bytes={0x0E, 0x01}},
    {ID = 2671036, Name = "Second Chance", Stacks=1, Offset = 0x15, Type="Support", Bytes={0x0F, 0x01}},
    {ID = 2671037, Name = "Once More", Stacks=1, Offset = 0x18, Type="Support", Bytes={0x10, 0x01}},
    {ID = 2671038, Name = "Scan", Stacks=1, Offset = 0x1B, Type="Support", Bytes={0x11, 0x01}},
    {ID = 2671039, Name = "Leaf Bracer", Stacks=1, Offset = 0x1E, Type="Support", Bytes={0x12, 0x01}},
    {ID = 2671040, Name = "Treasure Magnet", Stacks=5, Offset = 0x21, Type="Support", Bytes={0x13, 0x01}},
    --Spirit Abilities
    {ID = 2671041, Name = "Link Critical", Stacks=1, Offset = 0x24, Type="Spirit", Bytes={0x14, 0x01}},
    {ID = 2671042, Name = "Support Boost", Stacks=3, Offset = 0x27, Type="Spirit", Bytes={0x15, 0x01}},
    {ID = 2671043, Name = "Waking Dream", Stacks=1, Offset = 0x2A, Type="Spirit", Bytes={0x16, 0x01}},
    {ID = 2672000, Name = "Ability", Bytes={0x0F, 0x08}}
  }
  return abilities
end

return ItemDefs