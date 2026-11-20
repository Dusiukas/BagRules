local ADDON, BR = ...
local R=BR.Rules
local F=BR.Filters
BR.version="0.7.4-alpha.1"
local defaults={
    {name="Quest Items",expr="quest",icon=134400},
    {name="Recipes",expr="recipe",icon=134939},
    {name="Auction Candidates",expr="unbound & (weapon | armor) & quality >= uncommon & ahprice >= 20s & ratio >= 2",icon=133784},
    {name="Cloth",expr='tradegoods & subclass = 5',icon=132889},
    {name="Herbs",expr='tradegoods & subclass = 9',icon=134205},
    {name="Materials",expr="tradegoods | reagent",icon=132996},
    {name="Ammunition",expr="ammunition",icon=132382},
    {name="Equipment",expr="weapon | armor",icon=132624},
    {name="Consumables",expr="consumable",icon=134829}
}
BR.templates=defaults
local registered,compiled={},{}
local viewID="BagRules:inventory"
local metadata,prices={},{}
local function trim(s) return (s:match("^%s*(.-)%s*$")) end
local function copy(c) local n={}; for k,v in pairs(c) do n[k]=v end; return n end
local function manualIDs(t) local a,seen={},{}; if type(t)=="table" then for _,v in ipairs(t) do if type(v)=="number" and v>0 and v<=2147483647 and v%1==0 and not seen[v] and #a<1000 then a[#a+1]=v; seen[v]=true end end end; return a end
local function priority(v) local n=tonumber(v); if n and n==n and n%1==0 and math.abs(n)<=10000 then return n end; return 0 end
local function text(v,n) return type(v)=="string" and v:sub(1,n) or "" end
local function cleanName(s) return type(s)=="string" and trim(s):gsub("[%c|]", ""):sub(1,80) or "" end
local function safeIcon(v) local n=tonumber(v); if n and n>0 and n<100000000 and n%1==0 then return n end; return 134400 end
function BR:Print(s) print("|cff07d59dBagRules|r: "..tostring(s)) end
-- Parent IDs are authoritative. section is a derived compatibility label for
-- the existing native renderer and older profile readers, not editable state.
function BR:GetSection(key)
    for _,g in ipairs(self.db.sections or {}) do if g.id==key then return g end end
end
function BR:FindSection(name)
    for _,g in ipairs(self.db.sections or {}) do if g.name==name then return g end end
end
function BR:EnsureSection(name)
    name=cleanName(name); local g
    for _,old in ipairs(self.db.sections or {}) do if old.name==name then return old end end
    self.db.sections=self.db.sections or {}; self.db.nextSectionID=(self.db.nextSectionID or 0)+1
    g={id=name=="" and "ungrouped" or "s"..self.db.nextSectionID,name=name,enabled=true}
    self.db.sections[#self.db.sections+1]=g;return g
end
function BR:SyncHierarchy()
    for _,c in ipairs(self.db.categories) do
        local g=self:GetSection(c.sectionID) or self:EnsureSection(c.section or "")
        c.sectionID=g.id;c.section=g.name
    end
end
function BR:NewSection(name)
    name=cleanName(name);if name=="" then return nil,"Enter a parent category name" end
    if name=="Ungrouped" then return nil,"Ungrouped is reserved" end
    for _,g in ipairs(self.db.sections) do if g.name:lower()==name:lower() then return nil,"A parent with that name already exists" end end
    if #self.db.sections>=100 then return nil,"Maximum 100 parent categories" end
    return self:EnsureSection(name)
end
function BR:RenameSection(key,name)
    local g=self:GetSection(key); name=cleanName(name)
    if not g or g.id=="ungrouped" or name=="" or name=="Ungrouped" then return nil,"Choose a named parent and enter a valid name" end
    for _,other in ipairs(self.db.sections) do if other~=g and other.name:lower()==name:lower() then return nil,"A parent with that name already exists" end end
    local old=g.name;g.name=name;self:SyncHierarchy()
    if self.RuntimeSections and self.RuntimeSections.collapsed then local t=self.RuntimeSections.collapsed;t[name]=t[old];if old~=name then t[old]=nil end end
    self:Apply();return true
end
function BR:SetSectionIcon(key,icon)
    local g=self:GetSection(key);if not g then return nil,"Parent not found" end
    if InCombatLockdown and InCombatLockdown() then return nil,"Change icons outside combat" end
    if icon~=nil and safeIcon(icon)~=tonumber(icon) then return nil,"Invalid icon file ID" end
    g.icon=icon and tonumber(icon) or nil;self:Apply();return true
end
function BR:SetSectionEnabled(key,on)
    local g=self:GetSection(key);if not g then return nil,"Parent not found" end;g.enabled=not not on;self:Apply();return true
end
function BR:DeleteSection(key,destination)
    local g=self:GetSection(key);if not g or g.id=="ungrouped" then return nil,"Ungrouped cannot be deleted" end
    local dest=destination and self:GetSection(destination)
    if dest==g then return nil,"Choose another destination" end
    for _,c in ipairs(self.db.categories) do if c.sectionID==g.id then
        if not dest then return nil,"Move children before deleting this parent" end
    end end
    if dest then
        local kept,moving={},{}
        for _,c in ipairs(self.db.categories) do if c.sectionID==g.id then c.sectionID=dest.id;c.section=dest.name;moving[#moving+1]=c else kept[#kept+1]=c end end
        for _,c in ipairs(moving) do kept[#kept+1]=c end
        self.db.categories=kept
    end
    for i,x in ipairs(self.db.sections) do if x==g then table.remove(self.db.sections,i);break end end
    self:Apply();return true
end
function BR:DuplicateSection(key,name)
    local src=self:GetSection(key);if not src then return nil,"Parent not found" end
    local children={};for _,c in ipairs(self.db.categories) do if c.sectionID==src.id then children[#children+1]=c end end
    if #self.db.categories+#children>100 then return nil,"Maximum 100 subcategories" end
    local g,e=self:NewSection(name);if not g then return nil,e end;g.enabled=src.enabled;g.icon=src.icon
    for _,c in ipairs(children) do local t=copy(c);t.sectionID=g.id;t.section=g.name;self:NewCategory(t) end
    self:Apply();return g
end
function BR:SectionEnabled(c) local g=self:GetSection(c.sectionID);return not g or g.enabled~=false end
function BR:NewCategory(template)
    if #self.db.categories>=100 then return nil,"Maximum 100 categories in this alpha" end
    local c=copy(template or {name="New Subcategory",expr="never",filters={},icon=134400,enabled=true})
    if c.filters~=nil then local f,e=F.Validate(c.filters);if not f then return nil,e end;c.filters=f;c.expr="never" end
    self.db.nextID=self.db.nextID+1; c.id="c"..self.db.nextID; c.enabled=c.enabled~=false
    c.icon=safeIcon(c.icon);c.name=cleanName(c.name);if c.name=="" then c.name="New Subcategory" end
    c.priority=priority(c.priority); c.manual=manualIDs(c.manual); c.section=text(c.section,80); c.sourceSearch=text(c.sourceSearch,4096); c.source=text(c.source,100); c.warning=text(c.warning,2048)
    local highest=0; for _,old in ipairs(self.db.categories) do highest=math.max(highest,old.tie or 0) end
    if highest>=2147483647 then local ranked={};for i,old in ipairs(self.db.categories) do ranked[i]=old end;table.sort(ranked,function(a,b) return a.tie<b.tie end);for i,old in ipairs(ranked) do old.tie=i end;highest=#ranked end
    local g=self:GetSection(c.sectionID) or self:EnsureSection(c.section);c.sectionID=g.id;c.section=g.name
    c.tie=highest+1; self.db.categories[#self.db.categories+1]=c; return c
end
function BR:Initialize()
    if type(BagRulesDB)~="table" then BagRulesDB={} end
    self.db=BagRulesDB
    local cleanedSections,ids,names={},{},{}
    self.db.nextSectionID=math.max(0,math.floor(tonumber(self.db.nextSectionID) or 0))
    for _,g in ipairs(type(self.db.sections)=="table" and self.db.sections or {}) do
        if type(g)=="table" and type(g.id)=="string" then
            local name=cleanName(g.name);local n=g.id:match("^s(%d+)$")
            if (n and name~="" or g.id=="ungrouped" and name=="") and not ids[g.id] and not names[name] then
                ids[g.id]=true;names[name]=true;cleanedSections[#cleanedSections+1]={id=g.id,name=name,enabled=g.enabled~=false,icon=g.icon and safeIcon(g.icon) or nil};self.db.nextSectionID=math.max(self.db.nextSectionID,tonumber(n) or 0)
            end
        end
    end
    self.db.sections=cleanedSections
    if type(self.db.categories)~="table" then
        self.db.categories={};self.db.nextID=0
        local catalogue=F.Catalogue()
        for _,g in ipairs(F.Suggestions(catalogue)) do
            local seen={};for _,t in ipairs(g.children) do
                local name=cleanName(t.name);if name~="" and not seen[name:lower()] and #self.db.categories<100 then
                    seen[name:lower()]=true;self:NewCategory({name=name,section=g.name,filters=t.filters,icon=t.icon,enabled=true})
                end
            end
        end
    end
    self.db.nextID=math.max(0,math.floor(tonumber(self.db.nextID) or 0))
    self.db.enabled=self.db.enabled~=false
    self.db.native=self.db.native==true
    self.db.view=self.db.view~=false
    self.db.keepPinned=self.db.keepPinned~=false
    self.db.tightCompact=self.db.tightCompact~=false
    -- Migrate the old default to hierarchy; preserve explicit alternate modes.
    if not self.db.hierarchyIntroduced then
        if not self.db.sectionLayout or self.db.sectionLayout=="paths" then self.db.sectionLayout="hierarchy" end
        self.db.hierarchyIntroduced=true
    end
    if self.db.sectionLayout~="paths" and self.db.sectionLayout~="categories" and self.db.sectionLayout~="sections" and self.db.sectionLayout~="hierarchy" then self.db.sectionLayout="hierarchy" end
    local cleaned,seen={},{}; local tieSeen={}; local validTies=true
    for _,c in ipairs(self.db.categories) do
        if type(c)=="table" and (type(c.expr)=="string" or c.filters~=nil) and #cleaned<100 then
            local id=type(c.id)=="string" and c.id:match("^c%d+$") and c.id or nil
            if id then self.db.nextID=math.max(self.db.nextID,tonumber(id:sub(2)) or 0) end
            if not id or seen[id] then repeat self.db.nextID=self.db.nextID+1; id="c"..self.db.nextID until not seen[id] end
            seen[id]=true
            local name=cleanName(c.name); if name=="" then name="Unnamed" end
            local tie=tonumber(c.tie); if not tie or tie<1 or tie>2147483647 or tie%1~=0 or tieSeen[tie] then validTies=false else tieSeen[tie]=true end
            cleaned[#cleaned+1]={tie=tie,id=id,name=name,expr=text(c.expr,8192),icon=safeIcon(c.icon),enabled=c.enabled~=false,priority=priority(c.priority),manual=manualIDs(c.manual),sectionID=type(c.sectionID)=="string" and c.sectionID or nil,section=cleanName(c.section),sourceSearch=text(c.sourceSearch,4096),source=text(c.source,100),warning=text(c.warning,2048)}
            if c.filters~=nil then
                local f,e=F.Validate(c.filters);local out=cleaned[#cleaned];out.expr="never"
                if f then out.filters=f else out.filters={};out.enabled=false;out.warning="Invalid saved native filters; category disabled: "..e end
            end
        end
    end
    if not validTies then for i,c in ipairs(cleaned) do c.tie=i end end
    self.db.categories=cleaned
    self:SyncHierarchy()
end
function BR:Get(id)
    for i,c in ipairs(self.db.categories) do if c.id==id then return c,i end end
end
function BR:SaveCategory(id,name,expr,icon,p,section,manual,enabled,filters)
    local c=self:Get(id); if not c then return nil,"Unknown category" end
    name=cleanName(name); if name=="" then return nil,"Category name cannot be empty" end
    local f,err
    if filters~=nil then f,err=F.Validate(filters);if not f then return nil,err end;expr="never" else local ast;ast,err=R.Compile(expr);if not ast then return nil,err end end
    if p~=nil and (not tonumber(p) or tonumber(p)~=priority(p)) then return nil,"Priority must be an integer from -10000 to 10000" end
    if manual~=nil and type(manual)~="table" then return nil,"Invalid manual items" end
    if expr~=c.expr or (f~=nil)~=(c.filters~=nil) or (f and F.Encode(f)~=F.Encode(c.filters)) then
        local translated=not c.filters and f and F.Translate(c.expr)
        if not translated or F.Encode(translated)~=F.Encode(f) then c.sourceSearch=""; c.warning="" end
    end
    c.filters=f
    c.name=name; c.expr=expr; c.icon=safeIcon(icon); if p~=nil then c.priority=priority(p) end; if section~=nil then local g=self:FindSection(section) or self:EnsureSection(section);c.sectionID=g.id;c.section=g.name end; if manual~=nil then c.manual=manualIDs(manual) end; if enabled~=nil then c.enabled=enabled==true end; self:Apply(); return true
end
function BR:Delete(id)
    local _,i=self:Get(id); if i then table.remove(self.db.categories,i); self:Apply() end
end
-- Display ordering is deliberately separate from the stable legacy tie order.
function BR:SectionGroups()
    self:SyncHierarchy()
    local groups,byName={},{}
    for _,g in ipairs(self.db.sections) do
        local view={section=g.name,id=g.id,enabled=g.enabled,icon=g.icon,categories={}}
        groups[#groups+1]=view;byName[g.name]=view
    end
    for _,c in ipairs(self.db.categories) do local a=byName[c.section].categories;a[#a+1]=c end
    return groups,byName
end
local function indexOf(a,v) for i,x in ipairs(a) do if x==v then return i end end end
local function commitGroups(self,groups)
    local a={};for _,g in ipairs(groups) do for _,c in ipairs(g.categories) do a[#a+1]=c end end
    local parents={};for _,g in ipairs(groups) do parents[#parents+1]=self:GetSection(g.id) end
    self.db.sections=parents;self.db.categories=a;self:Apply();return true
end
function BR:MoveSection(source,target,after)
    local groups,by=self:SectionGroups();local a,b=by[source],by[target]
    if not a or not b then return nil,"Section not found" end
    if a==b then return false end
    table.remove(groups,indexOf(groups,a));local pos=indexOf(groups,b)+(after and 1 or 0);table.insert(groups,pos,a)
    return commitGroups(self,groups)
end
function BR:StepSection(section,delta)
    local groups,by=self:SectionGroups();local i=indexOf(groups,by[section]);local other=i and groups[i+delta]
    if other then return self:MoveSection(section,other.section,delta>0) end
    return false
end
-- targetKind: section = append inside section; category = before/after sibling.
function BR:MoveCategory(id,targetKind,target,after)
    local c=self:Get(id);if not c then return nil,"Category not found" end
    local groups,by=self:SectionGroups();local source=by[c.section or ""];local dest,anchor
    if targetKind=="section" then dest=by[target]
    elseif targetKind=="category" then anchor=self:Get(target);if anchor then dest=by[anchor.section or ""] end end
    if not dest then return nil,"Destination not found" end
    if anchor==c then return false end
    local oldIndex=indexOf(source.categories,c);local newIndex=anchor and indexOf(dest.categories,anchor)+(after and 1 or 0) or #dest.categories+1
    if source==dest and oldIndex<newIndex then newIndex=newIndex-1 end
    if source==dest and oldIndex==newIndex then return false end
    table.remove(source.categories,oldIndex);table.insert(dest.categories,newIndex,c);c.section=dest.section;c.sectionID=dest.id
    return commitGroups(self,groups)
end
function BR:Move(id,delta)
    local c=self:Get(id);if not c then return false end
    local _,by=self:SectionGroups();local a=by[c.section or ""].categories;local i=indexOf(a,c);local other=a[i+delta]
    if other then return self:MoveCategory(id,"category",other.id,delta>0) end
    return false
end
function BR:Invalidate() metadata={}; prices={} end
local function getAPI(group,method,legacy) return group and group[method] or legacy end
local function safeCall(fn,...)
    if type(fn)~="function" then return nil end
    local ok,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q=pcall(fn,...)
    if ok then return a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q end
end
function BR:HasPrices()
    local api=Auctionator and Auctionator.API and Auctionator.API.v1
    return api and type(api.GetAuctionPriceByItemLink)=="function" or false
end
function BR:Item(link,id,bag,slot,quality)
    local key=link or id; if not key then return {} end
    local base=metadata[key]
    if not base then
        local itemInfo=getAPI(C_Item,"GetItemInfo",GetItemInfo)
        local instant=getAPI(C_Item,"GetItemInfoInstant",GetItemInfoInstant)
        local name,_,q,il,rl,ty,sub,_,equip,_,vendor,classID,subID,bindType,_,setID,craft=safeCall(itemInfo,key)
        local iid,it,ist,ie,_,ic,isc=safeCall(instant,key)
        classID=classID or ic; subID=subID or isc
        base={id=id or iid,class=classID,subclass=subID,quality=q,itemlevel=il,requiredlevel=rl,type=ty or it,subtype=sub or ist,slot=equip or ie,vendor=vendor,bindtype=bindType,name=name}
        if classID~=nil then base.quest=classID==12 end
        if bindType~=nil then base.boe=bindType==2 end
        if name then base.itemset=type(setID)=="number" and setID>0; if type(craft)=="boolean" then base.craftingreagent=craft end end
        -- Do not cache incomplete asynchronous item data.
        if name then metadata[key]=base end
    end
    local item=copy(base); item.quality=quality or item.quality
    if bag~=nil and slot~=nil then
        local info=safeCall(C_Container and C_Container.GetContainerItemInfo,bag,slot)
        if type(info)=="table" and (not id or info.itemID==id) and (not link or not info.hyperlink or link==info.hyperlink) then
            item.count=info.stackCount
            if type(info.hasLoot)=="boolean" then item.openable=info.hasLoot end
            if info.isQuestItem==true then item.quest=true end
            if type(info.isBound)=="boolean" then item.bound=info.isBound end
            if item.bound==nil and ItemLocation and ItemLocation.CreateFromBagAndSlot and C_Item and C_Item.IsBound then
                local loc=safeCall(ItemLocation.CreateFromBagAndSlot,ItemLocation,bag,slot)
                local b=loc and safeCall(C_Item.IsBound,loc)
                if type(b)=="boolean" then item.bound=b end
            end
        end
    end
    if item.bound~=nil then item.unbound=not item.bound end
    if self.usePrices and link and self:HasPrices() then
        local v=prices[link]
        if v==nil then
            local p=safeCall(Auctionator.API.v1.GetAuctionPriceByItemLink,ADDON,link)
            v=type(p)=="number" and p>0 and p or false; prices[link]=v
        end
        if v then item.ahprice=v; if item.vendor and item.vendor>0 then item.ratio=v/item.vendor end end
    end
    return item
end
local function eval(c,item) if c.filters then return F.Eval(c.filters,item) end;return R.Eval(c.ast,item) end
local function explicit(c,id) return id~=nil and c.manual[id]==true end
function BR:ClassifyItem(item)
    for _,c in ipairs(compiled) do if explicit(c,item.id) then return c.id end end
    for _,c in ipairs(compiled) do if eval(c,item)==true then return c.id end end
end
function BR:Classify(link,id,bag,slot,quality)
    return self:ClassifyItem(self:Item(link,id,bag,slot,quality))
end
local function needsPrices(a) return a and ((a.field=="ahprice" or a.field=="ratio") or needsPrices(a.a) or needsPrices(a.b)) end
function BR:Apply()
    if not self.db then return end
    if InCombatLockdown and InCombatLockdown() then self.pending=true; return end
    self.pending=false; self.pendingRefresh=false; self:SyncHierarchy(); self:Invalidate(); compiled={}; self.usePrices=false
    self.invalid=0
    if self.db.enabled then
        for i,c in ipairs(self.db.categories) do
            if c.enabled and self:SectionEnabled(c) then
                local ast=not c.filters and R.Compile(c.expr)
                local filters=c.filters and F.Validate(c.filters)
                if ast or filters then
                    local ids={}; for _,id in ipairs(c.manual or {}) do ids[id]=true end
                    compiled[#compiled+1]={id=c.id,ast=ast,filters=filters,name=c.name,icon=c.icon,priority=c.priority or 0,display=i,tie=c.tie or i,manual=ids,section=c.section or ""}
                    if needsPrices(ast) or F.NeedsPrices(filters) then self.usePrices=true end
                else self.invalid=self.invalid+1 end
            end
        end
    end
    local display,byID={},{}; for _,c in ipairs(compiled) do byID[c.id]=c end
    for _,g in ipairs(self:SectionGroups()) do for _,c in ipairs(g.categories) do if byID[c.id] then display[#display+1]=byID[c.id] end end end
    table.sort(compiled,function(a,b) if a.priority==b.priority then return a.tie<b.tie end; return a.priority>b.priority end)
    local cm=_G.EUI_CategoryManager
    self.status={native=0,view=false,hasView=false,errors=0}
    if not cm then self.status.message="EllesmereUI Bags API not available"; return end
    local canNative=type(cm.RegisterVirtualCategory)=="function" and type(cm.UnregisterVirtualCategory)=="function"
    local canView=type(cm.RegisterVirtualView)=="function" and type(cm.UnregisterVirtualView)=="function"
    self.status.hasView=canView
    self.status.hierarchy=cm.BagRulesSectionsAPI==1
    self.status.runtime=not self.status.hierarchy and self.RuntimeSections and safeCall(self.RuntimeSections.Install,self.RuntimeSections) or false
    local wanted={}
    if canNative and self.db.enabled and (self.db.native or (self.db.view and not canView)) then
        for i,c in ipairs(display) do
            local id=c.id; local key="BagRules:"..id
            local ok=safeCall(cm.RegisterVirtualCategory,cm,key,{name=c.name,icon=c.icon,order=-1000+i,classify=function(...) return BR:Classify(...)==id end})
            if ok then wanted[key]=true; self.status.native=self.status.native+1 else self.status.errors=self.status.errors+1; if registered[key] then wanted[key]=true end end
        end
    end
    if canNative then for key in pairs(registered) do if not wanted[key] then safeCall(cm.UnregisterVirtualCategory,cm,key) end end end
    registered=wanted
    if self.status.native>0 and self.NativeSidebar then safeCall(self.NativeSidebar.Install,self.NativeSidebar) end
    if canView then
        if self.db.enabled and self.db.view then
            -- Supported hierarchy is opt-in; fall back to flat paths on stock host.
            local groups,groupOf,seen={},{},{}
            local layout=self.db.sectionLayout
            local hierarchy=layout=="hierarchy" and self.status.hierarchy
            if layout=="hierarchy" then layout="paths" end
            -- Both manager and renderer use SectionGroups display order.
            for _,c in ipairs(display) do
                local id,name=c.id,c.name
                if layout=="sections" and c.section~="" then
                    id="section:"..c.section; name=c.section
                elseif layout=="paths" and c.section~="" then
                    name=c.section.." / "..c.name
                end
                groupOf[c.id]=id
                if not seen[id] then
                    seen[id]=true; groups[#groups+1]={id=id,name=name,order=#groups+1,section=hierarchy and c.section or nil,shortName=hierarchy and c.name or nil}
                end
            end
            self.status.view=safeCall(cm.RegisterVirtualView,cm,viewID,{name="BagRules",icon=132996,order=0,otherName="Uncategorised",keepPinned=self.db.keepPinned,keepRecent=false,sectionHeaders=hierarchy==true,groups=groups,classify=function(...) return groupOf[BR:Classify(...)] end})==true
            if not self.status.view then self.status.errors=self.status.errors+1 end
        else safeCall(cm.UnregisterVirtualView,cm,viewID) end
    end
    self.status.message=not self.db.enabled and "Disabled" or (canNative or canView) and "Ready (registration checked)" or "Unsupported Bags API"
end
function BR:Refresh()
    if InCombatLockdown and InCombatLockdown() then self.pendingRefresh=true; return end
    self.pendingRefresh=false; self:Invalidate()
    local cm=_G.EUI_CategoryManager
    if cm then safeCall(cm.RefreshVirtualCategories,cm); safeCall(cm.RefreshVirtualViews,cm) end
end
function BR:Preview(expr,categoryID,draft)
    local ast,filters,err
    if draft and draft.filters~=nil then filters,err=F.Validate(draft.filters) else ast,err=R.Compile(expr) end
    if not ast and not filters then return nil,err end
    local candidate={ast=ast,filters=filters}
    local rows,counts={},{}; local unknown,total,shadowed=0,0,0
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then return nil,"Container API unavailable" end
    self:Invalidate()
    -- Preview may inspect a price rule not yet enabled; restore state immediately.
    local old=self.usePrices; self.usePrices=old or needsPrices(ast) or F.NeedsPrices(filters)
    for bag=0,(NUM_BAG_SLOTS or 4) do
        for slot=1,(safeCall(C_Container.GetContainerNumSlots,bag) or 0) do
            local info=safeCall(C_Container.GetContainerItemInfo,bag,slot)
            if info and info.itemID then
                total=total+1
                local item=self:Item(info.hyperlink,info.itemID,bag,slot,info.quality)
                local actual=self:ClassifyItem(item); if actual then counts[actual]=(counts[actual] or 0)+1 end
                local selected,position=self:Get(categoryID); position=selected and (selected.tie or position) or math.huge; if draft then selected=draft end; local pinned=false
                for _,id in ipairs(selected and selected.manual or {}) do if item.id==id then pinned=true; break end end
                local match=pinned or eval(candidate,item)
                if match==nil then unknown=unknown+1 elseif match then
                    local earlier=false
                    for _,c in ipairs(compiled) do
                        if c.id~=categoryID and ((explicit(c,item.id) and (not pinned or c.priority>(selected.priority or 0) or (c.priority==(selected.priority or 0) and c.tie<position))) or (not pinned and (not selected or c.priority>(selected.priority or 0) or (c.priority==(selected.priority or 0) and c.tie<position)) and eval(c,item)==true)) then earlier=true; break end
                    end
                    if earlier then shadowed=shadowed+1 end
                    rows[#rows+1]={name=item.name or ("Item "..info.itemID),link=info.hyperlink,count=item.count or 1,shadowed=earlier,icon=info.iconFileID or safeCall(getAPI(C_Item,"GetItemIconByID",GetItemIcon),info.itemID)}
                end
            end
        end
    end
    self.usePrices=old
    return rows,nil,unknown,total,shadowed,counts
end
-- Share format is data only. Never loads or evaluates Lua from text.
local function encode(s) return (tostring(s):gsub("([^%w _%.%-])",function(c) return string.format("%%%02X",string.byte(c)) end)) end
local function decode(s) return (s:gsub("%%(%x%x)",function(h) return string.char(tonumber(h,16)) end)) end
local function exportLegacy(self)
    local extended,previous=false,0
    -- Keep the legacy format when array order already represents tie order.
    for i,c in ipairs(self.db.categories) do local t=c.tie or i;if t<=previous then extended=true end;previous=t end
    local a={extended and "BAGRULES/3" or "BAGRULES/2"}
    for i,c in ipairs(self.db.categories) do
        a[#a+1]=table.concat({c.enabled and "1" or "0",c.icon,encode(c.name),encode(c.expr),tostring(c.priority or 0),encode(c.section or ""),table.concat(c.manual or {},","),encode(c.sourceSearch or ""),encode(c.source or ""),encode(c.warning or "")},"\t")
        if extended then a[#a]=a[#a].."\t"..tostring(c.tie or i) end
    end
    return table.concat(a,"\n")
end
function BR:Export()
    self:SyncHierarchy()
    local native=false;for _,c in ipairs(self.db.categories) do if c.filters~=nil then native=true end end
    local extendedFilters=false;for _,c in ipairs(self.db.categories) do if F.Extended(c.filters) then extendedFilters=true end end
    local a={extendedFilters and "BAGRULES/6" or native and "BAGRULES/5" or "BAGRULES/4"}
    for _,g in ipairs(self.db.sections) do a[#a+1]=table.concat({"S",g.id,encode(g.name),g.enabled and "1" or "0"},"\t") end
    local legacy=exportLegacy(self);local extended=legacy:sub(1,10)=="BAGRULES/3";local i=0
    for line in legacy:match("^[^\n]+\n?(.*)$"):gmatch("[^\n]+") do
        i=i+1;local c=self.db.categories[i];a[#a+1]=(c.filters~=nil and "N\t" or "C\t")..c.sectionID.."\t"..line..(extended and "" or "\t"..tostring(c.tie or i))
    end
    if native then for i,c in ipairs(self.db.categories) do if c.filters~=nil then a[#a+1]="F\t"..i.."\t"..encode(F.Encode(c.filters)).."!" end end end
    local payload=table.concat(a,"\n")
    local icons={};for _,g in ipairs(self.db.sections) do if g.icon then icons[#icons+1]="I\t"..g.id.."\t"..safeIcon(g.icon) end end
    if #icons>0 then return "BAGRULES/7\n"..payload.."\n"..table.concat(icons,"\n") end
    return payload
end
function BR:PrepareImport(s, keepLegacy)
    if type(s)~="string" or #s>800000 then return nil,"Import too large" end
    s=trim(s:gsub("\r\n","\n"))
    if s:sub(1,6)=="BGR!1!" or s:sub(1,1)=="{" then
        if not self.Baganator then return nil,"Baganator importer unavailable" end
        local a,report=self.Baganator.Plan(s)
        if not a or keepLegacy then return a,report end
        local migration=self:MigrationPlan(a)
        report.converted,report.retained=migration.ready,migration.blocked
        report.conversionRows=migration.rows
        report.comparedSlots=migration.slots
        for i,row in ipairs(migration.rows) do
            if row.filters then a[i].filters=row.filters;a[i].expr="never" end
        end
        return a,report
    end
    local header,body=s:match("^([^\n]+)\n?(.*)$")
    if header=="BAGRULES/7" then
        local inner=body:match("^([^\n]+)")
        if inner~="BAGRULES/4" and inner~="BAGRULES/5" and inner~="BAGRULES/6" then return nil,"Invalid parent icon profile" end
        local rows,icons={},{}
        for line in body:gmatch("[^\n]+") do
            if line:sub(1,2)=="I\t" then
                local key,id=line:match("^I\t([^\t]+)\t(%d+)$");id=tonumber(id)
                if not key or not id or safeIcon(id)~=id or icons[key] then return nil,"Invalid parent icon record" end
                icons[key]=id
            else rows[#rows+1]=line end
        end
        local a,report=self:PrepareImport(table.concat(rows,"\n"),true);if not a then return nil,report end
        for _,g in ipairs(report.parentDefinitions or {}) do g.icon=icons[g.id];icons[g.id]=nil end
        if next(icons) then return nil,"Unknown parent icon target" end
        return a,report
    end
    if header=="BAGRULES/5" or header=="BAGRULES/6" then
        local rows,filters,expected={},{},{};local n,ordinal=0,0
        for line in body:gmatch("[^\n]+") do
            if line:sub(1,2)=="F\t" then
                local i,encoded=line:match("^F\t(%d+)\t(.*)!$");i=tonumber(i)
                if not i or i<1 or i>100 or filters[i] then return nil,"Invalid native filter reference" end
                local f,e=F.Decode(decode(encoded));if not f then return nil,e end;if header=="BAGRULES/5" and F.Extended(f) then return nil,"Extended filters require BAGRULES/6" end;filters[i]=f;n=n+1
            else
                local kind=line:sub(1,2);if kind=="C\t" or kind=="N\t" then ordinal=ordinal+1;if kind=="N\t" then expected[ordinal]=true;line="C"..line:sub(2) end end
                rows[#rows+1]=line
            end
        end
        if n==0 then return nil,"Missing native filter records" end
        local a,report=self:PrepareImport("BAGRULES/4\n"..table.concat(rows,"\n"));if not a then return nil,report end
        for i,f in pairs(filters) do if not expected[i] or not a[i] or a[i].expr~="never" then return nil,"Invalid native filter target" end;a[i].filters=f end
        for i in pairs(expected) do if not filters[i] then return nil,"Missing native filter data for category "..i end end
        return a,report
    end
    if header=="BAGRULES/4" then
        local parents,byID,byName,rows,refs={},{},{},{},{}
        for line in body:gmatch("[^\n]+") do
            local id,n,on=line:match("^S\t([^\t]+)\t([^\t]*)\t([01])$")
            if id then
                local name=cleanName(decode(n));if not (id=="ungrouped" and name=="" or id:match("^s%d+$") and name~="") or byID[id] or byName[name] or #parents>=100 then return nil,"Invalid or duplicate parent" end
                local g={id=id,name=name,enabled=on=="1"};parents[#parents+1]=g;byID[id]=g;byName[name]=true
            else
                local ref,row=line:match("^C\t([^\t]+)\t(.+)$");if not ref then return nil,"Malformed hierarchy record" end;refs[#refs+1]=ref;rows[#rows+1]=row
            end
        end
        local a,report=self:PrepareImport("BAGRULES/3\n"..table.concat(rows,"\n"));if not a then return nil,report end
        for i,c in ipairs(a) do local g=byID[refs[i]];if not g or c.section~=g.name then return nil,"Invalid parent reference" end;c.sectionID=g.id end
        report.parentDefinitions=parents;report.sections=0;for _,g in ipairs(parents) do if g.name~="" then report.sections=report.sections+1 end end
        return a,report
    end
    if header~="BAGRULES/1" and header~="BAGRULES/2" and header~="BAGRULES/3" then return nil,"Expected BagRules export, BGR!1! or Baganator JSON" end
    -- trim above can strip trailing tabs on last record; restore empty optional columns.
    local a={}; local report={categories=0,sections=0,manual=0,warnings={}}; local sectionSet={};local ties={}
    for line in body:gmatch("[^\n]+") do
        local cols={}; for v in (line.."\t"):gmatch("([^\t]*)\t") do cols[#cols+1]=v end
        if header~="BAGRULES/1" then while #cols<10 do cols[#cols+1]="" end end
        local on,icon,n,e=cols[1],cols[2],cols[3],cols[4]
        if (on~="0" and on~="1") or not icon or not icon:match("^%d+$") or not n or not e or (header=="BAGRULES/1" and #cols~=4) or #cols>(header=="BAGRULES/3" and 11 or 10) then return nil,"Malformed category on row "..(#a+1) end
        local cname=cleanName(decode(n)); local expr=decode(e)
        local ast,err=R.Compile(expr)
        if cname=="" or not ast then return nil,"Invalid category "..(#a+1)..": "..(err or "empty name") end
        local p=0; local ids={}; local section=""
        if header~="BAGRULES/1" then
            p=tonumber(cols[5]); if p==nil or p~=priority(p) then return nil,"Invalid priority" end
            section=cleanName(decode(cols[6])); if section~="" then sectionSet[section]=true end
            if cols[7]~="" then
                if not cols[7]:match("^%d[%d,]*$") or cols[7]:find(",,") or cols[7]:sub(-1)=="," then return nil,"Invalid manual item IDs" end
                for v in cols[7]:gmatch("%d+") do ids[#ids+1]=tonumber(v) end
                if #manualIDs(ids)~=#ids then return nil,"Invalid or duplicate manual item IDs" end
            end
        end
        local tie
        if header=="BAGRULES/3" then tie=tonumber(cols[11]);if not tie or tie%1~=0 or tie<1 or tie>2147483647 or ties[tie] then return nil,"Invalid or duplicate classification order" end;ties[tie]=true end
        local warning=decode(cols[10] or ""); if warning~="" then report.warnings[#report.warnings+1]=cname..": "..warning end
        a[#a+1]={tie=tie,name=cname,expr=expr,enabled=on=="1",icon=safeIcon(icon),priority=p,manual=ids,section=section,sourceSearch=decode(cols[8] or ""),source=decode(cols[9] or ""),warning=warning}
        report.manual=report.manual+#ids
        if #a>100 then return nil,"Maximum 100 categories" end
    end
    report.categories=#a; for _ in pairs(sectionSet) do report.sections=report.sections+1 end
    return a,report
end
function BR:Import(s, keepLegacy)
    if InCombatLockdown and InCombatLockdown() then return nil,"Import outside combat" end
    local a,report=self:PrepareImport(s, keepLegacy); if not a then return nil,report end
    self.db.backup=self:Export(); self.db.iconBackup=nil; self.db.categories={};self.db.sections=report.parentDefinitions or {};self.db.nextSectionID=0
    for _,g in ipairs(self.db.sections) do self.db.nextSectionID=math.max(self.db.nextSectionID,tonumber(g.id:match("^s(%d+)$")) or 0) end
    for _,c in ipairs(a) do self:NewCategory(c) end
    for i,c in ipairs(a) do if c.tie then self.db.categories[i].tie=c.tie end end
    self:Apply(); return true,report
end
function BR:StarterPlan(chosen,catalogue,replace)
    local plan={};local count,newParents=0,0
    for _,g in ipairs(F.Suggestions(catalogue)) do if chosen[g.name] then
        local existing=not replace and self:FindSection(g.name);if not replace and not existing then for _,p in ipairs(self.db.sections) do if p.name:lower()==g.name:lower() then existing=p;break end end end;local seen={};if existing then for _,c in ipairs(self.db.categories) do if c.sectionID==existing.id then seen[c.name:lower()]=true end end end
        local children={};for _,c in ipairs(g.children) do if not seen[c.name:lower()] then
            local f,e=F.Validate(c.filters);if not f then return nil,e end;local name=cleanName(c.name);if name~="" and not seen[name:lower()] then seen[name:lower()]=true;children[#children+1]={name=name,filters=f,icon=c.icon};count=count+1 end
        end end
        if #children>0 then if not existing then newParents=newParents+1 end;plan[#plan+1]={name=existing and existing.name or g.name,children=children} end
    end end
    if (replace and 0 or #self.db.categories)+count>100 or (replace and 0 or #self.db.sections)+newParents>100 then return nil,"Not enough category capacity (100 maximum)." end
    return plan,count
end
function BR:GenerateStarter(chosen,catalogue,replace)
    if InCombatLockdown and InCombatLockdown() then return nil,"Wait until combat ends." end
    local plan,count=self:StarterPlan(chosen,catalogue,replace);if not plan then return nil,count end
    if count==0 then return true,0 end
    self.db.backup=self:Export()
    if replace then self.db.iconBackup=nil;self.db.categories={};self.db.sections={};self.db.nextSectionID=0 end
    for _,g in ipairs(plan) do local parent=self:EnsureSection(g.name);for _,c in ipairs(g.children) do self:NewCategory({name=c.name,sectionID=parent.id,section=parent.name,expr="never",filters=c.filters,icon=c.icon,priority=replace and 0 or -10000,enabled=true}) end end
    self:Apply();return true,count
end
local events=CreateFrame("Frame")
for _,e in ipairs({"ADDON_LOADED","PLAYER_LOGIN","PLAYER_REGEN_ENABLED","BAG_UPDATE_DELAYED","GET_ITEM_INFO_RECEIVED","AUCTION_HOUSE_CLOSED","BANKFRAME_OPENED"}) do events:RegisterEvent(e) end
local queued=false
local function scheduleRefresh()
    if queued then return end; queued=true
    if C_Timer and C_Timer.After then C_Timer.After(0.25,function() queued=false; BR:Refresh() end) else queued=false; BR:Refresh() end
end
events:SetScript("OnEvent",function(_,event,arg)
    if event=="ADDON_LOADED" and arg==ADDON then BR:Initialize()
    elseif event=="PLAYER_LOGIN" then
        if not BR.db then BR:Initialize() end
        BR:Apply(); if BR.RegisterOptions then BR:RegisterOptions() end
        if BR.status and not BR.status.hasView then BR:Print("Virtual View unavailable; native categories used if supported. /bagrules status") end
    elseif event=="PLAYER_REGEN_ENABLED" then
        -- Capture deferred layout work before Apply clears pending flags. Delay
        -- the refresh briefly so EUI has fully left combat lockdown before the
        -- runtime hierarchy and native sidebar are measured and rebuilt.
        local refresh=BR.pendingRefresh or (BR.status and (BR.status.native>0 or BR.status.runtime and BR.db and BR.db.sectionLayout=="hierarchy"))
        if BR.pending then BR:Apply() end
        if refresh then scheduleRefresh() end
    elseif BR.db and BR.db.enabled and (event=="BAG_UPDATE_DELAYED" or event=="GET_ITEM_INFO_RECEIVED" or event=="AUCTION_HOUSE_CLOSED" or event=="BANKFRAME_OPENED") then scheduleRefresh() end
end)

-- Explicit, conservative conversion of the already-imported BagRules expression.
-- The original Baganator import warnings remain attached to the category.
function BR:MigrationPlan(categories)
    categories=categories or self.db.categories
    local rows,items={},{};local available=C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo
    local old=self.usePrices;local priceNeeded=old
    for _,c in ipairs(categories) do if c.filters==nil and needsPrices(R.Compile(c.expr)) then priceNeeded=true end end
    self.usePrices=priceNeeded;self:Invalidate()
    if available then
        for bag=0,(NUM_BAG_SLOTS or 4) do for slot=1,(safeCall(C_Container.GetContainerNumSlots,bag) or 0) do
            local info=safeCall(C_Container.GetContainerItemInfo,bag,slot)
            if info and info.itemID then items[#items+1]=self:Item(info.hyperlink,info.itemID,bag,slot,info.quality) end
        end end
    end
    self.usePrices=old;self:Invalidate()
    local report={rows=rows,ready=0,blocked=0,native=0,slots=#items,available=not not available,snapshot=categories==self.db.categories and self:Export() or nil}
    for _,c in ipairs(categories) do
        local row={id=c.id,name=c.name,section=c.section,warning=c.warning,matched=0,mismatches=0,unknown=0};rows[#rows+1]=row
        if c.filters~=nil then row.status="Native";report.native=report.native+1
        else
            local f,e=F.Translate(c.expr);row.filters=f
            if f then
                local ast=R.Compile(c.expr)
                for _,item in ipairs(items) do local a,b=R.Eval(ast,item),F.Eval(f,item);if a~=b then row.mismatches=row.mismatches+1 end;if a==true then row.matched=row.matched+1 elseif a==nil then row.unknown=row.unknown+1 end end
                if row.mismatches>0 then row.filters=nil;row.reason="Current inventory comparison differs" end
            else row.reason=e end
            if row.filters then row.status="Ready";report.ready=report.ready+1 else row.status="Legacy retained";report.blocked=report.blocked+1 end
        end
    end
    return report
end
function BR:ConvertLegacy(ids,snapshot)
    if InCombatLockdown and InCombatLockdown() then return nil,"Convert outside combat" end
    if snapshot~=self:Export() then return nil,"Profile changed; refresh preview" end
    local plan=self:MigrationPlan();local ready={};for _,r in ipairs(plan.rows) do if r.filters and (not ids or ids[r.id]) then ready[#ready+1]=r end end
    if #ready==0 then return nil,"No compatible legacy categories selected" end
    local backup=self:Export();self.db.migrationBackup=backup;self.db.backup=backup
    for _,r in ipairs(ready) do local c,i=self:Get(r.id);local replacement=copy(c);replacement.filters=r.filters;replacement.expr="never";self.db.categories[i]=replacement end
    self:Apply();return true,#ready
end
function BR:RestoreMigration(snapshot)
    if InCombatLockdown and InCombatLockdown() then return nil,"Restore outside combat" end
    if snapshot~=self:Export() then return nil,"Profile changed; refresh preview" end
    local backup=self.db.migrationBackup;if not backup then return nil,"No migration backup" end
    local ok,report=self:Import(backup);if ok then self.db.migrationBackup=nil end;return ok,report
end
