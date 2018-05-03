%x incl
%x com_line
%x com_lb

%option noyywrap
%option yylineno
%option nounistd

%{

#include "unistd.h"
#include "global.h"
#include "mycc.h"

static int localvar = 3;	/* JVM first local var index */

static int install_id();
static int install_int();

#define MAX_INCLUDE_DEPTH 10
YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
int include_stack_ptr = 0;

%}

digit           [0-9]
alpha           [a-zA-Z_]
id              {alpha}({alpha}|{digit})*
int             {digit}+

%%

[ \t\v\n\f\r]                  /* skip white space */
"/*"                    	   BEGIN(com_lb);/* multiline comment start*/
<com_lb>[^"*/"]*      	       
<com_lb>"*/"                   BEGIN( 0 );

"//"						   BEGIN(com_line); /* inline comment */
<com_line>[^\n]
<com_line>[\n]				   BEGIN( 0 );

"#"include             		   BEGIN(incl);
<incl>[ \t\<]*    			   /* eat the whitespace */
<incl>[^ \t\n\<\>]+   	{ 	   /* got the include file name */ 
				if ( include_stack_ptr >= MAX_INCLUDE_DEPTH )
				{
				    	fprintf( stderr, "Includes nested too deeply" );
				    	exit( 1 );
				}

				include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;
				yyin = fopen( yytext, "r" );

				if ( ! yyin )
				{
					printf("ERROR\n");
					exit( 1 );
				}
			}
<incl>\>                {
                        	yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
                        	BEGIN( 0 );
                    	}

<<EOF>> 		{
				if ( --include_stack_ptr < 0 )
				{
					yyterminate();
				}

				else
				{
					yy_delete_buffer( YY_CURRENT_BUFFER );
					yy_switch_to_buffer(
					include_stack[include_stack_ptr] );
				}
			}
{id}                           { return install_id(); }
{int}                          { return install_int(); }
"+="                           { return PA; }
"-="                           { return NA; }
"*="                           { return TA; }
"/="                           { return DA; }
"%="                           { return MA; }
"&="                           { return AA; }
"^="                           { return XA; }
"|="                           { return OA; }
"<<="                          { return LA; }
">>="                          { return RA; }
"||"                           { return OR; }
"&&"                           { return AN; }
"=="                           { return EQ; }
"!="                           { return NE; }
"<="                           { return LE; }
">="                           { return GE; }
"<<"                           { return LS; }
">>"                           { return RS; }
"++"                           { return PP; }
"--"                           { return NN; }
"->"                           { return AR; }
"<%"                           { return '{'; }
"%>"                           { return '}'; }
"<:"                           { return '['; }
":>"                           { return ']'; }
[!$%&()*+,\-./:;<=>?\[\]^{|}~] { return yytext[0]; }
.                              { yyerror("Unknown character ignored"); }

%%

/* install_id - add identifier to symbol table if not already there and assign it a JVM local var index */
static int install_id()
{
	yylval.sym = lookup(yytext);

	if (!yylval.sym)
	{
		yylval.sym = insert(yytext, ID);
		yylval.sym->localvar = localvar++;
	}

	return yylval.sym->token;
}

/* install_int - convert decimal yytext[] to yylval.num and return INT8, INT16, or INT32 */
static int install_int()
{
	sscanf(yytext, "%u", &yylval.num);

	if (yylval.num < 128)
		return INT8;

	if (yylval.num < 32368)
		return INT16;

	return INT32;
}
