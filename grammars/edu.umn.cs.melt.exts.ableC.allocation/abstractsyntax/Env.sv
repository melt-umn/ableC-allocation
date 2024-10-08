grammar edu:umn:cs:melt:exts:ableC:allocation:abstractsyntax;

synthesized attribute alloc::Alloc;
synthesized attribute realloc::Realloc;
synthesized attribute dealloc::Dealloc;

closed data nonterminal AllocContext with alloc, realloc, dealloc;

production stackAllocContext
top::AllocContext ::=
{
  top.alloc = alloca;
  top.realloc = stackRealloc;
  top.dealloc = unsupportedDealloc("stack");
}

production heapAllocContext
top::AllocContext ::=
{
  top.alloc = malloc;
  top.realloc = realloc;
  top.dealloc = free;
}

production gcAllocContext
top::AllocContext ::=
{
  top.alloc = gcMalloc;
  top.realloc = gcRealloc;
  top.dealloc = unsupportedDealloc("Boehm GC");
}

production arenaAllocContext
top::AllocContext ::= a::Name
{
  top.alloc = arenaMalloc(^a);
  top.realloc = arenaRealloc(^a);
  top.dealloc = unsupportedDealloc("arena");
}

production unspecifiedAllocContext
top::AllocContext ::=
{
  top.alloc = unspecifiedAlloc;
  top.realloc = unspecifiedRealloc;
  top.dealloc = unspecifiedDealloc;
}


synthesized attribute allocContext::[AllocContext] occurs on Env;
synthesized attribute allocContextContribs::Maybe<AllocContext> occurs on Defs, Def;

aspect production emptyEnv
top::Env ::=
{
  top.allocContext = [unspecifiedAllocContext()];
}
aspect production addDefsEnv
top::Env ::= d::Defs  e::Env
{
  top.allocContext = fromMaybe(head(e.allocContext), d.allocContextContribs) :: tail(e.allocContext);
}
aspect production openScopeEnv
top::Env ::= e::Env
{
  top.allocContext = head(e.allocContext) :: e.allocContext;
}
aspect production globalEnv
top::Env ::= e::Env
{
  top.allocContext = [last(e.allocContext)];
}
aspect production nonGlobalEnv
top::Env ::= e::Env
{
  top.allocContext = init(e.allocContext);
}
aspect production functionEnv
top::Env ::= e::Env
{
  top.allocContext =
    case e.allocContext of
    | [ac] -> [ac]
    | acs -> [last(init(acs))]
    end;
}

aspect production nilDefs
top::Defs ::=
{
  top.allocContextContribs = empty;
}
aspect production consDefs
top::Defs ::= h::Def  t::Defs
{
  top.allocContextContribs = alt(h.allocContextContribs, t.allocContextContribs);
}

aspect default production
top::Def ::=
{
  top.allocContextContribs = empty;
}

abstract production allocContextDef
top::Def ::= a::AllocContext
{
  top.allocContextContribs = just(a);
}

fun allocErrors [Message] ::= env::Env =
  case env.allocContext of
  | unspecifiedAllocContext() :: _ -> [errFromOrigin(ambientOrigin(), "An allocator to use must be specfied (e.g. `allocate_using heap;`)")]
  | _ -> []
  end;

fun reallocErrors [Message] ::= env::Env =
  case env.allocContext of
  | unspecifiedAllocContext() :: _ -> [errFromOrigin(ambientOrigin(), "An allocator supporting reallocation must be specfied (e.g. `allocate_using heap;`)")]
  | _ -> []
  end;

fun deallocErrors [Message] ::= env::Env =
  case env.allocContext of
  | unspecifiedAllocContext() :: _ -> [errFromOrigin(ambientOrigin(), "An allocator supporting deallocation must be specfied (e.g. `allocate_using heap;`)")]
  | _ -> []
  end;
