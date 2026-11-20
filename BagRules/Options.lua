local ADDON, BR = ...
local R=BR.Rules
-- The page belongs to EUI: no opaque custom background. Use its theme tokens
-- and native primitives when exposed; older hosts get neutral translucent controls.
local accent={0.027,0.835,0.616}; local bg={0,0,0,0.24}; local panel={0,0,0,0}; local border={1,1,1,0.18}; local dim={0.72,0.72,0.72}; local white={0.93,0.95,0.96}
local selectedOff={0.25,0.25,0.25,1}; local knob={0.96,0.98,0.98,1}; local knobOn={0.96,0.98,0.98,1}; local toggleAlpha=1
local ddBG={0,0,0,0.35}; local ddBorder={1,1,1,0.22}; local ddMenuBG={0.09,0.08,0.07,0.98}
local unpack=unpack or table.unpack
local function tokens(r,g,b)
    local e=EllesmereUI or {}
    if type(r)=="number" and type(g)=="number" and type(b)=="number" then accent[1],accent[2],accent[3]=r,g,b
    else
        local ok,ar,ag,ab=false,nil,nil,nil
        if type(e.GetAccentColor)=="function" then ok,ar,ag,ab=pcall(e.GetAccentColor) end
        if ok and type(ar)=="number" and type(ag)=="number" and type(ab)=="number" then accent[1],accent[2],accent[3]=ar,ag,ab
        elseif type(e.ELLESMERE_GREEN)=="table" and type(e.ELLESMERE_GREEN.r)=="number" then local a=e.ELLESMERE_GREEN; accent[1],accent[2],accent[3]=a.r,a.g,a.b end
    end
    local d=e.DD_STYLE or {}
    local function n(a,b) return type(a)=="number" and a or b end
    bg[1],bg[2],bg[3],bg[4]=n(e.BTN_BG_R,0),n(e.BTN_BG_G,0),n(e.BTN_BG_B,0),n(e.BTN_BG_A,0.24)
    border[4]=n(e.BTN_BRD_A,0.18)
    ddBG[1],ddBG[2],ddBG[3],ddBG[4]=n(d.BG_R,n(e.DD_BG_R,0)),n(d.BG_G,n(e.DD_BG_G,0)),n(d.BG_B,n(e.DD_BG_B,0)),n(d.BG_A,n(e.DD_BG_A,0.35))
    ddBorder[4]=n(d.BRD_A,n(e.DD_BRD_A,0.22))
    -- Menus must remain opaque/readable above the options background.
    ddMenuBG[1],ddMenuBG[2],ddMenuBG[3]=n(d.BG_R,n(e.DD_BG_R,0.09)),n(d.BG_G,n(e.DD_BG_G,0.08)),n(d.BG_B,n(e.DD_BG_B,0.07))
    dim[1],dim[2],dim[3]=n(e.TEXT_DIM_R,0.72),n(e.TEXT_DIM_G,0.72),n(e.TEXT_DIM_B,0.72)
    white[1],white[2],white[3]=n(e.TEXT_WHITE_R,0.93),n(e.TEXT_WHITE_G,0.95),n(e.TEXT_WHITE_B,0.96)
    selectedOff[1],selectedOff[2],selectedOff[3],selectedOff[4]=n(e.TG_OFF_R,0.25),n(e.TG_OFF_G,0.25),n(e.TG_OFF_B,0.25),n(e.TG_OFF_A,1)
    knob[1],knob[2],knob[3],knob[4]=n(e.TG_KNOB_OFF_R,0.96),n(e.TG_KNOB_OFF_G,0.98),n(e.TG_KNOB_OFF_B,0.98),n(e.TG_KNOB_OFF_A,1)
    knobOn[1],knobOn[2],knobOn[3],knobOn[4]=n(e.TG_KNOB_ON_R,0.96),n(e.TG_KNOB_ON_G,0.98),n(e.TG_KNOB_ON_B,0.98),n(e.TG_KNOB_ON_A,1)
    toggleAlpha=n(e.TG_ON_A,1)
end
-- Track presentation roles, not snapshots of colours. Repaint in place, never
-- reload a draft or change a saved setting in response to a theme change.
local themed=setmetatable({},{__mode="k"})
local function track(obj,key,value)
    local t=themed[obj]; if not t then t={};themed[obj]=t end; t[key]=value
end
local function color(fs,c) track(fs,"text",c);fs:SetTextColor(c[1],c[2],c[3],c[4] or 1) end
local function surface(f,c,b)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    track(f,"bg",c); track(f,"border",b); f:SetBackdropColor(c[1],c[2],c[3],c[4] or 1); f:SetBackdropBorderColor(b[1],b[2],b[3],b[4] or 1)
end
local function frame(parent,c,b)
    local f=CreateFrame("Frame",nil,parent,"BackdropTemplate"); if c then surface(f,c,b or border) end; return f
end
local function label(parent,text,size,c)
    local f; local E=EllesmereUI
    if E and type(E.MakeFont)=="function" then
        local ok,v=pcall(E.MakeFont,parent,size=="large" and 16 or 12,nil,1,1,1)
        if ok and v and v.SetText then f=v end
    end
    f=f or parent:CreateFontString(nil,"ARTWORK",size=="large" and "GameFontNormalLarge" or "GameFontHighlightSmall")
    f:SetText(text or ""); color(f,c or white); f:SetJustifyH("LEFT"); return f
end
local function paint(b,c)
    track(b,"bg",c); track(b,"accentFill",false)
    if b._brNativeBg then b._brNativeBg:SetColorTexture(c[1],c[2],c[3],c[4] or 1) else b:SetBackdropColor(c[1],c[2],c[3],c[4] or 1) end
end
local function outline(b,c)
    track(b,"border",c)
    if b._brNativeBorder then b._brNativeBorder:SetColor(c[1],c[2],c[3],c[4] or 1) else b:SetBackdropBorderColor(c[1],c[2],c[3],c[4] or 1) end
end
local function accentPaint(b,a)
    paint(b,{accent[1],accent[2],accent[3],a});track(b,"accentFill",a)
end
local function selectedPaint(b,selected)
    if selected then accentPaint(b,0.15) else paint(b,bg) end
end
local function repaint(r,g,b)
    tokens(r,g,b)
    for obj,t in pairs(themed) do
        if t.text then color(obj,t.text) end
        if t.accentFill then accentPaint(obj,t.accentFill) elseif t.bg then paint(obj,t.bg) end
        if t.border then outline(obj,t.border) end
        if t.toggle~=nil then obj:State(t.toggle) end
        if t.marker~=nil then obj:SetColorTexture(accent[1],accent[2],accent[3],t.marker) end
    end
end
local accentRegistered=false
local function ensureTheme()
    local E=EllesmereUI
    if not accentRegistered and E and type(E.RegAccent)=="function" then
        accentRegistered=pcall(E.RegAccent,{type="callback",fn=repaint})
    end
    repaint()
end
local function btn(parent,text,w,h,fn,kind)
    local E=EllesmereUI; local b=CreateFrame("Button",nil,parent,"BackdropTemplate"); b:SetSize(w,h or 26)
    -- Use EUI's actual native button chrome for normal/dynamic controls if available.
    -- Tree rows need independent selection colours, so they use neutral theme tokens.
    if kind~="row" and E and type(E.MakeStyledButton)=="function" and type(E.RB_COLOURS)=="table" then
        local colors=E.RB_COLOURS
        if kind=="dropdown" then colors={ddBG[1],ddBG[2],ddBG[3],ddBG[4],ddBG[1],ddBG[2],ddBG[3],math.min(1,ddBG[4]+0.15),1,1,1,ddBorder[4],1,1,1,math.min(1,ddBorder[4]+0.15),1,1,1,0.8,1,1,1,1} end
        local ok,back,brd,t=pcall(E.MakeStyledButton,b,text,12,colors,nil)
        if ok and back and back.SetColorTexture and brd and brd.SetColor and t and t.SetText then
            b._brNativeBg,b._brNativeBorder,b.text=back,brd,t
            b:SetScript("OnClick",fn); return b
        end
        b:Hide(); b=CreateFrame("Button",nil,parent,"BackdropTemplate"); b:SetSize(w,h or 26)
    end
    surface(b,kind=="dropdown" and ddBG or bg,kind=="dropdown" and ddBorder or border)
    local t=label(b,text); t:SetPoint("CENTER"); b.text=t
    b:SetScript("OnEnter",function(self) outline(self,accent) end)
    b:SetScript("OnLeave",function(self) outline(self,kind=="dropdown" and ddBorder or border) end)
    b:SetScript("OnClick",fn); return b
end
local function edit(parent,multi)
    local e=CreateFrame("EditBox",nil,parent,"BackdropTemplate"); surface(e,ddBG,ddBorder)
    e:SetFontObject(GameFontHighlightSmall)
    if EllesmereUI and type(EllesmereUI.EXPRESSWAY)=="string" and e.SetFont then pcall(e.SetFont,e,EllesmereUI.EXPRESSWAY,12,"") end
    e:SetAutoFocus(false); e:SetTextInsets(7,7,5,5)
    e:SetMultiLine(multi or false); e:SetMaxLetters(multi and 8192 or 256)
    e:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    if not multi then e:SetScript("OnEnterPressed",function(self) self:ClearFocus() end) end
    return e
end
local function left(f,parent,x,y) f:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y) end
local function stretch(f,parent,x,y,right,h) left(f,parent,x,y); f:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-right,-y); f:SetHeight(h) end
local function title(parent,text,x,y)
    local l=label(parent,text,nil,dim); left(l,parent,x,y); return l
end
local function toggle(parent,text,w,fn)
    local b=btn(parent,"",w,26,function(self) fn() end)
    local t=b:CreateTexture(nil,"ARTWORK"); t:SetSize(30,14); t:SetPoint("LEFT",8,0)
    local handle=b:CreateTexture(nil,"OVERLAY"); handle:SetSize(10,10); handle:SetColorTexture(0.96,0.98,0.98,1)
    b.text:ClearAllPoints(); b.text:SetPoint("LEFT",t,"RIGHT",8,0); b.text:SetText(text)
    function b:State(on)
        track(self,"toggle",not not on)
        local c=on and accent or selectedOff; local k=on and knobOn or knob
        t:SetColorTexture(c[1],c[2],c[3],on and toggleAlpha or c[4]);handle:SetColorTexture(k[1],k[2],k[3],k[4]);handle:ClearAllPoints();handle:SetPoint(on and "RIGHT" or "LEFT",t,on and "RIGHT" or "LEFT",on and -2 or 2,0)
    end
    return b
end
-- Search across the full client catalogue; recycle a small visible row pool.
local iconID,validIcon=BR.IconSearch.ID,BR.IconSearch.ValidID
local iconCatalogue=BR.IconSearch.Catalogue
local iconBrowser
local dropdown -- shared EUI-styled searchable choice widget, defined below
local function closeIconBrowser() if iconBrowser then iconBrowser:Hide() end end
local function browseIcons(current,onPick,owner,context)
    closeIconBrowser();local I=BR.IconSearch;local catalogue=I.Rank(iconCatalogue(),context);local results={};local group="All"
    local cols,step,visible=12,42,9
    local win=iconBrowser
    if not win then
        win=frame(UIParent,ddMenuBG,ddBorder);iconBrowser=win;win:SetSize(552,614);win:SetPoint("CENTER",UIParent,"CENTER",0,0);win:SetFrameStrata("TOOLTIP");if win.SetClampedToScreen then win:SetClampedToScreen(true) end;win:EnableMouse(true)
        local heading=label(win,"CHOOSE ICON","large",accent);left(heading,win,12,10)
        btn(win,"X",26,24,closeIconBrowser):SetPoint("TOPRIGHT",win,"TOPRIGHT",-8,-8)
        win.search=edit(win,false);stretch(win.search,win,12,42,12,28)
        win.hint=label(win,"Search names, filenames, keywords or file IDs",nil,dim);left(win.hint,win,12,75)
        win.filters={};for i,g in ipairs(I.groups) do local b=btn(win,g,72,23,nil,"row");left(b,win,12+((i-1)%7)*75,96+math.floor((i-1)/7)*26);win.filters[g]=b end
        local choices={"All detailed categories"};for _,g in ipairs(I.details) do choices[#choices+1]=g end
        win.detail=dropdown(win,512,choices,function(v) if win.selectDetail then win.selectDetail(v) end end,false,false,win,true)
        left(win.detail,win,12,150)
        -- This popup lives above a TOOLTIP-strata modal, not the main options panel.
        if win.detail.brMenu.SetFrameLevel and win.GetFrameLevel then win.detail.brMenu:SetFrameLevel(win:GetFrameLevel()+20) end
        if win.detail.brChoiceSearch then win.detail.brChoiceSearch.brSearchHint:SetText("Find icon category...") end
        win.scroll=CreateFrame("ScrollFrame",nil,win,"UIPanelScrollFrameTemplate");win.scroll:SetPoint("TOPLEFT",win,"TOPLEFT",12,-183);win.scroll:SetSize(cols*step,visible*step);win.child=frame(win.scroll);win.child:SetSize(cols*step,visible*step);win.scroll:SetScrollChild(win.child)
        win.rows={};for i=1,cols*(visible+1) do local b=btn(win.child,"",39,39,nil,"row");b.ic=b:CreateTexture(nil,"ARTWORK");b.ic:SetSize(35,35);b.ic:SetPoint("CENTER");win.rows[i]=b
            b:SetScript("OnEnter",function(self) if self.entry and GameTooltip then GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(self.entry.name.."  ["..self.entry.id.."]");if self.entry.filename and self.entry.filename~=self.entry.name and GameTooltip.AddLine then GameTooltip:AddLine(self.entry.filename) end;GameTooltip:Show() end end);b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
        end
        win.info=label(win,"",nil,dim);left(win.info,win,12,566)
        win.manual=edit(win,false);win.manual:SetSize(118,24);left(win.manual,win,12,584);win.manualBtn=btn(win,"Use file ID",102,24,nil);left(win.manualBtn,win,138,584)
        win.coverage=label(win,"",nil,dim);left(win.coverage,win,248,590)
        local function vertical(_,offset) if win.render then win.render(offset) end end
        if win.scroll.HookScript then win.scroll:HookScript("OnVerticalScroll",vertical) else win.scroll:SetScript("OnVerticalScroll",vertical) end
        if win.scroll.EnableMouseWheel then win.scroll:EnableMouseWheel(true);win.scroll:SetScript("OnMouseWheel",function(self,d) local h=win.maxScroll or 0;local v=self.GetVerticalScroll and self:GetVerticalScroll() or 0;self:SetVerticalScroll(math.max(0,math.min(h,v-d*step*2)));if win.render then win.render(self:GetVerticalScroll()) end end) end
        win:SetScript("OnHide",function() if GameTooltip then GameTooltip:Hide() end;win.owner=nil;win.render=nil;win.selectDetail=nil;win.detail:CloseMenu();for _,b in ipairs(win.rows) do b.entry=nil;b:SetScript("OnClick",nil) end;win.search:SetScript("OnTextChanged",nil);for _,b in pairs(win.filters) do b:SetScript("OnClick",nil) end;win.manualBtn:SetScript("OnClick",nil) end)
    end
    win.owner=owner
    local named=0;for _,v in ipairs(catalogue) do if v.named then named=named+1 end end
    win.coverage:SetText(named.." / "..#catalogue.." labelled")
    local function pick(id) if win.owner and win.owner:IsVisible() then win:Hide();onPick(id) else win:Hide() end end
    local function render(offset)
        local y=math.max(0,math.min(win.maxScroll or 0,tonumber(offset) or 0));local first=math.floor(y/step)
        for i,b in ipairs(win.rows) do local j=first*cols+i;local v=results[j];b.entry=v;if v then
            b:ClearAllPoints();left(b,win.child,((j-1)%cols)*step,math.floor((j-1)/cols)*step);b.ic:SetTexture(v.id);outline(b,v.id==current and accent or border);b:SetScript("OnClick",function() pick(v.id) end);b:Show()
        else b:Hide();b:SetScript("OnClick",nil) end end
        win.info:SetText(#results.." of "..#catalogue.." icons  |  "..group.."  |  "..(#results>0 and (first*cols+1) or 0).."–"..math.min(#results,math.ceil((y+visible*step)/step)*cols))
    end
    win.render=render
    local function search()
        results=I.Search(catalogue,win.search:GetText(),group);local h=math.max(visible*step,math.ceil(#results/cols)*step);win.maxScroll=h-visible*step;win.child:SetHeight(h);win.scroll:SetVerticalScroll(0);render(0)
        for g,b in pairs(win.filters) do selectedPaint(b,g==group);color(b.text,g==group and accent or white) end
    end
    win.search:SetScript("OnTextChanged",function() if group=="Suggested" and win.search:GetText()~="" then group="All" end;search() end)
    win.selectDetail=function(v) group=v=="All detailed categories" and "All" or v;search() end
    win.detail:SetValue("All detailed categories")
    for g,b in pairs(win.filters) do local k=g;b:SetScript("OnClick",function() group=k;win.detail:SetValue("All detailed categories");win.detail:CloseMenu();search() end) end
    win.search:SetText("");win.manual:SetText(tostring(current or ""));win.manualBtn:SetScript("OnClick",function() local id=validIcon(win.manual:GetText());if id then pick(id) else win.info:SetText("Invalid icon file ID") end end)
    win:Show();search()
end
local function nativeIcons(current,onPick,owner,context)
    local E=EllesmereUI
    if E and type(E.ShowIconPicker)=="function" then
        local lead={};local data=BR.IconSearch.Rank(iconCatalogue(),context);for i=1,math.min(#data,150) do lead[i]=data[i].id end
        local ok=pcall(E.ShowIconPicker,{title="BagRules - Change Icon",subtitle="Select an icon for this category",current=current,lead=lead,customID=true,onPick=function(v) local id=iconID(v);if owner:IsVisible() and id then onPick(id) elseif owner:IsVisible() then browseIcons(current,onPick,owner,context) end end})
        if ok then return end
    end
    browseIcons(current,onPick,owner,context)
end
local activeMenu
dropdown=function(parent,w,values,changed,alignRight,fixed,popupOwner,searchable,multiple)
    -- The native dropdown factory owns its popup/arrow/scrolling and styling.
    -- Use it for stable choice lists. Dynamic lists below reuse native style
    -- primitives without assuming private menu reconstruction APIs.
    local E=EllesmereUI
    if fixed and E and type(E.BuildDropdownControl)=="function" and parent.GetFrameLevel then
        local host=frame(parent); host:SetSize(w,26); host.value=values[1]
        local names={_noLoc=true}; for _,v in ipairs(values) do names[v]=v end
        local ok,b,t=pcall(E.BuildDropdownControl,host,w,parent:GetFrameLevel()+3,names,values,function() return host.value end,function(v) host.value=v; changed(v) end)
        if ok and b and b.SetPoint and t and t.SetText then
            b:ClearAllPoints(); b:SetPoint("TOPLEFT",host,"TOPLEFT",0,0); b:SetSize(w,26)
            function host:SetValue(v) self.value=v; t:SetText(v) end
            host:SetValue(host.value); return host
        end
        host:Hide()
    end
    local b=btn(parent,"",w,26,nil,"dropdown"); local items={}; local arrow
    if EllesmereUI and type(EllesmereUI.MakeDropdownArrow)=="function" and EllesmereUI.PanelPP then local ok,v=pcall(EllesmereUI.MakeDropdownArrow,b,10,EllesmereUI.PanelPP); if ok and v then arrow=v end end
    b.text:ClearAllPoints(); b.text:SetPoint("LEFT",5,0); b.text:SetPoint("RIGHT",arrow and -19 or -5,0); b.text:SetWordWrap(false)
    local mw=math.max(w,multiple and 310 or 200)
    local menu=frame(popupOwner or parent,ddMenuBG,ddBorder); menu:SetFrameStrata("TOOLTIP"); menu:SetSize(mw,200); menu:SetPoint(alignRight and "TOPRIGHT" or "TOPLEFT",b,alignRight and "BOTTOMRIGHT" or "BOTTOMLEFT",0,-1); if menu.SetClampedToScreen then menu:SetClampedToScreen(true) end;menu:Hide()
    local sf=CreateFrame("ScrollFrame",nil,menu,"UIPanelScrollFrameTemplate"); sf:SetPoint("TOPLEFT",3,searchable and -31 or -3); sf:SetPoint("BOTTOMRIGHT",-25,3)
    local child=CreateFrame("Frame",nil,sf); child:SetSize(math.max(30,mw-32),1); sf:SetScrollChild(child)
    local choices=values;local filterBox
    if searchable then
        filterBox=edit(menu,false);stretch(filterBox,menu,3,3,4,24)
        local hint=label(filterBox,multiple and "Search choices..." or "Search conditions...",nil,dim);hint:SetPoint("LEFT",7,0)
        filterBox:SetScript("OnEditFocusGained",function() hint:Hide() end)
        filterBox:SetScript("OnEditFocusLost",function() if filterBox:GetText()=="" then hint:Show() end end)
        filterBox.brSearchHint=hint
    end
    local function populate(v)
        local oldScroll=multiple and menu:IsShown() and sf.GetVerticalScroll and sf:GetVerticalScroll() or 0
        for _,r in ipairs(items) do r:Hide() end
        for i,x in ipairs(v) do
            local row=items[i]
            if not row then row=btn(child,"",math.max(30,mw-32),24); row.text:ClearAllPoints();row.text:SetPoint("LEFT",5,0);row.text:SetPoint("RIGHT",-4,0);row.text:SetWordWrap(false);left(row,child,0,(i-1)*25); items[i]=row end
            local value=x; row.text:SetText(value); row:SetScript("OnClick",function() if multiple and value=="Done" then menu:Hide();return end;if not multiple then b:SetValue(value);menu:Hide() end;changed(value) end); row:Show()
        end
        child:SetHeight(math.max(1,#v*25)); menu:SetHeight(math.min(200,math.max(1,#v)*25+6)+(searchable and 28 or 0)); sf:SetVerticalScroll(math.min(oldScroll,math.max(0,#v*25-175)))
    end
    local function filtered()
        local q=filterBox and filterBox:GetText():lower() or "";local a={}
        for _,x in ipairs(choices) do if q=="" or (multiple and (x=="Done" or x=="Clear selection")) or x:lower():find(q,1,true) then a[#a+1]=x end end
        populate(a)
    end
    if filterBox then menu:SetScript("OnHide",function() filterBox:ClearFocus() end);filterBox:SetScript("OnTextChanged",function() if filterBox:GetText()=="" then filterBox.brSearchHint:Show() else filterBox.brSearchHint:Hide() end;filtered() end) end
    b.brMenu=menu;b.brChoiceSearch=filterBox
    function b:SetChoices(v) choices=v; if not popupOwner or menu:IsShown() then filtered() end end
    function b:SetValue(v) self.value=v; self.text:SetText(v..(arrow and "" or "  v")) end
    b:SetScript("OnClick",function() if menu:IsShown() then menu:Hide() else if b.brBeforeOpen then b.brBeforeOpen() end;if activeMenu and activeMenu~=menu then activeMenu:Hide() end; activeMenu=menu;if popupOwner then if filterBox then filterBox:SetText("");filterBox:ClearFocus();filtered() else filtered() end end;menu:Show() end end)
    function b:CloseMenu() menu:Hide();if filterBox then filterBox:ClearFocus() end end
    b:SetScript("OnHide",function() menu:Hide() end)
    b:SetChoices(values); b:SetValue(values[1]); return b
end
local function scroll(parent,x,y,w,h)
    local holder=frame(parent,bg,border); left(holder,parent,x,y); holder:SetSize(w,h)
    local sf=CreateFrame("ScrollFrame",nil,holder,"UIPanelScrollFrameTemplate"); sf:SetPoint("TOPLEFT",4,-4); sf:SetPoint("BOTTOMRIGHT",-25,4)
    local child=CreateFrame("Frame",nil,sf); child:SetSize(w-34,1); sf:SetScrollChild(child)
    return holder,child,sf
end
local function statusText()
    local s=BR.status or {}; return (s.message or "Waiting for login").." | Categories: "..(s.native or 0).." | View: "..(s.view and "active" or "not active").." | Section API: "..(s.hierarchy and "host patch active" or BR.RuntimeSections and BR.RuntimeSections.state or "stock / flat")..(BR.RuntimeSections and BR.RuntimeSections.hostVersion and (" | EUI Bags: "..BR.RuntimeSections.hostVersion) or "")..(BR.RuntimeSections and BR.RuntimeSections.state and BR.RuntimeSections.state:find("runtime nested",1,true) and BR.RuntimeSections.density and (" | Packing: "..BR.RuntimeSections.density) or "")..(BR.NativeSidebar and (s.native or 0)>0 and (" | Native sidebar: "..BR.NativeSidebar.state) or "").." | Auctionator: "..(BR:HasPrices() and "available" or "not installed")..((s.errors or 0)>0 and (" | Errors: "..s.errors) or "")..(BR.pending and " | Pending combat end" or "")..((BR.invalid or 0)>0 and (" | Invalid rules: "..BR.invalid) or "")
end
local selectedID
-- Simple filter editor: same EUI widgets, no operators or expression syntax.
local function buildFilterEditor(parent,getRootDraft,setRootDraft,replace,changed,convert)
    local active=1
    local function getDraft() local d=getRootDraft();return d and (d.methods and d.methods[active] or d) end
    local function setDraft(v) local d=getRootDraft();if d and d.methods then d.methods[active]=v else setRootDraft(v) end end
    local F=BR.Filters
    local holder=frame(parent,{0,0,0,0.08},border);left(holder,parent,0,0);holder:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",0,0)
    local sc=CreateFrame("ScrollFrame",nil,holder,"UIPanelScrollFrameTemplate");sc:SetPoint("TOPLEFT",4,-4);sc:SetPoint("BOTTOMRIGHT",-23,4)
    local content=frame(sc);content:SetSize(math.max(288,holder:GetWidth()-30),760);sc:SetScrollChild(content)
    local notice=frame(parent);left(notice,parent,0,0);notice:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",0,0)
    local msg=label(notice,"This category uses a legacy rule. Convert it to native filters when supported, or replace it manually.",nil,dim);stretch(msg,notice,4,8,4,76);msg:SetWordWrap(true)
    left(btn(notice,"Convert to native filters",200,28,convert),notice,4,92)
    left(btn(notice,"Replace with native filters",200,28,replace),notice,4,126)
    local updating=false;local controls={};local catalogue,fallback=F.Catalogue()
    local y=0
    local function heading(text) local t=label(content,text,nil,accent);left(t,content,4,y+4);y=y+24 end
    local function line(text,h) local t=label(content,text,nil,dim);left(t,content,4,y+6);t:SetWidth(116);t:SetWordWrap(false);local yy=y;y=y+(h or 32);return yy end
    local function refresh() if updating then return end;updating=true;local d=getDraft();for _,c in ipairs(controls) do c.refresh(d or {}) end;updating=false end
    heading("MATCHING METHODS")
    local methodNote=label(content,"An item can match any method. All selected properties within that method must match.",nil,dim);stretch(methodNote,content,4,y,4,34);methodNote:SetWordWrap(true);y=y+38
    local yy=line("Edit method");local methodPick
    methodPick=dropdown(content,170,{"Method 1 of 1"},function(v)local i=tonumber(v:match("^Method (%d+)"));if i then active=i;refresh() end end,true,false,parent)
    left(methodPick,content,125,yy);methodPick:SetPoint("TOPRIGHT",content,"TOPRIGHT",-4,-yy);methodPick.brFilterKey="method"
    controls[#controls+1]={refresh=function()local d=getRootDraft();local n=d and d.methods and #d.methods or 1;local a={};for i=1,n do a[i]="Method "..i.." of "..n end;methodPick:SetChoices(a);methodPick:SetValue(a[active] or a[1]) end}
    left(btn(content,"+ Alternative",124,25,function()
        local d=getRootDraft();if not d then return end
        if not d.methods then d={methods={d}};setRootDraft(d) end
        if #d.methods>=128 then return end;d.methods[#d.methods+1]={};active=#d.methods;changed();refresh()
    end),content,4,y)
    left(btn(content,"Remove method",135,25,function()
        local d=getRootDraft();if not d or not d.methods then return end;table.remove(d.methods,active);active=math.max(1,math.min(active,#d.methods));if #d.methods==1 then setRootDraft(d.methods[1]);active=1 end;changed();refresh()
    end),content,136,y);y=y+34
    local function change(key,value) local d=getDraft();if not d then return end;d[key]=value;changed();refresh() end
    local function selectedList(f,k,v)
        local a={};local found=false;for _,x in ipairs(f[k] or {}) do if x==v then found=true else a[#a+1]=x end end;if not found then a[#a+1]=v end;return #a>0 and a or nil
    end
    local function multi(text,keys,choicesFn)
        local yy=line(text);local map={};local b=dropdown(content,170,{"Any"},function(v)
            local d=getDraft();if not d then return end
            if v=="Clear selection" then for _,k in ipairs(keys) do d[k]=nil end
            else local entry=map[v];if not entry then return end;d[entry.k]=selectedList(d,entry.k,entry.v) end
            changed();refresh()
        end,true,false,parent,true,true)
        b.brFilterKey=keys[1];left(b,content,125,yy);b:SetPoint("TOPRIGHT",content,"TOPRIGHT",-4,-yy);b:SetHeight(25)
        controls[#controls+1]={refresh=function(d)
            local opts={"Done","Clear selection"};map={};local count=0;local selectedNames={};for _,k in ipairs(keys) do count=count+#(d[k] or {}) end
            local entries=choicesFn();for _,k in ipairs(keys) do for _,v in ipairs(d[k] or {}) do local found=false;for _,entry in ipairs(entries) do if entry.k==k and entry.v==v then found=true;break end end;if not found then entries[#entries+1]={k=k,v=v,label=tostring(v).." (not listed by client)"} end end end
            for _,entry in ipairs(entries) do
                local checked=F.Has(d[entry.k],entry.v);if checked then selectedNames[#selectedNames+1]=entry.label end;local label=(checked and "[x] " or "[ ] ")..entry.label
                if map[label] then label=label.." ("..tostring(entry.v)..")" end
                map[label]=entry;opts[#opts+1]=label
            end
            local display=table.concat(selectedNames,", ");b:SetChoices(opts);b:SetValue(count==0 and "Any (select...)" or (#selectedNames==count and #display<=38 and display or count.." selected (edit...)"))
        end,button=b}
        if keys[1]=="items" then local control=controls[#controls];b.brBeforeOpen=function()control.refresh(getDraft() or {})end end
    end
    local function list(k,a) return function() local out={};for _,v in ipairs(a) do out[#out+1]={k=k,v=v[1],label=v[2]} end;return out end end
    local function inventoryChoices()
        local a,seen={},{};if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo then
            for bag=0,(NUM_BAG_SLOTS or 4) do for slot=1,(C_Container.GetContainerNumSlots(bag) or 0) do
                local i=C_Container.GetContainerItemInfo(bag,slot);if i and i.itemID and not seen[i.itemID] then seen[i.itemID]=true;local item=BR:Item(i.hyperlink,i.itemID,bag,slot,i.quality)
                    a[#a+1]={k="items",v=i.itemID,label=((item.name or "Item").." ("..i.itemID..")"):gsub("|","/"),class=item.class,subclass=item.subclass}
                end
            end end
        end;table.sort(a,function(x,z)return x.label<z.label end);return a,seen
    end
    local function typeChoices()
        local a={};for _,c in ipairs(catalogue) do
            a[#a+1]={k="classes",v=c.id,label=c.name.." (all)"}
            for _,s in ipairs(c.subclasses) do a[#a+1]={k="subclasses",v=c.id..":"..s.id,label=c.name.." / "..s.name} end
        end;return a
    end
    heading("ITEM CLASSIFICATION")
    local guide=label(content,"Choose item types or copy one from your bags. Empty filters match nothing.",nil,dim);stretch(guide,content,4,y,4,30);guide:SetWordWrap(true);y=y+32
    local copyYY=line("Use item type");local sourceMap={};local sourcePick
    sourcePick=dropdown(content,220,{"Choose from bags..."},function(v)
        local item=sourceMap[v];local d=getDraft();if not d or not item or item.class==nil then return end
        if item.subclass~=nil then d.subclasses={item.class..":"..item.subclass};d.classes=nil else d.classes={item.class};d.subclasses=nil end
        changed();refresh()
    end,true,false,parent,true);left(sourcePick,content,125,copyYY);sourcePick:SetPoint("TOPRIGHT",content,"TOPRIGHT",-4,-copyYY);sourcePick.brFilterKey="sample"
    local function refreshSource()
        local choices={"Choose from bags..."};sourceMap={};for _,i in ipairs(inventoryChoices()) do if i.class~=nil then sourceMap[i.label]=i;choices[#choices+1]=i.label end end
        sourcePick:SetChoices(choices);sourcePick:SetValue(choices[1])
    end
    controls[#controls+1]={refresh=refreshSource};sourcePick.brBeforeOpen=refreshSource
    multi("Item types",{"classes","subclasses"},typeChoices)
    local typeSummary=label(content,"",nil,dim);stretch(typeSummary,content,4,y,4,42);typeSummary:SetWordWrap(true);y=y+43
    controls[#controls+1]={refresh=function(d) local names={};for _,v in ipairs(typeChoices()) do if F.Has(d[v.k],v.v) then names[#names+1]=v.label end end;typeSummary:SetText(#names>0 and table.concat(names,", "):gsub("|","/") or "No item type restriction. Class and subtype selections are alternatives.") end}
    local qualityChoices={{0,"Poor"},{1,"Common"},{2,"Uncommon"},{3,"Rare"},{4,"Epic"},{5,"Legendary"},{6,"Artifact"},{7,"Heirloom"}}
    multi("Quality",{"qualities"},list("qualities",qualityChoices))
    local function classChoices(k) return function()local a={};for _,c in ipairs(catalogue) do a[#a+1]={k=k,v=c.id,label=c.name} end;return a end end
    local function subtypeChoices(k) return function()
        local d=getDraft() or {};local a,names={},{}
        for _,c in ipairs(catalogue) do if not d.classes or F.Has(d.classes,c.id) then for _,s in ipairs(c.subclasses) do local n=names[s.id] or {};n[#n+1]=c.name.." / "..s.name;names[s.id]=n end end end
        for id,n in pairs(names) do a[#a+1]={k=k,v=id,label=table.concat(n," or ").." ("..id..")"} end;table.sort(a,function(x,z)return x.label<z.label end);return a
    end end
    multi("Subtype restriction",{"subclassIDs"},subtypeChoices("subclassIDs"))
    local function slotChoices(key) return function() local a={};for _,v in ipairs({"HEAD","NECK","SHOULDER","CHEST","ROBE","WAIST","LEGS","FEET","WRIST","HAND","FINGER","TRINKET","CLOAK","WEAPON","2HWEAPON","WEAPONMAINHAND","WEAPONOFFHAND","SHIELD","HOLDABLE","RANGED","RANGEDRIGHT","RELIC","BAG","BODY","TABARD"}) do local k="INVTYPE_"..v;a[#a+1]={k=key,v=k,label=type(_G[k])=="string" and _G[k] or v} end;return a end end
    multi("Equipment slots",{"slots"},slotChoices("slots"))
    heading("ITEM PROPERTIES")
    local bindingChoices={{0,"No binding"},{1,"Bind on pickup"},{2,"Bind on equip"},{3,"Bind on use"},{4,"Quest binding"}}
    multi("Binding type",{"bindings"},list("bindings",bindingChoices))
    local function flag(text,k,yes,no)
        local yy=line(text);local b=dropdown(content,170,{"Any",yes,no},function(v) local value;if v==yes then value=true elseif v==no then value=false end;change(k,value) end,true,false,parent)
        b.brFilterKey=k;left(b,content,125,yy);b:SetPoint("TOPRIGHT",content,"TOPRIGHT",-4,-yy);b:SetHeight(25)
        controls[#controls+1]={refresh=function(d)b:SetValue(d[k]==nil and "Any" or d[k] and yes or no)end,button=b}
    end
    flag("Binding status","bound","Soulbound","Not soulbound")
    flag("Quest items","quest","Only quest items","Exclude quest items")
    flag("Crafting reagent","craftingreagent","Yes","No")
    flag("Openable","openable","Yes","No")
    flag("BoE item type","boe","Yes","No")
    flag("Unbound status","unbound","Unbound","Not unbound")
    flag("Item set member","itemset","Yes","No")
    local function nameField()
        local yy=line("Name contains");local b=edit(content,false);stretch(b,content,125,yy,4,25);b:SetMaxLetters(200)
        b:SetScript("OnTextChanged",function()if not updating then local d=getDraft();if d then d.name=b:GetText();changed() end end end)
        controls[#controls+1]={refresh=function(d) if b:GetText()~=(d.name or "") then b:SetText(d.name or "") end end,box=b}
    end
    nameField()
    local function keywords(text,k)
        local yy=line(text);local picker=dropdown(content,170,{"No keywords"},function(v)
            local d=getDraft();if not d or v=="No keywords" then return end;local index=tonumber(v:match("^(%d+)%."));if index and d[k] then table.remove(d[k],index);if #d[k]==0 then d[k]=nil end;changed();refresh()end
        end,true,false,parent,true);left(picker,content,125,yy);picker:SetPoint("TOPRIGHT",content,"TOPRIGHT",-4,-yy);picker.brFilterKey=k
        local b=edit(content,false);left(b,content,4,y);b:SetPoint("TOPRIGHT",content,"TOPRIGHT",-65,-y);b:SetHeight(25);b:SetMaxLetters(200);b.brFilterKey=k.."Input"
        local add=btn(content,"Add",55,25,function()local d=getDraft();local v=b:GetText();if d and v~="" and #v<=200 then local a=d[k] or {};if #a<256 and not F.Has(a,v:lower()) then a[#a+1]=v:lower();d[k]=a;changed();refresh() end;b:SetText("") end end);add:SetPoint("TOPRIGHT",content,"TOPRIGHT",-4,-y);add.brFilterKey=k.."Add";y=y+32
        controls[#controls+1]={refresh=function(d)local a={};for i,v in ipairs(d[k] or {}) do a[#a+1]=i..". Remove: "..v:gsub("|","||") end;picker:SetChoices(#a>0 and a or {"No keywords"});picker:SetValue(#a==0 and "No keywords" or #a.." keywords (edit...)") end}
    end
    heading("NAME MATCHING")
    keywords("Contains any","names");keywords("Exact any","exactNames")
    heading("EXCLUSIONS")
    keywords("Exclude contains","excludeNames");keywords("Exclude exact","excludeExactNames")
    multi("Exclude classes",{"excludeClasses"},classChoices("excludeClasses"))
    multi("Exclude subtypes",{"excludeSubclassIDs"},subtypeChoices("excludeSubclassIDs"))
    multi("Exclude quality",{"excludeQualities"},list("excludeQualities",qualityChoices))
    multi("Exclude slots",{"excludeSlots"},slotChoices("excludeSlots"))
    multi("Exclude binding",{"excludeBindings"},list("excludeBindings",bindingChoices))
    multi("Exclude item IDs",{"excludeItems"},function()local a=inventoryChoices();for _,v in ipairs(a) do v.k="excludeItems" end;return a end)
    heading("OPTIONAL RANGES (BLANK = ANY)")
    local function range(text,k)
        local yy=line(text);local min,max=edit(content,false),edit(content,false);left(min,content,125,yy);min:SetSize(65,25);local sep=label(content,"to",nil,dim);left(sep,content,195,yy+6);left(max,content,213,yy);max:SetSize(65,25);min:SetMaxLetters(12);max:SetMaxLetters(12);min.brFilterKey=k.."Min";max.brFilterKey=k.."Max"
        local function update(b,suffix) if not updating then local d=getDraft();if d then local v=b:GetText();if v=="" then d[k..suffix]=nil else d[k..suffix]=tonumber(v) or v end;changed() end end end
        min:SetScript("OnTextChanged",function()update(min,"Min")end);max:SetScript("OnTextChanged",function()update(max,"Max")end)
        controls[#controls+1]={refresh=function(d) min:SetText(tostring(d[k.."Min"] or ""));max:SetText(tostring(d[k.."Max"] or "")) end}
    end
    range("Item level","itemlevel");range("Required level","requiredlevel");range("Stack count","count");range("Vendor copper","vendor");range("Auction copper","ahprice")
    heading("SPECIFIC ITEMS (OPTIONAL RESTRICTION)")
    multi("From inventory",{"items"},function() local a,seen=inventoryChoices();local d=getDraft();for _,id in ipairs(d and d.items or {}) do if not seen[id] then a[#a+1]={k="items",v=id,label="Item "..id.." (not in bags)"} end end;table.sort(a,function(x,z)return x.label<z.label end);return a end)
    local all=toggle(content,"Match all if no filters",250,function()end);left(all,content,4,y);y=y+34;all:SetScript("OnClick",function()local d=getDraft();if d then change("all",not d.all) end end);controls[#controls+1]={refresh=function(d)all:State(d.all==true)end}
    left(btn(content,"Clear this method",150,26,function()setDraft({});changed();refresh()end),content,4,y);y=y+35
    local note=label(content,"Selections within one field are alternatives; different fields narrow the match. Missing metadata never matches. Empty filters match nothing. Match everything applies only when no other filters are set. "..(fallback and "Some catalogue entries use Classic fallback data. " or "Item types from the client. ").."Auction data requires Auctionator; other properties depend on the client.",nil,dim);stretch(note,content,4,y,4,85);note:SetWordWrap(true);y=y+90;content:SetHeight(y)
    holder:SetScript("OnSizeChanged",function(_,w)content:SetWidth(math.max(288,w-30))end)
    return {Refresh=function()if getDraft() then holder:Show();notice:Hide();refresh() else holder:Hide();notice:Show() end end,Reset=function()active=1;sc:SetVerticalScroll(0)end}
end
local function categoryHeight(parent,y)
    local f=parent
    for _=1,8 do
        if not f then break end
        if ((f.IsObjectType and f:IsObjectType("ScrollFrame")) or (f.GetObjectType and f:GetObjectType()=="ScrollFrame")) and f.GetHeight then
            local h=f:GetHeight();if h and h>0 then return math.max(594,math.floor(h+y-18)),f end
        end
        f=f.GetParent and f:GetParent() or nil
    end
    local h=parent.GetHeight and parent:GetHeight() or 0
    return math.max(594,math.floor((h or 0)+y-18))
end
local function buildCategories(parent,y)
    local V=BR.VisualRules
    local height,viewport=categoryHeight(parent,y)
    local extra=height-594
    local root=frame(parent); stretch(root,parent,12,-y+6,12,height)
    local grows,shifts={},{}
    local function grow(f,h) grows[#grows+1]={f,h};f:SetHeight(h+extra);return f end
    local function shift(f,p,x,yy) shifts[#shifts+1]={f,p,x,yy};f:ClearAllPoints();left(f,p,x,yy+extra);return f end
    local function stretchShift(f,p,x,yy,r,h) shifts[#shifts+1]={f,p,x,yy,r,h};f:ClearAllPoints();stretch(f,p,x,yy+extra,r,h);return f end
    local heading=label(root,"CATEGORY MANAGER",nil,accent); left(heading,root,0,2)
    local search=edit(root,false); left(search,root,0,24); search:SetSize(216,26)
    local searchHint=label(search,"Find category or section...",nil,dim); searchHint:SetPoint("LEFT",7,0)
    search:SetScript("OnEditFocusGained",function() searchHint:Hide() end)
    search:SetScript("OnEditFocusLost",function() if search:GetText()=="" then searchHint:Show() end end)
    local holder,child,sf=scroll(root,0,83,216,409);grow(holder,409)
    local right=frame(root,panel,border); left(right,root,228,24); right:SetPoint("TOPRIGHT",root,"TOPRIGHT",0,-24); grow(right,542)
    local message=label(root,"",nil,accent); stretchShift(message,root,228,568,0,26); message:SetWordWrap(true)
    local function say(t,bad) message:SetText(t or ""); color(message,bad and {1,0.43,0.38} or accent) end
    local selected,loaded,loading,model,node,parentNode,draftError,mode,tab,activeEnabled=nil,nil,false,nil,nil,nil,nil,"Visual","Rules",false
    local refreshTree,load,rebuild,refreshPreview,queuePreview,updateTabs,save,chooseNode,validate,changeModel
    local filterDraft,filterEditor,confirmLegacy
    local F=BR.Filters
    local focusSection -- selected parent label; nil = editing a child
    local parentLoaded,sectionValue
    local function noParentLabel()
        local n="Ungrouped";while BR:FindSection(n) do n=n.." (no parent)" end;return n
    end
    local selectParent,addChild,refreshParent,guard
    local function current() return selected and BR:Get(selected) end
    local iconPreview=right:CreateTexture(nil,"ARTWORK"); iconPreview:SetSize(38,38); iconPreview:SetPoint("TOPLEFT",12,-12)
    local name=edit(right,false); stretch(name,right,58,8,120,28); name:SetMaxLetters(80)
    title(right,"In",58,44)
    local sectionPick=dropdown(right,154,{"Ungrouped"},function(s) sectionValue=s==noParentLabel() and "" or s;if not loading then validate() end end,true); left(sectionPick,right,80,38)
    local parentPanel=frame(root,panel,border);left(parentPanel,root,228,24);parentPanel:SetPoint("TOPRIGHT",root,"TOPRIGHT",0,-24);grow(parentPanel,542);parentPanel:Hide()
    local parentHeading=label(parentPanel,"PARENT CATEGORY","large",accent);left(parentHeading,parentPanel,12,14)
    title(parentPanel,"Name (applies to every subcategory)",12,48)
    local parentName=edit(parentPanel,false);stretch(parentName,parentPanel,12,70,12,28);parentName:SetMaxLetters(80)
    local parentIcon=parentPanel:CreateTexture(nil,"ARTWORK");parentIcon:SetSize(24,24);parentIcon:SetPoint("TOPRIGHT",parentPanel,"TOPRIGHT",-12,-108)
    local parentSummary=label(parentPanel,"",nil,dim);stretch(parentSummary,parentPanel,12,108,166,28);parentSummary:SetWordWrap(true)
    local parentEnabled=toggle(parentPanel,"Enable entire category",235,function() end);left(parentEnabled,parentPanel,12,140)
    local parentList=frame(parentPanel,{0,0,0,0.08},border);stretch(parentList,parentPanel,12,219,12,136);grow(parentList,136)
    local parentScroll=CreateFrame("ScrollFrame",nil,parentList,"UIPanelScrollFrameTemplate");parentScroll:SetPoint("TOPLEFT",3,-3);parentScroll:SetPoint("BOTTOMRIGHT",-23,3)
    local parentChild=frame(parentScroll);parentChild:SetSize(math.max(100,parentList:GetWidth()-30),1);parentScroll:SetScrollChild(parentChild)
    parentList:SetScript("OnSizeChanged",function(_,w) parentChild:SetWidth(math.max(100,w-30)) end)
    local parentRows={};title(parentPanel,"SUBCATEGORIES",12,204)
    local parentHelp=label(parentPanel,"Parent categories organise subcategories. Rules belong to subcategories only. Drag the parent row to move the entire group in the bags.",nil,dim);stretchShift(parentHelp,parentPanel,12,456,12,48);parentHelp:SetWordWrap(true)
    local deleteDest
    local deletePick=dropdown(parentPanel,190,{"Choose destination"},function(v) deleteDest=v end,true);shift(deletePick,parentPanel,12,385)
    shift(title(parentPanel,"Move children before deleting this parent",12,365),parentPanel,12,365)
    local parentMessage=label(parentPanel,"",nil,accent);stretchShift(parentMessage,parentPanel,12,420,12,32);parentMessage:SetWordWrap(true)
    local enabled=toggle(right,"Enabled",112,function() end); enabled:SetPoint("TOPRIGHT",right,"TOPRIGHT",-8,-8)
    enabled:SetScript("OnClick",function() if current() then activeEnabled=not activeEnabled; enabled:State(activeEnabled); queuePreview() end end)
    local priorityLabel=label(right,"",nil,dim);priorityLabel:SetPoint("TOPRIGHT",right,"TOPRIGHT",-12,-43)
    local stateLabel=label(right,"",nil,dim); stretch(stateLabel,right,12,65,12,20)
    local tabs={}; local pages={}; local sectionHeight=299
    for i,t in ipairs({"Rules","Appearance","Advanced"}) do
        local key=t; tabs[key]=btn(right,key,86,26,function() tab=key; updateTabs() end,"row"); left(tabs[key],right,12+(i-1)*90,88)
        local p=frame(right); stretch(p,right,12,120,12,sectionHeight);grow(p,sectionHeight); pages[key]=p
    end
    local rules,appearance,advanced=pages.Rules,pages.Appearance,pages.Advanced
    local applyPreset
    local modeButtons={}; for i,m in ipairs({"Filters","Visual","Expression"}) do local key=m; modeButtons[key]=btn(rules,key,73,25,nil,"row"); left(modeButtons[key],rules,(i-1)*76,0) end
    local presetRule=dropdown(rules,108,{"Rule presets...","Cloth","Herbs","Leather","Ore & Stone","Weapons","Armour","Consumables","Quest items","Recipes","Poor quality","Tradeable gear","Crafting materials"},function(v) if applyPreset then applyPreset(v) end end,true);presetRule:SetPoint("TOPRIGHT",rules,"TOPRIGHT",0,0)
    local visual=frame(rules); stretch(visual,rules,0,31,0,268);grow(visual,268)
    local raw=frame(rules); stretch(raw,rules,0,31,0,268);grow(raw,268)
    local ruleHolder=frame(visual,{0,0,0,0.09},border); stretch(ruleHolder,visual,0,0,0,229);grow(ruleHolder,229)
    local ruleScroll=CreateFrame("ScrollFrame",nil,ruleHolder,"UIPanelScrollFrameTemplate"); ruleScroll:SetPoint("TOPLEFT",3,-3); ruleScroll:SetPoint("BOTTOMRIGHT",-23,3)
    local ruleChild=CreateFrame("Frame",nil,ruleScroll); ruleChild:SetSize(math.max(100,ruleHolder:GetWidth()-30),1); ruleScroll:SetScrollChild(ruleChild)
    local rows,footers={},{}
    local changing=false
    local errorNode
    local visualError=label(visual,"",nil,dim); stretchShift(visualError,visual,0,233,0,32); visualError:SetWordWrap(true)
    local function canEdit(n)
        if loading or changing then return false end
        if draftError and errorNode and errorNode~=n then say("Fix the invalid value first, or discard your draft.",true);return false end
        return true
    end
    local function closeRow(r)
        for _,d in ipairs({r.field,r.op,r.pick,r.groupMode}) do if d and d.CloseMenu then d:CloseMenu() end end
    end
    local function setNode(n,p) node=n;parentNode=p end
    local function addTo(p,group)
        if not p or draftError then return end
        if #V.Rows(model)>=(group and 99 or 100) then say("Visual rule limit reached.",true);return end
        local n={kind="condition",field="constant",op="=",value=p.mode=="ALL" and "all" or "never"}
        if group then n={kind="group",mode="ALL",children={n}} end
        p.children[#p.children+1]=n;setNode(n,p);changeModel(true)
    end
    local function removeFrom(p,n)
        if not p or not canEdit(n) then return end
        if #p.children==1 then say("Every group needs a condition. Remove the group or replace its condition.",true);return end
        if V.Remove(p,n) then draftError=nil;errorNode=nil;setNode(p,nil);changeModel(true) end
    end
    local function commitRow(r,layout)
        local n=r.node;if not n or not canEdit(n) then return end
        local val=r.isChoice and r.pick.value or r.value:GetText()
        local p,e=V.Predicate(V.keys[r.field.value],V.opKeys[r.op.value],val)
        if not p then draftError=e;errorNode=n;validate();return end
        n.field,n.op,n.value=p.field,p.op,p.value;draftError=nil;errorNode=nil
        r.text:SetText((V.Describe(n):gsub("|","||")));setNode(n,r.parentNode);changeModel(layout)
    end
    local function chooseField(r,key,initial)
        local ops=V.Ops(key);r.op:SetChoices(ops);r.op:SetValue(initial and V.opNames[initial.op] or ops[1])
        local vals=V.Choices(key);local v=initial and V.Value(initial) or (vals and vals[1] or (R.fields[key]=="text" and "" or "1"))
        -- Preserve unusual imported enum values rather than coercing them.
        local available=false;if vals then for _,x in ipairs(vals) do if x==v or (R.fields[key]=="text" and x:lower()==tostring(v):lower()) then available=true;v=x;break end end end
        r.isChoice=vals and available and v~="Other / enter text" or false
        if vals then r.pick:SetChoices(vals);r.pick:SetValue(r.isChoice and v or "Other / enter text") end
        r.value:SetText(v);if r.isChoice then r.value:Hide();r.pick:Show() else r.value:Show();r.pick:Hide() end
    end
    local function makeRuleRow()
        local r=btn(ruleChild,"",220,28,nil,"row");r.text:Hide()
        r.neg=btn(r,"NOT",34,23,function()
            local n=r.node;if draftError then say("Fix the invalid value first.",true);return end;if n and canEdit(n) then n.negated=not n.negated;setNode(n,r.parentNode);changeModel(true) end
        end,"row")
        r.remove=btn(r,"X",22,23,function() removeFrom(r.parentNode,r.node) end,"row")
        r.match=label(r,"Match",nil,dim);r.ofThese=label(r,"of these",nil,dim)
        r.groupMode=dropdown(r,90,{"All (AND)","Any (OR)"},function(v) if r.node and not draftError and canEdit(r.node) then r.node.mode=v=="All (AND)" and "ALL" or "ANY";setNode(r.node,r.parentNode);changeModel(true) else if r.node then r.groupMode:SetValue(r.node.mode=="ALL" and "All (AND)" or "Any (OR)") end end end,nil,false,root)
        r.field=dropdown(r,136,V.fieldLabels,function(v)
            if not r.node or not canEdit(r.node) then if r.node then r.field:SetValue(V.names[r.node.field]) end;return end
            changing=true;chooseField(r,V.keys[v]);changing=false;commitRow(r,true)
        end,nil,false,root,true)
        r.op=dropdown(r,88,{"Is"},function(v) if r.node and canEdit(r.node) then commitRow(r,false) elseif r.node then r.op:SetValue(V.opNames[r.node.op]) end end,nil,false,root)
        r.value=edit(r,false);r.value:SetMaxLetters(8192)
        r.value:SetScript("OnTextChanged",function() if not changing and not loading and r.node then if canEdit(r.node) then commitRow(r,false) else changing=true;r.value:SetText(V.Value(r.node));changing=false end end end)
        r.pick=dropdown(r,100,{"Yes","No"},function(v)
            if not r.node or not canEdit(r.node) then if r.node then r.pick:SetValue(V.Value(r.node)) end;return end
            if v=="Other / enter text" then changing=true;r.isChoice=false;r.pick:Hide();r.value:Show();r.value:SetText("");changing=false;r.value:SetFocus();commitRow(r,false)
            else commitRow(r,false) end
        end,true,false,root)
        r:SetScript("OnEnter",function(self) outline(self,accent);if GameTooltip and GameTooltip.SetOwner and self.node then GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText((V.Describe(self.node):gsub("|","||")));GameTooltip:Show() end end)
        r:SetScript("OnLeave",function(self) outline(self,border);if GameTooltip then GameTooltip:Hide() end end)
        r:SetScript("OnClick",function() if r.node and canEdit(r.node) then setNode(r.node,r.parentNode) end end)
        return r
    end
    local function place(f,r,x,w)
        f:ClearAllPoints();left(f,r,x,2);f:SetSize(math.max(1,w),24)
    end
    local function sizeRow(r,width)
        local indent=math.min((r.depth or 0)*12,48,math.max(0,width-220));r.indent=indent;r:ClearAllPoints();left(r,ruleChild,indent,r.yy or 0);local w=math.max(1,width-indent);r:SetWidth(w)
        place(r.neg,r,3,32);place(r.remove,r,w-24,21)
        if r.node.kind=="group" then
            r.match:ClearAllPoints();left(r.match,r,42,8);local groupX=w<205 and 39 or 82;if w<205 then r.match:Hide() else r.match:Show() end;place(r.groupMode,r,groupX,math.min(105,math.max(24,w-groupX-27)));r.ofThese:ClearAllPoints();left(r.ofThese,r,groupX+109,8);if w<265 then r.ofThese:Hide() else r.ofThese:Show() end
        else
            local room=math.max(3,w-68);local f=math.floor(room*0.43);local o=math.floor(room*0.24);local v=room-f-o
            place(r.field,r,39,f);place(r.op,r,42+f,o);place(r.pick,r,45+f+o,v-3);place(r.value,r,45+f+o,v-3)
        end
    end
    ruleHolder:SetScript("OnSizeChanged",function(_,w)
        if activeMenu then activeMenu:Hide() end
        local cw=math.max(100,w-30);ruleChild:SetWidth(cw);for _,r in ipairs(rows) do if r.node then sizeRow(r,cw) end end;for _,f in ipairs(footers) do if f:IsShown() then f:ClearAllPoints();left(f,ruleChild,math.min(f.depth*12,48,math.max(0,cw-220))+3,f.yy) end end
    end)
    local rawHint=label(raw,"Edit the same rule as text. & AND   | OR   ! NOT   ( ) groups   ~ contains",nil,dim); stretch(rawHint,raw,0,0,0,38); rawHint:SetWordWrap(true)
    local rawHolder=frame(raw,bg,border); stretch(rawHolder,raw,0,36,0,188);grow(rawHolder,188)
    local rawScroll=CreateFrame("ScrollFrame",nil,rawHolder,"UIPanelScrollFrameTemplate"); rawScroll:SetPoint("TOPLEFT",4,-4); rawScroll:SetPoint("BOTTOMRIGHT",-25,4)
    local expr=edit(rawScroll,true); expr:SetMaxLetters(8192); expr:SetSize(math.max(100,rawHolder:GetWidth()-34),176); rawScroll:SetScrollChild(expr)
    local function rawSize() expr:SetHeight(math.max(176+extra,(expr:GetNumLetters()/math.max(10,expr:GetWidth()/6)+2)*15)) end
    rawHolder:SetScript("OnSizeChanged",function(_,w) expr:SetWidth(math.max(100,w-34));rawSize() end)
    local rawError=label(raw,"",nil,dim); stretchShift(rawError,raw,0,229,0,35); rawError:SetWordWrap(true)
    expr:SetScript("OnTextChanged",function() rawSize(); if not loading then if mode=="Expression" then draftError=nil end; validate() end end)
    title(appearance,"CATEGORY ICON",0,4)
    local icon=edit(appearance,false); left(icon,appearance,0,28); icon:SetSize(140,26)
    local bigIcon=appearance:CreateTexture(nil,"ARTWORK"); bigIcon:SetSize(54,54); bigIcon:SetPoint("TOPLEFT",154,-28)
    local function pickChild(useNative)
        local key=selected;if not key then return end
        local function done(id) if selected==key and focusSection==nil then icon:SetText(tostring(id)) end end
        (useNative and nativeIcons or browseIcons)(tonumber(icon:GetText()),done,appearance,BR.IconSearch.Context(name:GetText(),filterDraft,sectionValue))
    end
    left(btn(appearance,"Browse icons",130,27,function() pickChild(false) end),appearance,0,60)
    left(btn(appearance,"EUI icon picker",135,27,function() pickChild(true) end),appearance,218,28)
    left(btn(appearance,"Suggest icon",135,27,function() local id=BR.IconSearch.Suggest(name:GetText(),filterDraft,sectionValue,true);if id then icon:SetText(tostring(id)) else say("No confident icon suggestion. Browse all icons instead.",true) end end),appearance,138,60)
    local iconNote=label(appearance,"Suggested icons are ranked by name and filters. Browse the full icon catalogue or enter a file ID.",nil,dim); stretch(iconNote,appearance,0,96,0,38); iconNote:SetWordWrap(true)
    for i,id in ipairs({134400,132889,134205,132624,134829,134939,133784,132996,132382,134414,133651,133587,134179,134183,134332,133644}) do
        local b=btn(appearance,"",36,36,function() icon:SetText(tostring(id)) end); left(b,appearance,((i-1)%8)*42,139+math.floor((i-1)/8)*42)
        local t=b:CreateTexture(nil,"ARTWORK"); t:SetSize(32,32); t:SetPoint("CENTER"); t:SetTexture(id)
    end
    local function iconChanged() local i=tonumber(icon:GetText()) or 134400; iconPreview:SetTexture(i); bigIcon:SetTexture(i) end
    icon:SetScript("OnTextChanged",iconChanged)
    title(advanced,"RULE PRIORITY (higher wins)",0,4)
    local priority=edit(advanced,false); left(priority,advanced,0,26); priority:SetSize(92,26)
    local prNote=label(advanced,"Explicit item assignments win first. Equal priorities retain their original rule order; moving categories does not change matches.",nil,dim); stretch(prNote,advanced,0,60,0,35); prNote:SetWordWrap(true)
    title(advanced,"MANUAL ITEM ASSIGNMENTS",0,101)
    local manual=edit(advanced,true); stretch(manual,advanced,0,123,0,78); manual:SetMaxLetters(12000)
    local manNote=label(advanced,"Comma-separated item IDs. These bypass the automatic rule.",nil,dim); stretch(manNote,advanced,0,208,0,30); manNote:SetWordWrap(true)
    local importHolder=frame(advanced,{0,0,0,0.1},border);stretch(importHolder,advanced,0,242,0,56);local importScroll=CreateFrame("ScrollFrame",nil,importHolder,"UIPanelScrollFrameTemplate");importScroll:SetPoint("TOPLEFT",3,-3);importScroll:SetPoint("BOTTOMRIGHT",-23,3);local importChild=frame(importScroll);importChild:SetSize(math.max(80,importHolder:GetWidth()-30),90);importScroll:SetScrollChild(importChild);local importNote=label(importChild,"",nil,dim);stretch(importNote,importChild,0,0,0,90);importNote:SetWordWrap(true);importNote:SetJustifyV("TOP");local function warningSize() local h=math.max(50,math.ceil(#importNote:GetText()/math.max(12,importChild:GetWidth()/6))*15+16);importNote:SetHeight(h);importChild:SetHeight(h) end;importHolder:SetScript("OnSizeChanged",function(_,w) importChild:SetWidth(math.max(80,w-30));warningSize() end)
    local legacyAccess=btn(advanced,"Use legacy editor",148,25,function() end);left(legacyAccess,advanced,110,26)
    local preview=frame(right,{0,0,0,0.12},border); stretchShift(preview,right,12,422,12,84)
    -- Preview is shared by all tabs. Reserve the bottom of the page for it.
    local pt=label(preview,"LIVE PREVIEW",nil,accent); left(pt,preview,6,3)
    local ptext=label(preview,"",nil,dim); stretch(ptext,preview,6,18,6,19); ptext:SetWordWrap(false)
    local previewItems={}
    local previewHint=label(preview,"",nil,dim); stretch(previewHint,preview,6,65,6,16);previewHint:SetWordWrap(false)
    local function clearPreview()
        for _,b in ipairs(previewItems) do b:Hide() end;previewHint:SetText("")
    end
    local function showItems(a)
        clearPreview();local limit=math.min(8,math.max(1,math.floor((preview:GetWidth()-16)/31)))
        for i=1,math.min(limit,#a) do
            local r=a[i];local b=previewItems[i]
            if not b then
                b=btn(preview,"",28,28,nil,"row");b.text:Hide();b.ic=b:CreateTexture(nil,"ARTWORK");b.ic:SetPoint("TOPLEFT",2,-2);b.ic:SetPoint("BOTTOMRIGHT",-2,2);b.qty=label(b,"",nil,white);b.qty:SetPoint("BOTTOMRIGHT",-1,1)
                b:SetScript("OnEnter",function(self) if GameTooltip and GameTooltip.SetOwner then GameTooltip:SetOwner(self,"ANCHOR_RIGHT");if self.item.link and GameTooltip.SetHyperlink then GameTooltip:SetHyperlink(self.item.link) else GameTooltip:SetText((self.item.name:gsub("|","||"))) end;if self.item.shadowed and GameTooltip.AddLine then GameTooltip:AddLine("Claimed by another category (higher precedence)") end;GameTooltip:Show() end end)
                b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end);previewItems[i]=b
            end
            b.item=r;b.ic:SetTexture(r.icon or 134400);b.qty:SetText(r.count>1 and tostring(r.count) or "");outline(b,r.shadowed and {0.95,0.66,0.20,1} or border);left(b,preview,6+(i-1)*31,36);b:Show()
        end
        if #a>limit then previewHint:SetText("+ "..(#a-limit).." more matching slots") end
    end
    local function parseIDs()
        local s=manual:GetText():gsub("%s+",""); local ids,seen={},{}
        if s=="" then return ids end
        if not s:match("^%d[%d,]*$") or s:find(",,") or s:sub(-1)=="," then return nil,"Manual items must be comma-separated numeric IDs." end
        for v in s:gmatch("%d+") do local id=tonumber(v); if not id or id<1 or id>2147483647 or seen[id] or #ids>=1000 then return nil,"Invalid or duplicate manual item ID." end; ids[#ids+1]=id; seen[id]=true end
        return ids
    end
    local filterPanel=frame(rules);stretch(filterPanel,rules,0,31,0,268);grow(filterPanel,268)
    filterEditor=buildFilterEditor(filterPanel,function()return filterDraft end,function(d)filterDraft=d end,function()
        if not current() then return end
        filterDraft={};confirmLegacy=nil;draftError=nil;updateTabs();validate();say("New native filter draft. Save to replace the legacy rule.")
    end,function()confirmLegacy=nil;validate()end,function()
        local c=current();if not c then return end
        if expr:GetText()~=c.expr then say("Save or discard the legacy expression before converting.",true);return end
        local plan=BR:MigrationPlan();for _,r in ipairs(plan.rows) do if r.id==c.id then
            if not r.filters then say(r.reason or "Not convertible.",true);return end
            filterDraft=r.filters;mode="Filters";confirmLegacy=nil;draftError=nil;filterEditor.Reset();updateTabs();validate();say("Converted draft. Save changes to apply.");return
        end end
    end)
    local function dirty()
        if focusSection~=nil then return parentLoaded and parentName:GetText()~=(parentLoaded.name~="" and parentLoaded.name or "Ungrouped") or false end
        local c=current(); if not c then return false end
        return (filterDraft~=nil)~=(c.filters~=nil) or (filterDraft and F.Encode(filterDraft)~=F.Encode(c.filters)) or draftError~=nil or name:GetText()~=c.name or expr:GetText()~=c.expr or tostring(c.icon)~=icon:GetText() or tostring(c.priority or 0)~=priority:GetText() or (c.section or "")~=sectionValue or table.concat(c.manual or {},",")~=manual:GetText() or activeEnabled~=c.enabled
    end
    BR.MigrationDraftPending=dirty
    local function draft()
        if draftError then return nil,draftError end
        local ids,e=parseIDs(); if not ids then return nil,e end
        local p=tonumber(priority:GetText()); if not p or p%1~=0 or math.abs(p)>10000 then return nil,"Priority must be an integer from -10000 to 10000" end
        local f,a,e
        if filterDraft~=nil then f,e=F.Validate(filterDraft);if not f then return nil,e end else a,e=R.Compile(expr:GetText());if not a then return nil,e end end
        return {priority=p,manual=ids,enabled=activeEnabled,filters=f}
    end
    local previewToken=0
    local previewRunning=false
    local counts={}
    refreshPreview=function()
        clearPreview();if loading then return end
        if InCombatLockdown and InCombatLockdown() then ptext:SetText("Preview paused during combat.");return end
        if focusSection~=nil or not current() then
            previewRunning=true;local _,_,_,_,_,newCounts=BR:Preview("never",nil);previewRunning=false
            if newCounts then counts=newCounts;if refreshTree then refreshTree() end end
            ptext:SetText("Select a subcategory to preview.");return
        end
        local d,e=draft(); if not d then ptext:SetText(e);return end
        previewRunning=true
        local a,err,unknown,total,shadowed,newCounts=BR:Preview(expr:GetText(),selected,d)
        previewRunning=false
        if not a then ptext:SetText(err);return end
        counts=newCounts or {}; if refreshTree then refreshTree() end
        ptext:SetText(string.format("%d / %d slots match   |   %d conflicts   |   %d unknown",#a,total,shadowed,unknown))
        showItems(a)
        local c=current();if c and c.warning~="" then previewHint:SetText("Import warning — see Advanced") elseif not activeEnabled then previewHint:SetText("Disabled draft") elseif (BR:FindSection(sectionValue) or {}).enabled==false then previewHint:SetText("Parent disabled") end

    end
    queuePreview=function()
        if loading then return end
        local c=current();priorityLabel:SetText("Priority "..priority:GetText()); stateLabel:SetText(dirty() and "Unsaved changes" or (c and c.warning~="" and "Saved | Import warning (Advanced)" or "Saved"));color(stateLabel,c and c.warning~="" and not dirty() and {0.96,0.72,0.28} or dim)
        previewToken=previewToken+1; local token=previewToken
        if C_Timer and C_Timer.After then C_Timer.After(0.25,function() if token==previewToken and (not root.IsVisible or root:IsVisible()) then refreshPreview() end end) else refreshPreview() end
    end
    validate=function()
        if loading then return end
        local a,e=draft(); local msg=a and (filterDraft~=nil and "Valid filters" or "Valid rule") or e; local c=a and accent or {1,0.43,0.38}
        visualError:SetText(msg or ""); rawError:SetText(msg or ""); color(visualError,c);color(rawError,c);queuePreview()
    end
    rebuild=function()
        changing=true
        for _,r in ipairs(rows) do closeRow(r);r.node=nil;r:Hide() end;for _,f in ipairs(footers) do f:Hide() end
        local yy,ri,fi=0,0,0;local width=ruleChild:GetWidth()
        local function visit(n,p,depth)
            ri=ri+1;local r=rows[ri];if not r then r=makeRuleRow();rows[ri]=r end
            r.node,r.parentNode=n,p;r.depth,r.yy=depth,yy;r:SetHeight(28)
            r.text:SetText((V.Describe(n):gsub("|","||")));paint(r,n.kind=="group" and bg or {0,0,0,0.12});outline(r,border)
            color(r.neg.text,n.negated and {1,0.45,0.38} or dim);paint(r.neg,n.negated and {0.6,0.16,0.12,0.25} or bg)
            if p then r.remove:Show() else r.remove:Hide() end
            if n.kind=="group" then
                r.field:Hide();r.op:Hide();r.value:Hide();r.pick:Hide();r.groupMode:SetValue(n.mode=="ALL" and "All (AND)" or "Any (OR)");r.groupMode:Show();color(r.groupMode.text,accent);r.match:Show();r.ofThese:Show()
            else
                r.groupMode:Hide();r.match:Hide();r.ofThese:Hide();r.field:SetValue(V.names[n.field]);r.field:Show();r.op:Show();chooseField(r,n.field,n)
            end
            sizeRow(r,width);r:Show();yy=yy+30
            if n.kind=="group" then
                for _,c in ipairs(n.children) do visit(c,n,depth+1) end
                fi=fi+1;local f=footers[fi]
                if not f then f=frame(ruleChild);f.add=btn(f,"+ Condition",100,22,function() addTo(f.node,false) end,"row");left(f.add,f,0,0);f.group=btn(f,"+ Group",82,22,function() addTo(f.node,true) end,"row");left(f.group,f,105,0);footers[fi]=f end
                f.node=n;f:ClearAllPoints();left(f,ruleChild,r.indent+3,yy);f.depth=depth;f.yy=yy;f:SetSize(190,23);f:Show();yy=yy+26
            end
        end
        if model then visit(model,nil,0) end
        ruleChild:SetHeight(math.max(1,yy));changing=false
    end
    chooseNode=function(n,p) setNode(n,p) end
    changeModel=function(layout)
        if not model then return end
        local s,e=V.Expression(model);draftError=e
        if s then errorNode=nil;loading=true;expr:SetText(s);loading=false end
        if layout then rebuild() end;validate()
    end
    applyPreset=function(v)
        presetRule:SetValue("Rule presets...");local template=V.presets[v];if not template or not current() then return end
        if draftError or filterDraft~=nil then say("Switch to a legacy editor before applying a legacy preset.",true);return end
        local m,e=V.FromExpression(template);if not m then say(e,true);return end
        loading=true;expr:SetText(template);model=m;mode="Visual";chooseNode(model,nil);loading=false;rebuild();updateTabs();validate();say("Preset loaded into draft. Review and save to apply.")
    end
    local function setMode(m)
        if m==mode then return end
        if m=="Filters" then mode=m;confirmLegacy=nil;filterEditor.Refresh();updateTabs();validate();return end
        if filterDraft~=nil then
            if next(filterDraft) and confirmLegacy~=m then confirmLegacy=m;say("Press "..m.." again to replace this native filter with a blank legacy rule. Save to apply.",true);return end
            filterDraft=nil;confirmLegacy=nil;draftError=nil;loading=true;expr:SetText("never");loading=false
        end
        if draftError then say("Resolve the visual rule error or discard changes first.",true); return end
        if m=="Visual" then
            local n,e=V.FromExpression(expr:GetText()); if n then local check,err=V.Expression(n);if not check then n=nil;e=err end end; if not n then say(e,true);return end;model=n;chooseNode(model,nil);rebuild()
        end
        mode=m;updateTabs();validate()
    end
    legacyAccess:SetScript("OnClick",function() if filterDraft~=nil then setMode("Visual");if filterDraft==nil then tab="Rules";updateTabs() end end end)
    modeButtons.Filters:SetScript("OnClick",function() setMode("Filters") end);modeButtons.Visual:SetScript("OnClick",function() setMode("Visual") end);modeButtons.Expression:SetScript("OnClick",function() setMode("Expression") end)
    updateTabs=function()
        if activeMenu then activeMenu:Hide() end
        for k,p in pairs(pages) do if k==tab then p:Show() else p:Hide() end; color(tabs[k].text,k==tab and accent or dim);outline(tabs[k],k==tab and accent or border) end
        if filterDraft~=nil then legacyAccess:Show() else legacyAccess:Hide() end
        for k,b in pairs(modeButtons) do
            if k=="Filters" or filterDraft==nil then b:Show() else b:Hide() end
            color(b.text,k==mode and accent or dim);outline(b,k==mode and accent or border)
        end
        if mode=="Filters" then filterPanel:Show();visual:Hide();raw:Hide();presetRule:Hide();filterEditor.Refresh()
        elseif mode=="Visual" then filterPanel:Hide();visual:Show();raw:Hide();presetRule:Show()
        else filterPanel:Hide();raw:Show();visual:Hide();presetRule:Hide() end
    end
    local function sectionChoices()
        local choices={noParentLabel()};for _,g in ipairs(BR:SectionGroups()) do if g.section~="" then choices[#choices+1]=g.section end end
        sectionPick:SetChoices(choices);sectionPick:SetValue(sectionValue~="" and sectionValue or noParentLabel())
    end
    save=function()
        if not current() then return end
        local d,e=draft();if not d then say(e,true);return end
        local id=tonumber(icon:GetText());if not id or id<=0 or id>=100000000 or id%1~=0 then say("Enter a valid icon file ID.",true);return end
        -- Only auto-fill a placeholder when the name or native filters were edited.
        if id==134400 and current().icon==134400 and (name:GetText()~=current().name or d.filters and F.Encode(d.filters)~=F.Encode(current().filters or {})) then id=BR.IconSearch.Suggest(name:GetText(),d.filters,sectionValue) or BR.IconSearch.Suggest(name:GetText(),d.filters,sectionValue,true) or id end
        local migrationBackup=current().filters==nil and d.filters~=nil and BR:Export() or nil
        local ok,err=BR:SaveCategory(selected,name:GetText(),expr:GetText(),id,d.priority,sectionValue,d.manual,activeEnabled,d.filters)
        if ok then if migrationBackup then BR.db.migrationBackup=migrationBackup end;load(selected);say("Saved. "..(BR.pending and "Inventory update queued until combat ends." or "Inventory refreshed.")) else say(err,true) end
    end
    local apply=btn(right,"Save changes",104,28,save,"row"); apply:SetPoint("BOTTOMRIGHT",right,"BOTTOMRIGHT",-6,4); outline(apply,accent);color(apply.text,accent)
    btn(right,"Discard",65,28,function() load(selected);say("Draft discarded.") end):SetPoint("RIGHT",apply,"LEFT",-5,0)
    btn(preview,"Refresh preview",98,18,refreshPreview):SetPoint("TOPRIGHT",preview,"TOPRIGHT",-4,-1)
    for _,f in ipairs({name,priority,manual}) do f:SetScript("OnTextChanged",function() if not loading then validate() end end) end
    icon:SetScript("OnTextChanged",function() iconChanged();if not loading then queuePreview() end end)
    local listRows,headers,collapsed,visible={},{},{},{}
    local drag,dropRow,dropMode
    guard=function() if dirty() then say("Save or discard your current changes first.",true);return false end;return true end
    local moveNote=label(root,"",nil,dim);shift(moveNote,root,0,558);moveNote:SetWidth(216);moveNote:SetWordWrap(true)
    local indicator=frame(child);if indicator.SetFrameLevel and child.GetFrameLevel then indicator:SetFrameLevel(child:GetFrameLevel()+10) end
    local indicatorLine=indicator:CreateTexture(nil,"OVERLAY");indicatorLine:SetAllPoints(indicator);indicator:Hide()
    local function clearTarget()
        if dropRow then outline(dropRow,border) end;dropRow,dropMode=nil,nil;indicator:Hide()
    end
    local function cancelDrag()
        if not drag then return end
        clearTarget();drag=nil;root:SetScript("OnUpdate",nil)
    end
    local function moveAllowed()
        if not guard() then return false end
        if search:GetText()~="" then say("Clear search before rearranging the tree.",true);return false end
        if InCombatLockdown and InCombatLockdown() then say("Rearranging is paused during combat.",true);return false end
        return true
    end
    local function finishMove(ok,err,kind,key)
        if not ok then if err then say(err,true) else refreshTree() end;return end
        if kind=="category" then local c=BR:Get(key);if c then collapsed[c.section]=nil;load(key) end
        else local g=BR:FindSection(key);if g then selectParent(g.id) end end
        say("Order saved. Item classification unchanged.")
    end
    local function targetAtCursor()
        if not GetCursorPosition or not sf.GetEffectiveScale or not sf.GetTop or not sf.GetBottom or not sf.GetLeft or not sf.GetRight then return end
        local x,y=GetCursorPosition();local scale=sf:GetEffectiveScale();if not scale or scale<=0 then return end;x,y=x/scale,y/scale
        local top,bottom,l,r=sf:GetTop(),sf:GetBottom(),sf:GetLeft(),sf:GetRight();if not top or not bottom or not l or not r or x<l or x>r or y<bottom or y>top then return end
        for _,row in ipairs(visible) do
            local t,b=row:GetTop(),row:GetBottom()
            if t and b and y<=t+1 and y>=b-1 then
                if drag.kind=="section" then
                    if row.brSection==drag.key then return end
                    if row.brKind=="section" then return row,y>(t+b)/2 and "before" or "after" end
                    -- Children belong to their parent; drop after the whole parent.
                    for i=#visible,1,-1 do if visible[i].brSection==row.brSection then return visible[i],"after" end end
                elseif row.brKind=="section" then
                    return row,"inside"
                elseif row.brKey~=drag.key then return row,y>(t+b)/2 and "before" or "after" end
                return
            end
        end
    end
    local function updateDrag(_,elapsed)
        if not drag then return end
        if InCombatLockdown and InCombatLockdown() then cancelDrag();return end
        if elapsed and GetCursorPosition and sf.GetEffectiveScale and sf.GetTop and sf.GetBottom and sf.GetVerticalScroll and sf.GetVerticalScrollRange then
            local x,y=GetCursorPosition();local scale=sf:GetEffectiveScale();local top,bottom,l,r=sf:GetTop(),sf:GetBottom(),sf:GetLeft(),sf:GetRight()
            if scale and scale>0 and top and bottom and l and r then x,y=x/scale,y/scale
                if x>=l and x<=r and y>=bottom and y<=top then
                    local change=y>top-28 and -180*elapsed or y<bottom+28 and 180*elapsed or 0
                    if change~=0 then sf:SetVerticalScroll(math.max(0,math.min(sf:GetVerticalScrollRange(),sf:GetVerticalScroll()+change))) end
                end
            end
        end
        local row,mode=targetAtCursor();if row==dropRow and mode==dropMode then return end
        clearTarget();dropRow,dropMode=row,mode
        if not row then return end
        if mode=="inside" then outline(row,accent)
        else
            -- An after-section marker goes below its last visible category.
            local edge=row
            if drag.kind=="section" and mode=="after" then for i=#visible,1,-1 do if visible[i].brSection==row.brSection then edge=visible[i];break end end end
            local anchor=mode=="before" and "TOPLEFT" or "BOTTOMLEFT";indicator:ClearAllPoints();indicator:SetPoint("TOPLEFT",edge,anchor,edge.brKind=="category" and -10 or 0,mode=="before" and 1 or -1);indicator:SetWidth(child:GetWidth());indicator:SetHeight(2);indicatorLine:SetColorTexture(accent[1],accent[2],accent[3],1);indicator:Show()
        end
    end
    local function attachDrag(b)
        b:RegisterForDrag("LeftButton")
        b:SetScript("OnDragStart",function(self)
            if not moveAllowed() then return end
            drag={kind=self.brKind,key=self.brKey};if GameTooltip then GameTooltip:Hide() end
            root:SetScript("OnUpdate",updateDrag);updateDrag();say(self.brKind=="section" and "Drag section above or below another section." or "Drop on a section to move inside, or above/below another category.")
        end)
        b:SetScript("OnDragStop",function()
            if not drag then return end
            local source=drag;local row,mode=targetAtCursor();local kind,key,sec=row and row.brKind,row and row.brKey,row and row.brSection
            cancelDrag()
            if not row or not moveAllowed() then refreshTree();return end
            local ok,err
            if source.kind=="section" then ok,err=BR:MoveSection(source.key,sec,mode=="after")
            else ok,err=BR:MoveCategory(source.key,kind,key,mode=="after") end
            finishMove(ok,err,source.kind,source.key)
        end)
    end
    refreshTree=function()
        if drag then return end -- preview timers must not recycle active drag rows
        for _,b in ipairs(listRows) do b:Hide() end;for _,b in ipairs(headers) do b:Hide() end;visible={}
        local q=search:GetText():lower();local yy,ri,hi=0,0,0
        for _,g in ipairs(BR:SectionGroups()) do
            local sec=g.section;local entries={}
            for _,c in ipairs(g.categories) do if q=="" or c.name:lower():find(q,1,true) or sec:lower():find(q,1,true) or c.expr:lower():find(q,1,true) or (c.filters and F.Encode(c.filters):lower():find(q,1,true)) then entries[#entries+1]=c end end
            if #entries>0 or q=="" or sec:lower():find(q,1,true) then
                hi=hi+1;local h=headers[hi];if not h then h=btn(child,"",182,24,nil,"row");h.text:ClearAllPoints();h.text:SetPoint("LEFT",44,0);h.text:SetPoint("RIGHT",-39,0);h.ic=h:CreateTexture(nil,"ARTWORK");h.ic:SetSize(16,16);h.ic:SetPoint("LEFT",23,0);h.text:SetWordWrap(false);local grip=label(h,"::",nil,dim);grip:SetPoint("RIGHT",-5,0);headers[hi]=h;attachDrag(h);h.count=label(h,"",nil,dim);h.count:SetPoint("RIGHT",-17,0);h.chevron=btn(h,"-",20,23,nil,"row");h.chevron:SetPoint("LEFT",0,0) end
                h:ClearAllPoints();left(h,child,0,yy);h.ic:SetTexture(g.icon or 132996);h.text:SetText((sec~="" and sec or "Ungrouped")..(g.enabled==false and " (off)" or ""));h.chevron.text:SetText(collapsed[sec] and "+" or "-");color(h.text,accent);accentPaint(h,focusSection==sec and 0.22 or 0.10);outline(h,border)
                local total=0;for _,c in ipairs(g.categories) do total=total+(counts[c.id] or 0) end;h.count:SetText(tostring(total));h.brKind,h.brKey,h.brSection="section",sec,sec
                local key,parentID=sec,g.id;h:SetScript("OnClick",function() if guard() then selectParent(parentID);say("") end end)
                h.chevron:SetScript("OnClick",function() collapsed[key]=not collapsed[key];refreshTree() end);h:Show();visible[#visible+1]=h;yy=yy+25
                if not collapsed[sec] or q~="" then
                    for _,c in ipairs(entries) do
                        ri=ri+1;local b=listRows[ri];if not b then b=btn(child,"",172,25,nil,"row");b.ic=b:CreateTexture(nil,"ARTWORK");b.ic:SetSize(19,19);b.ic:SetPoint("LEFT",4,0);b.text:ClearAllPoints();b.text:SetPoint("LEFT",28,0);b.text:SetPoint("RIGHT",-49,0);b.text:SetWordWrap(false);b.text:SetJustifyH("LEFT");b.marker=b:CreateTexture(nil,"ARTWORK");b.marker:SetSize(2,24);b.marker:SetPoint("LEFT",0,0);b.warning=label(b,"",nil,{0.96,0.72,0.28});b.warning:SetPoint("RIGHT",-39,0);b.count=label(b,"",nil,dim);b.count:SetPoint("RIGHT",-16,0);local grip=label(b,"::",nil,dim);grip:SetPoint("RIGHT",-4,0);listRows[ri]=b;attachDrag(b) end
                        b:ClearAllPoints();left(b,child,10,yy);b.ic:SetTexture(c.icon);b.count:SetText((not c.enabled or g.enabled==false) and "OFF" or tostring(counts[c.id] or 0));b.text:SetText(c.name);b.warning:SetText(c.warning~="" and "!" or "");local ma=c.id==selected and focusSection==nil and 1 or 0;track(b.marker,"marker",ma);b.marker:SetColorTexture(accent[1],accent[2],accent[3],ma);color(b.text,(not c.enabled or g.enabled==false) and dim or c.id==selected and accent or white);if c.id==selected and focusSection==nil then accentPaint(b,0.18) else paint(b,ri%2==0 and {0,0,0,0.12} or {0,0,0,0.04}) end;outline(b,border)
                        b.brKind,b.brKey,b.brSection="category",c.id,sec
                        local id=c.id;b:SetScript("OnClick",function() if id~=selected or focusSection~=nil then if guard() then load(id);say("") end else refreshTree() end end);b:Show();visible[#visible+1]=b;yy=yy+26
                    end
                end
            end
        end
        child:SetHeight(math.max(1,yy))
        moveNote:SetText("Drag rows to reorder or move. Rule priority is independent.")
    end
    root.RefreshList=refreshTree
    search:SetScript("OnTextChanged",function() cancelDrag();if search:GetText()=="" then searchHint:Show() else searchHint:Hide() end;refreshTree();sf:SetVerticalScroll(0) end)
    load=function(id)
        focusSection=nil;parentLoaded=nil;parentPanel:Hide();right:Show();selected=id;selectedID=id;loaded=current();local c=loaded;loading=true;draftError=nil;errorNode=nil
        name:SetText(c and c.name or "");sectionValue=c and c.section or "";icon:SetText(tostring(c and c.icon or 134400));priority:SetText(tostring(c and c.priority or 0));manual:SetText(table.concat(c and c.manual or {},","));expr:SetText(c and c.expr or "never");activeEnabled=c and c.enabled or false;enabled:State(activeEnabled)
        importNote:SetText(c and c.warning~="" and ("IMPORT WARNING: "..c.warning:gsub("|","/")) or "No import warnings.");warningSize();importScroll:SetVerticalScroll(0)
        filterDraft=c and c.filters and F.Validate(c.filters) or nil;confirmLegacy=nil;filterEditor.Reset();model=V.FromExpression(expr:GetText());if model and not V.Expression(model) then model=nil end;mode=filterDraft and "Filters" or model and "Visual" or "Expression";if model and c and c.expr=="never" then chooseNode(model.children[1],model) else chooseNode(model,nil) end;rebuild();ruleScroll:SetVerticalScroll(0);sectionChoices();updateTabs();loading=false;refreshTree();validate()
    end
    local function uniqueParent(base)
        local name=base;local n=2
        while BR:FindSection(name) do name=base.." "..n;n=n+1 end
        return name
    end
    local function uniqueChild(base,sec)
        local name=base;local n=2;local function exists(v) for _,c in ipairs(BR.db.categories) do if c.section==sec and c.name==v then return true end end end
        while exists(name) do name=base.." "..n;n=n+1 end;return name
    end
    refreshParent=function()
        local g=parentLoaded;if not g then return end
        parentName:SetText(g.name~="" and g.name or "Ungrouped");parentEnabled:State(g.enabled);parentIcon:SetTexture(g.icon or 132996)
        local entries={};for _,c in ipairs(BR.db.categories) do if c.sectionID==g.id then entries[#entries+1]=c end end
        parentSummary:SetText(#entries.." subcategories  |  "..(g.enabled and "Enabled" or "Disabled"))
        for _,b in ipairs(parentRows) do b:Hide() end
        for i,c in ipairs(entries) do
            local b=parentRows[i];if not b then b=btn(parentChild,"",120,23,nil,"row");b.text:ClearAllPoints();b.text:SetPoint("LEFT",28,0);b.text:SetPoint("RIGHT",-8,0);b.text:SetWordWrap(false);b.ic=b:CreateTexture(nil,"ARTWORK");b.ic:SetSize(18,18);b.ic:SetPoint("LEFT",4,0);parentRows[i]=b end
            b:ClearAllPoints();stretch(b,parentChild,0,(i-1)*25,0,23);b.ic:SetTexture(c.icon);b.text:SetText(c.name..(c.enabled and "" or " (off)"));local id=c.id;b:SetScript("OnClick",function() if guard() then load(id) end end);b:Show()
        end
        parentChild:SetHeight(math.max(1,#entries*25));parentScroll:SetVerticalScroll(0)
        local choices={"Choose destination",noParentLabel()};for _,other in ipairs(BR.db.sections) do if other~=g and other.name~="" then choices[#choices+1]=other.name end end
        deletePick:SetChoices(choices);deletePick:SetValue(choices[1]);deleteDest=nil;parentMessage:SetText("")
    end
    local pendingParentDelete
    selectParent=function(key)
        local g=BR:GetSection(key);if not g then return end
        focusSection=g.name;parentLoaded=g;pendingParentDelete=nil;right:Hide();parentPanel:Show();refreshParent();refreshTree();queuePreview()
    end
    addChild=function()
        if not guard() then return end
        local sec=focusSection~=nil and focusSection or current() and current().section or ""
        local c,e=BR:NewCategory({name=uniqueChild("New Subcategory",sec),expr="never",filters={},icon=134400,enabled=true,section=sec})
        if c then collapsed[c.section]=nil;BR:Apply();load(c.id);say("Choose item filters, then save. Empty filters match nothing.") else say(e,true) end
    end
    local function createParent()
        if not guard() then return end;local g,e=BR:NewSection(uniqueParent("New Category"));if not g then say(e,true);return end
        selectParent(g.id);parentName:SetFocus();parentName:HighlightText();say("Name your new parent category, then Save name.")
    end
    left(btn(root,"+ Category",102,26,createParent),root,0,54)
    left(btn(root,"+ Subcategory",102,26,addChild),root,110,54)
    shift(btn(parentPanel,"Save name",120,28,function()
        if not parentLoaded then return end;local old=parentLoaded.name;local ok,e=BR:RenameSection(parentLoaded.id,parentName:GetText());if not ok then parentMessage:SetText(e);return end
        local g=parentLoaded;if not g.icon or g.icon==134400 then local id=BR.IconSearch.Suggest(g.name) or BR.IconSearch.Suggest(g.name,nil,nil,true);if id then BR:SetSectionIcon(g.id,id) end end;collapsed[g.name]=collapsed[old];if old~=g.name then collapsed[old]=nil end;selectParent(g.id);parentMessage:SetText("Renamed. All children updated.")
    end),parentPanel,12,510)
    shift(btn(parentPanel,"Discard",86,28,function() if parentLoaded then refreshParent() end end),parentPanel,140,510)
    local function pickParent(useNative)
        if not parentLoaded or not guard() then return end;local key=parentLoaded.id
        local function done(id) if parentLoaded and parentLoaded.id==key and focusSection~=nil then local ok,e=BR:SetSectionIcon(key,id);if ok then refreshParent();refreshTree();queuePreview() else parentMessage:SetText(e) end end end
        (useNative and nativeIcons or browseIcons)(parentLoaded.icon or 132996,done,parentPanel,BR.IconSearch.Context(parentLoaded.name))
    end
    local pBrowse=btn(parentPanel,"Browse icons",112,26,function() pickParent(false) end);pBrowse:SetPoint("TOPRIGHT",parentPanel,"TOPRIGHT",-42,-107)
    local pNative=btn(parentPanel,"EUI icon picker",128,26,function() pickParent(true) end);pNative:SetPoint("TOPRIGHT",parentPanel,"TOPRIGHT",-12,-140)
    btn(parentPanel,"Suggest icon",104,26,function() if parentLoaded and guard() then local id=BR.IconSearch.Suggest(parentLoaded.name,nil,nil,true);if id then BR:SetSectionIcon(parentLoaded.id,id);refreshParent();refreshTree();queuePreview() else parentMessage:SetText("No confident icon suggestion. Browse all icons instead.") end end end):SetPoint("RIGHT",pNative,"LEFT",-6,0)
    parentEnabled:SetScript("OnClick",function() if parentLoaded and guard() then BR:SetSectionEnabled(parentLoaded.id,not parentLoaded.enabled);refreshParent();refreshTree();queuePreview() end end)
    left(btn(parentPanel,"+ Add subcategory",160,28,addChild),parentPanel,12,174)
    left(btn(parentPanel,"Duplicate parent",145,28,function() if not parentLoaded or not guard() then return end;local g,e=BR:DuplicateSection(parentLoaded.id,uniqueParent((parentLoaded.name~="" and parentLoaded.name or "Ungrouped"):sub(1,65).." Copy"));if g then selectParent(g.id);say("Parent and all child rules duplicated.") else parentMessage:SetText(e) end end),parentPanel,180,174)
    shift(btn(parentPanel,"Delete parent",123,28,function()
        if not parentLoaded or not guard() then return end
        local g=parentLoaded;if g.id=="ungrouped" then parentMessage:SetText("Ungrouped cannot be deleted.");return end
        local count=0;for _,c in ipairs(BR.db.categories) do if c.sectionID==g.id then count=count+1 end end
        if count>0 and (not deleteDest or deleteDest=="Choose destination") then parentMessage:SetText("Choose where to move the children first.");return end
        local key=g.id..":"..tostring(deleteDest);if pendingParentDelete~=key then pendingParentDelete=key;parentMessage:SetText("Press Delete parent again to confirm. Child rules are kept.");return end
        local dest=deleteDest==noParentLabel() and BR:EnsureSection("").id or (BR:FindSection(deleteDest) or {}).id
        local ok,e=BR:DeleteSection(g.id,dest);if ok then load(BR.db.categories[1] and BR.db.categories[1].id);say("Parent deleted. Child rules preserved.") else parentMessage:SetText(e) end
    end),parentPanel,209,385)
    shift(btn(right,"Duplicate child",88,28,function() if not guard() or not current() then return end;if focusSection~=nil then say("Select a subcategory, or use Duplicate parent.",true);return end;local c,e=BR:NewCategory(current());if c then c.name=uniqueChild((c.name.." Copy"):sub(1,70),c.section);BR:Apply();collapsed[c.section]=nil;load(c.id);say("Subcategory duplicated.") else say(e,true) end end),right,6,510)
    shift(btn(root,"Expand all",102,26,function() for _,g in ipairs(BR:SectionGroups()) do collapsed[g.section]=nil end;refreshTree() end),root,0,524)
    shift(btn(root,"Collapse all",102,26,function() for _,g in ipairs(BR:SectionGroups()) do collapsed[g.section]=true end;refreshTree() end),root,110,524)
    local function step(delta)
        if not moveAllowed() then return end
        local ok,err
        if focusSection~=nil then local key=focusSection;ok,err=BR:StepSection(key,delta);finishMove(ok,err,"section",key)
        elseif current() then ok,err=BR:Move(selected,delta);finishMove(ok,err,"category",selected) end
        if not ok and not err then say("Already at the edge of its section or list.") end
    end
    shift(btn(root,"Move up",102,26,function() step(-1) end),root,0,496)
    shift(btn(root,"Move down",102,26,function() step(1) end),root,110,496)
    local confirmID
    shift(btn(right,"Delete category",86,28,function() if not guard() or not current() then return end;if focusSection~=nil then say("Select an individual category before deleting.",true);return end;if confirmID~=selected then confirmID=selected;say("Press Delete category again to confirm.",true);return end;BR:Delete(selected);confirmID=nil;load(BR.db.categories[1] and BR.db.categories[1].id);say("Category deleted.") end),right,98,510)
    load(BR:Get(selectedID) and selectedID or BR.db.categories[1] and BR.db.categories[1].id)
    if not current() and BR.db.sections[1] then selectParent(BR.db.sections[1].id) end
    root.Reload=function() if focusSection~=nil and parentLoaded==BR:GetSection(parentLoaded and parentLoaded.id) then refreshTree();return end;if focusSection~=nil or loaded~=current() or not current() then load(BR:Get(selectedID) and selectedID or BR.db.categories[1] and BR.db.categories[1].id);if not current() and BR.db.sections[1] then selectParent(BR.db.sections[1].id) end else refreshTree();queuePreview() end end
    local function fit()
        if not viewport then return end
        local h=categoryHeight(parent,y);if h==height then return end
        height=h;extra=h-594;root:SetHeight(h)
        for _,v in ipairs(grows) do v[1]:SetHeight(v[2]+extra) end
        for _,v in ipairs(shifts) do v[1]:ClearAllPoints();if v[5] then stretch(v[1],v[2],v[3],v[4]+extra,v[5],v[6]) else left(v[1],v[2],v[3],v[4]+extra) end end
        rawSize()
    end
    root.Fit=fit
    if viewport and viewport.HookScript then viewport:HookScript("OnSizeChanged",function() if root:IsVisible() then fit() end end) end
    root:SetScript("OnShow",function() fit();ensureTheme();queuePreview() end)
    root:SetScript("OnHide",function() cancelDrag();closeIconBrowser();if activeMenu then activeMenu:Hide() end end)
    -- Only preview when options are visible; do not touch the bag renderer.
    root:RegisterEvent("BAG_UPDATE_DELAYED");root:RegisterEvent("PLAYER_REGEN_ENABLED");root:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    root:SetScript("OnEvent",function() if not previewRunning and (not root.IsVisible or root:IsVisible()) then queuePreview() end end)
    return root,height+6
end
local function buildGeneral(parent,y)
    local root=frame(parent); stretch(root,parent,24,-y+8,24,602)
    local t=label(root,"INTEGRATION SETTINGS",nil,accent); left(t,root,0,0)
    local status=label(root,statusText(),nil,dim); stretch(status,root,0,24,0,60); status:SetWordWrap(true)
    local toggles={}
    local function addToggle(key,text,yy)
        local b=toggle(root,text,350,function() end); left(b,root,0,yy)
        toggles[key]=b; b:State(BR.db[key]); b:SetScript("OnClick",function() BR.db[key]=not BR.db[key]; b:State(BR.db[key]); BR:Apply(); status:SetText(statusText()) end)
        return b
    end
    addToggle("enabled","Enable BagRules",94); addToggle("view","Independent BagRules view",128); addToggle("native","Also register native virtual categories",162); addToggle("keepPinned","Preserve native pinned section in BagRules view",196)
    local layoutNames={hierarchy="Nested sections",paths="Section / Category",categories="Category names only",sections="Section overview"}
    local layoutKeys={["Nested sections"]="hierarchy",["Section / Category"]="paths",["Category names only"]="categories",["Section overview"]="sections"}
    title(root,"Bag display layout",0,236)
    local layout=dropdown(root,210,{"Nested sections","Section / Category","Category names only","Section overview"},function(v) BR.db.sectionLayout=layoutKeys[v]; BR:Apply(); status:SetText(statusText()) end,nil,true)
    left(layout,root,0,258); layout:SetValue(layoutNames[BR.db.sectionLayout] or layoutNames.hierarchy)
    addToggle("tightCompact","Tighter packing within nested Compact sections",296)
    local explain=label(root,"Virtual View is independent but bags-only. Native virtual categories appear under collapsible visual parent headers in the live bags sidebar when supported, after built-in categories. Bank/offline use the native flat list. If the View API is missing, the native adapter is used as fallback. Section overview combines items by parent section; category names only keeps separate categories. Nested sections use an experimental standalone runtime adapter on compatible stock EUI in Grid or Compact mode. It falls back to flat paths if unsupported, in combat, during cursor/selection work, or in List mode. Rules never sell, move or destroy items.",nil,dim); stretch(explain,root,0,334,0,95); explain:SetWordWrap(true)
    left(btn(root,"Refresh / check API",180,28,function() BR:Apply(); status:SetText(statusText()) end),root,0,441)
    title(root,"CATEGORY ICONS",0,479)
    local iconStatus=label(root,"Fill only missing/question-mark icons. Existing selected icons are preserved.",nil,dim);stretch(iconStatus,root,0,542,0,42);iconStatus:SetWordWrap(true)
    local planned,signature
    left(btn(root,"Fill missing icons",148,28,function()
        if BR.MigrationDraftPending and BR.MigrationDraftPending() then iconStatus:SetText("Save or discard your category draft first.");return end
        if InCombatLockdown and InCombatLockdown() then iconStatus:SetText("Change icons outside combat.");return end
        local current=BR:Export()
        if not planned or signature~=current then planned=BR.IconSearch.MissingPlan();signature=current;iconStatus:SetText(#planned>0 and (#planned.." suggestions ready. Press Fill missing icons again to apply.") or "No confident suggestions for missing icons.");if #planned==0 then planned=nil end;return end
        local n,e=BR.IconSearch.ApplyMissing(planned);planned=nil;signature=nil;iconStatus:SetText(n and ("Filled "..n.." icons. Use Undo icon fill to restore them.") or e)
    end),root,0,506)
    left(btn(root,"Undo icon fill",132,28,function()
        if BR.MigrationDraftPending and BR.MigrationDraftPending() then iconStatus:SetText("Save or discard your category draft first.");return end
        local n,e=BR.IconSearch.UndoMissing();planned=nil;signature=nil;iconStatus:SetText(n and ("Restored "..n.." icons; later manual changes preserved.") or e)
    end),root,156,506)
    root.Reload=function() planned=nil;signature=nil;for key,b in pairs(toggles) do b:State(BR.db[key]) end; layout:SetValue(layoutNames[BR.db.sectionLayout] or layoutNames.hierarchy); status:SetText(statusText()) end
    return root,610
end
local function buildShare(parent,y)
    local root=frame(parent); stretch(root,parent,24,-y+8,24,570)
    local t=label(root,"IMPORT / EXPORT",nil,accent); left(t,root,0,0)
    local hint=label(root,"Paste a Baganator BGR!1! string, Baganator JSON, or BagRules export. First Import analyses; second Import replaces categories and creates a backup.",nil,dim); stretch(hint,root,0,24,0,42); hint:SetWordWrap(true)
    local holder=frame(root,bg,border); stretch(holder,root,0,74,0,298)
    local sf=CreateFrame("ScrollFrame",nil,holder,"UIPanelScrollFrameTemplate"); sf:SetPoint("TOPLEFT",4,-4); sf:SetPoint("BOTTOMRIGHT",-25,4)
    local box=edit(sf,true); box:SetMaxLetters(800000); box:SetWidth(math.max(100,holder:GetWidth()-36)); box:SetHeight(286); sf:SetScrollChild(box)
    holder:SetScript("OnSizeChanged",function(_,w) box:SetWidth(math.max(100,w-36)) end)
    box:SetScript("OnTextChanged",function(self) self:SetHeight(math.max(286,(self:GetNumLetters()/math.max(10,self:GetWidth()/7)+2)*15)) end)
    local status=label(root,"",nil,accent); stretch(status,root,0,421,0,140); status:SetWordWrap(true)
    left(btn(root,"Export",92,28,function() box:SetText(BR:Export()); box:SetFocus(); box:HighlightText(); status:SetText("Press Ctrl+C to copy.") end),root,0,383)
    local pending
    left(btn(root,"Import",92,28,function()
        local s=box:GetText()
        if BR.MigrationDraftPending and BR.MigrationDraftPending() then status:SetText("Save or discard your category draft first.");return end
        if InCombatLockdown and InCombatLockdown() then status:SetText("Import outside combat.");return end
        if pending~=s then
            local plan,report=BR:PrepareImport(s)
            if not plan then pending=nil; status:SetText("Import rejected: "..tostring(report)); return end
            pending=s
            local count=#report.warnings
            status:SetText(string.format("Preview: %d categories | %d sections | %d manual IDs | %d warnings.\nPress Import again to replace your existing categories. Choose a bag display mode in General; runtime nesting is experimental. Full warnings printed to chat.",report.categories,report.sections,report.manual,count))
            if report.converted then
                status:SetText(string.format("Preview: %d categories | %d parents | %d manual IDs | %d warnings.\n%d native conversions; %d retained legacy; %d bag slots compared. Press Import again to confirm.",report.categories,report.sections,report.manual,count,report.converted,report.retained,report.comparedSlots))
                for _,r in ipairs(report.conversionRows) do if not r.filters then BR:Print(r.name..": legacy retained: "..tostring(r.reason)) end end
            end
            for _,w in ipairs(report.warnings) do BR:Print(w:gsub("|","/")) end
            return
        end
        local ok,e=BR:Import(s); pending=nil
        status:SetText(ok and string.format("Imported %d categories. Reopen Categories to edit. Previous configuration backed up.",e.categories) or tostring(e))
        if ok then selectedID=nil;if e.converted then status:SetText(string.format("Imported %d categories: %d native, %d legacy retained. Previous configuration backed up.",e.categories,e.converted,e.retained)) end end
    end),root,100,383)
    left(btn(root,"Restore backup",132,28,function() if not BR.db.backup then status:SetText("No import backup yet."); return end; box:SetText(BR.db.backup); pending=nil; status:SetText("Backup loaded. Press Import twice to restore it.") end),root,200,383)
    left(btn(root,"Restore migration backup",165,28,function() if not BR.db.migrationBackup then status:SetText("No migration backup available.");return end;box:SetText(BR.db.migrationBackup);pending=nil;status:SetText("Pre-migration profile loaded. Press Import twice to restore it.") end),root,340,383)
    return root,578
end
local function buildStarter(parent,y)
    local root=frame(parent);stretch(root,parent,24,-y+8,24,530)
    local catalogue,fallback=BR.Filters.Catalogue();local groups=BR.Filters.Suggestions(catalogue);local chosen={};local toggles={}
    title(root,"SMART ORGANISATION",0,0)
    local note=label(root,"Create native metadata categories in one step. Existing categories and rules are never replaced. Generated categories have the lowest priority, so your current assignments win.",nil,dim);stretch(note,root,0,24,0,50);note:SetWordWrap(true)
    local summary=label(root,"",nil,accent);stretch(summary,root,0,400,0,50);summary:SetWordWrap(true)
    local pending;local function refresh()local plan,n=BR:StarterPlan(chosen,catalogue);summary:SetText(plan and (n.." new subcategories can be appended. Existing names are skipped.") or n);pending=nil end
    local yy=82;for _,g in ipairs(groups) do local key=g.name;chosen[key]=true;local b=toggle(root,key,260,function()end);left(b,root,0,yy);b:State(true);b:SetScript("OnClick",function()chosen[key]=not chosen[key];b:State(chosen[key]);refresh()end);toggles[key]=b
        local a={};for _,c in ipairs(g.children) do a[#a+1]=c.name end;local l=label(root,table.concat(a,", "),nil,dim);stretch(l,root,0,yy+28,0,32);l:SetWordWrap(true);yy=yy+63 end
    local function generate(replace)
        local mode=replace and "replace" or "append";local plan,n=BR:StarterPlan(chosen,catalogue,replace);if not plan then summary:SetText(n);pending=nil;return end
        if n==0 then summary:SetText("Nothing new to create.");pending=nil;return end
        if pending~=mode then pending=mode;summary:SetText(replace and ("WARNING: press Start fresh again to replace ALL current categories with "..n.." native ones. Backup saved to Import / Export.") or ("Press Generate selected again to append "..n.." subcategories. A profile backup will be made."));return end
        local ok,count=BR:GenerateStarter(chosen,catalogue,replace);pending=nil;if ok then selectedID=nil;summary:SetText("Created "..count.." native subcategories. Open Categories to edit.") else summary:SetText(count) end
    end
    left(btn(root,"Generate selected",160,28,function()generate(false)end),root,0,455)
    left(btn(root,"Start fresh",128,28,function()generate(true)end),root,168,455)
    local source=label(root,fallback and "Catalogue: client APIs with Classic fallback where unavailable." or "Catalogue: discovered from game APIs.",nil,dim);stretch(source,root,0,490,0,32);source:SetWordWrap(true)
    root.Reload=refresh;refresh();return root,540
end
local pages={Categories=buildCategories,["Smart Organisation"]=buildStarter,General=buildGeneral,["Import / Export"]=buildShare}
local roots={}
local function buildPage(page,parent,y)
    if EllesmereUI.IsSearchPrebuild and EllesmereUI.IsSearchPrebuild() then return 0 end
    -- EUI provides the real header, sidebar, scrolling and overall styling.
    -- Custom controls are drawn only on the frame handed to this plugin.
    ensureTheme()
    local W=EllesmereUI.Widgets
    if page~="Categories" and W and W.SectionHeader then local _,h=W:SectionHeader(parent,"BAGRULES",y); y=y-(h or 0) end
    local root,h=pages[page](parent,y); roots[page]=root
    return -y+h
end
-- A separate fallback settings window for releases without RegisterPlugin.
local fallback
local function openFallback()
    if InCombatLockdown and InCombatLockdown() then BR:Print("Options cannot open during combat."); return end
    if not fallback then
        ensureTheme(); fallback=frame(UIParent,{0.07,0.065,0.06,0.98},border); fallback:SetSize(860,770); fallback:SetPoint("CENTER"); fallback:SetFrameStrata("DIALOG"); fallback:EnableMouse(true); fallback:SetMovable(true); fallback:RegisterForDrag("LeftButton"); fallback:SetScript("OnDragStart",fallback.StartMoving); fallback:SetScript("OnDragStop",fallback.StopMovingOrSizing)
        local titleText=label(fallback,"BagRules  |  EllesmereUI extension","large",accent); left(titleText,fallback,24,16)
        btn(fallback,"X",28,28,function() fallback:Hide() end):SetPoint("TOPRIGHT",-12,-12)
        local currentRoot
        local sf=CreateFrame("ScrollFrame",nil,fallback,"UIPanelScrollFrameTemplate"); sf:SetPoint("TOPLEFT",0,-80); sf:SetPoint("BOTTOMRIGHT",-25,10)
        local child=CreateFrame("Frame",nil,sf); child:SetSize(825,840); sf:SetScrollChild(child)
        local function showPage(page)
            if currentRoot then currentRoot:Hide() end
            local entry=fallback[page]
            if not entry then local root,h=pages[page](child,0); entry={root=root,height=h}; fallback[page]=entry end
            local root=entry.root; child:SetHeight(entry.height+20); sf:SetVerticalScroll(0)
            if root.Reload then root.Reload() end
            root:Show(); currentRoot=root
        end
        for i,p in ipairs({"Categories","Smart Organisation","General","Import / Export"}) do local page=p; left(btn(fallback,page,144,26,function() showPage(page) end),fallback,24+(i-1)*152,49) end
        showPage("Categories")
    end
    ensureTheme();fallback:Show()
end
function BR:RegisterOptions()
    if self.optionsAttempted then return end; self.optionsAttempted=true
    if EllesmereUI and type(EllesmereUI.RegisterPlugin)=="function" then
        local ok,result=pcall(EllesmereUI.RegisterPlugin,ADDON,{label="BagRules",modules={{key="Rules",title="Category Manager",description="Organise inventory with native item filters or legacy rules.",pages={"Categories","Smart Organisation","General","Import / Export"},searchPrebuild=false,buildPage=buildPage,onPageCacheRestore=function(page) ensureTheme();if roots[page] then if roots[page].Fit then roots[page].Fit() end;if roots[page].Reload then roots[page].Reload() end end end}}})
        self.pluginRegistered=ok and result==true
    end
end
SLASH_BAGRULES1="/bagrules"; SLASH_BAGRULES2="/brules"
SlashCmdList.BAGRULES=function(msg)
    if not BR.db then BR:Print("Not initialised yet."); return end
    msg=(msg or ""):lower():match("^%s*(.-)%s*$")
    if msg=="status" then BR:Print(statusText().." | Version "..BR.version)
    elseif msg=="refresh" then BR:Apply(); BR:Print(statusText())
    elseif msg=="fallback" then openFallback()
    else
        if BR.pluginRegistered and EllesmereUI.OpenPlugin then local ok,r=pcall(EllesmereUI.OpenPlugin,ADDON,"Rules","Categories"); if ok and r then return end end
        openFallback()
    end
end
