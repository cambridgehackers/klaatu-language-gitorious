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

    token TOKDIGRAPH: "digraph"
    token TOKLABEL: "label"
    token TOKRANK: "rank"
    token TOKDIR: "dir"
    token TOKNODE: "node"
    token TOKSAME: "same"

############################################################################
############################# Datatypes ####################################
############################################################################

    rule name:
        ( STR {{ return STR[1:-1].strip() }}
        | VAR {{ return VAR.strip() }}
        | TYPEVAR {{ return TYPEVAR.strip() }}
        )

    rule state_name:
        name {{ return name }}

    rule transition_name:
        name {{ return name }}

    rule attribute_list:
        LBRACKET
            ( TOKLABEL EQUAL name
            | VAR EQUAL VAR
            )*
        RBRACKET

    rule ranking:
        LBRACE
        TOKRANK EQUAL TOKSAME SEMICOLON
        (
            state_name
        )+
        RBRACE

    rule transition_definition:
        LBRACKET {{ direction = ''; transition = '' }}
            ( TOKLABEL EQUAL transition_name {{ transition = transition_name }}
            | TOKDIR EQUAL VAR {{ direction = VAR }}
            | VAR EQUAL (VAR | STR)
            )*
        RBRACKET
        {{ return (direction, transition) }}

    rule goal:
        TOKDIGRAPH name LBRACE
        ( TOKNODE attribute_list
        | state_name {{ firststate = state_name }}
             ( attribute_list SEMICOLON
             | RARROW state_name {{ states = (firststate, state_name, None) }}
                  [ transition_definition {{ states = (firststate, state_name, transition_definition) }} ]
                  {{ print "STATES", states }}
             )
        | ranking
        )*
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
