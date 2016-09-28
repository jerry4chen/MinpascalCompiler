%{
#include "lex.yy.c"
#include "node.h"
#include <stdio.h>

#define check(s) {printf("\tyacc_check: %s\n", s);}
%}

%token ARRAY ELSE END FUNCTION IF 
%token NOT OF PBEGIN
%token PROCEDURE PROGRAM THEN VAR
%token WHILE DO IDENTIFIER ASSIGNMENT CHARACTER_STRING COLON COMMA
%token DOT DOTDOT EQUAL GE GT LBRAC LE LPAREN LT MINUS
%token NOTEQUAL PLUS RBRAC REALNUMBER RPAREN SEMICOLON SLASH STAR
%token STARSTAR INTEGER REAL STRING NUM
%union 
{
    struct nodeType *node;
    int number;
    char *string;
}
/* left */
%left NOT
%left GE LT LE GT EQ NE
%left PLUS MINUS
%left STAR SLASH
%nonassoc UMINUS                 // uni minus

%start program                  //start from non-terminal: program

%%
program : program_heading SEMICOLON 
    declarations
    procedure_and_function_declaration_part
    compound_statement
    DOT
    ;

program_heading : PROGRAM IDENTIFIER
    |   PROGRAM IDENTIFIER LPAREN identifier_list RPAREN
    ;

identifier_list :  identifier_list COMMA IDENTIFIER
    |   IDENTIFIER
    ;

declarations : declarations VAR identifier_list COLON type SEMICOLON
    |
    ;

type : standard_type
    |   ARRAY LBRAC NUM DOTDOT NUM RBRAC OF type
    ;

standard_type : INTEGER
    |   REAL
    |   STRING
    ;

procedure_and_function_declaration_part : 
    procedure_and_function_declaration_part subprogram_declaration SEMICOLON
    |
    ;

subprogram_declaration :
    subprogram_head
    declarations
    compound_statement {check("subprogram");}
    ;

subprogram_head : FUNCTION IDENTIFIER arguments COLON standard_type SEMICOLON {check("subprogram_head");}
    | {check("subprogram_head2");} PROCEDURE IDENTIFIER arguments SEMICOLON {check("subprogram_head2 end");}
    ;

arguments : LPAREN {check("arguments");} parameter_list RPAREN {check("argumentsend");}
    |  
    ;

parameter_list : optional_var identifier_list COLON type {check("paramlist1");}
    | optional_var identifier_list COLON type SEMICOLON parameter_list {check("paramlist2");}
    ;

optional_var : VAR 
    |
    ;

/*statement and expressions goes*/

compound_statement : PBEGIN optional_statements END ;

optional_statements : statement_list
    |
    ;

statement_list : statement
    |   statement_list SEMICOLON statement
    ;

statement : variable ASSIGNMENT expression
    | procedure_statement
    | compound_statement
    | IF expression THEN statement ELSE statement
    | WHILE expression DO statement
    |
    ;

variable : IDENTIFIER tail ;

tail : LBRAC expression RBRAC tail 
    |
    ;

procedure_statement : IDENTIFIER
    | IDENTIFIER LPAREN expression_list RPAREN
    ;

expression_list : expression
    | expression_list COMMA expression
    ;

expression : simple_expression
    | simple_expression relop simple_expression
    ;

simple_expression : term
    | simple_expression addop term
    ;

term : factor
    | term mulop factor
    ;

factor : IDENTIFIER tail
    | IDENTIFIER LPAREN expression_list RPAREN
    | NUM
    | MINUS NUM %prec UMINUS
    | LPAREN expression RPAREN
    | NOT factor
    ;

addop : PLUS | MINUS ;
mulop : STAR | SLASH ;
relop : LT | GT | EQUAL | LE | GE | NOTEQUAL ;

%%

int main() {
    yyparse();
    printf("********************************\n"
           "*       No syntax error!       *\n"
           "********************************\n");
    //printTree(ASTRoot, 0);
    //SymbolTable.size = 0;
    //semanticCheck(ASTRoot);
    printf("********************************\n"
           "*      No semantic error!      *\n"
           "********************************\n");
    return 0;
}                                                                     



