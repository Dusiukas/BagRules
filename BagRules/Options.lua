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
local activeMenu
local function dropdown(parent,w,values,changed,alignRight,fixed)
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
    local mw=math.max(w,200)
    local menu=frame(parent,ddMenuBG,ddBorder); menu:SetFrameStrata("TOOLTIP"); menu:SetSize(mw,200); menu:SetPoint(alignRight and "TOPRIGHT" or "TOPLEFT",b,alignRight and "BOTTOMRIGHT" or "BOTTOMLEFT",0,-1); menu:Hide()
    local sf=CreateFrame("ScrollFrame",nil,menu,"UIPanelScrollFrameTemplate"); sf:SetPoint("TOPLEFT",3,-3); sf:SetPoint("BOTTOMRIGHT",-25,3)
    local child=CreateFrame("Frame",nil,sf); child:SetSize(math.max(30,mw-32),1); sf:SetScrollChild(child)
    function b:SetChoices(v)
        for _,r in ipairs(items) do r:Hide() end
        for i,x in ipairs(v) do
            local row=items[i]
            if not row then row=btn(child,"",math.max(30,mw-32),24); row.text:ClearAllPoints();row.text:SetPoint("LEFT",5,0);row.text:SetPoint("RIGHT",-4,0);row.text:SetWordWrap(false);left(row,child,0,(i-1)*25); items[i]=row end
            local value=x; row.text:SetText(value); row:SetScript("OnClick",function() b:SetValue(value); menu:Hide(); changed(value) end); row:Show()
        end
        child:SetHeight(math.max(1,#v*25)); menu:SetHeight(math.min(200,#v*25+6)); sf:SetVerticalScroll(0)
    end
    function b:SetValue(v) self.value=v; self.text:SetText(v..(arrow and "" or "  v")) end
    b:SetScript("OnClick",function() if menu:IsShown() then menu:Hide() else if activeMenu and activeMenu~=menu then activeMenu:Hide() end; activeMenu=menu;menu:Show() end end)
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
    local s=BR.status or {}; return (s.message or "Waiting for login").." | Categories: "..(s.native or 0).." | View: "..(s.view and "active" or "not active").." | Section API: "..(s.hierarchy and "host patch active" or BR.RuntimeSections and BR.RuntimeSections.state or "stock / flat")..(BR.RuntimeSections and BR.RuntimeSections.hostVersion and (" | EUI Bags: "..BR.RuntimeSections.hostVersion) or "")..(BR.RuntimeSections and BR.RuntimeSections.state and BR.RuntimeSections.state:find("runtime nested",1,true) and BR.RuntimeSections.density and (" | Packing: "..BR.RuntimeSections.density) or "").." | Auctionator: "..(BR:HasPrices() and "available" or "not installed")..((s.errors or 0)>0 and (" | Errors: "..s.errors) or "")..(BR.pending and " | Pending combat end" or "")..((BR.invalid or 0)>0 and (" | Invalid rules: "..BR.invalid) or "")
end
local selectedID
local function buildCategories(parent,y)
    local V=BR.VisualRules
    local root=frame(parent); stretch(root,parent,24,-y+8,24,884)
    local heading=label(root,"CATEGORY MANAGER",nil,accent); left(heading,root,0,2)
    local note=label(root,"Organise categories, build rules and preview matching items before saving.",nil,dim); stretch(note,root,0,22,0,24); note:SetWordWrap(true)
    local search=edit(root,false); left(search,root,0,51); search:SetSize(210,26)
    local searchHint=label(search,"Find category or section...",nil,dim); searchHint:SetPoint("LEFT",7,0)
    search:SetScript("OnEditFocusGained",function() searchHint:Hide() end)
    search:SetScript("OnEditFocusLost",function() if search:GetText()=="" then searchHint:Show() end end)
    local holder,child,sf=scroll(root,0,112,210,546)
    local right=frame(root,panel,border); left(right,root,222,51); right:SetPoint("TOPRIGHT",root,"TOPRIGHT",0,-51); right:SetHeight(810)
    local message=label(root,"",nil,accent); stretch(message,root,0,864,0,30); message:SetWordWrap(true)
    local function say(t,bad) message:SetText(t or ""); color(message,bad and {1,0.43,0.38} or accent) end
    local selected,loaded,loading,model,node,parentNode,draftError,mode,tab,activeEnabled=nil,nil,false,nil,nil,nil,nil,"Visual","Rules",false
    local refreshTree,load,rebuild,refreshPreview,queuePreview,updateTabs,save,chooseNode,validate,changeModel
    local focusSection -- selected parent label; nil = editing a child
    local parentLoaded,sectionValue
    local function noParentLabel()
        local n="Ungrouped";while BR:FindSection(n) do n=n.." (no parent)" end;return n
    end
    local selectParent,addChild,refreshParent,guard
    local function current() return selected and BR:Get(selected) end
    local iconPreview=right:CreateTexture(nil,"ARTWORK"); iconPreview:SetSize(38,38); iconPreview:SetPoint("TOPLEFT",12,-12)
    local name=edit(right,false); stretch(name,right,58,12,12,29); name:SetMaxLetters(80)
    title(right,"Parent",12,60)
    local sectionPick=dropdown(right,255,{"Ungrouped"},function(s) sectionValue=s==noParentLabel() and "" or s;if not loading then validate() end end,true); left(sectionPick,right,74,54)
    local parentPanel=frame(root,panel,border);left(parentPanel,root,222,51);parentPanel:SetPoint("TOPRIGHT",root,"TOPRIGHT",0,-51);parentPanel:SetHeight(810);parentPanel:Hide()
    local parentHeading=label(parentPanel,"PARENT CATEGORY","large",accent);left(parentHeading,parentPanel,12,14)
    title(parentPanel,"Name (applies to every subcategory)",12,48)
    local parentName=edit(parentPanel,false);stretch(parentName,parentPanel,12,70,12,28);parentName:SetMaxLetters(80)
    local parentSummary=label(parentPanel,"",nil,dim);stretch(parentSummary,parentPanel,12,110,12,40);parentSummary:SetWordWrap(true)
    local parentEnabled=toggle(parentPanel,"Enable entire category",235,function() end);left(parentEnabled,parentPanel,12,154)
    local parentList=label(parentPanel,"",nil,white);stretch(parentList,parentPanel,12,238,12,225);parentList:SetWordWrap(true);parentList:SetJustifyV("TOP")
    local parentHelp=label(parentPanel,"Parent categories organise subcategories. Rules belong to subcategories only. Drag the parent row to move the entire group in the bags.",nil,dim);stretch(parentHelp,parentPanel,12,660,12,75);parentHelp:SetWordWrap(true)
    local deleteDest
    local deletePick=dropdown(parentPanel,240,{"Choose destination"},function(v) deleteDest=v end,true);left(deletePick,parentPanel,12,508)
    title(parentPanel,"Move children before deleting this parent",12,482)
    local parentMessage=label(parentPanel,"",nil,accent);stretch(parentMessage,parentPanel,12,590,12,62);parentMessage:SetWordWrap(true)
    local enabled=toggle(right,"Enabled",112,function() end); left(enabled,right,12,88)
    enabled:SetScript("OnClick",function() if current() then activeEnabled=not activeEnabled; enabled:State(activeEnabled); queuePreview() end end)
    local stateLabel=label(right,"",nil,dim); stretch(stateLabel,right,132,88,12,26)
    local tabs={}; local pages={}; local sectionHeight=456
    for i,t in ipairs({"Rules","Appearance","Advanced"}) do
        local key=t; tabs[key]=btn(right,key,105,27,function() tab=key; updateTabs() end,"row"); left(tabs[key],right,12+(i-1)*111,123)
        local p=frame(right); stretch(p,right,12,160,12,sectionHeight); pages[key]=p
    end
    local rules,appearance,advanced=pages.Rules,pages.Appearance,pages.Advanced
    local applyPreset
    local modeButtons={}; for i,m in ipairs({"Visual","Expression"}) do local key=m; modeButtons[key]=btn(rules,key,102,26,nil,"row"); left(modeButtons[key],rules,(i-1)*108,0) end
    local presetRule=dropdown(rules,132,{"Rule presets...","Cloth","Herbs","Leather","Ore & Stone","Weapons","Armour","Consumables","Quest items","Recipes","Poor quality","Tradeable gear","Crafting materials"},function(v) if applyPreset then applyPreset(v) end end,true);left(presetRule,rules,216,0)
    local visual=frame(rules); stretch(visual,rules,0,35,0,418)
    local raw=frame(rules); stretch(raw,rules,0,35,0,418)
    local visualInfo=label(visual,"Choose a rule preset or click a condition to edit. ALL = AND, ANY = OR.",nil,dim); stretch(visualInfo,visual,0,0,0,29); visualInfo:SetWordWrap(true)
    local ruleHolder=frame(visual,bg,border); stretch(ruleHolder,visual,0,34,0,188)
    local ruleScroll=CreateFrame("ScrollFrame",nil,ruleHolder,"UIPanelScrollFrameTemplate"); ruleScroll:SetPoint("TOPLEFT",4,-4); ruleScroll:SetPoint("BOTTOMRIGHT",-25,4)
    local ruleChild=CreateFrame("Frame",nil,ruleScroll); ruleChild:SetSize(math.max(160,ruleHolder:GetWidth()-34),1); ruleScroll:SetScrollChild(ruleChild)
    ruleHolder:SetScript("OnSizeChanged",function(_,w) ruleChild:SetWidth(math.max(160,w-34)) end)
    local rows={}
    local editHead=label(visual,"SELECTED RULE",nil,accent); left(editHead,visual,0,231)
    local groupPanel=frame(visual); stretch(groupPanel,visual,0,251,0,89)
    local condPanel=frame(visual); stretch(condPanel,visual,0,251,0,89)
    local groupMode=dropdown(groupPanel,166,{"Match ALL (AND)","Match ANY (OR)"},function(v) if node and node.kind=="group" then node.mode=v=="Match ALL (AND)" and "ALL" or "ANY"; changeModel() end end,nil,true); left(groupMode,groupPanel,0,0)
    local groupNeg; groupNeg=toggle(groupPanel,"NOT group",132,function() if node then node.negated=not node.negated; groupNeg:State(node.negated); changeModel() end end); left(groupNeg,groupPanel,174,0)
    local field,op,value,preset,neg
    local changing=false
    local function configureField(key,initial)
        local ops=V.Ops(key); op:SetChoices(ops); op:SetValue(initial and V.opNames[initial.op] or ops[1])
        local vals=V.Choices(key); preset:Hide(); if vals then preset:SetChoices(vals); preset:SetValue("Choose value"); preset:Show() end
        local default=vals and vals[1] or (BR.Rules.fields[key]=="text" and "" or "1")
        value:SetText(initial and V.Value(initial) or default)
    end
    local function editCondition()
        if changing or loading or not node or node.kind~="condition" then return end
        local n,e=V.Predicate(V.keys[field.value],V.opKeys[op.value],value:GetText())
        if not n then draftError=e; validate(); return end
        node.field,node.op,node.value=n.field,n.op,n.value; draftError=nil; changeModel()
    end
    field=dropdown(condPanel,181,V.fieldLabels,function(v) changing=true; configureField(V.keys[v]); changing=false; editCondition() end,nil,true); left(field,condPanel,0,0)
    op=dropdown(condPanel,112,{"Is"},editCondition); left(op,condPanel,187,0)
    neg=toggle(condPanel,"NOT",76,function() if node then node.negated=not node.negated; neg:State(node.negated); editCondition() end end); left(neg,condPanel,0,63)
    value=edit(condPanel,false); stretch(value,condPanel,0,32,129,26); value:SetMaxLetters(8192); value:SetScript("OnTextChanged",editCondition)
    preset=dropdown(condPanel,121,{"Yes","No"},function(v) if v~="Other / enter text" then value:SetText(v) end; preset:SetValue("Choose value") end,true); preset:SetPoint("TOPRIGHT",condPanel,"TOPRIGHT",0,-32)
    local tip=label(condPanel,"Values are case-insensitive. Money accepts copper, 20s or 2g.",nil,dim); stretch(tip,condPanel,84,63,0,26); tip:SetWordWrap(true)
    local add=btn(visual,"+ Condition",109,26,function()
        if not model or draftError then return end; local p=node and node.kind=="group" and node or parentNode or model
        if #V.Rows(model)>=100 then say("Visual rule limit reached.",true);return end
        local n={kind="condition",field="constant",op="=",value=p.mode=="ALL" and "all" or "never"}; p.children[#p.children+1]=n; chooseNode(n,p); changeModel()
    end); left(add,visual,0,346)
    left(btn(visual,"+ Group",90,26,function()
        if not model or draftError then return end; local p=node and node.kind=="group" and node or parentNode or model
        if #V.Rows(model)>=99 then say("Visual rule limit reached.",true);return end
        local n={kind="group",mode="ALL",children={{kind="condition",field="constant",op="=",value=p.mode=="ALL" and "all" or "never"}}}; p.children[#p.children+1]=n; chooseNode(n,p); changeModel()
    end),visual,115,346)
    left(btn(visual,"Remove",82,26,function() if node and parentNode and V.Remove(parentNode,node) then local p=parentNode; draftError=nil; chooseNode(p,nil); changeModel() end end),visual,211,346)
    local visualError=label(visual,"",nil,dim); stretch(visualError,visual,0,378,0,38); visualError:SetWordWrap(true)
    local rawHint=label(raw,"Edit the same rule as text. & AND   | OR   ! NOT   ( ) groups   ~ contains",nil,dim); stretch(rawHint,raw,0,0,0,38); rawHint:SetWordWrap(true)
    local rawHolder=frame(raw,bg,border); stretch(rawHolder,raw,0,42,0,300)
    local rawScroll=CreateFrame("ScrollFrame",nil,rawHolder,"UIPanelScrollFrameTemplate"); rawScroll:SetPoint("TOPLEFT",4,-4); rawScroll:SetPoint("BOTTOMRIGHT",-25,4)
    local expr=edit(rawScroll,true); expr:SetMaxLetters(8192); expr:SetSize(math.max(100,rawHolder:GetWidth()-34),288); rawScroll:SetScrollChild(expr)
    local function rawSize() expr:SetHeight(math.max(288,(expr:GetNumLetters()/math.max(10,expr:GetWidth()/6)+2)*15)) end
    rawHolder:SetScript("OnSizeChanged",function(_,w) expr:SetWidth(math.max(100,w-34));rawSize() end)
    local rawError=label(raw,"",nil,dim); stretch(rawError,raw,0,350,0,55); rawError:SetWordWrap(true)
    expr:SetScript("OnTextChanged",function() rawSize(); if not loading then if mode=="Expression" then draftError=nil end; validate() end end)
    title(appearance,"CATEGORY ICON",0,4)
    local icon=edit(appearance,false); left(icon,appearance,0,28); icon:SetSize(140,26)
    local bigIcon=appearance:CreateTexture(nil,"ARTWORK"); bigIcon:SetSize(54,54); bigIcon:SetPoint("TOPLEFT",154,-28)
    local iconNote=label(appearance,"Enter a WoW icon file ID or select an icon from these common choices.",nil,dim); stretch(iconNote,appearance,0,96,0,38); iconNote:SetWordWrap(true)
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
    local importNote=label(advanced,"",nil,dim); stretch(importNote,advanced,0,251,0,190); importNote:SetWordWrap(true); importNote:SetJustifyV("TOP")
    local preview=frame(right,bg,border); stretch(preview,right,12,624,12,128)
    local pt=label(preview,"LIVE PREVIEW",nil,accent); left(pt,preview,8,6)
    local ptext=label(preview,"",nil,dim); stretch(ptext,preview,8,26,8,95); ptext:SetWordWrap(true); ptext:SetJustifyV("TOP")
    local function parseIDs()
        local s=manual:GetText():gsub("%s+",""); local ids,seen={},{}
        if s=="" then return ids end
        if not s:match("^%d[%d,]*$") or s:find(",,") or s:sub(-1)=="," then return nil,"Manual items must be comma-separated numeric IDs." end
        for v in s:gmatch("%d+") do local id=tonumber(v); if not id or id<1 or id>2147483647 or seen[id] or #ids>=1000 then return nil,"Invalid or duplicate manual item ID." end; ids[#ids+1]=id; seen[id]=true end
        return ids
    end
    local function dirty()
        if focusSection~=nil then return parentLoaded and parentName:GetText()~=(parentLoaded.name~="" and parentLoaded.name or "Ungrouped") or false end
        local c=current(); if not c then return false end
        return draftError~=nil or name:GetText()~=c.name or expr:GetText()~=c.expr or tostring(c.icon)~=icon:GetText() or tostring(c.priority or 0)~=priority:GetText() or (c.section or "")~=sectionValue or table.concat(c.manual or {},",")~=manual:GetText() or activeEnabled~=c.enabled
    end
    local function draft()
        if draftError then return nil,draftError end
        local ids,e=parseIDs(); if not ids then return nil,e end
        local p=tonumber(priority:GetText()); if not p or p%1~=0 or math.abs(p)>10000 then return nil,"Priority must be an integer from -10000 to 10000" end
        local a,e=R.Compile(expr:GetText()); if not a then return nil,e end
        return {priority=p,manual=ids,enabled=activeEnabled}
    end
    local previewToken=0
    local previewRunning=false
    local counts={}
    refreshPreview=function()
        if loading or focusSection~=nil or not current() then ptext:SetText("Select a category to preview."); return end
        if InCombatLockdown and InCombatLockdown() then ptext:SetText("Preview paused during combat.");return end
        local d,e=draft(); if not d then ptext:SetText(e);return end
        previewRunning=true
        local a,err,unknown,total,shadowed,newCounts=BR:Preview(expr:GetText(),selected,d)
        previewRunning=false
        if not a then ptext:SetText(err);return end
        counts=newCounts or {}; if refreshTree then refreshTree() end
        local lines={string.format("%d / %d slots match | %d conflicts | %d unknown%s",#a,total,shadowed,unknown,not activeEnabled and " | Disabled draft" or ((BR:FindSection(sectionValue) or {}).enabled==false and " | Parent disabled" or ""))}
        for i=1,math.min(4,#a) do local r=a[i]; lines[#lines+1]=(r.shadowed and "* " or "")..r.name.." x"..r.count end
        if #a>4 then lines[#lines+1]="... "..(#a-4).." more" end
        ptext:SetText(table.concat(lines,"\n"))
    end
    queuePreview=function()
        if loading or focusSection~=nil then return end
        local c=current(); stateLabel:SetText(dirty() and "Unsaved changes" or (c and c.warning~="" and "Saved | Import warning (Advanced)" or "Saved"))
        previewToken=previewToken+1; local token=previewToken
        if C_Timer and C_Timer.After then C_Timer.After(0.25,function() if token==previewToken and (not root.IsVisible or root:IsVisible()) then refreshPreview() end end) else refreshPreview() end
    end
    validate=function()
        if loading then return end
        local a,e=draft(); local msg=a and "Valid rule" or e; local c=a and accent or {1,0.43,0.38}
        visualError:SetText(msg or ""); rawError:SetText(msg or ""); color(visualError,c);color(rawError,c);queuePreview()
    end
    rebuild=function()
        for _,r in ipairs(rows) do r:Hide() end
        local a=V.Rows(model)
        for i,x in ipairs(a) do
            local b=rows[i]; if not b then b=btn(ruleChild,"",100,24,nil,"row"); b.text:ClearAllPoints(); b.text:SetPoint("LEFT",7,0); b.text:SetPoint("RIGHT",-5,0); b.text:SetWordWrap(false); b.text:SetJustifyH("LEFT"); rows[i]=b end
            b:ClearAllPoints(); stretch(b,ruleChild,math.min(8*x.depth,80),(i-1)*25,0,24)
            b.text:SetText((V.Describe(x.node):gsub("|","||")));color(b.text,x.node==node and accent or x.node.kind=="group" and dim or white)
            selectedPaint(b,x.node==node)
            local n,p=x.node,x.parent;b:SetScript("OnEnter",function(self) outline(self,accent);if GameTooltip and GameTooltip.SetOwner then GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText((V.Describe(n):gsub("|","||")));GameTooltip:Show() end end);b:SetScript("OnLeave",function(self) outline(self,border);if GameTooltip then GameTooltip:Hide() end end);b:SetScript("OnClick",function() if draftError and node~=n then say("Fix the current condition before selecting another, or use Remove.",true);return end; chooseNode(n,p);rebuild() end);b:Show()
        end
        ruleChild:SetHeight(math.max(1,#a*25))
    end
    chooseNode=function(n,p)
        node=n; parentNode=p
        if n and not p and n~=model then for _,x in ipairs(V.Rows(model)) do if x.node==n then parentNode=x.parent; break end end end
        changing=true
        groupPanel:Hide();condPanel:Hide()
        if n and n.kind=="group" then groupMode:SetValue(n.mode=="ALL" and "Match ALL (AND)" or "Match ANY (OR)"); groupNeg:State(n.negated); groupPanel:Show()
        elseif n then field:SetValue(V.names[n.field]); configureField(n.field,n); neg:State(n.negated); condPanel:Show() end
        changing=false
    end
    changeModel=function()
        if not model then return end
        local s,e=V.Expression(model); draftError=e
        if s then loading=true;expr:SetText(s);loading=false end
        rebuild();validate()
    end
    applyPreset=function(v)
        presetRule:SetValue("Rule presets...");local template=V.presets[v];if not template or not current() then return end
        if draftError then say("Resolve or discard the invalid condition first.",true);return end
        local m,e=V.FromExpression(template);if not m then say(e,true);return end
        loading=true;expr:SetText(template);model=m;mode="Visual";chooseNode(model,nil);loading=false;rebuild();updateTabs();validate();say("Preset loaded into draft. Review and save to apply.")
    end
    local function setMode(m)
        if m==mode then return end
        if draftError then say("Resolve the visual rule error or discard changes first.",true); return end
        if m=="Visual" then
            local n,e=V.FromExpression(expr:GetText()); if n then local check,err=V.Expression(n);if not check then n=nil;e=err end end; if not n then say(e,true);return end;model=n;chooseNode(model,nil);rebuild()
        end
        mode=m;updateTabs();validate()
    end
    modeButtons.Visual:SetScript("OnClick",function() setMode("Visual") end);modeButtons.Expression:SetScript("OnClick",function() setMode("Expression") end)
    updateTabs=function()
        for k,p in pairs(pages) do if k==tab then p:Show() else p:Hide() end; color(tabs[k].text,k==tab and accent or dim);outline(tabs[k],k==tab and accent or border) end
        for k,b in pairs(modeButtons) do color(b.text,k==mode and accent or dim);outline(b,k==mode and accent or border) end
        if mode=="Visual" then visual:Show();raw:Hide() else raw:Show();visual:Hide() end
    end
    local function sectionChoices()
        local choices={noParentLabel()};for _,g in ipairs(BR:SectionGroups()) do if g.section~="" then choices[#choices+1]=g.section end end
        sectionPick:SetChoices(choices);sectionPick:SetValue(sectionValue~="" and sectionValue or noParentLabel())
    end
    save=function()
        if not current() then return end
        local d,e=draft();if not d then say(e,true);return end
        local id=tonumber(icon:GetText());if not id or id<=0 or id>=100000000 or id%1~=0 then say("Enter a valid icon file ID.",true);return end
        local ok,err=BR:SaveCategory(selected,name:GetText(),expr:GetText(),id,d.priority,sectionValue,d.manual,activeEnabled)
        if ok then load(selected);say("Saved. "..(BR.pending and "Inventory update queued until combat ends." or "Inventory refreshed.")) else say(err,true) end
    end
    local apply=btn(right,"Save changes",122,30,save,"row"); left(apply,right,12,765); outline(apply,accent);color(apply.text,accent)
    left(btn(right,"Discard",86,30,function() load(selected);say("Draft discarded.") end),right,141,765)
    left(btn(right,"Refresh preview",118,30,refreshPreview),right,234,765)
    for _,f in ipairs({name,priority,manual}) do f:SetScript("OnTextChanged",function() if not loading then validate() end end) end
    icon:SetScript("OnTextChanged",function() iconChanged();if not loading then queuePreview() end end)
    local listRows,headers,collapsed,visible={},{},{},{}
    local drag,dropRow,dropMode
    guard=function() if dirty() then say("Save or discard your current changes first.",true);return false end;return true end
    local moveNote=label(root,"",nil,dim);left(moveNote,root,0,819);moveNote:SetWidth(210);moveNote:SetWordWrap(true)
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
            for _,c in ipairs(g.categories) do if q=="" or c.name:lower():find(q,1,true) or sec:lower():find(q,1,true) or c.expr:lower():find(q,1,true) then entries[#entries+1]=c end end
            if #entries>0 or q=="" or sec:lower():find(q,1,true) then
                hi=hi+1;local h=headers[hi];if not h then h=btn(child,"",176,25,nil,"row");h.text:ClearAllPoints();h.text:SetPoint("LEFT",24,0);h.text:SetPoint("RIGHT",-17,0);h.text:SetWordWrap(false);local grip=label(h,"::",nil,dim);grip:SetPoint("RIGHT",-5,0);headers[hi]=h;attachDrag(h);h.chevron=btn(h,"-",20,23,nil,"row");h.chevron:SetPoint("LEFT",0,0) end
                h:ClearAllPoints();left(h,child,0,yy);h.text:SetText((sec~="" and sec or "Ungrouped")..(g.enabled==false and " (off)" or ""));h.chevron.text:SetText(collapsed[sec] and "+" or "-");color(h.text,accent);accentPaint(h,focusSection==sec and 0.22 or 0.10);outline(h,border)
                h.brKind,h.brKey,h.brSection="section",sec,sec
                local key,parentID=sec,g.id;h:SetScript("OnClick",function() if guard() then selectParent(parentID);say("") end end)
                h.chevron:SetScript("OnClick",function() collapsed[key]=not collapsed[key];refreshTree() end);h:Show();visible[#visible+1]=h;yy=yy+27
                if not collapsed[sec] or q~="" then
                    for _,c in ipairs(entries) do
                        ri=ri+1;local b=listRows[ri];if not b then b=btn(child,"",166,28,nil,"row");b.ic=b:CreateTexture(nil,"ARTWORK");b.ic:SetSize(19,19);b.ic:SetPoint("LEFT",4,0);b.text:ClearAllPoints();b.text:SetPoint("LEFT",28,0);b.text:SetPoint("RIGHT",-35,0);b.text:SetWordWrap(false);b.text:SetJustifyH("LEFT");b.count=label(b,"",nil,dim);b.count:SetPoint("RIGHT",-16,0);local grip=label(b,"::",nil,dim);grip:SetPoint("RIGHT",-4,0);listRows[ri]=b;attachDrag(b) end
                        b:ClearAllPoints();left(b,child,10,yy);b.ic:SetTexture(c.icon);b.count:SetText(tostring(counts[c.id] or 0));b.text:SetText(c.name..(c.enabled and "" or " (off)"));color(b.text,(not c.enabled or g.enabled==false) and dim or c.id==selected and accent or white);selectedPaint(b,c.id==selected and focusSection==nil);outline(b,border)
                        b.brKind,b.brKey,b.brSection="category",c.id,sec
                        local id=c.id;b:SetScript("OnClick",function() if id~=selected or focusSection~=nil then if guard() then load(id);say("") end else refreshTree() end end);b:Show();visible[#visible+1]=b;yy=yy+30
                    end
                end
            end
        end
        child:SetHeight(math.max(1,yy))
        moveNote:SetText((focusSection~=nil and ("Moving section: "..(focusSection~="" and focusSection or "Ungrouped")) or ("Moving category: "..(current() and current().name or "None"))).."\nDrag rows or use Move up/down. Order does not change rule priority.")
    end
    root.RefreshList=refreshTree
    search:SetScript("OnTextChanged",function() cancelDrag();if search:GetText()=="" then searchHint:Show() else searchHint:Hide() end;refreshTree();sf:SetVerticalScroll(0) end)
    load=function(id)
        focusSection=nil;parentLoaded=nil;parentPanel:Hide();right:Show();selected=id;selectedID=id;loaded=current();local c=loaded;loading=true;draftError=nil
        name:SetText(c and c.name or "");sectionValue=c and c.section or "";icon:SetText(tostring(c and c.icon or 134400));priority:SetText(tostring(c and c.priority or 0));manual:SetText(table.concat(c and c.manual or {},","));expr:SetText(c and c.expr or "never");activeEnabled=c and c.enabled or false;enabled:State(activeEnabled)
        importNote:SetText(c and c.warning~="" and ("IMPORT WARNING: "..c.warning:gsub("|","/")) or "No import warnings.")
        model=V.FromExpression(expr:GetText());if model and not V.Expression(model) then model=nil end;mode=model and "Visual" or "Expression";if model and c and c.expr=="never" then chooseNode(model.children[1],model) else chooseNode(model,nil) end;rebuild();ruleScroll:SetVerticalScroll(0);sectionChoices();updateTabs();loading=false;refreshTree();validate()
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
        parentName:SetText(g.name~="" and g.name or "Ungrouped");parentEnabled:State(g.enabled)
        local entries={};for _,c in ipairs(BR.db.categories) do if c.sectionID==g.id then entries[#entries+1]=c.name..(c.enabled and "" or " (off)") end end
        parentSummary:SetText(#entries.." subcategories  |  "..(g.enabled and "Enabled" or "Disabled"))
        local lines={"SUBCATEGORIES"};for i=1,math.min(12,#entries) do lines[#lines+1]="  "..entries[i] end;if #entries>12 then lines[#lines+1]="  ... "..(#entries-12).." more" end
        parentList:SetText(table.concat(lines,"\n"))
        local choices={"Choose destination",noParentLabel()};for _,other in ipairs(BR.db.sections) do if other~=g and other.name~="" then choices[#choices+1]=other.name end end
        deletePick:SetChoices(choices);deletePick:SetValue(choices[1]);deleteDest=nil;parentMessage:SetText("")
    end
    local pendingParentDelete
    selectParent=function(key)
        local g=BR:GetSection(key);if not g then return end
        focusSection=g.name;parentLoaded=g;pendingParentDelete=nil;right:Hide();parentPanel:Show();refreshParent();refreshTree()
    end
    addChild=function()
        if not guard() then return end
        local sec=focusSection~=nil and focusSection or current() and current().section or ""
        local c,e=BR:NewCategory({name=uniqueChild("New Subcategory",sec),expr="never",icon=134400,enabled=false,section=sec})
        if c then collapsed[c.section]=nil;BR:Apply();load(c.id);say("Choose a preset or add conditions, enable, then save.") else say(e,true) end
    end
    local function createParent()
        if not guard() then return end;local g,e=BR:NewSection(uniqueParent("New Category"));if not g then say(e,true);return end
        selectParent(g.id);parentName:SetFocus();parentName:HighlightText();say("Name your new parent category, then Save name.")
    end
    left(btn(root,"+ Category",102,26,createParent),root,0,82)
    left(btn(root,"+ Subcategory",102,26,addChild),root,108,82)
    left(btn(parentPanel,"Save name",120,28,function()
        if not parentLoaded then return end;local old=parentLoaded.name;local ok,e=BR:RenameSection(parentLoaded.id,parentName:GetText());if not ok then parentMessage:SetText(e);return end
        local g=parentLoaded;collapsed[g.name]=collapsed[old];if old~=g.name then collapsed[old]=nil end;selectParent(g.id);parentMessage:SetText("Renamed. All children updated.")
    end),parentPanel,12,765)
    left(btn(parentPanel,"Discard",86,28,function() if parentLoaded then refreshParent() end end),parentPanel,140,765)
    parentEnabled:SetScript("OnClick",function() if parentLoaded and guard() then BR:SetSectionEnabled(parentLoaded.id,not parentLoaded.enabled);refreshParent();refreshTree() end end)
    left(btn(parentPanel,"+ Add subcategory",160,28,addChild),parentPanel,12,194)
    left(btn(parentPanel,"Duplicate parent",145,28,function() if not parentLoaded or not guard() then return end;local g,e=BR:DuplicateSection(parentLoaded.id,uniqueParent((parentLoaded.name~="" and parentLoaded.name or "Ungrouped"):sub(1,65).." Copy"));if g then selectParent(g.id);say("Parent and all child rules duplicated.") else parentMessage:SetText(e) end end),parentPanel,180,194)
    left(btn(parentPanel,"Delete parent",135,28,function()
        if not parentLoaded or not guard() then return end
        local g=parentLoaded;if g.id=="ungrouped" then parentMessage:SetText("Ungrouped cannot be deleted.");return end
        local count=0;for _,c in ipairs(BR.db.categories) do if c.sectionID==g.id then count=count+1 end end
        if count>0 and (not deleteDest or deleteDest=="Choose destination") then parentMessage:SetText("Choose where to move the children first.");return end
        local key=g.id..":"..tostring(deleteDest);if pendingParentDelete~=key then pendingParentDelete=key;parentMessage:SetText("Press Delete parent again to confirm. Child rules are kept.");return end
        local dest=deleteDest==noParentLabel() and BR:EnsureSection("").id or (BR:FindSection(deleteDest) or {}).id
        local ok,e=BR:DeleteSection(g.id,dest);if ok then load(BR.db.categories[1] and BR.db.categories[1].id);say("Parent deleted. Child rules preserved.") else parentMessage:SetText(e) end
    end),parentPanel,12,548)
    left(btn(root,"Duplicate child",210,26,function() if not guard() or not current() then return end;if focusSection~=nil then say("Select a subcategory, or use Duplicate parent.",true);return end;local c,e=BR:NewCategory(current());if c then c.name=uniqueChild((c.name.." Copy"):sub(1,70),c.section);BR:Apply();collapsed[c.section]=nil;load(c.id);say("Subcategory duplicated.") else say(e,true) end end),root,0,785)
    left(btn(root,"Expand all",102,26,function() for _,g in ipairs(BR:SectionGroups()) do collapsed[g.section]=nil end;refreshTree() end),root,0,755)
    left(btn(root,"Collapse all",102,26,function() for _,g in ipairs(BR:SectionGroups()) do collapsed[g.section]=true end;refreshTree() end),root,108,755)
    local function step(delta)
        if not moveAllowed() then return end
        local ok,err
        if focusSection~=nil then local key=focusSection;ok,err=BR:StepSection(key,delta);finishMove(ok,err,"section",key)
        elseif current() then ok,err=BR:Move(selected,delta);finishMove(ok,err,"category",selected) end
        if not ok and not err then say("Already at the edge of its section or list.") end
    end
    left(btn(root,"Move up",102,26,function() step(-1) end),root,0,666)
    left(btn(root,"Move down",102,26,function() step(1) end),root,108,666)
    local confirmID
    left(btn(root,"Delete category",210,26,function() if not guard() or not current() then return end;if focusSection~=nil then say("Select an individual category before deleting.",true);return end;if confirmID~=selected then confirmID=selected;say("Press Delete category again to confirm.",true);return end;BR:Delete(selected);confirmID=nil;load(BR.db.categories[1] and BR.db.categories[1].id);say("Category deleted.") end),root,0,698)
    load(BR:Get(selectedID) and selectedID or BR.db.categories[1] and BR.db.categories[1].id)
    if not current() and BR.db.sections[1] then selectParent(BR.db.sections[1].id) end
    root.Reload=function() if focusSection~=nil and parentLoaded==BR:GetSection(parentLoaded and parentLoaded.id) then refreshTree();return end;if focusSection~=nil or loaded~=current() or not current() then load(BR:Get(selectedID) and selectedID or BR.db.categories[1] and BR.db.categories[1].id);if not current() and BR.db.sections[1] then selectParent(BR.db.sections[1].id) end else refreshTree();queuePreview() end end
    root:SetScript("OnShow",function() ensureTheme();queuePreview() end)
    root:SetScript("OnHide",cancelDrag)
    -- Only preview when options are visible; do not touch the bag renderer.
    root:RegisterEvent("BAG_UPDATE_DELAYED");root:RegisterEvent("PLAYER_REGEN_ENABLED");root:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    root:SetScript("OnEvent",function() if not previewRunning and (not root.IsVisible or root:IsVisible()) then queuePreview() end end)
    return root,900
end
local function buildGeneral(parent,y)
    local root=frame(parent); stretch(root,parent,24,-y+8,24,488)
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
    local explain=label(root,"Virtual View is independent but bags-only. Native virtual categories also support host bank/offline layouts, after built-in categories. If the View API is missing, the native adapter is used as fallback. Section overview combines items by parent section; category names only keeps separate categories. Nested sections use an experimental standalone runtime adapter on compatible stock EUI in Grid or Compact mode. It falls back to flat paths if unsupported, in combat, during cursor/selection work, or in List mode. Rules never sell, move or destroy items.",nil,dim); stretch(explain,root,0,334,0,95); explain:SetWordWrap(true)
    left(btn(root,"Refresh / check API",180,28,function() BR:Apply(); status:SetText(statusText()) end),root,0,441)
    root.Reload=function() for key,b in pairs(toggles) do b:State(BR.db[key]) end; layout:SetValue(layoutNames[BR.db.sectionLayout] or layoutNames.hierarchy); status:SetText(statusText()) end
    return root,496
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
        if pending~=s then
            local plan,report=BR:PrepareImport(s)
            if not plan then pending=nil; status:SetText("Import rejected: "..tostring(report)); return end
            pending=s
            local count=#report.warnings
            status:SetText(string.format("Preview: %d categories | %d sections | %d manual IDs | %d warnings.\nPress Import again to replace your existing categories. Choose a bag display mode in General; runtime nesting is experimental. Full warnings printed to chat.",report.categories,report.sections,report.manual,count))
            for _,w in ipairs(report.warnings) do BR:Print(w:gsub("|","/")) end
            return
        end
        local ok,e=BR:Import(s); pending=nil
        status:SetText(ok and string.format("Imported %d categories. Reopen Categories to edit. Previous configuration backed up.",e.categories) or tostring(e))
        if ok then selectedID=nil end
    end),root,100,383)
    left(btn(root,"Restore backup",132,28,function() if not BR.db.backup then status:SetText("No import backup yet."); return end; box:SetText(BR.db.backup); pending=nil; status:SetText("Backup loaded. Press Import twice to restore it.") end),root,200,383)
    return root,578
end
local pages={Categories=buildCategories,General=buildGeneral,["Import / Export"]=buildShare}
local roots={}
local function buildPage(page,parent,y)
    if EllesmereUI.IsSearchPrebuild and EllesmereUI.IsSearchPrebuild() then return 0 end
    -- EUI provides the real header, sidebar, scrolling and overall styling.
    -- Custom controls are drawn only on the frame handed to this plugin.
    ensureTheme()
    local W=EllesmereUI.Widgets
    if W and W.SectionHeader then local _,h=W:SectionHeader(parent,"BAGRULES",y); y=y-(h or 0) end
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
        for i,p in ipairs({"Categories","General","Import / Export"}) do local page=p; left(btn(fallback,page,144,26,function() showPage(page) end),fallback,24+(i-1)*152,49) end
        showPage("Categories")
    end
    ensureTheme();fallback:Show()
end
function BR:RegisterOptions()
    if self.optionsAttempted then return end; self.optionsAttempted=true
    if EllesmereUI and type(EllesmereUI.RegisterPlugin)=="function" then
        local ok,result=pcall(EllesmereUI.RegisterPlugin,ADDON,{label="BagRules",modules={{key="Rules",title="Category Manager",description="Organise inventory categories and build visual rules.",pages={"Categories","General","Import / Export"},searchPrebuild=false,buildPage=buildPage,onPageCacheRestore=function(page) ensureTheme();if roots[page] and roots[page].Reload then roots[page].Reload() end end}}})
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
