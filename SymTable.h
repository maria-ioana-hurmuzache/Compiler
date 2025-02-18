#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <string.h>

using namespace std;

class ParamList {
    public:
    vector<pair<string, string>> params;
    void addParam(const string& type, const string& name)
    {
        params.emplace_back(type, name);
    }
    void getParams()
    {
        for (int i=0; i<params.size(); i++)
        {
            cout<<params[i].first<<' '<<params[i].second<<'\n';
        }
    }
    bool compare(ParamList* call_list)
    {
        for (int i=0; i<params.size(); i++)
        {
            if(this->params[i].first!=call_list->params[i].first)
            {
                return false;
            }
        }
        return true;
    }
};


class IdInfo {
    public:
    string idType;
    string type;
    string name;
    string val="";
    int dimensiune;
    ParamList params; //for functions
    IdInfo() {}
    IdInfo(const char* type, const char* name, const char* idType, int dimensiune=1) : type(type),name(name),idType(idType),dimensiune(dimensiune)
    {
        if(strcmp(type, "int")==0)
        {
            this->val="0";
        }
        else if(strcmp(type, "float")==0)
        {
            this->val="0.0";
        }
        else if(strcmp(type, "bool")==0)
        {
            this->val="false";
        }
    }
};



class SymTable {
    map<string, IdInfo> ids;
    string name;
    SymTable* parent;
    public:
    SymTable(const char* name, SymTable* parent) :  name(name), parent(parent){}
    SymTable* getParent();
    IdInfo* getVar(string var);
    string getName();
    bool existsId(string);
    bool existsIdinParent(string s);
    bool isBool(const char* s);
    void addVar(const char* type, const char* name);    
    void addObj(const char* type, const char* name);
    void addArray(const char* type, const char* name, int dimensiune);
    void addClass(const char* name);
    void addFunction(const char* type, const char*name);
    void printVars();
    ~SymTable();
};






