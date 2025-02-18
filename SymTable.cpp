#include "SymTable.h"
#include <fstream>

ofstream fout("SymTables.txt");

using namespace std;

void SymTable::addVar(const char* type, const char*name) {
    IdInfo var(type, name, "var");
    ids[name] = var;
}

void SymTable::addObj(const char* type, const char*name)
{
    IdInfo obj(type, name, "object");
    ids[name] = obj;
}

void SymTable::addArray(const char* type, const char*name, int dimensiune) {
    IdInfo var(type, name, "array", dimensiune);
    ids[name] = var;
}

void SymTable::addClass(const char*name) {
    IdInfo clasa("clasa", name, "clasa");
    ids[name] = clasa; 
}

void SymTable::addFunction(const char* type, const char*name) {
    IdInfo func(type , name, "func");
    ids[name] = func; 
}

bool SymTable::existsId(string var) {
    return ids.find(var)!= ids.end();  
}

bool SymTable::existsIdinParent(string var)
{
    if(parent!=NULL)
    {
        return (parent->existsId(var)||parent->existsIdinParent(var));
    }
    return false;
}

bool SymTable::isBool(const char* s)
{
   if( ids.find(s)!=ids.end())
   {
        auto it=ids.find(s);
        if(it->second.type=="bool")
        {
            return true;
        }
   }
   return false;
}

void SymTable::printVars()
{
    fout<<"SymTable of scope "<<this->name<<":\n";
    for (const pair<string, IdInfo>& v : ids)
    {
        fout << "name: " << v.first << "; type: " << v.second.type << "; idType: " << v.second.idType<<";";
        if(v.second.val!="")
        {
            fout<<" valoare: "<<v.second.val<<";";
        }
        if(v.second.idType=="func")
        {
            fout<<" tipuri parametri: ";
            for(int i=0; i<v.second.params.params.size(); i++)
            {
                fout<<v.second.params.params[i].first<<' ';
            }
            fout<<";";
        }
        fout<<'\n';
    }
    fout<<'\n';
}

SymTable::~SymTable() {
    ids.clear();
}

SymTable* SymTable::getParent()
{
    return parent;
}

IdInfo* SymTable::getVar(string var)
{
    if(this->existsId(var))
    {
        auto it=ids.find(var);
        IdInfo* ptr=&(it->second);
        return ptr;
    }
    else if(this->existsIdinParent(var))
    {
        bool found=false;
        auto parent2=parent;
        while(!found)
        {
            if(parent2->existsId(var))
            {
                found=true;
            }
            else
            {
                parent2=parent2->parent;
            }
        }
        auto it=parent2->ids.find(var);
        IdInfo* ptr=&(it->second);
        return ptr;
    }
    else
    {
        return NULL;
    }
}

string SymTable::getName()
{
    return this->name;
}