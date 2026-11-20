-- Native metadata filters. No dependency on imported expression syntax.
local _,BR=...
local F={};BR.Filters=F
F.sets={"classes","qualities","slots","bindings","items"}
F.flags={"bound","quest","craftingreagent","openable","boe","unbound","itemset"}
F.ranges={"itemlevel","requiredlevel","count","vendor","ahprice"}
-- Independent subtype IDs retain the original predicate's missing-data semantics.
F.extraSets={subclassIDs="subclass",excludeClasses="class",excludeSubclassIDs="subclass",excludeQualities="quality",excludeSlots="slot",excludeBindings="bindtype",excludeItems="id"}
F.wordSets={"names","exactNames","excludeNames","excludeExactNames"}
local function isWordSet(k) for _,v in ipairs(F.wordSets) do if k==v then return true end end end
local function integer(v,max) return type(v)=="number" and v>=0 and v<=max and v%1==0 end
local function cleanSet(a,kind)
    if type(a)~="table" then return nil end
    local out,seen={},{}
    for k,v in pairs(a) do
        if not integer(k,1000) or k<1 then return nil end
        local ok=(kind=="slots" or kind=="excludeSlots") and type(v)=="string" and v:match("^INVTYPE_[A-Z0-9_]+$") and #v<=48 or kind~="slots" and kind~="excludeSlots" and integer(v,(kind=="items" or kind=="excludeItems") and 2147483647 or (kind=="qualities" or kind=="excludeQualities") and 7 or 255)
        if not ok or (kind=="items" or kind=="excludeItems") and v==0 then return nil end
        if not seen[v] then out[#out+1]=v;seen[v]=true end
    end
    table.sort(out);return out
end
local function validateFlat(f)
    if type(f)~="table" then return nil,"Invalid filters" end
    local out={};local allowed={classes=true,subclasses=true,qualities=true,slots=true,bindings=true,items=true,name=true,all=true}
    for k in pairs(F.extraSets) do allowed[k]=true end;for _,k in ipairs(F.wordSets) do allowed[k]=true end;for _,k in ipairs(F.flags) do allowed[k]=true end;for _,k in ipairs(F.ranges) do allowed[k.."Min"]=true;allowed[k.."Max"]=true end
    for k in pairs(f) do if not allowed[k] then return nil,"Unsupported filter: "..tostring(k) end end
    for _,k in ipairs(F.sets) do if f[k]~=nil then local a=cleanSet(f[k],k);if not a then return nil,"Invalid "..k end;if #a>0 then out[k]=a end end end
    for k in pairs(F.extraSets) do if f[k]~=nil then local a=cleanSet(f[k],k);if not a then return nil,"Invalid "..k end;if #a>0 then out[k]=a end end end
    for _,k in ipairs(F.wordSets) do if f[k]~=nil then
        if type(f[k])~="table" then return nil,"Invalid "..k end
        local a,seen={},{};for i,v in pairs(f[k]) do
            if not integer(i,256) or i<1 or type(v)~="string" or #v==0 or #v>200 then return nil,"Invalid keyword in "..k end
            v=v:lower();if not seen[v] then a[#a+1]=v;seen[v]=true end
        end;table.sort(a);if #a>0 then out[k]=a end
    end end
    if f.subclasses~=nil then
        if type(f.subclasses)~="table" then return nil,"Invalid item subtypes" end
        local a={};local seen={}
        for k,v in pairs(f.subclasses) do
            if not integer(k,1000) or k<1 or type(v)~="string" then return nil,"Invalid item subtype" end
            local c,s=v:match("^(%d+):(%d+)$");c,s=tonumber(c),tonumber(s)
            if not integer(c,255) or not integer(s,255) then return nil,"Invalid item subtype" end
            local key=c..":"..s;if not seen[key] then a[#a+1]=key;seen[key]=true end
        end
        table.sort(a);if #a>0 then out.subclasses=a end
    end
    for _,k in ipairs(F.flags) do if f[k]~=nil then if type(f[k])~="boolean" then return nil,"Invalid "..k end;out[k]=f[k] end end
    for _,k in ipairs(F.ranges) do
        for _,suffix in ipairs({"Min","Max"}) do local v=f[k..suffix];if v~=nil then if not integer(v,2147483647) then return nil,"Invalid "..k.." range" end;out[k..suffix]=v end end
        if out[k.."Min"] and out[k.."Max"] and out[k.."Min"]>out[k.."Max"] then return nil,"Minimum exceeds maximum for "..k end
    end
    if f.name~=nil then if type(f.name)~="string" or #f.name>200 then return nil,"Invalid name filter" end;local n=f.name:match("^%s*(.-)%s*$");if n~="" then out.name=n end end
    if f.all~=nil and type(f.all)~="boolean" then return nil,"Invalid match-all setting" end
    if f.all then out.all=true end
    return out
end
-- Alternatives are a bounded list of independent native filter methods.
-- No expression syntax or legacy evaluator is used at runtime.
function F.Validate(f)
    if type(f)=="table" and f.methods~=nil then
        for k in pairs(f) do if k~="methods" then return nil,"Methods cannot be mixed with top-level filters" end end
        if type(f.methods)~="table" or #f.methods<1 or #f.methods>128 then return nil,"Invalid filter methods (1–128)" end
        local a={};local count=0;for k in pairs(f.methods) do if not integer(k,#f.methods) or k<1 then return nil,"Invalid method index" end;count=count+1 end;if count~=#f.methods then return nil,"Sparse method list" end
        for i,m in ipairs(f.methods) do local v,e=validateFlat(m);if not v then return nil,"Method "..i..": "..e end;a[i]=v end
        if #a==1 then return a[1] end;return {methods=a}
    end
    return validateFlat(f)
end
local function has(a,v) for _,x in ipairs(a or {}) do if x==v then return true end end;return false end
F.Has=has
local function evalFlat(f,item)
    -- No selections means no automatic matches, unless explicitly opted in.
    local any,unknown=false,false
    local function check(v) any=true;if v==nil then unknown=true end;return v~=false end
    if f.classes or f.subclasses then
        local v
        if type(item.class)=="number" then
            if has(f.classes,item.class) then v=true
            elseif f.subclasses then
                if type(item.subclass)=="number" then v=has(f.subclasses,item.class..":"..item.subclass)
                else local prefix=item.class..":";local possible=false;for _,x in ipairs(f.subclasses) do if x:sub(1,#prefix)==prefix then possible=true end end;if not possible then v=false end end
            else v=false end
        end
        if not check(v) then return false end
    end
    for _,p in ipairs({{"qualities","quality"},{"slots","slot"},{"bindings","bindtype"},{"items","id"}}) do
        local a=f[p[1]];if a then local v=item[p[2]];if type(v)~=(p[1]=="slots" and "string" or "number") then check(nil) elseif not check(has(a,p[1]=="slots" and v:upper() or v)) then return false end end
    end
    for _,k in ipairs(F.flags) do if f[k]~=nil then local v=item[k];if type(v)~="boolean" then check(nil) elseif not check(v==f[k]) then return false end end end
    for _,k in ipairs(F.ranges) do if f[k.."Min"]~=nil or f[k.."Max"]~=nil then
        local v=item[k];if type(v)~="number" then check(nil) elseif not check((not f[k.."Min"] or v>=f[k.."Min"]) and (not f[k.."Max"] or v<=f[k.."Max"])) then return false end
    end end
    for k,field in pairs(F.extraSets) do if f[k] then
        local v=item[field];local ok
        if k=="excludeSlots" then if type(v)=="string" then ok=not has(f[k],v:upper()) end
        elseif type(v)=="number" then ok=has(f[k],v);if k~="subclassIDs" then ok=not ok end end
        if not check(ok) then return false end
    end end
    for _,k in ipairs(F.wordSets) do if f[k] then
        local v=item.name;local ok
        if type(v)=="string" then
            v=v:lower();local found=false;local exact=k=="exactNames" or k=="excludeExactNames"
            for _,w in ipairs(f[k]) do if (exact and v==w) or (not exact and v:find(w,1,true)) then found=true;break end end
            ok=found;if k=="excludeNames" or k=="excludeExactNames" then ok=not found end
        end
        if not check(ok) then return false end
    end end
    if f.name then if type(item.name)~="string" then check(nil) elseif not check(item.name:lower():find(f.name:lower(),1,true)~=nil) then return false end end
    if unknown then return nil end;return any or f.all==true
end
function F.Eval(f,item)
    if not f.methods then return evalFlat(f,item) end
    local unknown=false;for _,m in ipairs(f.methods) do local v=evalFlat(m,item);if v==true then return true elseif v==nil then unknown=true end end
    if unknown then return nil end;return false
end
function F.NeedsPrices(f)
    if not f then return false end
    if f.methods then for _,m in ipairs(f.methods) do if F.NeedsPrices(m) then return true end end;return false end
    return f.ahpriceMin~=nil or f.ahpriceMax~=nil
end
function F.Extended(f)
    if not f then return false end;if f.methods then return true end
    for k in pairs(f) do if F.extraSets[k] or isWordSet(k) or k=="boe" or k=="unbound" or k=="itemset" then return true end end;return false
end
local function hex(s) return (s:gsub(".",function(c)return string.format("%02X",c:byte())end)) end
local function unhex(s) if #s%2~=0 or s:find("[^%x]") then return nil end;return (s:gsub("%x%x",function(h)return string.char(tonumber(h,16))end)) end
-- deterministic, strict, data-only serialisation, outer profile layer escapes text.
function F.Encode(f)
    if f and f.methods then local a={};for _,m in ipairs(f.methods) do a[#a+1]=hex(F.Encode(m)) end;return "methods:"..table.concat(a,",") end
    local a={};for k,v in pairs(f or {}) do
        local x=type(v)=="table" and table.concat(v,",") or type(v)=="boolean" and (v and "true" or "false") or tostring(v)
        if isWordSet(k) and type(v)=="table" then local w={};for _,word in ipairs(v) do w[#w+1]=hex(word) end;x=table.concat(w,",") end
        x=x:gsub("([^%w_%.%-,: ])",function(c)return string.format("%%%02X",c:byte())end)
        a[#a+1]=k.."="..x
    end;table.sort(a);return table.concat(a,";")
end
function F.Decode(s)
    if type(s)~="string" or #s>240000 then return nil,"Invalid filter data" end
    if s:sub(1,8)=="methods:" then
        local a={};for x in (s:sub(9)..","):gmatch("([^,]*),") do
            if #a>=128 then return nil,"Too many methods" end
            local raw=unhex(x);if not raw or raw:sub(1,8)=="methods:" then return nil,"Invalid method data" end
            local v,e=F.Decode(raw);if not v then return nil,e end;a[#a+1]=v
        end;return F.Validate({methods=a})
    end
    local f={};for row in (s..";"):gmatch("([^;]*);") do
        if row~="" then local k,v=row:match("^(%a+)=(.*)$");if not k or f[k]~=nil then return nil,"Malformed filter record" end
            v=v:gsub("%%(%x%x)",function(h)return string.char(tonumber(h,16))end)
            if has(F.sets,k) or F.extraSets[k] or k=="subclasses" or isWordSet(k) then local a={};for x in (v..","):gmatch("([^,]*),") do if x=="" then return nil,"Invalid filter list" end;local parsed;if isWordSet(k) then parsed=unhex(x) elseif k=="slots" or k=="excludeSlots" or k=="subclasses" then parsed=x else parsed=tonumber(x) end;if parsed==nil then return nil,"Invalid filter value" end;a[#a+1]=parsed end;f[k]=a
            elseif k=="name" then f[k]=v
            elseif has(F.flags,k) or k=="all" then if v~="true" and v~="false" then return nil,"Invalid boolean" end;f[k]=v=="true"
            else f[k]=tonumber(v);if f[k]==nil then return nil,"Invalid filter number" end end
        end
    end;return F.Validate(f)
end
-- Discover classes using the client when exposed. Fallback is a small Classic
-- catalogue; unsupported/unverified subclass codes are not guessed.
local fallback={ [0]="Consumable",[1]="Container",[2]="Weapon",[4]="Armor",[5]="Reagent",[6]="Projectile",[7]="Trade Goods",[9]="Recipe",[11]="Quiver",[12]="Quest",[13]="Key",[15]="Miscellaneous" }
local fallbackSubs={ [7]={[0]="Trade Goods",[1]="Parts",[2]="Explosives",[3]="Devices",[5]="Cloth",[6]="Leather",[7]="Metal & Stone",[8]="Meat",[9]="Herb",[10]="Elemental",[12]="Enchanting"},[4]={[0]="Miscellaneous",[1]="Cloth",[2]="Leather",[3]="Mail",[4]="Plate",[6]="Shield"},[0]={[0]="Consumable",[1]="Potion",[2]="Elixir",[3]="Flask",[5]="Food & Drink",[7]="Bandage"}}
local function safe(fn,...) if type(fn)=="function" then local ok,v=pcall(fn,...);if ok and type(v)=="string" and v~="" then return v end end end
function F.Catalogue()
    local classFn=C_Item and C_Item.GetItemClassInfo or GetItemClassInfo
    local subFn=C_Item and C_Item.GetItemSubClassInfo or GetItemSubClassInfo
    local classNames={};for i=0,31 do classNames[i]=safe(classFn,i) end
    local usedFallback=next(classNames)==nil or not subFn
    if next(classNames)==nil then classNames=fallback end
    local a={};for i=0,31 do local name=classNames[i];if name then
        local c={id=i,name=name,subclasses={}};for j=0,63 do local sub=safe(subFn,i,j) or (not subFn and fallbackSubs[i] and fallbackSubs[i][j]);if sub then c.subclasses[#c.subclasses+1]={id=j,name=sub} end end;a[#a+1]=c
    end end;return a,usedFallback
end
function F.Suggestions(catalogue)
    local byID={};for _,c in ipairs(catalogue) do byID[c.id]=c end
    local icons={[0]=134829,[1]=133634,[2]=132624,[4]=132632,[5]=132996,[6]=132382,[7]=132996,[9]=134939,[11]=134409,[12]=134400,[13]=134237,[15]=133784}
    local subIcons={[5]=132889,[6]=134257,[7]=134566,[9]=134205,[10]=135138,[12]=135913}
    local a={};for _,group in ipairs({{name="Equipment",ids={2,4}},{name="Consumables",ids={0}},{name="Professions",ids={7,5,9}},{name="Utility",ids={1,6,11,13,15}},{name="Quest",ids={12}}}) do
        local g={name=group.name,children={}};for _,id in ipairs(group.ids) do local c=byID[id];if c then
            if (id==0 or id==7) and #c.subclasses>0 then for _,s in ipairs(c.subclasses) do g.children[#g.children+1]={name=s.name,filters={subclasses={id..":"..s.id}},icon=id==7 and subIcons[s.id] or icons[id]} end else g.children[#g.children+1]={name=c.name,filters={classes={id}},icon=icons[id]} end
        end end;if #g.children>0 then a[#a+1]=g end
    end;return a
end

-- Legacy migration. Push negations through the AST, distribute into a bounded
-- union of native methods, then combine equivalent dropdown selections.
-- This is a one-time transformation; evaluation never calls the legacy parser.
local positive={class="classes",subclass="subclassIDs",quality="qualities",slot="slots",bindtype="bindings",id="items"}
local negative={class="excludeClasses",subclass="excludeSubclassIDs",quality="excludeQualities",slot="excludeSlots",bindtype="excludeBindings",id="excludeItems"}
local unionable={classes=true,subclassIDs=true,qualities=true,slots=true,bindings=true,items=true,names=true,exactNames=true}
local function clone(t) local o={};for k,v in pairs(t) do o[k]=v end;return o end
local function union(a,b) local o={};for _,v in ipairs(a) do o[#o+1]=v end;for _,v in ipairs(b) do if not has(o,v) then o[#o+1]=v end end;table.sort(o);return o end
local function equalValue(k,a,b) return F.Encode({[k]=a})==F.Encode({[k]=b}) end
local function combine(a,b)
    local o=clone(a)
    for k,v in pairs(b) do
        local old=o[k]
        if old==nil then o[k]=v
        elseif not equalValue(k,old,v) then
            if k:sub(1,7)=="exclude" then o[k]=union(old,v)
            elseif unionable[k] and k~="names" then local x={};for _,n in ipairs(old) do if has(v,n) then x[#x+1]=n end end;if #x==0 then return nil,"Contradictory selections need a legacy rule" end;o[k]=x
            elseif k:sub(-3)=="Min" then o[k]=math.max(old,v)
            elseif k:sub(-3)=="Max" then o[k]=math.min(old,v)
            else return nil,"Multiple simultaneous conditions on "..k.." need a legacy rule" end
        end
    end
    return o
end
local function simplify(a)
    -- Merge alternative methods sharing every property except one inclusive list.
    local changed=true
    while changed do
        changed=false
        for i=1,#a do
            for j=i+1,#a do
                local x,y=a[i],a[j];local diff,count=nil,0
                for k,v in pairs(x) do if y[k]==nil or not equalValue(k,v,y[k]) then diff=k;count=count+1 end end
                for k in pairs(y) do if x[k]==nil then diff=k;count=count+1 end end
                local function subset(a,b)
                    for k,v in pairs(a) do if b[k]==nil or not equalValue(k,v,b[k]) then return false end end;return true
                end
                if subset(x,y) then table.remove(a,j);changed=true;break
                elseif subset(y,x) then table.remove(a,i);changed=true;break
                elseif count==0 or count==1 and unionable[diff] and x[diff] and y[diff] then
                    if count==1 then local z=clone(x);z[diff]=union(x[diff],y[diff]);a[i]=z end
                    table.remove(a,j);changed=true;break
                end
            end
            if changed then break end
        end
    end
    return a
end
function F.Translate(expr)
    local R=BR.Rules;local ast,err=R.Compile(expr);if not ast then return nil,err end
    local budget=0
    local function walk(node,neg,depth)
        budget=budget+1;if budget>2048 or depth>128 then return nil,"Rule too complex for automatic migration" end
        local tag=node.tag
        if tag=="not" then return walk(node.a,not neg,depth+1) end
        if tag=="all" or tag=="never" then if (tag=="all")~=neg then return {{}} else return {} end end
        if tag=="unknown" then return nil,"Contains an unsupported/unknown legacy condition" end
        if tag=="and" or tag=="or" then
            local a,e=walk(node.a,neg,depth+1);if not a then return nil,e end
            local b,f=walk(node.b,neg,depth+1);if not b then return nil,f end
            local out={}
            if (tag=="and")~=neg then
                if #a*#b>128 then return nil,"Too many alternative methods" end
                for _,x in ipairs(a) do for _,y in ipairs(b) do local z,why=combine(x,y);if not z then return nil,why end;out[#out+1]=z end end
            else for _,x in ipairs(a) do out[#out+1]=x end;for _,x in ipairs(b) do out[#out+1]=x end end
            if #out>128 then return nil,"Too many alternative methods" end;return simplify(out)
        end
        local k,op,v=node.field,node.op,node.value
        if neg then op=({["="]="!=",["!="]="=",["~"]="notcontains",[">="]="<",["<="]=">",[">"]="<=",["<"]=">="})[op] end
        local f={}
        if positive[k] and (op=="=" or op=="!=") then
            f[(op=="=" and positive or negative)[k]]={k=="slot" and v:upper() or v}
        elseif has(F.flags,k) and (op=="=" or op=="!=") then
            f[k]=v;if op=="!=" then f[k]=not v end
        elseif k=="name" and (op=="=" or op=="!=" or op=="~" or op=="notcontains") then
            f[({["="]="exactNames",["!="]="excludeExactNames",["~"]="names",notcontains="excludeNames"})[op]]={v}
        elseif has(F.ranges,k) and (op=="=" or op==">=" or op=="<=") then
            if op~="<=" then f[k.."Min"]=v end;if op~=">=" then f[k.."Max"]=v end
        else return nil,"Unsupported comparison: "..tostring(k).." "..tostring(op) end
        local valid,why=validateFlat(f);if not valid then return nil,why end
        return {valid}
    end
    local a,e=walk(ast,false,0);if not a then return nil,e end
    if #a==0 then return {} end
    for _,m in ipairs(a) do if next(m)==nil then return {all=true} end end
    local f,why=F.Validate({methods=a});if not f then return nil,why end
    if #F.Encode(f)>240000 then return nil,"Converted filter too large" end
    return f
end
