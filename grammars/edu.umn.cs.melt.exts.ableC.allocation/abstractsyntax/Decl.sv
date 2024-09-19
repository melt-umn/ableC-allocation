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
    | [] -> [errFromOrigin(top, "Heap allocation requires include of <alloca.h>")]
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
top::Decl ::= n::Name
{
  top.pp = pp"allocate_using arena ${n};";
  propagate env;

  local localErrors::[Message] =
    case lookupValue("arena_malloc", top.env), n.valueLookupCheck, n.valueItem.typerep of
    | [], _, _ -> [errFromOrigin(top, "Arena allocation requires include of <arena.h>")]
    | _ , [], pointerType(_, extType(_, refIdExtType(structSEU(), just("arena"), _))) -> []
    | _, [], t -> [errFromOrigin(n, s"Expected arena to have type arena_t (got ${show(80, t)}")]
    | _, errs, _ -> errs
    end;
  forwards to allocDecl(localErrors, arenaAllocContext(^n));
}

production allocDecl
top::Decl ::= errs::[Message] ac::AllocContext
{
  forwards to
    decls(
      consDecl(
        defsDecl([allocContextDef(ac)]),
        if null(errs) then nilDecl() else consDecl(warnDecl(errs), nilDecl())));
}
