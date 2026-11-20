-- A data-only editor model on top of the existing parser. No rule evaluation changes.
local _,BR=...
local R=BR.Rules
local V={}; BR.VisualRules=V
V.presets={Cloth='tradegoods & subclass = 5',Herbs='tradegoods & subclass = 9',Leather='tradegoods & subclass = 6',['Ore & Stone']='tradegoods & subclass = 7',Weapons='weapon',Armour='armor',Consumables='consumable',['Quest items']='quest',Recipes='recipe',['Poor quality']='quality = poor',['Tradeable gear']='unbound & (weapon | armor)',['Crafting materials']='tradegoods | reagent'}
V.fields={
 {'name','Item name'}, {'type','Item type'}, {'subtype','Item subtype'}, {'quality','Item quality'},
 {'quest','Quest item'}, {'boe','Bind on equip'}, {'bound','Soulbound'}, {'unbound','Unbound'},
 {'craftingreagent','Crafting reagent'}, {'itemset','Equipment set'}, {'openable','Openable'},
 {'slot','Equipment slot'}, {'class','Item class ID'}, {'subclass','Item subclass ID'}, {'id','Item ID'},
 {'itemlevel','Item level'}, {'requiredlevel','Required level'}, {'bindtype','Binding type ID'},
 {'count','Stack count'}, {'vendor','Vendor value (copper or 2g)'}, {'ahprice','Auction price (copper or 2g)'}, {'ratio','Auction / vendor ratio'}, {'constant','Special match'}
}
V.names={}; V.keys={}; V.fieldLabels={}
for _,f in ipairs(V.fields) do V.names[f[1]]=f[2]; V.keys[f[2]]=f[1]; V.fieldLabels[#V.fieldLabels+1]=f[2] end
V.opNames={['=']='Is',['!=']='Is not',['~']='Contains',['>=']='At least',['<=']='At most',['>']='Greater than',['<']='Less than'}
V.opKeys={}; for k,v in pairs(V.opNames) do V.opKeys[v]=k end
V.quality={'Poor','Common','Uncommon','Rare','Epic','Legendary','Artifact','Heirloom'}
function V.Ops(field)
 local k=R.fields[field]; local a=(field=='constant' and {'='}) or (k=='text' and {'=','!=','~'}) or (k=='bool' and {'=','!='}) or {'=','!=','>=','<=','>','<'}
 local out={};for _,o in ipairs(a) do out[#out+1]=V.opNames[o] end;return out
end
function V.Choices(field)
 if field=='constant' then return {'Never','All','Unknown'} end
 if R.fields[field]=='bool' then return {'Yes','No'} end
 if field=='quality' then return V.quality end
 if field=='class' then return {'0 - Consumable','1 - Container','2 - Weapon','3 - Gem','4 - Armor','5 - Reagent','6 - Projectile','7 - Trade Goods','9 - Recipe','11 - Quiver','12 - Quest','13 - Key','15 - Miscellaneous'} end
 if field=='type' then return {'Trade Goods','Weapon','Armor','Consumable','Container','Recipe','Quest','Reagent','Miscellaneous','Projectile','Gem','Quiver','Item Enhancement','Other / enter text'} end
end
function V.Value(n)
 if n.field=='constant' then return tostring(n.value):gsub('^%l',string.upper) end
 if R.fields[n.field]=='bool' then return n.value and 'Yes' or 'No' end
 if n.field=='quality' then return V.quality[n.value+1] or tostring(n.value) end
 if n.field=='class' then for _,v in ipairs(V.Choices('class')) do if tonumber(v:match('^%d+'))==n.value then return v end end end
 return type(n.value)=='number' and string.format('%.17g',n.value):gsub('e%+','e') or tostring(n.value)
end
function V.Predicate(field,op,value)
 if field=='constant' then local t=tostring(value):lower();if t~='all' and t~='never' and t~='unknown' then return nil,'Choose a special match' end; return {kind='condition',field=field,op='=',value=t} end
 if field=='class' then value=tostring(value):match('^(%d+)%s+%-') or value end
 local k=R.fields[field]; if k=='bool' then if value=='Yes' then value='true' elseif value=='No' then value='false' end end
 local expr,e=R.Condition(field,op,tostring(value)); if not expr then return nil,e end
 local a=R.Compile(expr); return {kind='condition',field=a.field,op=a.op,value=a.value}
end
-- Associative flattening is valid even with three-valued logic. Negation remains explicit.
function V.FromExpression(expr)
 local a,e=R.Compile(expr); if not a then return nil,e end
 local count=0
 local convert
 convert=function(x,depth)
  count=count+1; if count>100 or depth>16 then error('Rule is too large for visual mode; use Expression mode.',0) end
  if x.tag=='not' then local n=convert(x.a,depth+1);n.negated=not n.negated;return n end
  if x.tag=='and' or x.tag=='or' then
   local n={kind='group',mode=x.tag=='and' and 'ALL' or 'ANY',children={}}
   local function collect(t) if t.tag==x.tag then collect(t.a);collect(t.b) else n.children[#n.children+1]=convert(t,depth+1) end end
   collect(x); return n
  elseif x.tag=='pred' then return {kind='condition',field=x.field,op=x.op,value=x.value} end
  return {kind='condition',field='constant',op='=',value=x.tag}
 end
 local ok,n=pcall(convert,a,0); if not ok then return nil,n end
 if n.kind~='group' then n={kind='group',mode='ALL',children={n}} end
 return n
end
function V.Expression(root)
 local count=0
 local function emit(n,depth)
  count=count+1;if count>100 or depth>16 then error('Visual rule limit reached',0) end
  local s
  if n.kind=='group' then
   if #n.children==0 then error('Add a condition to every group',0) end
   local a={};for _,c in ipairs(n.children) do a[#a+1]=emit(c,depth+1) end
   s=#a==1 and a[1] or '('..table.concat(a,n.mode=='ALL' and ' & ' or ' | ')..')'
  elseif n.field=='constant' then s=n.value
  else
   local k=R.fields[n.field];local v=k=='text' and R.Quote(n.value) or type(n.value)=='number' and string.format('%.17g',n.value):gsub('e%+','e') or tostring(n.value)
   s=n.field..' '..n.op..' '..v
  end
  if n.negated then s='!('..s..')' end; return s
 end
 local ok,s=pcall(emit,root,0);if not ok then return nil,s end
 local ast,e=R.Compile(s);if not ast then return nil,e end;return s
end
function V.Rows(root)
 local out={};local function visit(n,parent,depth) out[#out+1]={node=n,parent=parent,depth=depth};if n.kind=='group' then for _,x in ipairs(n.children) do visit(x,n,depth+1) end end end
 if root then visit(root,nil,0) end;return out
end
function V.Describe(n)
 local neg=n.negated and 'NOT  ' or ''
 if n.kind=='group' then return neg..'Match '..n.mode..' ('..#n.children..')' end
 if n.field=='constant' then return neg..'Special: '..V.Value(n) end
 return neg..(V.names[n.field] or n.field)..' '..(V.opNames[n.op] or n.op)..' '..V.Value(n)
end
function V.Remove(parent,node) if not parent then return false end;for i,n in ipairs(parent.children) do if n==node then table.remove(parent.children,i);return true end end;return false end
