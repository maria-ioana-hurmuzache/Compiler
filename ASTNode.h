#include <iostream>
#include <string>
#include <string.h>
using namespace std;

enum nodetype
{
    OP_INT=0,
    OP_BOOL=1,
    IDV=2,
    NR_INTV=3,
    NR_FLOATV=4,
    CHARV=5,
    STRINGV=6,
    BOOLV=7
};

class ASTNode
{
    private:
    string valoare;
    string op;
    string type;
    nodetype nod;
    ASTNode* st;
    ASTNode* dr;
    
    public:
    ASTNode(nodetype nod, string type, string valoare);//pentru noduri frunza
    ASTNode(nodetype nod, const char* op, ASTNode* st, ASTNode* dr=nullptr);
    void evalASTNode();
    void typeASTNode();
    string getASTNodeType();
    string getASTNodeValoare();
    ~ASTNode();
};