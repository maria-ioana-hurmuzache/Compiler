%{
#include <stdio.h>
#include "limbaj.tab.h"
%}

%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool" {yylval.string = strdup(yytext);return TYPE;}
"private"|"protected"|"public" {yylval.string = strdup(yytext);return ACCES;}
"begin_progr" {return BGIN;}
"end_progr" {return END;}

"if" {yylval.string = strdup(yytext); return IF;}
"else" {yylval.string = strdup(yytext); return ELSE;}
"for" {yylval.string = strdup(yytext); return FOR;}
"break" {yylval.string = strdup(yytext); return BREAK;}
"return" {yylval.string = strdup(yytext); return RETURN;}
"while" {yylval.string = strdup(yytext); return WHILE;}

"class" {yylval.string = strdup(yytext); return CLASS;}

"true" {yylval.string = strdup(yytext); return T;}
"false" {yylval.string = strdup(yytext); return F;}
"Print" {yylval.string = strdup(yytext); return PRINT;}
"TypeOf" {yylval.string = strdup(yytext); return TYPEOF;}

":=" {return ASSIGN;}
"||" {return SAU;}
"&&" {return SI;}
"==" {return EQ;}
"!=" {return NEQ;}
"<=" {return LEQ;}
">=" {return GEQ;}

[a-zA-Z][a-zA-Z0-9]* {yylval.string = strdup(yytext); return ID;}
-?[1-9][0-9]*|0 {yylval.string = strdup(yytext); return NR_INT;}
-?([1-9][0-9]*|0)\.([1-9][0-9]*|0) {yylval.string = strdup(yytext); return NR_FLOAT;}
\'[a-zA-Z0-9]\' {yylval.string = strdup(yytext); return CHAR;}
\"[a-zA-Z0-9 ]*\" {yylval.string = strdup(yytext); return STRING;}

"//"[^\n]* ;
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
