%{
// C declare.
#include <stdio.h>
#include "y.tab.h"
#include "node.h"
#define token(s) {printf("\ttoken:%d, %s\n",s, yytext); return(s);}

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

{I}{N}{T}{E}{G}{E}{R} {
    yylval.node = newTokenNode(INTEGER);
    yylval.node->valueType = TypeInt;
    token(INTEGER);
}

{R}{E}{A}{L} {
    yylval.node = newTokenNode(REAL);
    yylval.node->valueType = TypeReal;
    token(REAL);
}

{S}{T}{R}{I}{N}{G} {
    yylval.node = newTokenNode(STRING);
    token(STRING);
}

{F}{U}{N}{C}{T}{I}{O}{N} {
    yylval.node = newTokenNode(FUNCTION);
    token(FUNCTION);
}

{O}{F} {
    yylval.node = newTokenNode(OF);
    token(OF);
}

{N}{O}{T} {
    yylval.node = newTokenNode(NOT);
    token(NOT);
}

{A}{R}{R}{A}{Y} {
    yylval.node = newTokenNode(ARRAY);
    token(ARRAY);
}

{P}{R}{O}{G}{R}{A}{M} {
    yylval.node = newTokenNode(PROGRAM);
    token(PROGRAM);
}

{P}{R}{O}{C}{E}{D}{U}{R}{E} {
    yylval.node = newTokenNode(PROCEDURE);
    token(PROCEDURE);
}

{D}{O} {
    yylval.node = newTokenNode(DO);
    token(DO);
}

{W}{H}{I}{L}{E} {
    yylval.node = newTokenNode(WHILE);
    token(WHILE);
}

{B}{E}{G}{I}{N} {
    yylval.node = newTokenNode(PBEGIN);
    token(PBEGIN);
}

{E}{N}{D} {
    yylval.node = newTokenNode(END);
    token(END);
}

{I}{F} {  
    yylval.node = newTokenNode(IF);
    token(IF);
}

{T}{H}{E}{N}   {
    yylval.node = newTokenNode(THEN);
    token(THEN);
}

{E}{L}{S}{E}   {
    yylval.node = newTokenNode(ELSE);
    token(ELSE);
}

{V}{A}{R}   {
    yylval.node = newTokenNode(VAR);
    token(VAR);
}

[a-zA-Z]([a-zA-Z0-9])*  {
    yylval.node = newTokenNode(IDENTIFIER);
    yylval.node->string = (char*)malloc(yyleng+1);
    strcpy(yylval.node->string, yytext);
    token(IDENTIFIER);
}

"!="    {
    yylval.node = newTokenNode(NOTEQUAL);
    yylval.node->op = OP_NE;
    token(NOTEQUAL);
}

":="    {
    yylval.node = newTokenNode(ASSIGNMENT);
    token(ASSIGNMENT);
}

'({NQUOTE}|'')+'  {
    yylval.node = newTokenNode(CHARACTER_STRING);
    token(CHARACTER_STRING); 
}

":"    {
    yylval.node = newTokenNode(COLON);
    token(COLON);
}
","    {
    yylval.node = newTokenNode(COMMA);
    token(COMMA);
}
([0-9]+|([0-9]*)([eE][-+]?[0-9]+)?) {  
    // yylval.dval = atof(yytext);                                 
    yylval.node = newTokenNode(NUM);
    yylval.node->valueValid = VALUE_I_VALID;
    yylval.node->iValue = atoi(yytext);
    token(NUM);
}

[0-9]+"."[0-9]+   {
    yylval.node = newTokenNode(REAL);
    yylval.node->valueValid = VALUE_R_VALID;
    yylval.node->rValue = atof(yytext);
    token(REALNUMBER);
}

"."    {
    yylval.node = newTokenNode(DOT);
    token(DOT);
}

".."    {
    yylval.node = newTokenNode(DOTDOT);
    token(DOTDOT);
}

"="    {
    yylval.node = newTokenNode(EQUAL);
    yylval.node->op = OP_EQ;
    token(EQUAL);
}

">="    {
    yylval.node = newTokenNode(GE);
    yylval.node->op = OP_GE;
    token(GE);
}

">"    {
    yylval.node = newTokenNode(GT);
    yylval.node->op = OP_GT;
    token(GT);
}

"["    {
    yylval.node = newTokenNode(LBRAC);
    token(LBRAC);
}

"<="    {
    yylval.node = newTokenNode(LE);
    yylval.node->op = OP_LE;
    token(LE);
}

"("    {
    yylval.node = newTokenNode(LPAREN);
    token(LPAREN);
}

"<"    {
    yylval.node = newTokenNode(LT);
    yylval.node->op = OP_LT;
    token(LT);
}

"-"    {
    yylval.node = newTokenNode(MINUS);
    yylval.node->op = OP_SUB;
    token(MINUS);
}

"+"    {
    yylval.node = newTokenNode(PLUS);
    yylval.node->op = OP_ADD;
    token(PLUS);
}

"]"    {
    yylval.node = newTokenNode(RBRAC);
    token(RBRAC);
}
 
")"    {
    yylval.node = newTokenNode(RPAREN);
    token(RPAREN);
}

";"    {
    yylval.node = newTokenNode(SEMICOLON);
    token(SEMICOLON);
}

"/"    {
    yylval.node = newTokenNode(SLASH);
    yylval.node->op = OP_DIV;
    token(SLASH);
}

"*"    {
    yylval.node = newTokenNode(STAR);
    yylval.node->op = OP_MUL;
    token(STAR);
}

"//".*"\n"  {                           //string value
    printf("%d: %s", line_no++, yytext);
}

[\t\f]    ;
[ ] ;
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

