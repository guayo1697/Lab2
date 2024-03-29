/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int const_count = 1;
    int var_count = 1;
    int str_count = 1;
    int white = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
	/* If necessary, add code for other states here, e.g:
	   case COMMENT:
	   ...
	   break;
	*/
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer 
%cup

%%

<YYINITIAL>"=>"			{ /* Sample lexical rule for "=>" arrow.
                                     Further lexical rules should be defined
                                     here, after the last %% separator */
                                  return new Symbol(TokenConstants.DARROW); }
<YYINITIAL>\n           {curr_lineno++;}
<YYINITIAL>[" "]|[\t]           {white++;}
<YYINITIAL>[0-9]+       {return new Symbol(TokenConstants.INT_CONST,new IdSymbol(yytext(), yytext().length(), const_count++)); }
<YYINITIAL>"+"          {return new Symbol(TokenConstants.PLUS,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"-"          {return new Symbol(TokenConstants.MINUS,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"*"          {return new Symbol(TokenConstants.MULT,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"/"          {return new Symbol(TokenConstants.DIV,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"~"          {return new Symbol(TokenConstants.NEG,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"<"          {return new Symbol(TokenConstants.LT,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"<="         {return new Symbol(TokenConstants.LE,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"<-"         {return new Symbol(TokenConstants.ASSIGN,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"="          {return new Symbol(TokenConstants.EQ,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>","          {return new Symbol(TokenConstants.COMMA,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>":"          {return new Symbol(TokenConstants.COLON,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>";"          {return new Symbol(TokenConstants.SEMI,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"not"        {return new Symbol(TokenConstants.NOT,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"true"       {return new Symbol(TokenConstants.BOOL_CONST,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>"false"      {return new Symbol(TokenConstants.BOOL_CONST,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>[\{] 		{return new Symbol(TokenConstants.LBRACE,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>[\}] 		{return new Symbol(TokenConstants.RBRACE,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>[\(]  		{return new Symbol(TokenConstants.LPAREN,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>[\)]  		{return new Symbol(TokenConstants.RPAREN,new IdSymbol(yytext(), yytext().length(), white++)); }
<YYINITIAL>[a-z][a-zA-Z0-9]*         {return new Symbol(TokenConstants.OBJECTID,new IdSymbol(yytext(), yytext().length(), var_count++)); }
<YYINITIAL>[\"][a-zA-Z0-9" "]*[\"]  {
									String token = yytext().substring(1, yytext().length() - 1);
									int l = token.length();
									return new Symbol(TokenConstants.STR_CONST, new StringSymbol(token,l,0));
								 }
<YYINITIAL>[A-Z][a-zA-Z0-9\_]*       {return new Symbol(TokenConstants.TYPEID,new IdSymbol(yytext(), yytext().length(), var_count++)); }

.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                  System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
