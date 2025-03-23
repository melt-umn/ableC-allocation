grammar edu:umn:cs:melt:exts:ableC:allocation:abstractsyntax;

production stackAllocDecl
top::Decl ::=
{
  top.pp = pp"allocate_using stack;";

  local localErrors::[Message] =
    case lookupValue("alloca", top.env) of
    | [] -> [errFromOrigin(top, "Stack allocation requires include of <alloca.h>")]
    | _ -> []
    end;
  forwards to allocDecl(localErrors, stackAllocContext());
}

production heapAllocDecl
top::Decl ::=
{
  top.pp = pp"allocate_using heap;";

  local localErrors::[Message] =
    case lookupValue("malloc", top.env) of
    | [] -> [errFromOrigin(top, "Heap allocation requires include of <stdlib.h>")]
    | _ -> []
    end;
  forwards to allocDecl(localErrors, heapAllocContext());
}

production gcAllocDecl
top::Decl ::=
{
  top.pp = pp"allocate_using gc;";

  local localErrors::[Message] =
    case lookupValue("GC_malloc", top.env) of
    | [] -> [errFromOrigin(top, "GC allocation requires include of <alloca.h>")]
    | _ -> []
    end;
  forwards to allocDecl(localErrors, gcAllocContext());
}

production arenaAllocDecl
top::Decl ::= a::Expr
{
  top.pp = pp"allocate_using arena ${a};";
  propagate env, controlStmtContext;

  local localErrors::[Message] =
    case lookupValue("arena_malloc", top.env), a.typerep of
    | [], _ -> [errFromOrigin(top, "Arena allocation requires include of <arena.h>")]
    | _, errorType() -> []
    | _, pointerType(_, extType(_, refIdExtType(structSEU(), just("arena"), _))) -> []
    | _, t -> [errFromOrigin(a, s"Expected arena to have type arena_t (got ${show(80, t)}")]
    end;
  forwards to allocDecl(localErrors, arenaAllocContext(^a));
}

production allocDecl
top::Decl ::= errs::[Message] ac::AllocContext
{
  forwards to
    if null(errs)
    then defsDecl([allocContextDef(ac)])
    else warnDecl(errs);
}
