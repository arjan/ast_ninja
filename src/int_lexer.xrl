Definitions.

INT   = [0-9]
OP   = [+*-/]
WS  = ([\000-\s])

Rules.

{INT}  : {token, {value, list_to_integer(TokenChars)}}.
{OP}   : {token, {operator, list_to_atom(TokenChars)}}.
{WS}+  : skip_token.

Erlang code.
