%{
#include "lex.yy.c"
#include "node.h"
#include <stdio.h>

#define check(s) {printf("\tyacc_check: %s\n", s);}

struct nodeType* newOpNode(int op);
extern struct nodeType* ASTRoot;

struct symtab{
    char var_name[256];
    char Type[10];
    int const;
    int val;
    int scope;
    char strval[256];
}   symtable[100];
    
%}
%union 
{
    struct nodeType *node;
    int number;
    char *string;
}

%token <node> ARRAY ELSE END FUNCTION IF 
%token <node> NOT OF PBEGIN
%token <node> PROCEDURE PROGRAM THEN VAR
%token <node> WHILE DO IDENTIFIER ASSIGNMENT CHARACTER_STRING COLON COMMA
%token <node> DOT DOTDOT EQUAL GE GT LBRAC LE LPAREN LT MINUS
%token <node> NOTEQUAL PLUS RBRAC REALNUMBER RPAREN SEMICOLON SLASH STAR
%token <node> STARSTAR INTEGER REAL STRING NUM

%type <node> goal program program_heading identifier_list declarations 
%type <node> type standard_type procedure_and_function_declaration_part
%type <node> subprogram_declaration subprogram_head arguments parameter_list
%type <node> optional_var compound_statement optional_statements statement_list
%type <node> statement variable tail expression procedure_statement 
%type <node> expression_list simple_expression term factor addop mulop relop

/* left */
%left NOT
%left GE LT LE GT EQ NE
%left PLUS MINUS
%left STAR SLASH
%nonassoc UMINUS                 // uni minus

%start goal

%%
goal : program {
        ASTRoot = $1;
}
    ;
program : program_heading SEMICOLON 
    declarations
    procedure_and_function_declaration_part
    compound_statement
    DOT {
            $$ = newNode(NODE_PROGRAM);
            addChild($$,$3);
            addChild($$,$4);
            addChild($$,$5);
            deleteNode($6);
        }
    ;

program_heading : PROGRAM IDENTIFIER
    {
        $$ = $2;
        //deleteNode($1);

    }
    |   PROGRAM IDENTIFIER LPAREN identifier_list RPAREN
    {
        $$ =$2;
        //deleteNode($1);
        //deleteNode($3);
        //deleteNode($5);
    }
;

identifier_list :  identifier_list COMMA IDENTIFIER
    {
        $$ = $1;
        addChild($$, $3);
        //deleteNode($2);
    }
    
    |   IDENTIFIER
    {
        $$ = newNode(NODE_LIST);
        addChild($$, $1);
        
    }
    ;

declarations : declarations VAR identifier_list COLON type SEMICOLON
    {
        $$ = $1;
        addChild($$, $3);
        addChild($$, $5);
    
    }
    |   
    {
        $$ = newNode(NODE_VAR_DECL);
    }
    ; 

type : standard_type
{
        $$ = $1;
}
    |   ARRAY LBRAC NUM DOTDOT NUM RBRAC OF type
{
        $$ = $1;
        addChild($$,$3);
        addChild($$,$5);
        addChild($$,$8);
        deleteNode($1);
        deleteNode($2);
        deleteNode($4);
        deleteNode($6);
        deleteNode($7);
}
    ;

standard_type : INTEGER
{
        $$ = $1;
        $$ -> nodeType = NODE_TYPE_INT;
}
    |   REAL
{
        $$ = $1;
        $$ ->nodeType = NODE_TYPE_REAL;
}
    |   STRING
{
        $$ = $1;
        $$ -> nodeType = NODE_TYPE_STRING;
}
    ;

procedure_and_function_declaration_part : 
    procedure_and_function_declaration_part subprogram_declaration SEMICOLON
{
        $$ = newNode(NODE_PROC_AND_FUNC_DECL);
        addChild($$, $1);
        addChild($$, $2);
        deleteNode($3);
}
    |
{
    $$ = newNode(NODE_EMPTY);
}
    ;

subprogram_declaration :
    subprogram_head
    declarations
    compound_statement 
    {
        $$ = newNode(NODE_VAR_OR_PROC);
    }
    ;

subprogram_head : FUNCTION IDENTIFIER arguments COLON standard_type SEMICOLON 
{
check("subprogram_head");
}
    | PROCEDURE IDENTIFIER arguments SEMICOLON 
    {
    check("subprogram_head2 end");
    }
    ;

arguments : LPAREN parameter_list RPAREN 
{
check("argumentsend");
}
    |  
    ;

parameter_list : optional_var identifier_list COLON type 
{
check("paramlist1");
}
    | optional_var identifier_list COLON type SEMICOLON parameter_list 
{
check("paramlist2");
}
    ;

optional_var : VAR 
{

    //deleteNode($1);
}
    |
    ;

/*statement and expressions goes*/

compound_statement : PBEGIN optional_statements END 
{
    $$ = newNode(NODE_CMP_STMT);
    addChild($$, $2);
    deleteNode($1);
    deleteNode($3);
}
;

optional_statements : statement_list
{
    $$ = newNode(NODE_CMP_STMT);
    printf("\topt stlist\n");
}
    |
{
    $$ = newNode(NODE_CMP_STMT);
    printf("\topt lamba\n");
}
    ;

statement_list : statement
{
    $$ = $1;
    printf("\tstlist stmt\n");
    
}
    |   statement_list SEMICOLON statement
{
    $$ = newNode(NODE_LIST);
    addChild($$, $1);
    addChild($$, $3);
    printf("\tstlist semicolon\n");
}
    ;

statement : variable ASSIGNMENT expression
{
    printf("\tstmt VAR ASSGINMENT\n");
    //deleteNode($2);

}
    | procedure_statement
{
    printf("\tstmt procedureSTMT\n");

}
    | compound_statement
{
    printf("\tstmt COMPSTMT\n");

}
    | IF expression THEN statement ELSE statement
{
    printf("\tstmt IFELSE\n");

}
    | WHILE expression DO statement
{

    printf("\tstmt VAR ASSGINMENT\n");
}
    |
{
    printf("\tstmt lambda\n");
    $$ = newNode(NODE_EMPTY);
}
    ;

variable : IDENTIFIER tail
{
    
}
    ;
tail : LBRAC expression RBRAC tail 
{
    //deleteNode($1);
    //deleteNode($3);

}
    |
    ;

procedure_statement : IDENTIFIER
{
    //deleteNode($1);

}
    | IDENTIFIER LPAREN expression_list RPAREN
{
    //deleteNode($1);
    //deleteNode($2);
    //deleteNode($4);

}
    ;

expression_list : expression
{

}
    | expression_list COMMA expression
{
    //deleteNode($2);

}
    ;

expression : simple_expression
{

    //deleteNode($1);
}
    | simple_expression relop simple_expression
{
    //deleteNode($1);
    //deleteNode($2);
    //deleteNode($3);

}
    ;

simple_expression : term
{
    $$ = newNode(NODE_EMPTY);

}
    | simple_expression addop term
{
    $$ = newNode(NODE_OP);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    ;

term : factor
{
    $$ = $1;
}
    | term mulop factor
{

}
    ;

factor : IDENTIFIER tail
{
    //deleteNode($1);
    $$ = newNode(NODE_VAR_OR_PROC);
}
    | IDENTIFIER LPAREN expression_list RPAREN
{
    //deleteNode($1);
    //deleteNode($2);
    //deleteNode($4);

}
    | NUM
{
    //deleteNode($1);

}
    | MINUS NUM %prec UMINUS
{
    //deleteNode($1);
    //deleteNode($2);

}
    | LPAREN expression RPAREN
{
    //deleteNode($1);
    //deleteNode($3);

}
    | NOT factor
{
    //deleteNode($1);
}
    ;

addop : PLUS 
{
    $$ = $1;

    //deleteNode($1);
}
| MINUS 
{
    $$ = $1;

    //deleteNode($1);
}
;
mulop : STAR 
{
    $$ = $1;
    //deleteNode($1);

}
| SLASH 
{
    $$ = $1;
    //deleteNode($1);

}
;
relop : LT 
{
    $$ = $1;
    //deleteNode($1);

}
| GT 
{
    $$ = $1;
    //deleteNode($1);

}
| EQUAL 
{
    $$ = $1;
    //deleteNode($1);

}
| LE 
{

    $$ = $1;
    //deleteNode($1);
}
| GE 
{
    $$ = $1;
    //deleteNode($1);

}
| NOTEQUAL 
{
    //deleteNode($1);
    $$ = $1;
}
;

%%
struct nodeType *ASTRoot;
int yyerror(const char *s) {
    printf("Syntax error\n");
    exit(0);
}

struct nodeType * newOpNode(int op) {
    struct nodeType *node = newNode(NODE_OP);
    node -> op = op;

    return node;
}

int main() {
    yyparse();
    printf("********************************\n"
           "*       No syntax error!       *\n"
           "********************************\n");
    printTree(ASTRoot, 0);
    //SymbolTable.size = 0;
    //semanticCheck(ASTRoot);
    printf("********************************\n"
           "*      No semantic error!      *\n"
           "********************************\n");
    return 0;
}                                                                     



