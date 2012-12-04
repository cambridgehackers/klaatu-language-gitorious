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

%%
parser HSDL:
    option:      "context-insensitive-scanner"

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

    token TOKBASED: "based"
    token TOKDIGRAPH: "digraph"
    token TOKLABEL: "label"
    token TOKSHAPE: "shape"
    token TOKSTYLE: "style"
    token TOKCOLOR: "color"
    token TOKRANK: "rank"
    token TOKSAME: "same"
    token TOKBOX: "box"
    token TOKFILLED: "filled"
#cyan
#darkolivegreen3
#firebrick
#orchid4

############################################################################
############################# Datatypes ####################################
############################################################################

    rule state_name:
        STR

    rule transition_name:
        STR

    rule state_definition:
        state_name
        LBRACKET
            ( TOKLABEL EQUAL STR
            | TOKSHAPE EQUAL TOKBOX
            | TOKSTYLE EQUAL TOKFILLED
            | TOKCOLOR EQUAL VAR
            )*
        RBRACKET
        SEMICOLON

    rule ranking:
        LBRACE
        TOKRANK EQUAL TOKSAME SEMICOLON
        (
            state_name
        )+
        RBRACE

    rule transition_definition:
        state_name
        RARROW
        state_name
        LBRACKET
            TOKLABEL EQUAL transition_name
        RBRACKET

    rule goal:
        TOKDIGRAPH STR LBRACE
        ( state_definition )+
        ( ranking )+
        ( transition_definition )+
        RBRACE 
        ENDTOKEN {{ return globalvars }}

%%
import string
import newrt

if __name__=='__main__':
    if len(sys.argv) > 2:
        newrt.printtrace = True
    s = open(sys.argv[1]).read() + '\n'
    s1 = parse('goal', s)

###########
