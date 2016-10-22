#include "node.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define help(s) {printf("\thelp: %s\n",s);}
struct SymTable SymbolTable;

struct SymTableEntry* findSymbol(char *s) {
    for(int i=0; i<SymbolTable.size; i++) {
        if(strcmp(s, SymbolTable.entries[i].name) == 0) {
            return &SymbolTable.entries[i];
        }
    }

    return 0;
}

struct SymTableEntry* addVariable(char *s, enum StdType type, struct nodeType* link) {
    printf("s:%s, Type:%d\n",s, type);
    if(findSymbol(s) != 0) {
        printf("Error: duplicate declaration of variable %s\n", s);
        exit(0);
    }

    int index = SymbolTable.size;
    SymbolTable.size++;

    strcpy(SymbolTable.entries[index].name, s);
    SymbolTable.entries[index].type = type;
    SymbolTable.entries[index].link = link;
    
    return &SymbolTable.entries[index];
}

struct nodeType* nthChild(int n, struct nodeType *node) {
    struct nodeType *child = node->child;
    for(int i=1; i<n; i++) {
        child = child->rsibling;
    }
    return child;
}

void semanticCheck(struct nodeType *node) {
    printf("nodetype:%d\n", node->nodeType);
    switch(node->nodeType) {

        // Declaration part, add to symbol table.
        case NODE_VAR_DECL: {
            // TODO loop inside the rsibling of NODE_VAR_DECL.

            struct nodeType *typeNode = nthChild(1, node);
            enum StdType valueType;
            
            do{
              
              switch(typeNode->nodeType){
              case NODE_TYPE_INT:
                valueType = TypeInt;
                break;
              case NODE_TYPE_REAL:
                valueType = TypeReal;
                break;
              case NODE_TYPE_ARRAY:
                valueType = TypeArray;
                break;
              }

              struct nodeType *idList = nthChild(1, typeNode);
              struct nodeType *idNode = idList->child;
              if(valueType == TypeArray){
                // TODO array . extract the start end from node.
                while(idList->nodeType != NODE_LIST){
                  idList = idList->rsibling;
                }
                idNode = idList->child;

                
              }

              do {
                addVariable(idNode->string, valueType, typeNode);
                idNode = idNode->rsibling;
              } while(idNode != idList->child);

              typeNode = typeNode -> rsibling;

            }while(typeNode != node->child);
            return;
        }

        /* This case is simplified, actually you should check
           the symbol is a variable or a function with no parameter */
        case NODE_ARR_REF:
          printf("ARR_REF: lefttype:%d, righttype:%d\n",
                  node->child->nodeType, node->child->rsibling->nodeType);
          return;
        case NODE_VAR_OR_PROC: 
        case NODE_SYM_REF: {
            struct SymTableEntry *entry = findSymbol(node->string);
            if(entry == 0) {
                printf("Error: undeclared variable %s\n", node->string);
                exit(0);
            }

            node->entry = entry;
            node->valueType = entry->type;

            return;
        }
        
        case NODE_TYPE_ARRAY: {
            node->valueType = TypeArray;
            return;
        }
        case NODE_INT: {
            node->valueType = TypeInt;
            return;
        }

        case NODE_REAL: {
            node->valueType = TypeReal;
            return;
        }

        /* Only implemented binary op here, you should implement unary op */
        case NODE_OP:

        /* You should check the LHS of assign stmt is assignable
           You should also report error if LHS is a function with no parameter 
           (function is not implemented in this sample, you should implement it) */ 
        case NODE_ASSIGN_STMT: {
            struct nodeType *child1 = nthChild(1, node);
            struct nodeType *child2 = nthChild(2, node);
            semanticCheck(child1);
            semanticCheck(child2);

            /* We only implement the checking for integer and real types
               you should implement the checking for array type by yourself */
            if(child1->valueType != child2->valueType) {
                if(node->nodeType == NODE_OP)
                    printf("Error: type mismatch for operator\n");
                else
                    printf("Error: type mismatch for assignment\n");
                exit(0);
            }

            node->valueType = child1->valueType;

            return;
        }
    }

    /* Default action for other nodes not listed in the switch-case */
    struct nodeType *child = node->child;
    if(child != 0) {
        do {
            semanticCheck(child);
            child = child->rsibling;
        } while(child != node->child);
    }
}

