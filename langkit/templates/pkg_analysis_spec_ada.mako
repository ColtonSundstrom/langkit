## vim: filetype=makoada

with Ada.Containers.Hashed_Maps;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Hash;

with System;

with Langkit_Support.Bump_Ptr;    use Langkit_Support.Bump_Ptr;
with Langkit_Support.Cheap_Sets;
with Langkit_Support.Diagnostics; use Langkit_Support.Diagnostics;
with Langkit_Support.Symbols;     use Langkit_Support.Symbols;
with Langkit_Support.Text;        use Langkit_Support.Text;
with Langkit_Support.Vectors;

with ${_self.ada_api_settings.lib_name}.Analysis_Interfaces;
use ${_self.ada_api_settings.lib_name}.Analysis_Interfaces;
with ${_self.ada_api_settings.lib_name}.AST;
use ${_self.ada_api_settings.lib_name}.AST;
with ${_self.ada_api_settings.lib_name}.Lexer;
use ${_self.ada_api_settings.lib_name}.Lexer.Token_Data_Handlers;
% if _self.default_unit_file_provider:
with ${_self.ada_api_settings.lib_name}.Unit_Files;
use ${_self.ada_api_settings.lib_name}.Unit_Files;
% endif
%if _self.default_unit_file_provider:
with ${_self.default_unit_file_provider[0]};
%endif

--  This package provides types and primitives to analyze source files as
--  analysis units.
--
--  This is the entry point to parse and process an unit: first create an
--  analysis context with Create, then get analysis units out of it using
--  Get_From_File and/or Get_From_Buffer.

package ${_self.ada_api_settings.lib_name}.Analysis is

   ----------------------
   -- Analysis context --
   ----------------------

   type Analysis_Context is private;
   ${ada_doc('langkit.analysis_context_type', 3)}

   type Analysis_Unit is private;
   ${ada_doc('langkit.analysis_unit_type', 3)}

   type Grammar_Rule is (
      % for i, name in enumerate(_self.user_rule_names):
         % if i > 0:
            ,
         % endif
         ${Name.from_lower(name)}_Rule
      % endfor
   );
   ${ada_doc('langkit.grammar_rule_type')}

   Invalid_Unit_Name_Error : exception;
   ${ada_doc('langkit.invalid_unit_name_error')}

   function Create
     (Charset : String := ${string_repr(_self.default_charset)}
      % if _self.default_unit_file_provider:
         ; Unit_File_Provider : Unit_File_Provider_Access_Cst :=
             ${'.'.join(_self.default_unit_file_provider)}
      % endif
     ) return Analysis_Context;
   ${ada_doc('langkit.create_context', 3)}

   procedure Inc_Ref (Context : Analysis_Context);
   ${ada_doc('langkit.context_incref')}

   procedure Dec_Ref (Context : in out Analysis_Context);
   ${ada_doc('langkit.context_decref')}

   function Get_From_File
     (Context     : Analysis_Context;
      Filename    : String;
      Charset     : String := "";
      Reparse     : Boolean := False;
      With_Trivia : Boolean := False;
      Rule        : Grammar_Rule :=
         ${Name.from_lower(_self.main_rule_name)}_Rule)
      return Analysis_Unit;
   ${ada_doc('langkit.get_unit_from_file', 3)}

   function Get_From_Buffer
     (Context     : Analysis_Context;
      Filename    : String;
      Charset     : String := "";
      Buffer      : String;
      With_Trivia : Boolean := False;
      Rule        : Grammar_Rule :=
         ${Name.from_lower(_self.main_rule_name)}_Rule)
      return Analysis_Unit;
   ${ada_doc('langkit.get_unit_from_buffer', 3)}

   % if _self.default_unit_file_provider:

   function Get_From_Provider
     (Context     : Analysis_Context;
      Name        : Text_Type;
      Kind        : Unit_Kind;
      Charset     : String := "";
      Reparse     : Boolean := False;
      With_Trivia : Boolean := False;
      Rule        : Grammar_Rule :=
         ${Name.from_lower(_self.main_rule_name)}_Rule)
      return Analysis_Unit;
   ${ada_doc('langkit.get_unit_from_provider', 3)}

   function Unit_File_Provider
     (Context : Analysis_Context)
      return Unit_File_Provider_Access_Cst;
   --  Object to translate unit names to file names
   % endif

   procedure Remove (Context   : Analysis_Context;
                     File_Name : String);
   ${ada_doc('langkit.remove_unit', 3)}

   procedure Destroy (Context : in out Analysis_Context);
   ${ada_doc('langkit.destroy_context', 3)}

   procedure Inc_Ref (Unit : Analysis_Unit);
   ${ada_doc('langkit.unit_incref')}

   procedure Dec_Ref (Unit : Analysis_Unit);
   ${ada_doc('langkit.unit_decref')}

   function Get_Context (Unit : Analysis_Unit) return Analysis_Context;
   ${ada_doc('langkit.unit_context')}

   procedure Reparse (Unit : Analysis_Unit; Charset : String := "");
   ${ada_doc('langkit.unit_reparse_file', 3)}

   procedure Reparse
     (Unit    : Analysis_Unit;
      Charset : String := "";
      Buffer  : String);
   ${ada_doc('langkit.unit_reparse_buffer', 3)}

   procedure Populate_Lexical_Env (Unit : Analysis_Unit);
   ${ada_doc('langkit.unit_populate_lexical_env')}

   function Get_Filename (Unit : Analysis_Unit) return String;
   ${ada_doc('langkit.unit_filename')}

   function Has_Diagnostics (Unit : Analysis_Unit) return Boolean;
   ${ada_doc('langkit.unit_has_diagnostics', 3)}

   function Diagnostics (Unit : Analysis_Unit) return Diagnostics_Array;
   ${ada_doc('langkit.unit_diagnostics', 3)}

   function Root (Unit : Analysis_Unit) return ${root_node_type_name};
   ${ada_doc('langkit.unit_root', 3)}

   function Get_Unit
     (Node : access ${root_node_value_type}'Class)
      return Analysis_Unit;
   ${ada_doc('langkit.node_unit', 3)}

   function First_Token (Unit : Analysis_Unit) return Token_Type;
   ${ada_doc('langkit.unit_first_token', 3)}

   function Last_Token (Unit : Analysis_Unit) return Token_Type;
   ${ada_doc('langkit.unit_last_token', 3)}

   procedure Dump_Lexical_Env (Unit : Analysis_Unit);
   --  Debug helper: output the lexical envs for given analysis unit

   procedure Print (Unit : Analysis_Unit);
   --  Debug helper: output the AST and eventual diagnostic for this unit on
   --  standard output.

   procedure PP_Trivia (Unit : Analysis_Unit);
   --  Debug helper: output a minimal AST with mixed trivias

   procedure Reference_Unit (From, Referenced : Analysis_Unit);
   --  Set the Referenced unit as being referenced from the From unit. This is
   --  useful for visibility purposes, and is mainly meant to be used in the
   --  env hooks.

   function Is_Referenced
     (Unit, Referenced : Analysis_Unit) return Boolean;
   --  Check whether the Referenced unit is referenced from Unit

private

   type Analysis_Context_Type;
   type Analysis_Unit_Type;

   type Analysis_Context is access all Analysis_Context_Type;
   type Analysis_Unit is access all Analysis_Unit_Type;

   package Units_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => Unbounded_String,
      Element_Type    => Analysis_Unit,
      Hash            => Ada.Strings.Unbounded.Hash,
      Equivalent_Keys => "=");

   type Analysis_Context_Type is record
      Ref_Count  : Natural;
      Units_Map  : Units_Maps.Map;
      Symbols    : Symbol_Table;

      Charset    : Unbounded_String;
      --  Default charset to use in analysis units

      Root_Scope : AST_Envs.Lexical_Env;
      --  The lexical scope that is shared amongst every compilation unit. Used
      --  to resolve cross file references.

      % if _self.default_unit_file_provider:
      Unit_File_Provider : Unit_File_Provider_Access_Cst;
      --  Object to translate unit names to file names
      % endif
   end record;

   type Destroyable_Type is record
      Object  : System.Address;
      --  Object to destroy

      Destroy : Destroy_Procedure;
      --  Procedure to destroy Object
   end record;
   --  Simple holder to associate an object to destroy and the procedure to
   --  perform the destruction.

   package Destroyable_Vectors is new Langkit_Support.Vectors
     (Destroyable_Type);

   package Analysis_Unit_Sets
   is new Langkit_Support.Cheap_Sets (Analysis_Unit, null);

   type Analysis_Unit_Type is new Analysis_Unit_Interface_Type with
   record
      Context          : Analysis_Context;
      --  The owning context for this analysis unit

      Ref_Count        : Natural;
      --  Ref count for the analysis unit. Note that in the Ada API you'll
      --  still have to call Inc_Ref/Dec_Ref manually.

      AST_Root         : ${root_node_type_name};

      File_Name        : Unbounded_String;
      --  The originating name for this analysis unit. This should be set even
      --  if the analysis unit was parsed from a buffer.

      Charset          : Unbounded_String;
      --  The parsing charset for this analysis unit, as a string

      TDH              : aliased Token_Data_Handler;
      --  The token data handler that handles all token data during parsing and
      --  owns it afterwards.

      Diagnostics      : Diagnostics_Vectors.Vector;
      --  The list of diagnostics produced for this analysis unit

      With_Trivia      : Boolean;
      --  Whether Trivia nodes were parsed and included in this analysis unit

      Is_Env_Populated : Boolean;
      --  Whether Populate_Lexical_Env was called on this unit. Used not to
      --  populate multiple times the same unit and hence avoid infinite
      --  populate recursions for circular dependencies.

      Rule             : Grammar_Rule;
      --  The grammar rule used to parse this unit

      AST_Mem_Pool     : Bump_Ptr_Pool;
      --  This memory pool shall only be used for AST parsing. Stored here
      --  because it is more convenient, but one shall not allocate from it.

      Destroyables     : Destroyable_Vectors.Vector;
      --  Collection of objects to destroy when destroying the analysis unit

      Referenced_Units : Analysis_Unit_Sets.Set;
      --  Units that are referenced from this one. Useful for
      --  visibility/computation of the reference graph.
   end record;

   % if _self.default_unit_file_provider:
   function Unit_File_Provider
     (Context : Analysis_Context)
      return Unit_File_Provider_Access_Cst is (Context.Unit_File_Provider);
   % endif

   overriding function Token_Data
     (Unit : access Analysis_Unit_Type)
      return Token_Data_Handler_Access
   is
     (Unit.TDH'Access);

   overriding procedure Register_Destroyable_Helper
     (Unit    : access Analysis_Unit_Type;
      Object  : System.Address;
      Destroy : Destroy_Procedure);

   overriding function Is_Referenced
     (Unit, Referenced : access Analysis_Unit_Type) return Boolean;
   --  Check whether the Referenced unit is referenced from Unit

   function Is_Referenced
     (Unit, Referenced : Analysis_Unit) return Boolean
   is
     (Unit.Is_Referenced (Referenced));
   --  Check whether the Referenced unit is referenced from Unit

   function Root (Unit : Analysis_Unit) return ${root_node_type_name} is
     (Unit.AST_Root);

   function Get_Context (Unit : Analysis_Unit) return Analysis_Context is
     (Unit.Context);

   function Get_Filename (Unit : Analysis_Unit) return String is
     (To_String (Unit.File_Name));

   function First_Token (Unit : Analysis_Unit) return Token_Type is
     (First_Token (Unit.TDH'Access));

   function Last_Token (Unit : Analysis_Unit) return Token_Type is
     (Last_Token (Unit.TDH'Access));

end ${_self.ada_api_settings.lib_name}.Analysis;
