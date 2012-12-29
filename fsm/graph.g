
import string

transition = {}
event_names = []

def add_elements(first, second, events):
    if transition.get(first) is None:
        transition[first] = {}
    if transition.get(second) is None:
        transition[second] = {}
    for tname in events:
        if tname not in event_names and tname != ' ':
            event_names.append(tname)
        if transition[first].get(tname) is None:
            transition[first][tname] = []
        transition[first][tname].append(second)

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
    if events == []:
        events = [' ']
    add_elements(first, second, events)
    if dir == 'both':
        add_elements(second, first, events)

def get_sname(aname):
    return aname.upper() + '_STATE'

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
            fh.write('{' + t + ',' + get_sname(sitem) + '}, ')
    fh.write('{0,0} };\n')

def print_transitions():
    #print "OVER", sorted(event_names)
    fh = open('xx.output', 'w')
    fh.write('namespace android {\n')
    fh.write('#ifdef FSM_DEFINE_ENUMS\n')
    #fh.write('class WifiStateMachine {\npublic:\n')
    fh.write('enum { EVENT_NONE=1,\n    ')
    index = 0
    for item in sorted(event_names):
        fh.write(item + ', ')
        index += 1
        if index > 2:
            index = 0
            fh.write('\n    ')
    fh.write('MAX_WIFI_EVENT};\n')
    #fh.write('};\n')
    fh.write('#endif\n')
    fh.write('enum { STATE_NONE=1,\n    ')
    index = 0
    for item in sorted(transition):
        fh.write(get_sname(item) + ', ')
        index += 1
        if index > 2:
            index = 0
            fh.write('\n    ')
    fh.write('STATE_MAX};\n')
    fh.write('extern const char *sMessageToString[' + 'MAX_WIFI_EVENT];\n')
    fh.write('#ifdef FSM_INITIALIZE_CODE\n')
    fh.write('const char *sMessageToString[' + 'MAX_WIFI_EVENT];\n')
    fh.write('STATE_TABLE_TYPE state_table[' + 'STATE_MAX];\n')
    fh.write('void initstates(void)\n{\n')
    for item in sorted(transition):
        print_states(fh, item)
    fh.write('\n')
    for item in sorted(transition):
        fh.write('    state_table[' + get_sname(item) + '].name = "' + item + '";\n')
        if transition[item] != {}:
            fh.write('    state_table[' + get_sname(item) + '].tran = TRA_' + item + ';\n')
    for item in sorted(event_names):
        fh.write('    sMessageToString[' + item + '] = "' + item + '";\n')
    fh.write('}\n')
    fh.write('\n#endif\n\n#ifdef FSM_ACTION_CODE\n')
    fh.write('#define addstateitem(command, aprocess) \\\n')
    fh.write('    mStateMap[command].mName = #command; \\\n')
    fh.write('    mStateMap[command].mProcess = aprocess;\n\n')
    addstring = ''
    fh.write('class WifiStateMachineActions: public WifiStateMachine {\npublic:\n')
    for item in sorted(transition):
        if item not in ['DEFER', 'Initial', 'Unused', 'default']:
            atemp = item+'_process'
            fh.write('stateprocess_t ' + atemp + '(Message *);\n')
            atemp = 'static_cast<PROCESS_PROTO>(&WifiStateMachineActions::' + atemp + ')'
            addstring = addstring + '    addstateitem('  + item.upper() + '_STATE, ' + atemp + ');\n'
    fh.write('};\nvoid ADD_ITEMS(State *mStateMap) {\n' + addstring + '}\n\n#endif\n} /* namespace android */\n')
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
    token TOKDEFER: "defer"
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
        ( TOKNODE LBRACKET ( VAR EQUAL VAR)* RBRACKET
        | name {{ firststate = name }}
             ( LBRACKET
                 ( TOKDEFER EQUAL name {{ add_elements(firststate, "DEFER", name.split('\\n')) }}
                 | ( TOKLABEL | VAR ) EQUAL name
                 )* RBRACKET SEMICOLON
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
import newrt

if __name__=='__main__':
    if len(sys.argv) > 2:
        newrt.printtrace = True
    s = open(sys.argv[1]).read() + '\n'
    s1 = parse('goal', s)

###########
