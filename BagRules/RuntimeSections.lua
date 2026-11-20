-- BagRules runtime hierarchy adapter for compatible stock EllesmereUI Bags renderers.
-- No host file edits, no replacement of host functions, no item IDs/attributes changed.
-- The native renderer runs first. Only its already-positioned blocks are reflowed,
-- out of combat, after all frame geometry and native item counts are validated.
local _, BR = ...
local S={headers={},slots=setmetatable({}, {__mode='k'}),collapsed={}}
BR.RuntimeSections=S
local abs,max,min=math.abs,math.max,math.min
local unpack=unpack or table.unpack
local function combat() return InCombatLockdown and InCombatLockdown() end
local function shown(f) return f and f.IsShown and f:IsShown() end
local function hasCursor() return GetCursorInfo and GetCursorInfo()~=nil end
local function groupName(text)
    if type(text)~='string' then return end
    local name,count=text:match('^(.-) %((%d+)%)$')
    if name then return name,tonumber(count) end
end
local function position(f,child)
    if f:GetNumPoints()~=1 then return end
    local p,rel,rp,x,y=f:GetPoint(1)
    if p~='TOPLEFT' or rel~=child or rp~='TOPLEFT' or type(x)~='number' or type(y)~='number' then return end
    local w,h=f:GetWidth(),f:GetHeight()
    if not w or not h or w<=0 or h<=0 or x~=x or y~=y or w~=w or h~=h then return end
    return {f=f,x=x,y=y,w=w,h=h}
end
local function sortPos(a,b) if abs(a.y-b.y)>0.1 then return a.y>b.y end return a.x<b.x end
-- Pure planner. Retain native per-block geometry, but never pack across parents.
-- Existing host bands are sliced at parent boundaries. No item data is touched.
function S.Plan(blocks,collapsed,search,left,right,oldHeight,reordered)
    if #blocks==0 then return nil,'no blocks' end
    local bands={}
    for _,b in ipairs(blocks) do
        local band=bands[#bands]
        if reordered or not band or abs(b.y-band.y)>0.1 then band={y=b.y,blocks={}}; bands[#bands+1]=band end
        band.blocks[#band.blocks+1]=b
    end
    local plan={moves={},headers={},height=oldHeight}; local y=bands[1].y; local lastSection
    -- A reordered block can originate lower down the native grid. Begin at the true top.
    for _,b in ipairs(blocks) do y=max(y,b.y) end
    local function addMove(p,x,yy,hide,label) plan.moves[#plan.moves+1]={p=p,x=x,y=yy,hide=hide,label=label} end
    for bi,band in ipairs(bands) do
        local i=1
        while i<=#band.blocks do
            local b=band.blocks[i]; local section=b.section; local j=i
            while j<#band.blocks and band.blocks[j+1].section==section do j=j+1 end
            if section and section~=lastSection then
                plan.headers[#plan.headers+1]={name=section,x=left,y=y,w=right-left,collapsed=collapsed[section] and not search}
                y=y-23
            end
            lastSection=section
            local hide=section and collapsed[section] and not search
            local xshift=left-b.x
            local h=0
            for k=i,j do
                local cur=band.blocks[k]
                local name=cur.short and (cur.short..' ('..cur.count..')') or nil
                addMove(cur,cur.x+xshift,y,hide,name)
                h=max(h,cur.h)
                for _,p in ipairs(cur.members) do
                    addMove(p,p.x+xshift,y+(p.y-cur.y),hide)
                    h=max(h,cur.y-p.y+p.h)
                end
            end
            if not hide then
                -- Native grid includes padding; give blocks a minimum 4px gutter.
                -- Preserve a larger native band gap when it remains intact.
                local step=h+4
                if not reordered and i==1 and j==#band.blocks and bands[bi+1] then step=max(step,band.y-bands[bi+1].y) end
                y=y-step
            end
            i=j+1
        end
    end
    plan.height=max(1,-y+10)
    return plan
end
-- Dense compact planner: respect the actual group footprint and short label,
-- not the host's full-path label width or original band breaks. Keep each
-- native block's internal item anchors, sorting and stack merging intact.
local COMPACT_GAP, COMPACT_ROW_GAP=8,4
function S.PlanCompact(blocks,collapsed,search,left,right,oldHeight,reordered)
    if #blocks==0 then return nil,'no blocks' end
    local available=right-left
    local plan={moves={},headers={},height=oldHeight}
    local y=blocks[1].y
    for _,b in ipairs(blocks) do y=max(y,b.y) end
    local i=1
    local function move(b,x,yy,hide,width)
        local label=b.short and (b.short..' ('..b.count..')') or nil
        plan.moves[#plan.moves+1]={p=b,x=x,y=yy,hide=hide,label=label,width=width}
        local h=b.h
        for _,p in ipairs(b.members) do
            plan.moves[#plan.moves+1]={p=p,x=x+p.x-b.x,y=yy+p.y-b.y,hide=hide}
            h=max(h,b.y-p.y+p.h)
        end
        return h
    end
    while i<=#blocks do
        local first=blocks[i]; local section=first.section; local j=i
        if section then
            while j<#blocks and blocks[j+1].section==section do j=j+1 end
            local hide=collapsed[section] and not search
            plan.headers[#plan.headers+1]={name=section,x=left,y=y,w=available,collapsed=hide}
            y=y-23
            local x,rowH=left,0
            for k=i,j do
                local b=blocks[k]
                local footprint=1
                for _,p in ipairs(b.members) do footprint=max(footprint,p.x-b.x+p.w) end
                if footprint>available+0.1 or not b.textWidth then return nil,'compact footprint or label unavailable' end
                -- Long labels may truncate at the right edge, but slots never do.
                local width=max(footprint,min(available,math.ceil(b.textWidth)+2))
                if x>left and x+width>right+0.1 then
                    if not hide then y=y-rowH-COMPACT_ROW_GAP end
                    x,rowH=left,0
                end
                rowH=max(rowH,move(b,x,y,hide,width))
                x=x+width+COMPACT_GAP
            end
            if not hide then y=y-rowH-COMPACT_ROW_GAP end
        else
            -- Keep the stock positions within a band for special groups (pins,
            -- recent, uncategorised, junk) and ordinary unsectioned categories.
            while not reordered and j<#blocks and not blocks[j+1].section and abs(blocks[j+1].y-first.y)<=0.1 do j=j+1 end
            local h=0
            for k=i,j do local b=blocks[k]; h=max(h,move(b,left+b.x-first.x,y,false)) end
            y=y-h-COMPACT_ROW_GAP
        end
        i=j+1
    end
    plan.height=max(1,-y+10)
    return plan
end
-- Use the host header's exact font to measure its new counted label, without
-- writing to the original label before the geometry has been validated.
function S:MeasureShortLabel(child,b)
    local label=b.f._label
    if not label.GetFont or not child.CreateFontString then return nil end
    local font,size,flags=label:GetFont()
    if not font or not size then return nil end
    if not self.measure or self.measureOwner~=child then
        self.measure=child:CreateFontString(nil,'OVERLAY')
        self.measureOwner=child; self.measure:Hide()
    end
    local fs=self.measure
    if not fs.SetFont or not fs.GetUnboundedStringWidth then return nil end
    if fs:SetFont(font,size,flags)==false then return nil end
    fs:SetText(b.short..' ('..b.count..')')
    local w=fs:GetUnboundedStringWidth()
    if type(w)~='number' or w~=w or w<=0 or w==math.huge then return nil end
    return w
end
-- The stock compact label has its own hover and divider geometry. Snapshot
-- only visual properties we change, so a failed repaint restores the host.
local function snapshotLabel(f)
    local l=f._label
    return {width=f:GetWidth(),labelWidth=l:GetWidth(),lineShown=f._line:IsShown(),
        cut=f._cut,shownW=f._shownW,insets=f.GetHitRectInsets and {f:GetHitRectInsets()} or nil}
end
local function sizeLabel(f,w,textWidth)
    f:SetWidth(w); f._label:SetWidth(w); f._line:Hide()
    f._cut=textWidth>w; f._shownW=min(textWidth,w)
    if f.SetHitRectInsets then f:SetHitRectInsets(0,max(0,w-f._shownW),0,0) end
end
local function restoreLabel(f,s)
    f:SetWidth(s.width); f._label:SetWidth(s.labelWidth)
    if s.lineShown then f._line:Show() else f._line:Hide() end
    f._cut,f._shownW=s.cut,s.shownW
    if s.insets and f.SetHitRectInsets then f:SetHitRectInsets(unpack(s.insets)) end
end
local function getVersion()
    local f=C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return f and f('EllesmereUIBags','Version')
end
-- Version metadata is diagnostic only. The renderer contract, not the release
-- number, decides whether the adapter can run. Frame checks occur on each paint.
local function missingMethods(obj, names, owner)
    if not obj then return owner..' unavailable' end
    for _,name in ipairs(names) do
        if type(obj[name])~='function' then return owner..'.'..name..' unavailable' end
    end
end
function S:Install()
    if self.installed then return true end
    if self.installFailed then return false end
    local bag=_G.EUI_Bags; local cm=_G.EUI_CategoryManager
    local ok,version=pcall(getVersion)
    self.hostVersion=ok and tostring(version or 'unknown') or 'unknown'
    local reason=missingMethods(bag,{'RefreshInventory','RegisterItemOverlayIcon','IsListMode','IsCompactMode','IsVisible'},'EUI_Bags')
        or missingMethods(cm,{'GetViews','GetCategories'},'EUI_CategoryManager')
    if not reason and type(hooksecurefunc)~='function' then reason='hooksecurefunc unavailable' end
    if not reason and cm.BagRulesSectionsAPI==1 then reason='host hierarchy available' end
    if reason then self.state='flat: '..reason; return false end
    -- Register an observational native overlay callback, not a secure item hook.
    local registered,err=pcall(bag.RegisterItemOverlayIcon,'BagRules:sectionGeometry',function(btn,data)
        if self.failed or not BR.db or BR.db.sectionLayout~='hierarchy' or not BR.db.enabled or not BR.db.view then return end
        if not btn or type(btn.GetParent)~='function' then return end
        local p=btn:GetParent()
        if p and type(p.GetParent)=='function' and p:GetParent()==bag._scrollChild then self.slots[p]=true end
    end)
    if not registered then self.state='flat: overlay registration failed: '..tostring(err); return false end
    local hooked,hookError=pcall(hooksecurefunc,bag,'RefreshInventory',function()
        -- Protect preflight checks too, including any newly changed host API.
        if self.failed then return end
        local success,failure=pcall(self.AfterRefresh,self,bag)
        if not success then
            self.failed=true; self.busy=false
            pcall(self.HideHeaders,self)
            self.state='runtime disabled after compatibility error: '..tostring(failure)
            BR:Print(self.state)
        end
    end)
    if not hooked then
        self.installFailed=true; self.failed=true
        if type(bag.UnregisterItemOverlayIcon)=='function' then pcall(bag.UnregisterItemOverlayIcon,'BagRules:sectionGeometry') end
        self.state='flat: refresh hook failed: '..tostring(hookError); return false
    end
    self.installed=true; self.state='runtime ready (awaiting inventory)'
    return true
end
function S:Selected(bag)
    local cm=_G.EUI_CategoryManager; local view
    local views=cm:GetViews()
    if type(views)~='table' then return nil,'unrecognised GetViews result' end
    for _,v in ipairs(views) do
        if type(v)~='table' then return nil,'unrecognised view entry' end
        if v.id=='BagRules:inventory' then view=v; break end
    end
    if not view then return nil,'BagRules view unavailable' end
    if missingMethods(bag._sidebarChild,{'GetChildren'},'sidebar') then return nil,'sidebar geometry unavailable' end
    -- The host's selected indicator is set every refresh, including collapsed icons.
    for _,b in ipairs({bag._sidebarChild:GetChildren()}) do
        if b._catIdx==view.idx and shown(b) and shown(b._indicator) then return view end
    end
    return nil,'waiting for BagRules selection'
end
function S:HideHeaders() for _,b in ipairs(self.headers) do b:Hide() end end
local function activeCatch(bag) return shown(bag._pinCatcher) or shown(bag._assignCatcher) end
function S:Collect(bag,view)
    local child=bag._scrollChild
    local missing=missingMethods(child,{'GetChildren','GetWidth','GetHeight','SetHeight','GetFrameLevel'},'scroll child')
    if missing then return nil,missing end
    -- Use the exact same tree order as the manager, independent of registered
    -- group order, rule priority, labels and the host's native screen geometry.
    local rank,nextRank={},0
    for _,section in ipairs(BR:SectionGroups()) do
        for _,c in ipairs(section.categories) do
            nextRank=nextRank+1; rank[c.id]=nextRank
        end
    end
    local lookup={}; local count=0
    for _,g in ipairs(view.groups or {}) do
        local c=BR:Get(g.id)
        if c then
            if lookup[g.name] then return nil,'duplicate category labels' end
            if not rank[g.id] then return nil,'category display rank unavailable' end
            lookup[g.name]={section=c.section~='' and c.section or nil,short=c.name,rank=rank[g.id]}; count=count+1
        end
    end
    if count==0 then return nil,'no registered categories' end
    local cm=_G.EUI_CategoryManager; local junk=cm:GetCategories()[cm._junkCatIdx or 0]
    local L=EllesmereUI and EllesmereUI.L or function(a)return a end
    local pin,recent=L('Pinned Items'),L('Recent Items')
    local special={[pin]=-2,[recent]=-1,[view.otherName or 'Uncategorised']=nextRank+1,[junk and junk.name or L('Junk')]=nextRank+2}
    for n in pairs(special) do if lookup[n] then return nil,'category collides with native label' end end
    local blocks,objects={},{}; local pads={}; local usedLabels={}; local hasSection=false
    for _,p in pairs(bag._emptyPads or {}) do pads[p]=true end
    for _,f in ipairs({child:GetChildren()}) do
        if shown(f) and not self.ownFrames[f] then
            if self.slots[f] or pads[f] then
                local p=position(f,child); if not p then return nil,'unrecognised slot anchor' end
                p.item=self.slots[f] and true or false; objects[#objects+1]=p
            elseif f._label and f._line and f._label.GetText then
                local name,num=groupName(f._label:GetText()); local def=lookup[name]
                if not name or not (def or special[name]) or usedLabels[name] then return nil,'unrecognised category header' end
                local b=position(f,child); if not b then return nil,'unrecognised header anchor' end
                b.count=num; b.members={}; b.actual=0; b.pinned=name==pin; b.name=name
                if def then b.section=def.section; b.short=def.short; b.rank=def.rank else b.rank=special[name] end
                if b.section then hasSection=true end
                usedLabels[name]=true; blocks[#blocks+1]=b
            elseif f~=bag._pinOverlayBtn then
                -- No unknown visible child may be left behind by our reflow.
                return nil,'unrecognised visible inventory frame'
            end
        end
    end
    if #blocks==0 or not hasSection then return nil,'no visible sections' end
    table.sort(blocks,sortPos)
    local left=blocks[1].x; local right=child:GetWidth()-10
    if right<=left then return nil,'invalid grid width' end
    for _,b in ipairs(blocks) do left=min(left,b.x) end
    for _,p in ipairs(objects) do
        local best
        for _,b in ipairs(blocks) do
            -- Compact groups are rectangular, arranged left to right in each band.
            -- Choose the nearest preceding band, then nearest preceding block on x.
            if b.y>=p.y+0.1 and b.x<=p.x+0.1 then
                if not best or b.y<best.y-0.1 or (abs(b.y-best.y)<=0.1 and b.x>best.x) then best=b end
            end
        end
        if not best or p.x+p.w>right+2 or p.y>best.y-best.h+0.1 then return nil,'slot outside recognised block' end
        -- Check the actual horizontal interval before accepting ownership.
        for _,other in ipairs(blocks) do
            if abs(other.y-best.y)<=0.1 and other.x>best.x+0.1 and p.x+p.w>other.x+0.1 then return nil,'slot crosses category boundary' end
        end
        best.members[#best.members+1]=p; if p.item then best.actual=best.actual+1 end
    end
    for _,b in ipairs(blocks) do
        local expected=b.count+(b.pinned and not bag.IsCompactMode() and 1 or 0)
        if b.actual~=expected then return nil,'native slot count mismatch: '..b.name..' ('..b.actual..'/'..expected..')' end
    end
    -- Do not reorder before resolving ownership: that requires the original
    -- native geometry. Only move validated groups, never individual item order.
    local reordered=false
    for i=2,#blocks do if blocks[i-1].rank>blocks[i].rank then reordered=true;break end end
    if reordered then table.sort(blocks,function(a,b) return a.rank<b.rank end) end
    return blocks,left,right,reordered
end
function S:Header(i,child)
    local b=self.headers[i]
    if b and b:GetParent()==child then return b end
    if b then b:Hide() end
    b=CreateFrame('Button',nil,child); self.ownFrames[b]=true; self.headers[i]=b
    b:SetHeight(20); b:SetFrameLevel(child:GetFrameLevel()+4)
    local fs=b:CreateFontString(nil,'OVERLAY','GameFontNormalSmall'); fs:SetPoint('LEFT',b,'LEFT',0,0); fs:SetTextColor(0.027,0.835,0.616); b.text=fs
    local line=b:CreateTexture(nil,'ARTWORK'); line:SetHeight(1); line:SetColorTexture(0.027,0.835,0.616,0.45); line:SetPoint('LEFT',fs,'RIGHT',8,0); line:SetPoint('RIGHT',b,'RIGHT',0,0)
    b:SetScript('OnClick',function(btn)
        if combat() or hasCursor() or not btn.section or not self:Selected(_G.EUI_Bags) then return end
        self.collapsed[btn.section]=not self.collapsed[btn.section] or nil
        _G.EUI_Bags:RefreshInventory()
    end)
    return b
end
S.ownFrames=setmetatable({}, {__mode='k'})
function S:AfterRefresh(bag)
    if self.busy then return end
    self:HideHeaders()
    if not bag:IsVisible() or not BR.db or not BR.db.enabled or not BR.db.view or BR.db.sectionLayout~='hierarchy' or self.failed then return end
    if combat() or hasCursor() or activeCatch(bag) or bag.IsListMode() then self.state='flat (combat, cursor, selection or list mode)'; return end
    local view,reason=self:Selected(bag); if not view then self.state='flat: '..tostring(reason); return end
    if not bag._scrollChild or type(bag._scrollChild.GetHeight)~='function' then self.state='flat: scroll child geometry unavailable'; return end
    local child=bag._scrollChild
    local changed={}; local oldH=child and child:GetHeight()
    self.busy=true
    local ok,err=pcall(function()
        local blocks,left,right,reordered=self:Collect(bag,view)
        if not blocks then self.state='flat: '..tostring(left); return end
        local search=bag._appliedSearch and bag._appliedSearch~=''
        local plan
        if bag.IsCompactMode() and BR.db.tightCompact~=false then
            local measured=true
            for _,b in ipairs(blocks) do
                if b.section then
                    b.textWidth=self:MeasureShortLabel(child,b)
                    if not b.textWidth or not b.f.SetWidth or not b.f._label.SetWidth or not b.f._label.GetWidth or not b.f._line.IsShown or not b.f._line.Hide or not b.f._line.Show then measured=false; break end
                end
            end
            if measured then plan=self.PlanCompact(blocks,self.collapsed,search,left,right,oldH,reordered) end
        end
        -- Keep the previously validated hierarchical layout if dense packing
        -- is disabled or the host has no supported measurement contract.
        local dense=plan~=nil
        if not plan then plan=self.Plan(blocks,self.collapsed,search,left,right,oldH,reordered) end
        if not plan or #plan.headers==0 then self.state='flat: no sections'; return end
        -- Pre-create only plain header buttons. Never create or alter a secure item button.
        for i,h in ipairs(plan.headers) do
            local b=self:Header(i,child); b:ClearAllPoints(); b:SetPoint('TOPLEFT',child,'TOPLEFT',h.x,h.y); b:SetWidth(h.w)
            b.section=h.name; b.text:SetText((h.collapsed and '+ ' or '- ')..h.name); b:Hide()
        end
        for _,m in ipairs(plan.moves) do
            local p=m.p; local f=p.f
            changed[#changed+1]={p=p,label=m.label and f._label:GetText() or nil,visual=m.width and not m.hide and snapshotLabel(f) or nil}
            if m.hide then f:Hide() else
                f:ClearAllPoints(); f:SetPoint('TOPLEFT',child,'TOPLEFT',m.x,m.y)
                if m.label then f._label:SetText(m.label) end
                if m.width then sizeLabel(f,m.width,p.textWidth) end
            end
        end
        child:SetHeight(plan.height)
        local sf=bag._scrollFrame
        if sf then sf:SetVerticalScroll(min(sf:GetVerticalScroll(),sf:GetVerticalScrollRange())) end
        for i=1,#plan.headers do self.headers[i]:Show() end
        if bag._updateThumb then bag._updateThumb() end
        self.state='runtime nested ('..#plan.headers..' sections)'
        self.density=dense and 'compact' or 'native bands'
    end)
    if not ok then
        -- Best-effort rollback of the native layout before disabling this session.
        if not combat() then
            for i=#changed,1,-1 do local m=changed[i]; local p=m.p; pcall(function() p.f:ClearAllPoints(); p.f:SetPoint('TOPLEFT',child,'TOPLEFT',p.x,p.y); if m.label then p.f._label:SetText(m.label) end; if m.visual then restoreLabel(p.f,m.visual) end; p.f:Show() end) end
            if oldH then pcall(child.SetHeight,child,oldH) end
        end
        self:HideHeaders(); self.failed=true; self.state='runtime disabled after error: '..tostring(err)
        BR:Print(self.state)
    end
    self.busy=false
end
