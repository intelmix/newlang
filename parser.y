%{
#include <cstdio>
#include <iostream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yyparse();
extern "C" int yylex();
extern "C" FILE *yyin;
 
void yyerror(const char *s);

FILE* output_file;
%}

%token NUMBER
%token OPERATOR
%token ENDL

%start PROGRAM

%%

PROGRAM :   |
            PROGRAM LINE 
            ;

LINE:       ENDL {
            }
            |
            EXP ENDL
            ;
    
EXP:        NUMBER {
            }
            |
            NUMBER OPERATOR EXP { 
                if ( $2 == '+' ) {
                    $$ = $1+$3;
                    cout << $1 << '+' << $3 << '=' << $$ << endl;
                    fprintf(output_file, "ADD %d,%d\n", $1, $3);
                }
                if ( $2 == '-' ) {
                    $$ = $1-$3;
                    cout << $1 << '-' << $3 << '=' << $$ << endl;
                    fprintf(output_file, "SUB %d,%d\n", $1, $3);
                }
                if ( $2 == '*' ) {
                    $$=$1*$3;
                    cout << $1 << '*' << $3 << '=' << $$ << endl;
                    fprintf(output_file, "MUL %d,%d\n", $1, $3);
                }
                if ( $2 == '/' ) {
                    $$=$1/$3;
                    cout << $1 << '/' << $3 << '=' << $$ << endl;
                    fprintf(output_file, "DIV %d,%d\n", $1, $3);
                }
            }
            ;

%%

int main(int, char**) {
    // open a file handle to a particular file:
    FILE *myfile = fopen("input", "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "I can't open input file!" << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    
    output_file = fopen("output", "w");
    if (!output_file) {
        cout << "I can't open output file!" << endl;
        return -1;
    }

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    fclose(output_file);
    
}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
