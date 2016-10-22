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
goal :  program {
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
        deleteNode($2);
    }
    
    |   IDENTIFIER
    {
        $$ = newNode(NODE_LIST);
        printf("%s\n",$1->string);
        addChild($$, $1);
        
    }
    ;

declarations : declarations VAR identifier_list COLON type SEMICOLON 
    {
        //$$ = $4;
        //addChild($$, $2);
        //addChild($$, $6);
        //deleteNode($1); 
        //deleteNode($3); 
        //deleteNode($5); 

        $$ = $1;
        addChild($5, $3);
        addChild($$, $5);
        deleteNode($2); 
        deleteNode($4); 
        deleteNode($6); 
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
        $$->nodeType = NODE_TYPE_ARRAY;
        $$->idxstart = $3->iValue;
        $$->idxend = $5-> iValue;

        //$3->nodeType = NODE_INT;
        //$5->nodeType = NODE_INT;
        //addChild($$,$3);
        //addChild($$,$5);
        addChild($$,$8);
        deleteNode($3);
        deleteNode($5);
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
    $$ = $1;
    addChild($$, $2);
    deleteNode($3);
}
    |
{
    $$ = newNode(NODE_PROC_AND_FUNC_DECL);
}
    ;

subprogram_declaration :
    subprogram_head
    declarations
    compound_statement 
    {
        $$ = $1;
    }
    ;

subprogram_head : FUNCTION IDENTIFIER arguments COLON standard_type SEMICOLON 
{
    $$ = newNode(NODE_FUNC);
    addChild($$, $2);
    addChild($$, $5);
    addChild($2, $3);
    deleteNode($1);
    deleteNode($4);
    deleteNode($6);
    // TODO
    // add to symboltable
}
    | PROCEDURE IDENTIFIER arguments SEMICOLON 
    {
        $$ = newNode(NODE_PROC);
        addChild($$, $2);
        addChild($2, $3);
        deleteNode($1);
        deleteNode($4);
        // TODO
        // add to symboltable
    }
    ;

arguments : LPAREN parameter_list RPAREN 
{
    $$ = $2;
    deleteNode($1);
    deleteNode($3);
}
    |
{
    $$ = newNode(NODE_EMPTY);
}
    ;

parameter_list : optional_var identifier_list COLON type 
{
    $$ = newNode(NODE_PLIST);
    addChild($$, $2);
    addChild($$, $4);
    deleteNode($1);
    deleteNode($3);
}
    | optional_var identifier_list COLON type SEMICOLON parameter_list 
{
    $$ = $6;
    addChild($$, $2);
    addChild($$, $4);
    deleteNode($1);
    deleteNode($3);
    deleteNode($5);
}
    ;

optional_var : VAR 
{
    $$ = $1;
}
    |
{
    $$ = newNode(NODE_EMPTY);
}
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
    $$ = $1;
}
    |
{
    $$ = newNode(NODE_EMPTY);
}
    ;

statement_list : statement
{
    $$ = newNode(NODE_LIST);
    addChild($$, $1);
    
}
    |   statement_list SEMICOLON statement
{
    addChild($1, $3);
    $$ = $1;
}
    ;

statement : variable ASSIGNMENT expression
{
    $$ = newNode(NODE_ASSIGN_STMT);
    addChild($$, $1);
    addChild($$, $3);
    if($1->nodeType != NODE_ARR_REF)
        $1->nodeType = NODE_SYM_REF;
    deleteNode($2); 
}
    | procedure_statement
{
    $$ = $1;
}
    | compound_statement
{
    $$ = $1;
}
    | IF expression THEN statement ELSE statement
{
    $$ = newNode(NODE_IFSTMT);
    addChild($$, $2);
    addChild($$, $4);
    addChild($$, $6);
    deleteNode($1);
    deleteNode($3);
    deleteNode($5);
}
    | WHILE expression DO statement
{
    $$ = newNode(NODE_WHILE);
    addChild($$, $2);
    addChild($$, $4);
    deleteNode($1);
    deleteNode($3);
}
    |
{
    $$ = newNode(NODE_EMPTY);
}
    ;

variable : IDENTIFIER tail
{
    if($2->nodeType == NODE_TAIL)
        {$$ = $1;       
        deleteNode($2);}
    else{
        $$=$2;
        //TODO FIXME replace NODE_TAIL with $1

        
        struct nodeType* treetail = $2->child;
        struct nodeType* rhs;

        while(treetail->nodeType!=NODE_TAIL)
           //while(idNode != idList->child);
            treetail = treetail->child;
        printf("treetail.\n");
        
        
        treetail->tokenType = $1->tokenType;
        treetail->nodeType = $1->nodeType;
        treetail->string = (char*)malloc(strlen($1->string)+1);
        strcpy(treetail->string, $1->string);

        //strcpy(treetail->string, $1->string);
        
        //addChild($$,$1);
    }
        
    
}
    ;
tail : tail LBRAC simple_expression RBRAC 
{
    $$ = newNode(NODE_ARR_REF);
    addChild($$, $1);
    addChild($$, $3);
    deleteNode($2);
    deleteNode($4);

}
    |
{
    $$ = newNode(NODE_TAIL);
}
    ;

procedure_statement : IDENTIFIER
{
    //deleteNode($1);
    $$ = $1;
    $$->nodeType = NODE_VAR_OR_PROC;
}
    | IDENTIFIER LPAREN expression_list RPAREN
{
    $$ = $1;
    $$ -> nodeType = NODE_CALLPROC;
    addChild($$, $3);
    deleteNode($2);
    deleteNode($4);
}
    ;

expression_list : expression
{
    $$ = newNode(NODE_LIST);
    addChild($$, $1);
}
    | expression_list COMMA expression
{
    $$ = $1;
    addChild($$, $3);
    deleteNode($2);
}
    ;

expression : simple_expression
{
    $$=$1;
}
    | simple_expression relop simple_expression
{
    $$ = $2;
    addChild($$, $1);
    addChild($$, $3);
}
    ;

simple_expression : term
{
    $$ = $1;
}
    | simple_expression addop term
{
    $$ = $2;
    addChild($$, $1);
    addChild($$, $3);
}
    ;

term : factor
{
    $$ = $1;
}
    | term mulop factor
{
    $$ = newNode(NODE_OP);
    $$->op = $2->op;
    addChild($$, $1);
    addChild($$, $3);
}
    ;

factor : IDENTIFIER tail
{
    $$ = $1;
    addChild($$, $2);
}
    | IDENTIFIER LPAREN expression_list RPAREN
{
    $$ = $1;
    addChild($$, $3);
    deleteNode($2);
    deleteNode($4);
}
    | REALNUMBER
{
    $$ = $1;
    $$->nodeType = NODE_REAL;

}
    | MINUS REALNUMBER %prec UMINUS
{   
    $$ = $2;
    $$->nodeType = NODE_REAL;
    $$->rValue = -($$->rValue);
    deleteNode($1);
}
    | NUM
{
    $$ = $1; 
    $$->nodeType = NODE_INT;
}
    | MINUS NUM %prec UMINUS
{
    $$ = $2;
    $$->iValue = -($$->iValue);
    $$->nodeType = NODE_INT;
    deleteNode($1);
}
    | LPAREN expression RPAREN
{
    $$ = $2;
    deleteNode($1);
    deleteNode($3);
}
    | NOT factor
{
    $$ = newNode(NODE_ERROR);
}
    ;

addop : PLUS 
{
    $$ = newOpNode(OP_ADD);
    deleteNode($1);
}
| MINUS 
{
    $$ = newOpNode(OP_SUB);
    deleteNode($1);
}
;
mulop : STAR 
{
    $$ = newOpNode(OP_MUL);
    deleteNode($1);
}
| SLASH 
{
    $$ = newOpNode(OP_DIV);
    deleteNode($1);
}
;
relop : LT 
{
    $$ = newOpNode(OP_LT);
    deleteNode($1);
}
| GT 
{
    $$ = newOpNode(OP_GT);
    deleteNode($1);
}
| EQUAL 
{
    $$ = newOpNode(OP_EQ);
    deleteNode($1);
}
| LE 
{
    $$ = newOpNode(OP_LE);
    deleteNode($1);
}
| GE 
{
    $$ = newOpNode(OP_GE);
    deleteNode($1);
}
| NOTEQUAL 
{
    $$ = newOpNode(OP_NE);
    deleteNode($1);
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
    printf("********************************\n"
           "*       Start Semantic !       *\n"
           "********************************\n");
    SymbolTable.size = 0;
    semanticCheck(ASTRoot);
    printf("********************************\n"
           "*      No semantic error!      *\n"
           "********************************\n");
    return 0;
}                                                                     



