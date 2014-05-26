/* -*- C++ -*-   vim: set syntax=cpp:
 * CONTENT: 
 *
 * (1) Includes for required standard headers.
 * (2) Definitions of options and settings for the particular application.
 * (3) #include <quex/code_base/definitions> for default settings.
 * (4) Lexical Analyzer class EasyLexer and its memento class.
 * (5) Constructor and init core of EasyLexer.
 * (6) Memento pack and unpack functions.
 *
 * File content generated by Quex 0.64.8.
 *
 * (C) 2005-2012 Frank-Rene Schaefer
 * ABSOLUTELY NO WARRANTY                                                      */
#ifndef __QUEX_INCLUDE_GUARD__ANALYZER__GENERATED__QUEX___EASYLEXER
#define __QUEX_INCLUDE_GUARD__ANALYZER__GENERATED__QUEX___EASYLEXER

#ifdef      __QUEX_INCLUDE_INDICATOR__ANALYZER__MAIN
    /* In case that multiple lexical analyzers are used the same header
     * files are compiled with a different setting of the macros. The
     * undef of the include guards happens in the following file.              */
#   ifdef   __QUEX_SIGNAL_DEFINED_LEXER_IN_NAMESPACE_QUEX_
#      error "More than one lexical analyzer have been generated in the same name space. Read documentation on command line option '-o'."
#   endif
#   include <quex/code_base/include-guard-undef>
#   include <quex/code_base/analyzer/member/token-sending-undef.i>
#   undef   __QUEX_INCLUDE_GUARD__ANALYZER__CONFIGURATION__QUEX___EASYLEXER
#else
#   define  __QUEX_INCLUDE_INDICATOR__ANALYZER__MAIN
#endif
#define     __QUEX_SIGNAL_DEFINED_LEXER_IN_NAMESPACE_QUEX_

#include "EasyLexer-configuration.h"

#include <quex/code_base/definitions>

struct  QUEX_NAME(Engine_tag);
struct  QUEX_NAME(Memento_tag);
QUEX_TYPE0_ANALYZER;    /* quex_EasyLexer */
typedef __QUEX_TYPE_ANALYZER_RETURN_VALUE  (*QUEX_NAME(AnalyzerFunctionP))(QUEX_TYPE0_ANALYZER*);

/* Token Class Declaration must preceed the user's header, so that the user
 * can refer to it at ease.                                                    */
QUEX_TYPE0_TOKEN;

/* START: User defined header content _________________________________________
 *        Must come before token class definition, since the token class 
 *        might rely on contents of the header.                                */

#   line 2 "ada.qx"

#include <stdlib.h>  /* for: atoi() */

#   line 55 "EasyLexer.h"


/* END: _______________________________________________________________________*/
#if defined(__QUEX_OPTION_CONVERTER_HELPER)
#   include "quex/code_base/converter_helper/from-unicode-buffer"
#endif
#include <quex/code_base/analyzer/headers>

#include "EasyLexer-token_ids.h"
#include "EasyLexer-token.h"


QUEX_NAMESPACE_MAIN_OPEN 

enum {
    QUEX_NAME(ModeID_ONE_AND_ONLY) = 0
};
    
        extern QUEX_NAME(Mode)  QUEX_NAME(ONE_AND_ONLY);


extern     __QUEX_TYPE_ANALYZER_RETURN_VALUE QUEX_NAME(ONE_AND_ONLY_analyzer_function)(QUEX_TYPE_ANALYZER*);
#ifdef QUEX_OPTION_RUNTIME_MODE_TRANSITION_CHECK
extern     bool QUEX_NAME(ONE_AND_ONLY_has_base)(const QUEX_NAME(Mode)*);
extern     bool QUEX_NAME(ONE_AND_ONLY_has_entry_from)(const QUEX_NAME(Mode)*);
extern     bool QUEX_NAME(ONE_AND_ONLY_has_exit_to)(const QUEX_NAME(Mode)*);
#endif



typedef struct QUEX_NAME(Memento_tag) {
#   include <quex/code_base/analyzer/EngineMemento_body>

    /* Con- and Destruction are **not** necessary in C. No con- or de-
     * structors of members need to be triggered.                              */

/* START: User's memento extentions ___________________________________________*/

/* END: _______________________________________________________________________*/
} QUEX_NAME(Memento);

QUEX_NAMESPACE_MAIN_CLOSE 

#include <quex/code_base/temporary_macros_on>

QUEX_NAMESPACE_MAIN_OPEN 

typedef struct quex_EasyLexer_tag {

#include <quex/code_base/analyzer/Engine_body>
#define self  (*(QUEX_TYPE_DERIVED_ANALYZER*)this)
/* START: User's class body extensions _____________________________________________*/

/* END: ____________________________________________________________________________*/
#undef  self

} quex_EasyLexer;

QUEX_NAMESPACE_MAIN_CLOSE
#include <quex/code_base/temporary_macros_off>

#endif /* __QUEX_INCLUDE_GUARD__ANALYZER__GENERATED__QUEX___EASYLEXER */
