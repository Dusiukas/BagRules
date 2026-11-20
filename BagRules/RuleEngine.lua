-- Original, data-only expression parser. Never executes user input as Lua.
local _, BR = ...
local R = {}; BR.Rules = R
local lower, tonumber = string.lower, tonumber
R.fields = {
    id="number", class="number", subclass="number", quality="quality",
    itemlevel="number", requiredlevel="number", bindtype="number", count="number",
    vendor="money", ahprice="money", ratio="number", name="text", type="text",
    subtype="text", slot="text", bound="bool", boe="bool", unbound="bool", quest="bool", craftingreagent="bool", itemset="bool", openable="bool"
}
R.fieldOrder = {"name","id","class","subclass","type","subtype","quality","itemlevel","requiredlevel","slot","bindtype","boe","bound","unbound","quest","count","vendor","ahprice","ratio"}
local qualityMap = {poor=0,junk=0,common=1,uncommon=2,rare=3,epic=4,legendary=5,artifact=6,heirloom=7}
local aliases = {weapon={"class",2},armor={"class",4},armour={"class",4},consumable={"class",0},container={"class",1},reagent={"class",5},tradegoods={"class",7},recipe={"class",9},questitem={"class",12},ammunition={"class",6},projectile={"class",6},junk={"quality",0}}
local function fail(s) error(s,0) end
local function tokenize(s)
    if type(s)~="string" or #s>8192 then fail("Rule must be text, at most 8192 bytes") end
    local a,i={},1
    while i<=#s do
        local c=s:sub(i,i)
        if c:match("%s") then i=i+1
        elseif c=='"' or c=="'" then
            local q=c; local value={}; i=i+1; local closed=false
            while i<=#s do
                c=s:sub(i,i); i=i+1
                if c==q then closed=true; break end
                if c=="\\" then
                    c=s:sub(i,i); i=i+1
                    if c~="\\" and c~=q then fail("Only quote and backslash escapes are supported") end
                end
                value[#value+1]=c
            end
            if not closed then fail("Unclosed quoted value") end
            a[#a+1]={kind="literal",v=table.concat(value)}
        else
            local pair=s:sub(i,i+1)
            if pair==">=" or pair=="<=" or pair=="!=" or pair=="~=" or pair=="==" or pair=="&&" or pair=="||" then
                a[#a+1]={kind="op",v=({["&&"]="&",["||"]="|",["=="]="=",["~="]="!="})[pair] or pair}; i=i+2
            elseif c:match("[&|!()=<>~]") then a[#a+1]={kind="op",v=c}; i=i+1
            else
                local value=s:sub(i):match("^[%w_%.%-]+")
                if not value then fail("Unexpected character at position "..i..": "..c) end
                a[#a+1]={kind="word",v=value}; i=i+#value
            end
        end
        if #a>2048 then fail("Too many tokens (maximum 2048)") end
    end
    a[#a+1]={kind="eof",v="<end>"}; return a
end
local function number(s,kind)
    local n=tonumber(s)
    if not n and kind=="money" then
        local v,u=s:match("^(%d+%.?%d*)([gsc])$")
        if v then n=tonumber(v)*({g=10000,s=100,c=1})[u] end
    elseif not n and kind=="quality" then n=qualityMap[lower(s)] end
    if not n or n~=n or n==math.huge or n==-math.huge or n<0 then fail("Invalid "..kind.." value: "..s) end
    if kind=="quality" and (n>7 or n%1~=0) then fail("Quality must be 0–7 or a quality name") end
    return n
end
local function parse(s)
    local tokens=tokenize(s); local p=1; local parseOr, parseAnd, parseUnary
    local function peek() return tokens[p] end
    local function take() local t=peek(); p=p+1; return t end
    local function accept(sym)
        local t=peek(); if t.kind~="literal" and lower(t.v)==sym then p=p+1; return true end
    end
    local function predicate()
        local t=take(); if t.kind~="word" then fail("Expected field or keyword, got "..t.v) end
        local field=lower(t.v)
        if aliases[field] then local a=aliases[field]; return {tag="pred",field=a[1],op="=",value=a[2]} end
        if field=="all" or field=="never" or field=="unknown" then return {tag=field} end
        local kind=R.fields[field]; if not kind then fail("Unknown field or keyword: "..field) end
        local op=peek().v
        if peek().kind=="op" and ({["="]=true,["!="]=true,[">="]=true,["<="]=true,[">"]=true,["<"]=true,["~"]=true})[op] then take()
        elseif kind=="bool" then return {tag="pred",field=field,op="=",value=true}
        else fail("Expected comparison after "..field) end
        local v=take(); if v.kind~="word" and v.kind~="literal" then fail("Expected value after "..field) end
        local value=v.v
        if kind=="text" then
            if op~="=" and op~="!=" and op~="~" then fail("Text supports =, != and ~ (contains)") end
            value=lower(value); if value=="" then fail("Empty text value") end
        elseif kind=="bool" then
            if op~="=" and op~="!=" then fail("Boolean supports = and !=") end
            value=lower(value); if value~="true" and value~="false" then fail("Use true or false") end
            value=value=="true"
        else
            if op=="~" then fail("Contains is for text fields only") end
            value=number(lower(value),kind)
        end
        return {tag="pred",field=field,op=op,value=value}
    end
    parseUnary=function(d)
        if d>24 then fail("Rule nesting exceeds 24") end
        if accept("!") or accept("not") then return {tag="not",a=parseUnary(d+1)} end
        if accept("(") then local a=parseOr(d+1); if not accept(")") then fail("Expected )") end; return a end
        return predicate()
    end
    parseAnd=function(d)
        local a=parseUnary(d); while accept("&") or accept("and") do a={tag="and",a=a,b=parseUnary(d)} end; return a
    end
    parseOr=function(d)
        local a=parseAnd(d); while accept("|") or accept("or") do a={tag="or",a=a,b=parseAnd(d)} end; return a
    end
    local ast=parseOr(0); if peek().kind~="eof" then fail("Unexpected token: "..peek().v) end
    return ast
end
function R.Compile(s) local ok,ast=pcall(parse,s); if ok then return ast end; return nil,tostring(ast) end
-- Three-valued logic: missing information must never become a match through NOT.
function R.Eval(a,item)
    if a.tag=="all" then return true elseif a.tag=="never" then return false elseif a.tag=="unknown" then return nil end
    if a.tag=="not" then local x=R.Eval(a.a,item); if x==nil then return nil end; return not x end
    if a.tag=="and" then
        local x=R.Eval(a.a,item); if x==false then return false end
        local y=R.Eval(a.b,item); if y==false then return false end
        if x==nil or y==nil then return nil end; return true
    end
    if a.tag=="or" then
        local x=R.Eval(a.a,item); if x==true then return true end
        local y=R.Eval(a.b,item); if y==true then return true end
        if x==nil or y==nil then return nil end; return false
    end
    local x,y,op=item[a.field],a.value,a.op
    if x==nil or type(x)~=type(y) then return nil end
    if type(x)=="string" then x=lower(x) end
    if op=="=" then return x==y elseif op=="!=" then return x~=y elseif op==">=" then return x>=y elseif op=="<=" then return x<=y elseif op==">" then return x>y elseif op=="<" then return x<y elseif op=="~" then return x:find(y,1,true)~=nil end
end
function R.Match(ast,item) return ast~=nil and R.Eval(ast,item)==true end
function R.Quote(s) return '"'..s:gsub('\\','\\\\'):gsub('"','\\"')..'"' end
function R.Condition(field,op,value)
    local kind=R.fields[field]; if not kind then return nil,"Unknown field" end
    local expr=field.." "..op.." "..(kind=="text" and R.Quote(value) or value)
    local ast,err=R.Compile(expr); if not ast then return nil,err end; if ast.tag~="pred" or ast.field~=field then return nil,"Enter a single condition value" end; return expr
end
