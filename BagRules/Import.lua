-- Original, bounded data-only decoder and translator. No executable input.
local _, BR = ...
local I={}; BR.Baganator=I
local MAX=800000
local function fail(s) error(s,0) end
local function trim(s) return (s:match('^%s*(.-)%s*$')) end
local function decode64(s)
    s=s:gsub('%s',''); if #s%4~=0 or #s>MAX then fail('Invalid Base64 length') end
    local chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local map={}; for i=1,#chars do map[chars:sub(i,i)]=i-1 end
    local out={}
    for i=1,#s,4 do
        local a,b,c,d=s:sub(i,i),s:sub(i+1,i+1),s:sub(i+2,i+2),s:sub(i+3,i+3)
        local x,y,z,w=map[a],map[b],map[c],map[d]
        if x==nil or y==nil or (z==nil and c~='=') or (w==nil and d~='=') or (c=='=' and d~='=') or ((c=='=' or d=='=') and i+3~=#s) then fail('Invalid Base64 alphabet or padding') end
        out[#out+1]=string.char(x*4+math.floor(y/16))
        if z then out[#out+1]=string.char(y%16*16+math.floor(z/4)) end
        if w then out[#out+1]=string.char(z%4*64+w) end
    end
    return table.concat(out)
end
-- RFC 1951 raw DEFLATE reader, bounded output; independent of client encoding APIs.
local function inflate(s)
    local p,buf,bits=1,0,0
    local function read(n)
        while bits<n do local b=s:byte(p); if not b then fail('Truncated DEFLATE stream') end; p=p+1; buf=buf+b*2^bits; bits=bits+8 end
        local k=2^n; local v=buf%k; buf=math.floor(buf/k); bits=bits-n; return v
    end
    local function tree(lengths)
        local count,nextCode,m={}, {}, {}; local max=0
        for _,l in ipairs(lengths) do if l>15 then fail('Invalid Huffman length') end; if l>0 then count[l]=(count[l] or 0)+1; max=math.max(max,l) end end
        local code=0
        for n=1,max do code=(code+(count[n-1] or 0))*2; nextCode[n]=code; if code+(count[n] or 0)>2^n then fail('Oversubscribed Huffman tree') end; m[n]={} end
        for i,l in ipairs(lengths) do if l>0 then local v=nextCode[l]; nextCode[l]=v+1; m[l][v]=i-1 end end
        return {m=m,max=max}
    end
    local function symbol(t)
        local c=0; for n=1,t.max do c=c*2+read(1); local v=t.m[n][c]; if v~=nil then return v end end; fail('Invalid Huffman symbol')
    end
    local lenBase={3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258}
    local lenExtra={0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0}
    local distBase={1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577}
    local distExtra={0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13}
    local out={}; local function emit(b) if #out>=MAX then fail('Decompressed profile too large') end; out[#out+1]=b end
    local final=0
    repeat
        final=read(1); local typ=read(2)
        if typ==0 then
            read(bits%8); local n,k=read(16),read(16); if n+k~=65535 then fail('Invalid stored block') end
            for _=1,n do emit(string.char(read(8))) end
        elseif typ==1 or typ==2 then
            local lt,dt
            if typ==1 then
                local a,b={},{}; for i=0,287 do a[i+1]=i<=143 and 8 or i<=255 and 9 or i<=279 and 7 or 8 end; for i=1,32 do b[i]=5 end; lt,dt=tree(a),tree(b)
            else
                local nl,nd,nc=read(5)+257,read(5)+1,read(4)+4
                if nl>286 then fail('Invalid literal tree length') end
                local order={16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15}; local cl={}; for i=1,19 do cl[i]=0 end
                for i=1,nc do cl[order[i]+1]=read(3) end
                local ct=tree(cl); local a={}
                while #a<nl+nd do
                    local v=symbol(ct); local n=1
                    if v==16 then if #a==0 then fail('Invalid repeated code') end; v,n=a[#a],read(2)+3
                    elseif v==17 then v,n=0,read(3)+3 elseif v==18 then v,n=0,read(7)+11 end
                    if #a+n>nl+nd then fail('Too many code lengths') end
                    for _=1,n do a[#a+1]=v end
                end
                if a[257]==0 then fail('Missing end-of-block code') end
                local l,d={},{}; for i=1,nl do l[i]=a[i] end; for i=1,nd do d[i]=a[nl+i] end; lt,dt=tree(l),tree(d)
            end
            while true do
                local v=symbol(lt)
                if v<256 then emit(string.char(v)) elseif v==256 then break else
                    local j=v-256; if not lenBase[j] then fail('Invalid length code') end
                    local n=lenBase[j]+read(lenExtra[j]); local d=symbol(dt)+1; if not distBase[d] then fail('Invalid distance code') end
                    local off=distBase[d]+read(distExtra[d]); if off>#out then fail('Out-of-range back-reference') end
                    for _=1,n do emit(out[#out-off+1]) end
                end
            end
        else fail('Reserved DEFLATE block type') end
    until final==1
    if p<=#s then fail('Trailing compressed data') end
    return table.concat(out)
end
local NULL={}
-- CBOR subset for category bundles: definite-length maps/arrays, strings, integers, booleans, null.
local function cbor(s)
    local p,nodes=1,0
    local function take(n) if n<0 or n>#s-p+1 then fail('Truncated CBOR data') end; local v=s:sub(p,p+n-1); p=p+n; return v end
    local function uint(n) local v=0; for i=1,n do v=v*256+take(1):byte() end; if v>9007199254740991 then fail('CBOR integer too large') end; return v end
    local function val(depth)
        nodes=nodes+1; if nodes>30000 or depth>40 then fail('CBOR complexity limit') end
        local h=uint(1); local typ,n=math.floor(h/32),h%32
        if n>=24 and n<=27 then n=uint(2^(n-24)) elseif n>=28 then fail('Unsupported CBOR length') end
        if typ==0 then return n elseif typ==1 then return -1-n elseif typ==2 or typ==3 then return take(n) end
        if typ==4 or typ==5 then
            if n>10000 then fail('CBOR collection limit') end; local t={}
            for i=1,n do
                if typ==4 then t[i]=val(depth+1) else
                    local k=val(depth+1); if type(k)~='string' and type(k)~='number' then fail('Unsupported CBOR key') end; k=tostring(k); if t[k]~=nil then fail('Duplicate CBOR key') end; t[k]=val(depth+1)
                end
            end; return t
        end
        if typ==7 then if h==244 then return false elseif h==245 then return true elseif h==246 then return NULL end end
        fail('Unsupported CBOR value')
    end
    local t=val(0); if p~=#s+1 then fail('Trailing CBOR data') end; return t
end
local function utf8(n)
    if n<128 then return string.char(n) elseif n<2048 then return string.char(192+math.floor(n/64),128+n%64) elseif n<65536 then return string.char(224+math.floor(n/4096),128+math.floor(n/64)%64,128+n%64) elseif n<=1114111 then return string.char(240+math.floor(n/262144),128+math.floor(n/4096)%64,128+math.floor(n/64)%64,128+n%64) end; fail('Invalid Unicode')
end
local function json(s)
    local p,nodes=1,0
    local function ws() local _,j=s:find('^%s*',p); p=(j or p-1)+1 end
    local function str()
        if s:sub(p,p)~='"' then fail('Expected JSON string') end; p=p+1; local a={}
        while p<=#s do
            local c=s:sub(p,p); p=p+1; if c=='"' then return table.concat(a) end
            if c=='\\' then
                c=s:sub(p,p); p=p+1
                if c=='u' then
                    local function hex() local h=s:sub(p,p+3); if not h:match('^%x%x%x%x$') then fail('Invalid Unicode escape') end; p=p+4; return tonumber(h,16) end
                    local n=hex(); if n>=55296 and n<=56319 then if s:sub(p,p+1)~='\\u' then fail('Missing low surrogate') end; p=p+2; local lo=hex(); if lo<56320 or lo>57343 then fail('Invalid surrogate') end; n=65536+(n-55296)*1024+lo-56320 elseif n>=56320 and n<=57343 then fail('Unexpected low surrogate') end; c=utf8(n)
                else c=({['"']='"',['\\']='\\',['/']='/',b='\b',f='\f',n='\n',r='\r',t='\t'})[c]; if not c then fail('Invalid JSON escape') end end
            elseif c:byte()<32 then fail('Unescaped JSON control character') end; a[#a+1]=c
        end; fail('Unterminated JSON string')
    end
    local function val(depth)
        nodes=nodes+1; if nodes>30000 or depth>40 then fail('JSON complexity limit') end; ws(); local c=s:sub(p,p)
        if c=='"' then return str() end
        if c=='{' or c=='[' then
            local obj=c=='{'; local stop=obj and '}' or ']'; local t={}; p=p+1; ws(); if s:sub(p,p)==stop then p=p+1; return t end
            while true do
                ws(); if obj then local k=str(); ws(); if s:sub(p,p)~=':' then fail('Expected colon') end; p=p+1; if t[k]~=nil then fail('Duplicate JSON key') end; t[k]=val(depth+1) else t[#t+1]=val(depth+1) end
                ws(); c=s:sub(p,p); p=p+1; if c==stop then return t elseif c~=',' then fail('Expected comma or closing bracket') end
            end
        end
        for _,v in ipairs({'true','false','null'}) do if s:sub(p,p+#v-1)==v then p=p+#v; if v=='true' then return true elseif v=='false' then return false else return NULL end end end
        local n=s:sub(p):match('^%-?%d+%.?%d*[eE]?[%+%-]?%d*'); local num=n and tonumber(n); if not num or num~=num or math.abs(num)==math.huge then fail('Invalid JSON value at '..p) end; p=p+#n; return num
    end
    local v=val(0); ws(); if p<=#s then fail('Trailing JSON data') end; return v
end
function I.Decode(s)
    local ok,result=pcall(function()
        if type(s)~='string' or #s>MAX then fail('Import too large') end; s=trim(s)
        if s:sub(1,6)=='BGR!1!' then local raw=inflate(decode64(s:sub(7))); if raw:sub(1,1)=='{' then return json(raw) end; return cbor(raw)
        elseif s:sub(1,1)=='{' then return json(s) end; fail('Expected BGR!1! string or Baganator JSON')
    end); if ok then return result end; return nil,tostring(result)
end
-- Translate search atoms independently; keep unsupported data unknown under negation.
local class7=function(n) return '(class = 7 & subclass = '..n..')' end
local maps={
 key='class = 13',quest='quest',miscellaneous='class = 15',reagent='(class = 5 | class = 7 | craftingreagent)',
 set='itemset',['equipment set']='unknown',consumable='consumable',boe='(boe & unbound)',junk='junk',weapon='weapon',armor='armor',armour='armor',
 trinket='slot = "INVTYPE_TRINKET"',finger='slot = "INVTYPE_FINGER"',neck='slot = "INVTYPE_NECK"',potion='(class = 0 & subclass = 1)',
 food='(class = 0 & subclass = 5)',drink='(class = 0 & subclass = 5)',recipe='recipe',cloth=class7(5),tailoring=class7(5),
 cooking=class7(8),fish='(name ~ "fish" | name ~ "fisch")',fishing='(class = 2 & subclass = 20)',elemental=class7(10),enchanting=class7(12),
 herb=class7(9),alchemy=class7(9),leather=class7(6),leatherworking=class7(6),ore=class7(7),metal=class7(7),stone=class7(7),parts=class7(1),mining=class7(7),
 mount='(class = 15 & subclass = 5)',['battle pet']='(class = 17 | (class = 15 & subclass = 2))',open='openable',tabard='slot = "INVTYPE_TABARD"',shirt='slot = "INVTYPE_BODY"'
}
local approx={quest=true,reagent=true,set=true,['equipment set']=true,boe=true,junk=true,food=true,drink=true,tailoring=true,cooking=true,fish=true,fishing=true,enchanting=true,alchemy=true,leatherworking=true,ore=true,stone=true,mining=true,mount=true,['battle pet']=true,open=true}
local qualities={poor=true,common=true,uncommon=true,rare=true,epic=true,legendary=true}
function I.Translate(s)
    if type(s)~='string' or #s>4096 then return nil,'Unsupported search length' end
    local warnings,seen={},{}; local function warn(w) if not seen[w] then seen[w]=true; warnings[#warnings+1]=w end end
    if trim(s)=='' then return 'never',warnings end
    local out,p={},1
    while p<=#s do
        local ch=s:sub(p,p)
        if ch:match('[&|!()]') then out[#out+1]=ch; p=p+1
        else
            local j=s:find('[&|!()]',p) or (#s+1); local atom=trim(s:sub(p,j-1)); p=j
            if atom~='' then
                local low=atom:lower()
                if low:sub(1,1)=='#' then
                    local k=trim(low:sub(2)); local v=maps[k]
                    if not v then warn('Unsupported #'..k); v='unknown' elseif approx[k] then warn('Approximate #'..k) end
                    out[#out+1]='('..v..')'
                elseif qualities[low] then out[#out+1]='(quality = '..low..')'
                elseif low:find('[<>~=]') then warn('Unsupported comparison '..atom); out[#out+1]='unknown'
                else out[#out+1]='(name ~ '..BR.Rules.Quote(atom)..')' end
            end
        end
    end
    local expr=table.concat(out,' '); local ast,err=BR.Rules.Compile(expr); if not ast then return nil,err end; return expr,warnings
end
local function name(s) if type(s)~='string' or #s>80 or trim(s)=='' or s:find('[%c|]') then fail('Invalid category or section name') end; return trim(s) end
local function validID(v) return type(v)=='number' and v>0 and v%1==0 and v<=2147483647 end
function I.Plan(s)
    local data,err=I.Decode(s); if not data then return nil,err end
    local ok,out,report=pcall(function()
        if type(data)~='table' or data.addon~='Baganator' or (data.version~=1 and data.version~=2) or type(data.categories)~='table' or #data.categories>100 then fail('Unsupported Baganator schema or category count') end
        local cats,mods,byID,hidden={}, {}, {}, {}; local warnings={}; local manualCount=0
        for _,m in ipairs(data.modifications or {}) do if type(m.source)~='string' or mods[m.source] then fail('Invalid or duplicate modification source') end; mods[m.source]=m end
        for _,id in ipairs(data.hidden or {}) do hidden[id]=true end
        if next(hidden) then warnings[#warnings+1]='Hidden categories imported as disabled; host hiding semantics may differ' end
        for _,c in ipairs(data.categories) do
            if type(c.source)~='string' or byID[c.source] then fail('Invalid or duplicate category source') end
            local m=mods[c.source] or {}; local p=m.priority or 0; if type(p)~='number' or p%1~=0 or math.abs(p)>10000 then fail('Invalid priority') end
            local expr,w=I.Translate(c.search or ''); if not expr then fail(c.name..': '..w) end
            local items={}; local seen={}; for _,id in ipairs(m.items or {}) do if not validID(id) then fail('Invalid manual item ID') end; if not seen[id] then items[#items+1]=id; seen[id]=true; manualCount=manualCount+1 end end
            if #items>1000 then fail('Too many manual item IDs') end
            local cat={name=name(c.name),expr=expr,priority=p,manual=items,sourceSearch=c.search or '',source=c.source,enabled=not hidden[c.source],icon=134400,section='',warning=table.concat(w,', ')}
            byID[c.source]=cat; cats[#cats+1]=cat
            if #w>0 then warnings[#warnings+1]=cat.name..': '..cat.warning end
        end
        local list,used,section,sections,skipped={}, {}, '',{},{}
        for _,id in ipairs(data.order or {}) do
            if type(id)~='string' then fail('Invalid display order') end
            if id=='__end' then section=''
            elseif id:match('^_%d+$') then local k=id:sub(2); local d=(data.sections or {})[k]; section=d and name(d.name) or ''; if section~='' then sections[section]=true end
            elseif byID[id] then if used[id] then fail('Duplicate display order category') end; local c=byID[id]; c.section=section; list[#list+1]=c; used[id]=true
            else skipped[#skipped+1]=id end
        end
        for _,c in ipairs(cats) do if not used[c.source] then list[#list+1]=c end end
        local count=0; for _ in pairs(sections) do count=count+1 end
        if #list==0 then fail('No custom categories in import') end
        if #skipped>0 then warnings[#warnings+1]='Host-managed or unsupported layout entries: '..table.concat(skipped,', ') end
        return list,{categories=#list,sections=count,manual=manualCount,warnings=warnings}
    end)
    if ok then return out,report end; return nil,tostring(out)
end
