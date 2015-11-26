return {
    KEYWORDS =
        {
            PRINT = 'print',
            GOTO = 'goto',
            LET = 'let',
            IF = 'if',
            THEN = 'then',
        },
    SYMBOL = {
        {'ID', '@l@(@l@|@n)'},
        {'NUMBER', '@n@(@n)'},
        {'ADD', '+'},
        {'SUB', '-'},
        {'MUL', '*'},
        {'DIV', '/'},
        {'LP', '('},
        {'RP', ')'},
        {'LB', '['},
        {'RB', ']'},
        {'LESS', '<'},
        {'GREATER', '>'},
        {'EQ', '='},
        {'LEQ', '<='},
        {'GEQ', '>='},
        {'UEQ', '<>'},
    },
}
