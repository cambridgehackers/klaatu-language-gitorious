
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

def print_states(fh, aname):
    tralist = transition[aname]
    #print 'item', aname, tralist
    if tralist == {}:
        return
    fh.write('    static STATE_TRANSITION TRA_' + aname + '[] = {')
    for item in sorted(tralist):
        t = item
        if item == ' ':
            t = '0'
        for sitem in tralist[item]:
            fh.write('{' + t + ',STATE_' + sitem + '}, ')
    fh.write('};\n')

def print_transitions():
    #print "OVER", sorted(event_names)
    fh = open('xx.output', 'w')
    fh.write('enum { EVENT_NONE=1,\n    ')
    index = 0
    for item in sorted(event_names):
        fh.write(item + ', ')
        index += 1
        if index > 2:
            index = 0
            fh.write('\n    ')
    fh.write('EVENT_MAX};\n\n')
    fh.write('enum { STATE_NONE=1,\n    ')
    index = 0
    for item in sorted(transition):
        fh.write('STATE_' + item + ', ')
        index += 1
        if index > 2:
            index = 0
            fh.write('\n    ')
    fh.write('STATE_MAX};\n\n')
    fh.write('typedef struct {\n   int event;\n   int state;\n} STATE_TRANSITION;\n')
    fh.write('#ifdef STATE_INITIALIZE_CODE\nSTATE_TRANSITION *state_table[STATE_MAX];\nvoid initstates(void)\n{\n')
    for item in sorted(transition):
        print_states(fh, item)
    fh.write('\n')
    for item in sorted(transition):
        if transition[item] != {}:
            fh.write('    state_table[STATE_' + item + '] = TRA_' + item + ';\n')
    fh.write('}\n#endif\n')
    fh.close()

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
