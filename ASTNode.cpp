#include "ASTNode.h"

ASTNode::ASTNode(nodetype nod, string type, string valoare)
{
    this->valoare=valoare;
    this->op="";
    this->type=type;
    this->nod=nod;
    this->st=nullptr;
    this->dr=nullptr;
}

ASTNode::ASTNode(nodetype nod, const char* op, ASTNode* st, ASTNode* dr)
{
    this->valoare="";
    this->op=op;
    this->type="";
    this->nod=nod;
    this->st=st;
    this->dr=dr;
}

string calculeaza_int(string e1, string e2, string op)
{
    int ex1=stoi(e1);
    int ex2=stoi(e2);
    int rez=0;
    bool isbool=false;
    bool rezbool=false;
    if(op=="+")
    {
        rez=ex1+ex2;
    }
    else if(op=="-")
    {
        rez=ex1-ex2;
    }
    else if(op=="*")
    {
        rez=ex1*ex2;
    }
    else if(op=="/")
    {
        if(ex2!=0)
        {
            rez=ex1/ex2;
        }
        else
        {
            return "Nu se poate efectua impartirea la 0!";
        }
    }
    else if(op=="==")
    {
        isbool=true;
        rezbool=(ex1==ex2);
    }
    else if(op=="<")
    {
        isbool=true;
        rezbool=(ex1<ex2);
    }
    else if(op=="<=")
    {
        isbool=true;
        rezbool=(ex1<=ex2);
    }
    else if(op==">")
    {
        isbool=true;
        rezbool=(ex1>ex2);
    }
    else if(op==">=")
    {
        isbool=true;
        rezbool=(ex1>=ex2);
    }
    else if(op=="!=")
    {
        isbool=true;
        rezbool=(ex1!=ex2);
    }
    if(isbool==true)
    {
        if(rezbool==true)
        {
            return "true";
        }
        return "false";
    }
    return to_string(rez);
}

string calculeaza_float(string e1, string e2, string op)
{
    float ex1=stof(e1);
    float ex2=stof(e2);
    float rez=0;
    bool isbool=false;
    bool rezbool=false;
    if(op=="+")
    {
        rez=ex1+ex2;
    }
    else if(op=="-")
    {
        rez=ex1-ex2;
    }
    else if(op=="*")
    {
        rez=ex1*ex2;
    }
    else if(op=="/")
    {
        if(ex2!=0)
        {
            rez=ex1/ex2;
        }
        else
        {
            return "Nu se poate efectua impartirea la 0!";
        }
    }
    else if(op=="==")
    {
        isbool=true;
        rezbool=(ex1==ex2);
    }
    else if(op=="<")
    {
        isbool=true;
        rezbool=(ex1<ex2);
    }
    else if(op=="<=")
    {
        isbool=true;
        rezbool=(ex1<=ex2);
    }
    else if(op==">")
    {
        isbool=true;
        rezbool=(ex1>ex2);
    }
    else if(op==">=")
    {
        isbool=true;
        rezbool=(ex1>=ex2);
    }
    else if(op=="!=")
    {
        isbool=true;
        rezbool=(ex1!=ex2);
    }
    if(isbool==true)
    {
        if(rezbool==true)
        {
            return "true";
        }
        return "false";
    }
    return to_string(rez);
}

const char* calculeaza_bool(string e1, string e2, string op)
{
    bool ex1, ex2;
    if(e1=="true")
    {
        ex1=true;
    }
    else
    {
        ex1=false;
    }
    if(e2=="true")
    {
        ex2=true;
    }
    else if(e2=="false")
    {
        ex2=false;
    }
    bool rez=false;
    if(op=="!")
    {
        rez=(!ex1);
    }
    else if(op=="||")
    {
        rez=(ex1||ex2);
    }
    else if(op=="&&")
    {
        rez=(ex1&&ex2);
    }
    if(rez==true)
    {
        return "true";
    }
    return "false";
}

void ASTNode::evalASTNode()
{
    if(this->valoare!="")
    {
        return;
    }
    else if(this->nod==OP_INT)
    {
        if(this->type=="unknown")
        {
            this->valoare="unknown";
        }
        else
        {
            st->evalASTNode();
            dr->evalASTNode();
            if(this->st->type=="int")
            {
                this->valoare=calculeaza_int(st->valoare, dr->valoare, op);
            }
            else if(this->st->type=="float")
            {
                this->valoare=calculeaza_float(st->valoare, dr->valoare, op);
            }
            else if(this->st->type=="bool" && op=="==")
            {
                if(st->valoare==dr->valoare)
                {
                    this->valoare="true";
                }
                else
                {
                    this->valoare="false";
                }
            }
            else if(this->st->type=="char" && op=="+")
            {
                this->valoare=this->st->valoare+this->dr->valoare;
            }
            else
            {
                this->valoare="unknown";
            }
        }
    }
    else if(this->nod==OP_BOOL)
    {
        if(this->type=="unknown")
        {
            this->valoare="unknown";
        }
        if(dr!=nullptr)
        {
            st->evalASTNode();
            dr->evalASTNode();
            this->valoare=calculeaza_bool(st->valoare, dr->valoare, op);
        }
        else
        {
            st->evalASTNode();
            this->valoare=calculeaza_bool(st->valoare, "", op);
        }
    }
}

void ASTNode::typeASTNode()
{
    //caz de baza: valoare/id/noduri calculate
    if(this->type!="")
    {
        return;
    }
    //recursia
    else if(this->nod==OP_INT)
    {
        this->st->typeASTNode();
        this->dr->typeASTNode();
        if(this->st->type!=this->dr->type)
        {
            this->type="unknown";
        }
        else
        {
            if(this->op=="+"||this->op=="-"||this->op=="/"||this->op=="*")
            {
                if(this->st->type=="char")
                {
                    this->type="string";
                }
                else
                {
                    this->type=this->st->type;
                }
            }
            else
            {
                this->type="bool";
            }
        }
    }
    else if(this->nod==OP_BOOL)
    {
        if(this->dr!=nullptr)
        {
            this->st->typeASTNode();
            this->dr->typeASTNode();
            if(this->st->type!="bool" || this->dr->type!="bool")
            {
                this->type="unknown";
            }
            else
            {
                this->type="bool";
            }
        }
        else
        {
            this->st->typeASTNode();
            if(this->st->type!="bool")
            {
                this->type="unknown";
            }
            else
            {
                this->type="bool";
            }
        }
    }
}

string ASTNode::getASTNodeType()
{
    return this->type;
}
string ASTNode::getASTNodeValoare()
{
    return this->valoare;
}