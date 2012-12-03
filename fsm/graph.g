globalvars = {}       # We will store the calculator's variables here
globaldecls = []      # sorted by declaration order
def lookup(map, name):
    #print "lookup", map, name
    for x, v in map:
        if x == name: return v
    if not globalvars.has_key(name):
        #print 'Undefined (defaulting to 0):', name
        pass
    return globalvars.get(name, 0)

def define(decl):
    globalvars[decl.name] = decl
    globaldecls.append(decl)

from AST import *

%%
parser HSDL:
    #option:      "context-insensitive-scanner"

    token ENDTOKEN: " "
    token LPAREN: "("
    token RPAREN: ")"
    token COLON: ':'
    token SEMICOLON: ';'
    token LARROW: "<-"
    token RARROW: "->"
    token EQUAL: "="
    token LBRACKET: "["
    token RBRACKET: "]"
    token LBRACE: "{"
    token RBRACE: "}"
    token DOT: "."
    token COMMA: ','

    token NUM: " "
    token STR:   " "
    token VAR: " "
    token TYPEVAR: " "
    token CLASSVAR: " " 
    token BUILTINVAR: " "

    token TOKACTIONSTATEMENT: "action"
based
box
color
cyan
darkolivegreen3
digraph
filled
firebrick
label
on
orchid4
preserved
rank
same
shape
style

############################################################################
############################# Datatypes ####################################
############################################################################

    rule type_decl:
        ( typevar_item
        | CLASSVAR typevar_item
        ) {{ return typevar_item}}
        [ LBRACKET NUM (COLON NUM)* RBRACKET ]

    rule goal:
        ( single_declaration
        | TOKPACKAGE ( VAR | TYPEVAR ) SEMICOLON ( single_declaration )* TOKENDPACKAGE [ COLON  VAR]
        )* ENDTOKEN {{ return globalvars }}

%%
import string
import newrt

if __name__=='__main__':
    if len(sys.argv) > 2:
        newrt.printtrace = True
    s = open(sys.argv[1]).read() + '\n'
    s1 = parse('goal', s)

###########
