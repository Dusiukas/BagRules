-- Icon catalogue and recommendations. No dependency on the inventory renderer.
local _,BR=...
local I={};BR.IconSearch=I
local function normalize(s) return (tostring(s or ""):lower():gsub("[_%-%./\\]"," "):gsub("%s+"," ")) end
local synonyms={armour="armor",armors="armor",armours="armor",weapons="weapon",swords="sword",axes="axe",daggers="dagger",shields="shield",potions="potion",elixirs="elixir",herbs="herb",ores="ore",reagents="reagent",materials="material",recipes="recipe",containers="container",bags="bag",mounts="mount",pets="pet",rings="ring",scrolls="scroll",teleports="teleport",stones="stone",gems="gem",jewellery="jewelry",consumables="consumable",professions="profession",bandages="bandage",hearthstones="hearthstone",fish="fish",cooking="cook",fishing="fish",tailoring="cloth",herbalism="herb",mining="ore",skin="leather",skinning="leather",firstaid="bandage",boe="equipment"}
local function tokens(s)
    local a,seen={},{};for w in normalize(s):gmatch("[%w\128-\255]+") do w=synonyms[w] or w;if not seen[w] then seen[w]=true;a[#a+1]=w end end;return a
end
local themes={
    Equipment={"weapon","sword","axe","mace","dagger","shield","armor","helmet","chest","boot","glove","ring","jewelry","staff","bow","wand","equipment"},
    Consumables={"potion","elixir","flask","drink","food","bread","meat","fish","bandage","consumable","cook","healing"},
    Materials={"cloth","linen","fabric","silk","thread","herb","plant","leather","hide","ore","mining","stone","gem","enchant","reagent","craft","material","profession","recipe","anvil","hammer","engineering","tailor"},
    Utility={"bag","container","backpack","key","hearthstone","teleport","portal","scroll","book","quest","map","mount","pet","utility"},
    Currency={"coin","gold","silver","copper","money","auction","currency","token","jewelry"},
    Creatures={"bear","wolf","cat","dragon","beast","pet","mount","horse","animal","bird","spider","demon","creature"},
    Magic={"spell","ability","magic","fire","frost","ice","shadow","holy","nature","arcane","lightning","rune","heal"},
}
I.groups={"All","Suggested","Inventory","Items","Spells","Equipment","Consumables","Materials","Utility","Currency","Creatures","Magic","Unlabelled"}
-- A separate, overlapping taxonomy; detailed categories are advisory browsing
-- labels, not exclusive item classes or verified spell restrictions. Prefer exact
-- filename/name tokens (including common compound WoW filename tokens).
local taxonomy={
 {"Equipment",{
  {"Swords","sword greatsword longsword shortsword claymore blade"},
  {"Axes","axe greataxe hatchet"},{"Maces & hammers","mace hammer maul warhammer"},
  {"Daggers & fist weapons","dagger fistweapon knuckle knife"},{"Staves & polearms","staff stave staves polearm spear halberd"},
  {"Bows & ranged","bow crossbow gun rifle pistol ranged"},{"Wands","wand"},{"Shields & off-hands","shield buckler offhand"},
  {"Head & shoulders","helmet helm hat head shoulder shoulders hood crown tiara"},{"Chest & robes","chest robe tunic vest breastplate"},
  {"Hands & wrists","glove gloves gauntlet gauntlets bracer bracers wrist"},{"Waist, legs & feet","belt waist pants leggings legs trousers boot boots shoe"},
  {"Cloaks","cape cloak"},{"Jewellery & trinkets","ring jewelry necklace pendant amulet trinket"},
  {"Shirts & tabards","shirt tabard"},{"Ammunition & quivers","ammo ammunition arrow bullet projectile quiver"},
 }},
 {"Consumables",{
  {"Potions","potion"},{"Elixirs & flasks","elixir flask"},{"Food & cooking","food bread cheese meat jerky steak feast cook stew soup ration"},
  {"Drinks","drink water beverage milk juice ale beer wine"},{"Bandages & remedies","bandage firstaid antidote salve remedy"},
  {"Poisons & oils","poison venom oil coating"},{"Scrolls & buffs","scroll buff"},{"Explosives","bomb dynamite grenade explosive explosives"},
 }},
 {"Materials",{
  {"Cloth & thread","cloth linen silk wool fabric thread spool textile mageweave runecloth"},
  {"Leather & hides","leather hide pelt skin scale"},{"Herbs & plants","herb plant flower leaf root seed mushroom peacebloom"},
  {"Ore, bars & stone","ore bar ingot metal stone mineral coal"},{"Gems & crystals","gem jewel crystal diamond ruby sapphire emerald pearl"},
  {"Enchanting materials","enchant enchanting dust essence shard"},{"Elemental reagents","elemental mote primal eternal volatile"},
  {"Meat, fish & eggs","meat fish egg claw fang bone"},{"Parts & devices","cog gear spring screw bolt parts device engineering"},
  {"Wood & crafting tools","wood log lumber anvil tool hammer pickaxe"},
 }},
 {"Professions",{
  {"Alchemy","alchemy alchemist potion elixir flask cauldron transmute"},{"Blacksmithing","blacksmith blacksmithing smithing anvil ingot"},
  {"Enchanting","enchant enchanting enchantment disenchant dust essence"},{"Engineering","engineer engineering cog dynamite gadget gizmo"},
  {"Herbalism","herbalism herb plant flower"},{"Leatherworking","leatherworking leather hide"},{"Mining","mining mine ore pickaxe ingot"},
  {"Skinning","skin skinning hide pelt"},{"Tailoring","tailor tailoring cloth linen fabric thread spool"},{"Cooking","cook chef cooking food stew feast"},
  {"Fishing","fish fishing fishingpole fishingrod"},{"First Aid","firstaid bandage"},{"Jewelcrafting","jewelcrafting gem jewelry jewel"},
  {"Inscription","inscription glyph ink parchment quill"},{"Recipes & plans","recipe pattern schematic formula plans blueprint"},
 }},
 {"Character classes",{
  {"Warrior","warrior charge battlecry bloodthirst whirlwind overpower"},{"Paladin","paladin crusader judgement judgment consecration layonhands"},
  {"Hunter","hunter aimedshot multishot arcaneshot serpentsting beastcall"},{"Rogue","rogue stealth backstab sinisterstrike pickpocket vanish"},
  {"Priest","priest smite renew psychicflay mindflay prayer"},{"Shaman","shaman totem chainlightning chainheal windfury bloodlust"},
  {"Mage","mage fireball frostbolt arcaneintellect polymorph blink"},{"Warlock","warlock corruption shadowbolt soulstone felguard"},
  {"Druid","druid moonfire starfire rejuvenation bearform catform"},{"Death Knight","deathknight runeweapon deathcoil runeblade"},
  {"Monk","monk chi mistweaver windwalker brewmaster"},{"Demon Hunter","demonhunter warglaive felrush"},{"Evoker","evoker dracthyr empower"},
 }},
 {"Magic",{
  {"Fire","fire flame flames fireball burn inferno lava molten pyroblast"},{"Frost & ice","frost ice frozen snow blizzard frostbolt"},
  {"Arcane","arcane arcaneintellect arcaneexplosion mana"},{"Holy & light","holy light divine blessing prayer smite sacred"},
  {"Shadow & void","shadow void darkness dark shadowbolt"},{"Nature","nature plant leaf entangle thorn moonfire"},
  {"Lightning & storms","lightning thunder storm chainlightning shock"},{"Fel & demonic","fel demon demonic infernal"},
  {"Healing & restoration","heal healing restore restoration renew rejuvenation"},{"Runes & enchantments","rune runes enchant enchantment glyph"},
  {"Buffs & protection","buff barrier protect protection ward aura blessing"},{"Movement & travel spells","blink teleport portal sprint dash flight"},
 }},
 {"Creatures",{
  {"Beasts & woodland","bear wolf fox cat lion tiger boar deer stag beast rabbit"},{"Birds & flying creatures","bird eagle owl hawk raven gryphon bat"},
  {"Dragons & reptiles","dragon drake wyrm lizard snake serpent raptor"},{"Insects & arachnids","spider insect beetle scorpion wasp moth silithid"},
  {"Undead","undead skeleton skull zombie ghoul lich"},{"Demons & elementals","demon imp infernal felguard elemental"},
  {"Aquatic creatures","fish shark crab turtle aquatic octopus"},{"Mounts","mount horse steed ram riding kodo"},{"Pets & companions","pet companion critter"},
 }},
 {"Utility",{
  {"Bags & containers","bag container backpack chest box crate pouch sack barrel"},{"Keys & locks","key lock lockbox lockpick"},
  {"Travel & hearthstones","hearthstone teleport portal map compass travel flight"},{"Quest items & books","quest book scroll letter document note journal"},
  {"Tokens & reputation","token badge emblem insignia reputation commendation"},{"Tools & gadgets","tool wrench gadget gizmo lantern torch rope"},
  {"Money & valuables","money coin gold silver copper currency treasure auction"},{"Junk & broken items","junk trash broken scrap rubble"},
 }},
 {"Symbols & scenery",{
  {"Flags & banners","flag banner standard pennant"},{"Stars & celestial","star stars sun moon eclipse celestial"},
  {"Skulls & bones","skull bone skeleton"},{"Hearts & health","heart health life"},{"Marks & symbols","symbol mark icon question exclamation check cross circle"},
  {"Buildings & locations","building tower castle house city tavern dungeon"},{"Water & weather","water rain snow wind storm cloud"},
 }},
}
I.groups={"All","Suggested","Inventory","Items","Spells","Equipment","Consumables","Materials","Utility","Currency","Creatures","Magic","Unlabelled"}
I.details={};local detailParents={};local detailWords={};local groupWords={}
for key,terms in pairs(themes) do for _,w in ipairs(terms) do groupWords[w]=groupWords[w] or {};groupWords[w][key]=true end end
for _,family in ipairs(taxonomy) do
    I.details[#I.details+1]=family[1].." / All"
    for _,entry in ipairs(family[2]) do
        local key=family[1].." / "..entry[1];I.details[#I.details+1]=key;detailParents[key]=family[1]
        for _,w in ipairs(tokens(entry[2])) do detailWords[w]=detailWords[w] or {};detailWords[w][key]=true end
    end
end
local classGroups={ [0]="Consumables",[1]="Utility",[2]="Equipment",[4]="Equipment",[5]="Materials",[6]="Equipment",[7]="Materials",[9]="Materials",[11]="Utility",[12]="Utility",[13]="Utility",[15]="Utility" }
-- Stable Classic class/subclass IDs for item metadata collected from the bags.
local materialSub={ [5]="Cloth & thread",[6]="Leather & hides",[7]="Ore, bars & stone",[8]="Meat, fish & eggs",[9]="Herbs & plants",[10]="Elemental reagents",[12]="Enchanting materials",[1]="Parts & devices",[2]="Parts & devices",[3]="Parts & devices" }
local weaponSub={ [0]="Axes",[1]="Axes",[2]="Bows & ranged",[3]="Bows & ranged",[4]="Maces & hammers",[5]="Maces & hammers",[6]="Staves & polearms",[7]="Swords",[8]="Swords",[10]="Staves & polearms",[13]="Daggers & fist weapons",[15]="Daggers & fist weapons",[18]="Bows & ranged",[19]="Wands" }
local consumableSub={ [1]="Potions",[2]="Elixirs & flasks",[3]="Elixirs & flasks",[5]="Food & cooking",[7]="Bandages & remedies" }
local slotGroup={INVTYPE_HEAD="Head & shoulders",INVTYPE_SHOULDER="Head & shoulders",INVTYPE_CHEST="Chest & robes",INVTYPE_ROBE="Chest & robes",INVTYPE_HAND="Hands & wrists",INVTYPE_WRIST="Hands & wrists",INVTYPE_WAIST="Waist, legs & feet",INVTYPE_LEGS="Waist, legs & feet",INVTYPE_FEET="Waist, legs & feet",INVTYPE_CLOAK="Cloaks",INVTYPE_FINGER="Jewellery & trinkets",INVTYPE_NECK="Jewellery & trinkets",INVTYPE_TRINKET="Jewellery & trinkets",INVTYPE_SHIELD="Shields & off-hands",INVTYPE_HOLDABLE="Shields & off-hands",INVTYPE_BODY="Shirts & tabards",INVTYPE_TABARD="Shirts & tabards"}
local function classify(v)
    v.search=normalize(v.search);v.words={};v.groups={}
    local function tag(key) if key then v.groups[key]=true;local parent=detailParents[key];if parent then v.groups[parent.." / All"]=true;if themes[parent] then v.groups[parent]=true end end end end
    local function tags(w) for g in pairs(groupWords[w] or {}) do tag(g) end;for g in pairs(detailWords[w] or {}) do tag(g) end end
    for _,w in ipairs(tokens(v.search)) do
        v.words[w]=true;tags(w)
        -- WoW filenames often attach a numeric variant directly to the word.
        -- Retain the exact word and index its stem, e.g. fireball02 -> fireball.
        local stem=w:match("^(%a+)%d+$")
        if stem then stem=synonyms[stem] or stem;v.words[stem]=true;tags(stem) end
    end
    for _,item in ipairs(v.items or {}) do
        local class,sub=item.class,item.subclass;tag(classGroups[class])
        -- Metadata labels enrich browsing without inventing a new icon filename.
        for _,w in ipairs(tokens(item.subtype)) do tags(w) end
        if class==7 and materialSub[sub] then tag("Materials / "..materialSub[sub]) end
        if class==2 and weaponSub[sub] then tag("Equipment / "..weaponSub[sub]) end
        if class==0 and consumableSub[sub] then tag("Consumables / "..consumableSub[sub]) end
        if slotGroup[item.slot] then tag("Equipment / "..slotGroup[item.slot]) end
        if class==1 then tag("Utility / Bags & containers") elseif class==9 then tag("Professions / Recipes & plans") elseif class==12 then tag("Utility / Quest items & books") elseif class==13 then tag("Utility / Keys & locks") elseif class==6 or class==11 then tag("Equipment / Ammunition & quivers") end
    end
    v.named=next(v.labels)~=nil
end
local iconSeeds={{134400,"Question mark unknown"},{132889,"Cloth tailoring linen fabric"},{134205,"Herb herbalism plant"},{132624,"Equipment weapon"},{134829,"Potion consumable"},{134939,"Recipe scroll book"},{133784,"Coin gold money auction"},{132996,"Materials crafting reagents"},{132382,"Ammunition arrow"},{134414,"Bag container"},{133651,"Food drink"},{133587,"Gem jewel"},{134179,"Leather skinning"},{134183,"Ore mining"},{134332,"Fishing fish"},{133644,"Utility"}}
local function validIcon(id) id=tonumber(id);return id and id>0 and id<100000000 and id%1==0 and id or nil end
local function iconID(v)
    local id=validIcon(v);if id then return id end
    if type(v)~="string" then return end
    local path=v:find("\\",1,true) and v or "Interface\\Icons\\"..v
    local fn=C_Texture and C_Texture.GetFileIDFromPath or GetFileIDFromPath
    if type(fn)=="function" then local ok,x=pcall(fn,path);if ok then return validIcon(x) end end
end
local function iconCatalogue(light)
    local a,seen={},{}
    local localNames=type(BR.IconFileIndex)=="table" and BR.IconFileIndex or {}
    local function hasFilename(v) return type(localNames[v.id])=="string" end
    local function add(raw,name,source,item)
        local id=iconID(raw);if not id then return end
        if type(name)~="string" or name=="" then name=nil end
        local alias=type(raw)=="string" and not tonumber(raw) and raw or nil
        local v=seen[id]
        if not v then v={id=id,name=tostring(id),search=tostring(id),sources={},labels={},items={}};seen[id]=v;a[#a+1]=v end
        if source then v.sources[source]=true end
        local function addName(n)
            if n and not v.labels[n] then v.labels[n]=true;v.search=v.search.." "..normalize(n);if v.name==tostring(id) then v.name=n end end
        end
        addName(name);addName(alias)
        if item then v.items[#v.items+1]=item end
    end
    for _,v in ipairs(iconSeeds) do add(v[1],v[2],"Named") end
    -- Resolve familiar Classic item examples using the client's item icon API.
    local itemIcon=C_Item and C_Item.GetItemIconByID or GetItemIcon
    if type(itemIcon)=="function" then for _,v in ipairs({
        {6948,"Hearthstone teleport"},{2589,"Linen cloth tailoring"},{2318,"Light leather skinning"},
        {2447,"Peacebloom herb herbalism"},{2770,"Copper ore mining"},{10940,"Strange dust enchanting"},
        {118,"Minor healing potion alchemy"},{1251,"Linen bandage first aid"},{6291,"Raw brilliant smallfish fishing"},
        {4470,"Simple wood reagent"},{2840,"Copper bar metal blacksmithing"},{117,"Tough jerky food"},
        {159,"Refreshing spring water drink"},{2512,"Rough arrow ammunition"},{2835,"Rough stone"}
    }) do local ok,id=pcall(itemIcon,v[1]);if ok then add(id,v[2],"Items") end end end
    -- Do not associate an arbitrary old category name with the question mark.
    -- User-chosen icons remain searchable by ID, but names come from game data.
    for _,c in ipairs(BR.db.categories or {}) do add(c.icon,nil,"Used") end
    for _,g in ipairs(BR.db.sections or {}) do add(g.icon,nil,"Used") end
    if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo then
        for bag=0,(NUM_BAG_SLOTS or 4) do for slot=1,(C_Container.GetContainerNumSlots(bag) or 0) do
            local i=C_Container.GetContainerItemInfo(bag,slot)
            if i and i.itemID then local x=BR:Item(i.hyperlink,i.itemID,bag,slot,i.quality);add(i.iconFileID or (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(i.itemID)),x.name,"Inventory",x) end
        end end
    end
    if light then
        for _,v in ipairs(a) do
            if hasFilename(v) then add(v.id,localNames[v.id],"Named");v.filename=localNames[v.id] end
            classify(v)
        end
        return a
    end
    -- Optional community filename index, loaded only when opening the picker.
    if type(ICON_FILE_NAMES)~="table" and C_AddOns and C_AddOns.GetAddOnInfo and C_AddOns.LoadAddOn then
        local ok,name=pcall(C_AddOns.GetAddOnInfo,"IconFileNames");if ok and name then pcall(C_AddOns.LoadAddOn,"IconFileNames") end
    end
    local names=type(ICON_FILE_NAMES)=="table" and ICON_FILE_NAMES or {}
    for _,fn in ipairs({"GetMacroIcons","GetMacroItemIcons","GetLooseMacroIcons","GetLooseMacroItemIcons"}) do
        local api=_G[fn] or (C_Macro and C_Macro[fn]);if type(api)=="function" then local t={};local ok,result=pcall(api,t);if ok then if type(result)=="table" then t=result end;for _,v in ipairs(t) do add(v,names[iconID(v)],fn:find("Item") and "Items" or "Spells") end end end
    end
    -- Index names of known player spells when the client exposes its spellbook.
    local sb=C_SpellBook;local spell=C_Spell;local bank=Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    if sb and bank and sb.GetNumSpellBookSkillLines and sb.GetSpellBookSkillLineInfo and sb.GetSpellBookItemInfo then
        local ok,n=pcall(sb.GetNumSpellBookSkillLines);if ok and type(n)=="number" then for k=1,math.min(n,100) do
            local good,line=pcall(sb.GetSpellBookSkillLineInfo,k);if good and line and line.itemIndexOffset and line.numSpellBookItems then for index=line.itemIndexOffset+1,line.itemIndexOffset+math.min(line.numSpellBookItems,1000) do
                local valid,info=pcall(sb.GetSpellBookItemInfo,index,bank);if valid and info then local sp=info.spellID and spell and spell.GetSpellInfo and spell.GetSpellInfo(info.spellID);if sp then add(sp.iconID,sp.name,"Spells") end end
            end end
        end end
    elseif GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemName and GetSpellBookItemTexture then
        for tab=1,GetNumSpellTabs() do local _,_,offset,count=GetSpellTabInfo(tab);if offset and count then for i=offset+1,offset+count do add(GetSpellBookItemTexture(i,BOOKTYPE_SPELL or "spell"),GetSpellBookItemName(i,BOOKTYPE_SPELL or "spell"),"Spells") end end end
    end
    -- Only intersect optional filename data with icons available on this client.
    for _,v in ipairs(a) do
        local n=names[v.id];if type(n)=="string" then add(v.id,n,"Named") end
        -- Enrich only IDs actually collected from the client, never inject the
        -- whole listfile (which includes other expansions and unavailable assets).
        if hasFilename(v) then add(v.id,localNames[v.id],"Named");v.filename=localNames[v.id]
        elseif type(n)=="string" and n~="" then v.filename=n end
        classify(v)
    end
    return a
end
I.Catalogue=iconCatalogue
BR.IconCatalogue=iconCatalogue
I.ValidID=validIcon
I.ID=iconID

local stop={new=true,subcategory=true,category=true,other=true,general=true,all=true,["and"]=true,items=true,item=true,of=true,the=true,permanent=true,world=true,copy=true}
local metadataWords={ [0]="consumable",[1]="bag container",[2]="weapon equipment",[4]="armor equipment",[5]="material reagent",[6]="ammunition arrow",[7]="material reagent",[9]="recipe",[11]="container",[12]="quest",[15]="miscellaneous utility" }
local aliases={cloth="cloth linen fabric textile silk thread",herb="herb plant flower herbalism",leather="leather hide skin",ore="ore mining metal stone",equipment="equipment weapon armor",profession="craft material reagent tool",consumable="consumable potion food drink",jewelry="ring jewel jewelry gem",auction="auction coin gold money",boe="equipment weapon armor",quest="quest scroll book",hearthstone="hearthstone stone teleport",portal="portal teleport",teleport="teleport portal",enchanting="enchant dust essence magic",recipe="recipe book scroll",bandage="bandage first aid",fishing="fish fishing",fish="fish fishing",utility="utility bag key",mount="mount horse",pet="pet animal",junk="junk trash",reagent="reagent material craft"}
function I.Context(name,filters,parent)
    local c={name=name or "",weights={},methods=filters and (filters.methods or {filters}) or {},parent=parent or ""}
    local function add(s,weight) for _,w in ipairs(tokens(s)) do if not stop[w] and #w>1 then c.weights[w]=math.max(c.weights[w] or 0,weight);for _,a in ipairs(tokens(aliases[w])) do c.weights[a]=math.max(c.weights[a] or 0,math.floor(weight/3)) end end end end
    add(name,18);add(parent,3)
    local catalogue
    for _,m in ipairs(c.methods) do if m.subclasses and not catalogue and BR.Filters and BR.Filters.Catalogue then catalogue=BR.Filters.Catalogue() end end
    for _,m in ipairs(c.methods) do
        for _,id in ipairs(m.classes or {}) do add(metadataWords[id],6) end
        for _,id in ipairs(m.subclasses or {}) do local x,y=id:match("^(%d+):(%d+)$");for _,cl in ipairs(catalogue or {}) do if cl.id==tonumber(x) then for _,sub in ipairs(cl.subclasses) do if sub.id==tonumber(y) then add(sub.name,12) end end end end end
        for _,w in ipairs(m.names or {}) do add(w,5) end;add(m.name,5)
        if m.quest then add("quest",9) end
    end
    return c
end
function I.Score(v,c)
    if v.id==134400 or not c then return 0 end
    local score=0;local primary=false
    for w,weight in pairs(c.weights) do
        if v.words[w] then score=score+weight;if weight>=6 then primary=true end
        elseif v.search:find(w,1,true) then score=score+math.max(1,math.floor(weight/3));if weight>=12 and #w>=5 and v.search:find(" "..w,1,true) then primary=true end end
    end
    if BR.Filters then for _,item in ipairs(v.items or {}) do for _,m in ipairs(c.methods) do if BR.Filters.Eval(m,item)==true then score=score+30;primary=true;break end end;if primary and score>=30 then break end end end
    if not primary then return 0 end
    return score
end
function I.Rank(data,context)
    for _,v in ipairs(data) do v.score=(v.named or #v.items>0) and I.Score(v,context) or 0 end
    table.sort(data,function(a,b) if a.score~=b.score then return a.score>b.score end;return a.id<b.id end)
    return data
end
function I.Best(data,context)
    local chosen,best=nil,0;for _,v in ipairs(data) do local score=(v.named or #v.items>0) and I.Score(v,context) or 0;if score>best or score==best and score>0 and chosen and v.id<chosen then chosen,best=v.id,score end end
    return best>=6 and chosen or nil
end
function I.Suggest(name,filters,parent,full)
    return I.Best(iconCatalogue(not full),I.Context(name,filters,parent))
end
-- Plan/commit only missing icons. Existing explicit icons are never replaced.
function I.MissingPlan()
    local data=iconCatalogue(false);local a={}
    local function plan(kind,o,filters,parent)
        if o.icon and o.icon~=134400 then return end
        local id=I.Best(data,I.Context(o.name,filters,parent));if id then a[#a+1]={kind=kind,key=o.id,old=o.icon,id=id,name=o.name} end
    end
    for _,g in ipairs(BR.db.sections or {}) do if g.name~="" then plan("parent",g) end end
    for _,c in ipairs(BR.db.categories or {}) do plan("child",c,c.filters,c.section) end
    return a
end
local function target(r) if r.kind=="parent" then return BR:GetSection(r.key) elseif r.kind=="child" then return BR:Get(r.key) end end
function I.ApplyMissing(plan)
    if InCombatLockdown and InCombatLockdown() then return nil,"Change icons outside combat." end
    local backup={};for _,r in ipairs(plan or {}) do local o=target(r);if o and o.name==r.name and o.icon==r.old and (not o.icon or o.icon==134400) then o.icon=r.id;backup[#backup+1]=r end end
    if #backup>0 then BR.db.iconBackup=backup;BR:Apply() end;return #backup
end
function I.UndoMissing()
    if InCombatLockdown and InCombatLockdown() then return nil,"Change icons outside combat." end
    local n=0;for _,r in ipairs(BR.db.iconBackup or {}) do local o=target(r);if o and o.name==r.name and o.icon==r.id then o.icon=r.old;n=n+1 end end
    BR.db.iconBackup=nil;if n>0 then BR:Apply() end;return n
end
function I.Search(data,query,group)
    local q=tokens(query);local results={};local numeric=tostring(query or ""):match("^%s*(%d+)%s*$")
    for _,v in ipairs(data) do
        local accept=group==nil or group=="All" or group=="Suggested" and (v.score or 0)>0 or group=="Unlabelled" and not v.named or v.groups[group] or v.sources[group]
        if accept then for _,w in ipairs(q) do if not v.words[w] and not v.search:find(w,1,true) then accept=false;break end end end
        if accept then results[#results+1]=v end
    end
    -- Exact numeric lookup before partial file-ID matches. Full search stays available.
    if numeric then local id=tonumber(numeric);for i,v in ipairs(results) do if v.id==id then table.remove(results,i);table.insert(results,1,v);break end end end
    return results
end
