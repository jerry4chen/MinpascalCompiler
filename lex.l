%{
// C declare.
#include <stdio.h>
#include "y.tab.h"
#include "node.h"
#define token(s) {printf("%s\n", yytext);return(s);}

int line_no = 1;
struct nodeType* newTokenNode(int tokenType);
%}

A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]
NQUOTE [^']

%%

{I}{N}{T}{E}{G}{E}{R} token(INTEGER);
{R}{E}{A}{L} token(REAL);
{S}{T}{R}{I}{N}{G} token(STRING);
{F}{U}{N}{C}{T}{I}{O}{N} token(FUNCTION);
{O}{F}    token(OF);
{N}{O}{T}   token(NOT);
{A}{R}{R}{A}{Y}   token(ARRAY);
{P}{R}{O}{G}{R}{A}{M}  token(PROGRAM);
{P}{R}{O}{C}{E}{D}{U}{R}{E} token(PROCEDURE);
{D}{O}    token(DO);
{W}{H}{I}{L}{E}   token(WHILE);
{B}{E}{G}{I}{N}   token(PBEGIN);
{E}{N}{D}   token(END);
{I}{F}    token(IF);
{T}{H}{E}{N}   token(THEN);
{E}{L}{S}{E}   token(ELSE);
{V}{A}{R}   token(VAR);
[a-zA-Z]([a-zA-Z0-9])*  token(IDENTIFIER);

"!="    token(NOTEQUAL);
":="    token(ASSIGNMENT);
'({NQUOTE}|'')+'  token(CHARACTER_STRING); //FIXME
":"    token(COLON);
","    token(COMMA);
([0-9]+|([0-9]*)([eE][-+]?[0-9]+)?) {          // yylval.dval = atof(yytext); 
                                    token(NUM);}
"."    token(DOT);
".."    token(DOTDOT);
"="    token(EQUAL);
">="    token(GE);
">"    token(GT);
"["    token(LBRAC);
"<="    token(LE);
"("    token(LPAREN);
"<"    token(LT);
"-"    token(MINUS);
"+"    token(PLUS);
"]"    token(RBRAC);
[0-9]+"."[0-9]+   token(REAL); //FIXME
")"    token(RPAREN);
";"    token(SEMICOLON);
"/"    token(SLASH);
"*"    token(STAR);
"//".*"\n"  {                           //string value
    printf("%d: %s", line_no++, yytext);
}
[ \t\f]    ;

\n    line_no++;


.    { fprintf (stderr,
        "'%c' (0%o): illegal charcter at line %d\n",
        yytext[0], yytext[0], line_no);
    }

%%
struct nodeType* newTokenNode(int tokenType) {
    struct nodeType *node = newNode(NODE_TOKEN);
    node->tokenType = tokenType;

    return node;
}
commenteof()
{
    fprintf(stderr, "unexpected EOF inside commment at line %d\n", line_no);
    exit (1);
}

yywrap(){
    token (1);
}

