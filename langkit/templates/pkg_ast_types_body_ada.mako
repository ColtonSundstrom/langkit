## vim: filetype=makoada

<%namespace name="array_types"   file="array_types_ada.mako" />
<%namespace name="astnode_types" file="astnode_types_ada.mako" />
<%namespace name="enum_types"    file="enum_types_ada.mako" />
<%namespace name="list_types"    file="list_types_ada.mako" />
<%namespace name="struct_types"  file="struct_types_ada.mako" />

<% root_node_array = T.root_node.array_type() %>
<% no_builtins = lambda ts: filter(lambda t: not t.is_builtin(), ts) %>

with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

pragma Warnings (Off, "referenced");
with Adalog.Abstract_Relation;   use Adalog.Abstract_Relation;
with Adalog.Debug;               use Adalog.Debug;
with Adalog.Operations;          use Adalog.Operations;
with Adalog.Predicates;          use Adalog.Predicates;
with Adalog.Pure_Relations;      use Adalog.Pure_Relations;
with Adalog.Variadic_Operations; use Adalog.Variadic_Operations;

with Langkit_Support.Extensions; use Langkit_Support.Extensions;
with Langkit_Support.Relative_Get;
with Langkit_Support.Slocs;      use Langkit_Support.Slocs;
with Langkit_Support.Symbols;    use Langkit_Support.Symbols;

with ${_self.ada_api_settings.lib_name}.Analysis.Internal;
with ${_self.ada_api_settings.lib_name}.Analysis;
pragma Warnings (On, "referenced");

%if _self.env_hook_subprogram:
with ${_self.env_hook_subprogram.unit_fqn};
%endif

package body ${_self.ada_api_settings.lib_name}.AST.Types is

   use Eq_Node, Eq_Node.Raw_Impl;
   ##  Make logic operations on nodes accessible

   procedure Register_Destroyable is new
      Analysis_Interfaces.Register_Destroyable
        (AST_Envs.Lexical_Env_Type, AST_Envs.Lexical_Env, AST_Envs.Destroy);

   function Get_Lex_Env_Data
     (Node : access ${root_node_value_type}'Class) return Lex_Env_Data
   is (${_self.ada_api_settings.lib_name}.Analysis.Get_Lex_Env_Data
        (Analysis.Internal.Convert (Node.Unit)));

   % for struct_type in no_builtins(_self.struct_types):
   ${struct_types.body(struct_type)}
   % endfor

   % for array_type in _self.sorted_types(_self.array_types):
   % if array_type.element_type().should_emit_array_type:
   ${array_types.body(array_type)}
   % endif
   % endfor

   ${astnode_types.logic_helpers()}

   % for astnode in no_builtins(_self.astnode_types):
     % if not astnode.is_list_type:
       ${astnode_types.body(astnode)}
     % endif
   % endfor

   % for astnode in _self.astnode_types:
      % if astnode.is_root_list_type:
         ${list_types.body(astnode.element_type())}
      % elif astnode.is_list_type:
         ${astnode_types.body(astnode)}
      % endif
   % endfor

end ${_self.ada_api_settings.lib_name}.AST.Types;
