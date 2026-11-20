-- Read-only visual hierarchy for BagRules virtual category rows on live bags.
-- EUI's public registration API has no groups. Never mutate its category records,
-- native scripts, selection, saved group names, item buttons, or classification.
local _,BR=...
local S={headers={},collapsed={},state='not installed'};BR.NativeSidebar=S
local function combat() return InCombatLockdown and InCombatLockdown() end
local function shown(f) return f and f.IsShown and f:IsShown() end
local function protected(f) return f and type(f.IsProtected)=='function' and f:IsProtected() and true or false end
local function positioned(f,child)
    if not (f.GetNumPoints and f.GetPoint and f.GetWidth and f.GetHeight) or f:GetNumPoints()~=1 then return end
    local p,rel,rp,x,y=f:GetPoint(1)
    if p~='TOPLEFT' or rel~=child or rp~='TOPLEFT' or type(x)~='number' or type(y)~='number' then return end
    local w,h=f:GetWidth(),f:GetHeight()
    if type(w)~='number' or type(h)~='number' or w<=0 or h<=0 or x~=x or y~=y then return end
    return {f=f,x=x,y=y,w=w,h=h}
end
local function place(p,child,x,y,w)
    p.f:ClearAllPoints();p.f:SetPoint('TOPLEFT',child,'TOPLEFT',x,y);p.f:SetWidth(w)
end
-- Original row order and native spacing are retained, with one heading per
-- contiguous named parent. Only the virtual rows are indented.
function S.Plan(rows,oldHeight,collapsed)
    local moves,headers,seen={}, {},{};local offset,last=0,nil
    for i,r in ipairs(rows) do
        local section=r.section
        if section and section~=last then
            if seen[section] then return nil,'noncontiguous virtual groups' end
            seen[section]=true
            local head={name=r.sectionName,section=section,collapsed=collapsed and collapsed[section] or false,icon=r.sectionIcon,y=r.y-offset,w=r.w,h=r.h,count=0,first=r.f}
            headers[#headers+1]=head;offset=offset+r.h+2
        end
        if section then headers[#headers].count=headers[#headers].count+(r.count or 0) end
        if section and collapsed and collapsed[section] then
            moves[#moves+1]={p=r,x=r.x,y=r.y,w=r.w,hide=true}
            local following=rows[i+1];local gap=following and math.max(0,math.min(8,r.y-following.y-r.h)) or 0
            offset=offset-r.h-gap
        elseif section or offset~=0 then
            local indent=section and 12 or 0
            if r.w-indent<36 then return nil,'sidebar too narrow' end
            moves[#moves+1]={p=r,x=r.x+indent,y=r.y-offset,w=r.w-indent}
        end
        last=section
    end
    return {moves=moves,headers=headers,height=oldHeight+offset}
end
function S:Hide() for _,b in ipairs(self.headers) do b:Hide() end end
function S:Intact(child)
    local last=self.last;if not last or not child or not shown(last.f) then return false end
    local p=positioned(last.f,child)
    return p and math.abs(p.x-last.x)<=0.1 and math.abs(p.y-last.y)<=0.1 or false
end
local function accent()
    local e=EllesmereUI
    if e and type(e.GetAccentColor)=='function' then local ok,r,g,b=pcall(e.GetAccentColor);if ok and type(r)=='number' and type(g)=='number' and type(b)=='number' then return r,g,b end end
    return .85,.85,.85
end
function S:Header(index,child,h)
    local f=self.headers[index]
    if not f or f:GetParent()~=child then
        if f then f:Hide() end
        f=CreateFrame('Button',nil,child);self.headers[index]=f;f.brHeading=true
        f:SetScript('OnClick',function(b)
            if combat() or (GetCursorInfo and GetCursorInfo()) or not b.section or not _G.EUI_Bags or not _G.EUI_Bags:IsVisible() then return end
            self.collapsed[b.section]=not self.collapsed[b.section] or nil;_G.EUI_Bags:RefreshInventory()
        end)
        f.label=f:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');f.label:SetPoint('LEFT',f,'LEFT',28,0);f.icon=f:CreateTexture(nil,'ARTWORK');f.icon:SetSize(16,16);f.icon:SetPoint('LEFT',f,'LEFT',8,0);f.label:SetPoint('RIGHT',f,'RIGHT',-30,0);f.label:SetJustifyH('LEFT');f.label:SetWordWrap(false)
        f.count=f:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');f.count:SetPoint('RIGHT',f,'RIGHT',-6,0);f.count:SetJustifyH('RIGHT')
    end
    local sample=h.first._label
    if sample and sample.GetFont and f.label.SetFont then local path,size,flags=sample:GetFont();if path and size then f.label:SetFont(path,size,flags);f.count:SetFont(path,math.max(8,size-1),flags) end end
    f:ClearAllPoints();f:SetPoint('TOPLEFT',child,'TOPLEFT',0,h.y);f:SetWidth(h.w);f:SetHeight(h.h)
    f.section=h.section;f.icon:SetTexture(h.icon or 132996);f.label:SetText((h.collapsed and "+ " or "- ")..h.name);f.label:SetTextColor(accent());f.count:SetText(tostring(h.count));f.count:SetTextColor(.65,.65,.65);f:Show()
    return f
end
function S:AfterRefresh(bag)
    if self.failed or self.busy or not BR.db or not BR.db.enabled or not BR.status or (BR.status.native or 0)==0 then self.deferred=false;self:Hide();self.state='inactive';return end
    -- EUI rebuilds its sidebar rows during combat too, so skipping work left the
    -- sidebar flat. Sidebar rows are plain buttons: regroup them in combat unless
    -- one is protected, and then keep headings only while rows are untouched.
    local inCombat=combat()
    local function defer(why)
        self.deferred=true;BR.pendingRefresh=true
        if self:Intact(bag._sidebarChild) then self.state='deferred (combat, '..why..')' else self:Hide();self.last=nil;self.state='flat until combat ends ('..why..')' end
    end
    if GetCursorInfo and GetCursorInfo() then if inCombat then defer('cursor') else self.deferred=false;self:Hide();self.state='flat (cursor)' end;return end
    if not inCombat then self.deferred=false;self.last=nil;self:Hide() end
    local function flat(msg) if inCombat then defer(msg) else self.state=msg end end
    local child,sidebar=bag._sidebarChild,bag._sidebar
    if not bag:IsVisible() or not shown(sidebar) or not child or not child.GetChildren or not child.GetHeight or not child.GetWidth or not shown(bag._sidebarHdr and bag._sidebarHdr._label) then flat('flat (sidebar unavailable or collapsed)');return end
    -- Only normal, current-character bags: the offline panel can independently
    -- rebuild its sidebar without a full inventory refresh. Detect it when exposed.
    local cm=_G.EUI_CategoryManager
    if not cm or type(cm.GetCategories)~='function' then flat('flat (host categories unavailable)');return end
    local cats=cm:GetCategories();if type(cats)~='table' then flat('flat (host categories unrecognised)');return end
    local rows,own={},0
    for _,f in ipairs({child:GetChildren()}) do
        if shown(f) and (f._catIdx~=nil or f==sidebar._addCatBtn) then
            local p=positioned(f,child);if not p or math.abs(p.x)>0.1 or math.abs(p.w-child:GetWidth())>1 then flat('flat (unrecognised sidebar geometry)');return end
            local c=cats[f._catIdx];local id=c and c.isVirtual and type(c._defaultName)=='string' and c._defaultName:match('^Virtual:BagRules:(c%d+)$')
            local rule=id and BR:Get(id)
            if rule then
                local parent=BR:GetSection(rule.sectionID)
                if parent and parent.name~='' then p.section=parent.id;p.sectionName=parent.name;p.sectionIcon=parent.icon;p.count=tonumber(f._catCount) or 0;own=own+1 end
            end
            rows[#rows+1]=p
        end
    end
    if own==0 then flat('flat (no visible grouped categories)');return end
    table.sort(rows,function(a,b)return a.y>b.y end)
    local oldHeight=child:GetHeight();local prev
    for _,r in ipairs(rows) do if prev and r.y>prev.y-prev.h+0.1 then flat('flat (overlapping native rows)');return end;prev=r end
    local plan,reason=self.Plan(rows,oldHeight,self.collapsed);if not plan then flat('flat: '..reason);return end
    if inCombat then
        local locked=protected(child)
        for _,m in ipairs(plan.moves) do if protected(m.p.f) then locked=true;break end end
        if locked then defer('protected rows');return end
    end
    self:Hide()
    self.busy=true;local changed={}
    local ok,err=pcall(function()
        for _,m in ipairs(plan.moves) do changed[#changed+1]=m.p;if m.hide then m.p.f:Hide() else place(m.p,child,m.x,m.y,m.w) end end
        for i,h in ipairs(plan.headers) do self:Header(i,child,h) end
        child:SetHeight(plan.height)
        -- A partial offline rebuild resets native row anchors independently of
        -- RefreshInventory. Remove headings as soon as that happens; no writes
        -- to rows in this observer, and no repeated layout work per frame.
        local watch=self.headers[1]
        if watch then watch:SetScript('OnUpdate',function()
            local m=plan.moves[1];if not m then return end
            local p=positioned(m.p.f,child)
            if not p or (m.hide and shown(m.p.f)) or (not m.hide and (math.abs(p.x-m.x)>0.1 or math.abs(p.y-m.y)>0.1 or not shown(m.p.f))) or math.abs(child:GetHeight()-plan.height)>0.1 then
                -- Rows moved under us: never leave stale headings over them.
                self:Hide();self.last=nil
                if combat() then self.deferred=true;BR.pendingRefresh=true;self.state='flat until combat ends (rows rebuilt)' end
            end
        end) end
        self.last=nil;for _,m in ipairs(plan.moves) do if not m.hide then self.last={f=m.p.f,x=m.x,y=m.y};break end end
        self.deferred=false;self.state='grouped ('..#plan.headers..' parents'..(inCombat and ', combat repaint' or '')..')'
    end)
    if not ok then
        for _,p in ipairs(changed) do pcall(place,p,child,p.x,p.y,p.w);pcall(p.f.Show,p.f) end
        pcall(child.SetHeight,child,oldHeight);self:Hide();self.failed=true;self.state='flat after sidebar error: '..tostring(err)
    end
    self.busy=false
end
function S:Install()
    if self.installed then return not self.failed end
    local bag=_G.EUI_Bags
    if not bag or type(bag.RefreshInventory)~='function' or type(hooksecurefunc)~='function' then self.state='flat (refresh API unavailable)';return false end
    local ok=pcall(hooksecurefunc,bag,'RefreshInventory',function()
        if self.failed then return end
        local success,err=pcall(self.AfterRefresh,self,bag)
        if not success then self:Hide();self.failed=true;self.state='flat: '..tostring(err) end
    end)
    self.installed=ok;self.state=ok and 'ready' or 'flat (hook unavailable)';return ok
end
