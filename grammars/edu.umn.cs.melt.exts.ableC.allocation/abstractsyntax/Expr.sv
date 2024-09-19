grammar edu:umn:cs:melt:exts:ableC:allocation:abstractsyntax;

production allocExpr
top::Expr ::= size::Expr
{
  top.pp = pp"allocate(${size})";

  forwards to head(top.env.allocContext).alloc(size);
}

production reallocExpr
top::Expr ::= ptr::Expr size::Expr
{
  top.pp = pp"reallocate(${size})";

  forwards to head(top.env.allocContext).realloc(ptr, size);
}

production deallocExpr
top::Expr ::= ptr::Expr
{
  top.pp = pp"deallocate(${ptr})";

  forwards to head(top.env.allocContext).dealloc(ptr);
}
