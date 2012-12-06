
transition = {}
event_names = []

def add_transition(first, second, attrs):
    dir = ''
    events = []
    if attrs is not None:
        dir = attrs[0]
        events = attrs[1]
    if dir == 'back':
        temp = first
        first = second
        second = temp
    #print "ADD", first, second, dir, events
    if len(first) > 7 and first[0:7] == 'default':
        first = 'default'
    for tname in events:
        if tname not in event_names:
            event_names.append(tname)
    if events == []:
        events = [' ']
    if transition.get(first) is None:
        transition[first] = {}
    if transition.get(second) is None:
        transition[second] = {}
    for tname in events:
        if transition[first].get(tname) is None:
            transition[first][tname] = []
        transition[first][tname].append(second)
    if dir == 'both':
        for tname in events:
            if transition[second].get(tname) is None:
                transition[second][tname] = []
            transition[second][tname].append(first)

def print_transitions():
    print "OVER", sorted(event_names)
    for item in sorted(transition):
        print 'item', item, transition[item]

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

    rule attribute_list:
        LBRACKET
            ( TOKLABEL EQUAL name
            | VAR EQUAL VAR
            )*
        RBRACKET

    rule transition_definition:
        LBRACKET {{ direction = ''; transition = '' }}
            ( TOKLABEL EQUAL name {{ transition = name.split('\\n') }}
            | TOKDIR EQUAL VAR {{ direction = VAR }}
            | VAR EQUAL (VAR | STR)
            )*
        RBRACKET
        {{ return (direction, transition) }}

    rule goal:
        TOKDIGRAPH name LBRACE
        ( TOKNODE attribute_list
        | name {{ firststate = name }}
             ( attribute_list SEMICOLON
             | RARROW name {{ attr = None }}
                  [ transition_definition {{ attr = transition_definition }} ]
                  {{ add_transition(firststate, name, attr) }}
             )
        | LBRACE TOKRANK EQUAL TOKSAME SEMICOLON ( name )+ RBRACE
        )*
        RBRACE 
        {{ print_transitions() }}
        ENDTOKEN

%%
import string
import newrt

if __name__=='__main__':
    if len(sys.argv) > 2:
        newrt.printtrace = True
    s = open(sys.argv[1]).read() + '\n'
    s1 = parse('goal', s)

###########
