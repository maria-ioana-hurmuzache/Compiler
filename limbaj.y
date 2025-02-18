%{
#include <iostream>
#include <vector>
#include "SymTable.h"
#include "ASTNode.cpp"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yylex();
void yyerror(const char * s);
class SymTable* current; /*informatii identificatori*/
class SymTable* clasa; /*pentru cand caut symtable-ul clasei*/
vector<SymTable*> symtables;

class SymTable* lookup(string); 
int errorCount = 0;
%}

%union
{
     char* string;
     class ASTNode* tree;
     class ParamList* list;
     const char* assign;
}

%token  BGIN END ASSIGN
%token IF ELSE FOR WHILE CLASS PRINT TYPEOF BREAK RETURN
%token<string>ID TYPE ACCES CHAR STRING NR_INT NR_FLOAT T F
%type<tree> e b expr
%type<list> call_list
%type<assign> assignment

%start progr

%nonassoc IF ELSE
%left SAU
%left SI
%left EQ NEQ
%right '!'
%left LEQ GEQ '<' '>'
%left '+' '-' 
%left '*' '/'

%%
progr : classes declarations functions main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite!\n";}
      | classes declarations main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite!\n";}
      | classes functions main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite\n!";}
      | classes main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite!\n";}
      | declarations functions main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite!\n";}
      | declarations main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite!\n";}
      | functions main {if (errorCount == 0) cout<< "Programul este corect!" << endl; else cout<<"Programul nu este corect! Verifica erorile survenite!\n";}
      ;

declarations : var_decl           
	        | declarations var_decl    
	        ;

var_decl : TYPE ID ';' { 
                              if(!current->existsId($2))
                              {
                                    current->addVar($1,$2);
                              }
                              else
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Variabila %s a fost definita deja!", $2);
                                   yyerror(msg);
                              }
                       }
         | TYPE ID '[' NR_INT ']' ';' { 
                                             if(!current->existsId($2))
                                             {
                                                  current->addArray($1,$2,atoi($4));
                                             }
                                             else
                                             {
                                                  errorCount++;
                                                  char msg[256];
                                                  sprintf(msg, "Vectorul %s a fost definit deja!", $2);
                                                  yyerror(msg);
                                             }
                                      } 
         | TYPE ID ASSIGN expr ';' { 
                                     if(!current->existsId($2))
                                     {
                                          current->addVar($1,$2);
                                     }
                                     else
                                     {
                                          errorCount++;
                                          char msg[256];
                                          sprintf(msg, "Variabila %s a fost definita deja!", $2);
                                          yyerror(msg);
                                     }
                                     $4->typeASTNode();
                                     $4->evalASTNode();
                                     if($1==$4->getASTNodeType())
                                     {
                                        current->getVar($2)->val=$4->getASTNodeValoare();
                                     }
                                     else
                                     {
                                          errorCount++; 
                                          yyerror("Tipul expresiei din dreapta nu corespunde cu tipul variabilei!");
                                     }
                                }
         | TYPE ID '[' NR_INT ']' ASSIGN '{' call_list '}' ';' { 
                                                                      if(!current->existsId($2))
                                                                      {
                                                                           if($8->params.size()==atoi($4))
                                                                           {
                                                                                current->addArray($1,$2, atoi($4));
                                                                           }
                                                                           else
                                                                           {
                                                                                errorCount++;
                                                                                char msg[256];
                                                                                sprintf(msg, "Dimensiunea vectorului %s nu corespunde cu numarul sau de elemente!", $2);
                                                                                yyerror(msg);
                                                                           }
                                                                      }
                                                                      else
                                                                      {
                                                                           errorCount++;
                                                                           char msg[256];
                                                                           sprintf(msg, "Vectorul %s a fost definit deja!", $2);
                                                                           yyerror(msg);
                                                                      }
                                                               }
          | ID ID ';' {
                         if(current->existsId($1))
                         {
                              if(!((current->getVar($1))->type=="clasa"))
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "The class %s does not exist", $1);
                                   yyerror(msg);
                              }
                              else 
                              {
                                   if(!current->existsId($2))
                                   {    
                                        current->addObj($1, $2);
                                   }
                                   else
                                   {
                                        errorCount++;
                                        char msg[256];
                                        sprintf(msg, "The object %s already exists", $2);
                                        yyerror(msg);
                                   }
                              }
                         }
                      }
         ;

functions : functions function_decl
          | function_decl
          ;

function_decl : TYPE ID   { 
                              if(!current->existsId($2))
                              {
                                   current->addFunction($1,$2);
                                   SymTable* aux=new SymTable($2, current);
                                   symtables.push_back(aux);
                                   current=aux;
                              }
                              else
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Functia %s a fost definita deja!", $2);
                                   yyerror(msg);
                              }
                          }  '(' list_param ')' '{' list '}' {current->printVars(); current=current->getParent();}
              ;

returnare : RETURN expr ';' {
                                if(current->getName()!="IF" && current->getName()!="ELSE" && current->getName()!="FOR" && current->getName()!="WHILE") 
                                {
                                    IdInfo* funcInfo = current->getVar(current->getName());
                                    if(funcInfo->idType=="func")
                                    {
                                        $2->typeASTNode();
                                        $2->evalASTNode();
                                        if($2->getASTNodeType()!=funcInfo->type)
                                        { 
                                           errorCount++;
                                           char msg[256];
                                           sprintf(msg, "Tipul expresiei de return nu corespunde cu tipul functiei!");
                                           yyerror(msg);
                                        }
                                    } 
                                }
                            }
          | RETURN ';'
          ;

classes : classes class_decl
        | class_decl
        ; 

class_decl : CLASS ID '{' {
                              if (!current->existsId($2))
                              {
                                   current->addClass($2);
                                   SymTable* aux=new SymTable($2, current);
                                   symtables.push_back(aux);
                                   current=aux;
                              }
                              else
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Clasa %s a fost definita deja!", $2);
                                   yyerror(msg);
                              }
                          } class_b '}' ';' {current->printVars(); current=current->getParent();}

class_b : ACCES ':' class_block 
        | class_b ACCES ':' class_block

class_block : class_member
            | class_block class_member
            ;

class_member : var_decl
             | TYPE ID  {
                              if (!current->existsId($2))
                              {
                                   current->addFunction($1, $2);
                                   //(current->getParent())->getVar(current->getName())->params.addParam($1, $2);
                                   SymTable* aux=new SymTable($2, current);
                                   current=aux;
                              }
                              else
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Metoda %s a fost definita deja!", $2);
                                   yyerror(msg);
                              }
                         }  '(' list_param ')' '{' list '}' {current->printVars(); current=current->getParent();}
             ;

list_param : param
           | list_param ','  param
           |
           ;

param : TYPE ID { 
                    if(!current->existsId($2))
                    {
                         current->addVar($1,$2);
                         (current->getParent())->getVar(current->getName())->params.addParam($1, $2);
                    }
                    else
                    {
                         errorCount++;
                         char msg[256];
                         sprintf(msg, "Parametrul %s a fost adaugat deja!", $2);
                         yyerror(msg);
                    }
                } 
      | TYPE ID ASSIGN expr { 
                              if(!current->existsId($2))
                              {
                                   current->addVar($1,$2);
                                   (current->getParent())->getVar(current->getName())->params.addParam($1, $2);
                              }
                              else
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Parametru %s a fost adaugat deja!", $2);
                                   yyerror(msg);
                              }
                              $4->typeASTNode();
                              $4->evalASTNode();
                              if($1==$4->getASTNodeType())
                              {
                                   current->getVar($2)->val=$4->getASTNodeValoare();
                              }
                              else
                              {
                                   errorCount++; 
                                   yyerror("Tipul expresiei din dreapta nu corespunde cu tipul variabilei!");
                              }
                         }
      | ID ID {
                    if(symtables[0]->existsId($1))
                    {
                         if(!((symtables[0]->getVar($1))->type=="clasa"))
                         {
                              errorCount++;
                              char msg[256];
                              sprintf(msg, "Clasa %s nu a fost definita!", $1);
                              yyerror(msg);
                         }
                         else 
                         {
                              if(!current->existsId($2))
                              {    
                                   current->addObj($1, $2);
                                   (current->getParent())->getVar(current->getName())->params.addParam($1, $2);
                              }
                              else
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Obiectul %s a fost definit deja!", $2);
                                   yyerror(msg);
                              }
                         }
                    }
               }
      ; 

main : BGIN list END
     ;

list : list var_decl
     | list statement
     | statement
     | var_decl
     ;

assignment : ID ASSIGN expr {
                                   if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                                   {
                                        errorCount++;
                                        char msg[256];
                                        sprintf(msg, "Variabila %s nu a fost definita!", $1);
                                        yyerror(msg);
                                   }
                                   else
                                   {
                                        $3->typeASTNode();
                                        $3->evalASTNode();
                                        if(current->getVar($1)->type==$3->getASTNodeType())
                                        {
                                             if($3->getASTNodeValoare()!="unknown")
                                             {
                                                  current->getVar($1)->val=$3->getASTNodeValoare();
                                             }
                                             $$=(current->getVar($1))->type.c_str();
                                        }
                                        else
                                        {
                                             errorCount++; 
                                             yyerror("Tipul expresiei din dreapta nu corespunde cu tipul variabilei!");
                                        }
                                   }
                            }
           | ID '[' NR_INT ']' ASSIGN expr {
                                                  if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                                                  {
                                                       errorCount++;
                                                       char msg[256];
                                                       sprintf(msg, "Vectorul %s nu a fost definit!", $1);
                                                       yyerror(msg);
                                                  }
                                                  else
                                                  {
                                                       if(!((current->getVar($1))->idType=="array"))
                                                       {
                                                            errorCount++;
                                                            char msg[256];
                                                            sprintf(msg, "Identificatorul %s nu reprezinta un vector!", $1);
                                                            yyerror(msg);
                                                       }
                                                       else if (!((current->getVar($1))->dimensiune>atoi($3)))
                                                       {
                                                            errorCount++;
                                                            char msg[256];
                                                            sprintf(msg, "Dimensiunea vectorului %s este depasita!", $1);
                                                            yyerror(msg);
                                                       }
                                                       else
                                                       {
                                                            $6->typeASTNode();
                                                            if(current->getVar($1)->type!=$6->getASTNodeType())
                                                            {
                                                                 errorCount++; 
                                                                 yyerror("Tipul expresiei din dreapta nu corespunde cu tipul variabilei!");
                                                            }
                                                            else
                                                            {
                                                                 $$=$6->getASTNodeType().c_str();
                                                            }
                                                       }
                                                  }
                                           }
           | ID '.' ID ASSIGN expr {
                                       if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                                        {
                                             errorCount++;
                                             char msg[256];
                                             sprintf(msg, "Obiectul %s nu a fost definit!", $1);
                                             yyerror(msg);
                                        }
                                        else if(current->getVar($1)->idType!="object")
                                        {
                                             errorCount++;
                                             char msg[256];
                                             sprintf(msg, "Identificatorul %s nu reprezinta un obiect!", $1);
                                             yyerror(msg);
                                        }
                                        else
                                        {
                                             clasa=lookup(current->getVar($1)->type);
                                             if(clasa->existsId($3)==false)
                                             {
                                                  errorCount++;
                                                  char msg[256];
                                                  sprintf(msg, "Atributul %s nu exista!", $3);
                                                  yyerror(msg);
                                             }
                                             else
                                             {
                                                  char* v= (char*)malloc(strlen($1)+strlen($3)+2);
                                                  strcpy(v, $1);
                                                  strcat(v, ".");
                                                  strcat(v, $3);
                                                  
                                                  if((current->existsId(v)==false)&&(current->existsIdinParent(v)==false))
                                                  {
                                                       current->addVar(clasa->getVar($3)->type.c_str(), v);
                                                  }
                                                  
                                                  $5->typeASTNode();
                                                  $5->evalASTNode();
                                                  if(current->getVar(v)->type==$5->getASTNodeType())
                                                  {
                                                       if($5->getASTNodeValoare()!="unknown")
                                                       {
                                                            current->getVar(v)->val=$5->getASTNodeValoare();
                                                       }
                                                       $$=(current->getVar(v))->type.c_str();
                                                  }
                                                  else
                                                  {
                                                       errorCount++; 
                                                       yyerror("Tipul expresiei din dreapta nu corespunde cu tipul variabilei!");
                                                  }
                                             }
                                        } 
                                   }
           ;

control : if_statement elsee
        | for_statement
        | while_statement
        ;

statement : ID '(' call_list ')' ';'  {
                                             if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                                             {
                                                  errorCount++;
                                                  char msg[256];
                                                  sprintf(msg, "Functia %s nu a fost definita!", $1);
                                                  yyerror(msg);
                                             }
                                             else if(symtables[0]->getVar($1)->params.compare($3)==false)
                                             {
                                                  errorCount++;
                                                  char msg[256];
                                                  sprintf(msg, "Tipurile parametrilor functiei %s nu corespund!", $1);
                                                  yyerror(msg);
                                             }
                                      }
          | PRINT '(' expr ')' ';' {
                                        $3->typeASTNode();
                                        $3->evalASTNode();
                                        if($3->getASTNodeValoare()!="unknown")
                                        {
                                             cout<<"Valoarea este: "<<$3->getASTNodeValoare()<<'\n';
                                        }
                                        else
                                        {
                                             errorCount++;
                                             char msg[256];
                                             sprintf(msg, "Valoare nu a putut fi calculata deoarece tipurile operanzilor difera!");
                                             yyerror(msg);
                                        }
                                   }
          | TYPEOF '(' expr ')' ';' {
                                        $3->typeASTNode();
                                        if($3->getASTNodeType()!="unknown")
                                        {
                                             cout<<"Tipul este: "<<$3->getASTNodeType()<<'\n';
                                        }
                                        else
                                        {
                                             errorCount++;
                                             char msg[256];
                                             sprintf(msg, "Tipul nu a putut fi calculat deoarece tipurile operanzilor difera!");
                                             yyerror(msg);
                                        }
                                    }
          | assignment ';'
          | control
          | ID '.' ID '(' call_list ')' ';' {
                                                       if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                                                       {
                                                            errorCount++;
                                                            char msg[256];
                                                            sprintf(msg, "Obiectul %s nu a fost definit!", $1);
                                                            yyerror(msg);
                                                       }
                                                       else if(current->getVar($1)->idType!="object")
                                                       {
                                                            errorCount++;
                                                            char msg[256];
                                                            sprintf(msg, "Identificatorul %s nu reprezinta un obiect!", $1);
                                                            yyerror(msg);
                                                       }
                                                       else
                                                       {
                                                            clasa=lookup(current->getVar($1)->type);
                                                            if(clasa->existsId($3)==false)
                                                            {
                                                                 errorCount++;
                                                                 char msg[256];
                                                                 sprintf(msg, "Metoda %s nu exista!", $3);
                                                                 yyerror(msg);
                                                            }
                                                            else
                                                            {
                                                                 if(clasa->getVar($3)->params.compare($5)==false)
                                                                 {
                                                                      errorCount++;
                                                                      char msg[256];
                                                                      sprintf(msg, "Tipurile parametrilor metodei %s nu corespund!", $3);
                                                                      yyerror(msg);
                                                                 }
                                                            }
                                                       }
                                             }
          | BREAK ';'
          | returnare
          ;

if_statement : IF '(' b ')' '{' {SymTable* aux=new SymTable("IF", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
             | IF '(' T ')' '{' {SymTable* aux=new SymTable("IF", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
             | IF '(' F ')' '{' {SymTable* aux=new SymTable("IF", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
             ;

elsee : ELSE '{' {SymTable* aux=new SymTable("ELSE", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
      |
      ;

for_statement : FOR '(' assignment ';' b ';' assignment ')' '{' {SymTable* aux=new SymTable("FOR", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
              ;

while_statement : WHILE '(' b ')'  '{' {SymTable* aux=new SymTable("WHILE", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
                | WHILE '(' T ')'  '{' {SymTable* aux=new SymTable("WHILE", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
                | WHILE '(' F ')'  '{' {SymTable* aux=new SymTable("WHILE", current); current=aux;} list '}' {current->printVars(); current=current->getParent();}
                ;

call_list : expr {$$=new ParamList(); $1->typeASTNode(); $$->addParam($1->getASTNodeType(), "");}
          | call_list ',' expr {$$=$1; $3->typeASTNode(); $$->addParam($3->getASTNodeType(), "");}
          | assignment {$$=new ParamList(); $$->addParam($1, "");}
          | call_list ',' assignment {$$=$1; $$->addParam($3, "");}
          | {$$=new ParamList(); $$->addParam("", "");}
          ;

expr : e {$$=$1;}
     | b {$$=$1;}
     ;

b : b SAU b {$$=new ASTNode(OP_BOOL, "||", $1, $3);}
  | b SI b {$$=new ASTNode(OP_BOOL, "&&", $1, $3);}
  | e '<' e {$$=new ASTNode(OP_INT, "<", $1, $3);}
  | e '>' e {$$=new ASTNode(OP_INT, ">", $1, $3);}
  | e LEQ e {$$=new ASTNode(OP_INT, "<=", $1, $3);}
  | e GEQ e {$$=new ASTNode(OP_INT, ">=", $1, $3);}
  | e EQ e {$$=new ASTNode(OP_INT, "==", $1, $3);}
  | e NEQ e {$$=new ASTNode(OP_INT, "!=", $1, $3);}
  | '!' b {$$=new ASTNode(OP_BOOL, "!", $2);}
  | '(' b ')' {$$=$2;}
  ;

e : e '+' e {$$=new ASTNode(OP_INT, "+", $1, $3);}
  | e '*' e {$$=new ASTNode(OP_INT, "*", $1, $3);}
  | e '-' e {$$=new ASTNode(OP_INT, "-", $1, $3);}
  | e '/' e {
               $$=new ASTNode(OP_INT, "/", $1, $3);
               $3->typeASTNode();
               $3->evalASTNode();
               if($3->getASTNodeValoare()=="0")
               {
                    errorCount++;
                    yyerror("Nu se poate efectua impartirea la 0!");
               }
            }
  |'(' e ')' {$$=$2;}
  | NR_INT {$$=new ASTNode(NR_INTV, "int", $1);}
  | NR_FLOAT {$$=new ASTNode(NR_FLOATV, "float", $1);}
  | CHAR {$$=new ASTNode(CHARV, "char", $1);}
  | STRING {$$=new ASTNode(STRINGV, "string", $1);}
  | ID {
          if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
          {
               errorCount++;
               char msg[256];
               sprintf(msg, "Variabila %s nu a fost definita!", $1);
               yyerror(msg);
          }
          else
          {
               $$=new ASTNode(IDV, current->getVar($1)->type, current->getVar($1)->val);
          }
       }
  | ID '[' NR_INT']' {
                         if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                         {
                              errorCount++;
                              char msg[256];
                              sprintf(msg, "Vectorul %s nu a fost definit!", $1);
                              yyerror(msg);
                         }
                         else
                         {
                              if(!((current->getVar($1))->idType=="array"))
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Identificatorul %s nu reprezinta un vector!", $1);
                                   yyerror(msg);
                              }
                              else
                              {
                                   if (!((current->getVar($1))->dimensiune>atoi($3)))
                                   {
                                        errorCount++;
                                        char msg[256];
                                        sprintf(msg, "Dimensiunea vectorulul %s este depasita!", $1);
                                        yyerror(msg);
                                   }
                                   $$=new ASTNode(IDV, current->getVar($1)->type, current->getVar($1)->val);
                              }
                         }
                     }
  | ID '.' ID {
                    if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                    {
                         errorCount++;
                         char msg[256];
                         sprintf(msg, "Obiectul %s nu a fost definit!", $1);
                         yyerror(msg);
                    }
                    else if(current->getVar($1)->idType!="object")
                    {
                         errorCount++;
                         char msg[256];
                         sprintf(msg, "Identificatorul %s nu reprezinta un obiect!", $1);
                         yyerror(msg);
                    }
                    else
                    {
                         clasa=lookup(current->getVar($1)->type);
                         if(clasa->existsId($3)==false)
                         {
                              errorCount++;
                              char msg[256];
                              sprintf(msg, "Atributul %s nu exista!", $3);
                              yyerror(msg);
                         }
                         else
                         {
                              char* variabila= (char*)malloc(strlen($1)+strlen($3)+2);
                              strcpy(variabila, $1);
                              strcat(variabila, ".");
                              strcat(variabila, $3);
                              const char* v=variabila;
                              if((current->existsId(v)==false)&&(current->existsIdinParent(v)==false))
                              {
                                   current->addVar(clasa->getVar($3)->type.c_str(), v);
                              }
                              $$=new ASTNode(IDV, current->getVar(v)->type.c_str(), current->getVar(variabila)->val);
                         }
                    }
              }
  | ID '.' ID '(' call_list ')' {
                                        if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                                        {
                                             errorCount++;
                                             char msg[256];
                                             sprintf(msg, "Obiectul %s nu a fost definit!", $1);
                                             yyerror(msg);
                                        }
                                        else if(current->getVar($1)->idType!="object")
                                        {
                                             errorCount++;
                                             char msg[256];
                                             sprintf(msg, "%s nu este un obiect!", $1);
                                             yyerror(msg);
                                        }
                                        else
                                        {
                                             clasa=lookup(current->getVar($1)->type);
                                             if(clasa->existsId($3)==false)
                                             {
                                                  errorCount++;
                                                  char msg[256];
                                                  sprintf(msg, "Metoda %s nu exista!", $3);
                                                  yyerror(msg);
                                             }
                                             else
                                             {
                                                  if(clasa->getVar($3)->params.compare($5)==false)
                                                  {
                                                       errorCount++;
                                                       char msg[256];
                                                       sprintf(msg, "Tipurile parametrilor metodei %s nu corespund!", $3);
                                                       yyerror(msg);
                                                  }
                                                  $$=new ASTNode(IDV, clasa->getVar($3)->type, clasa->getVar($3)->val);
                                             }
                                        }
                                }
  | ID '(' call_list ')' {
                              if((current->existsId($1)==false)&&(current->existsIdinParent($1)==false))
                              {
                                   errorCount++;
                                   char msg[256];
                                   sprintf(msg, "Functia %s nu a fost definita!", $1);
                                   yyerror(msg);
                              }
                              else
                              {
                                   if(current->getVar($1)->params.compare($3)==false)
                                   {
                                        errorCount++;
                                        char msg[256];
                                        sprintf(msg, "Tipurile parametrilor functiei %s nu corespund!", $1);
                                        yyerror(msg);
                                   }
                                   $$=new ASTNode(IDV, current->getVar($1)->type, current->getVar($1)->val);
                              }
                         }
  | T {$$=new ASTNode(BOOLV, "bool", $1);}
  | F {$$=new ASTNode(BOOLV, "bool", $1);}
  ;




%%
void yyerror(const char * s){
     cout << "eroare: \"" << s << "\" la linia: " << yylineno << endl;
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");
     current = new SymTable("global", NULL);
     symtables.push_back(current);
     yyparse();
     current->printVars();
     for(int i=0; i<symtables.size(); i++)
     {
          delete(symtables[i]);
     }
     symtables.clear();
}

class SymTable* lookup(string nume)
{
     for(int i=0; i<symtables.size(); i++)
     {
          if(symtables[i]->getName()==nume)
          {
               return symtables[i];
          }
     }
     return NULL;
}