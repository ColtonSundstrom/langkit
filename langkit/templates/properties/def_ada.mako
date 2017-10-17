## vim: filetype=makoada

<%namespace name="scopes"  file="scopes_ada.mako" />
<%namespace name="helpers" file="helpers.mako" />

## Regular property function


% if property.abstract_runtime_check:

${"overriding" if property.overriding else ""} function ${property.name}
  ${helpers.argument_list(property, property.dispatching)}
   return ${property.type.name}
is (raise Property_Error
    with "Property ${property.name} not implemented on type "
    & Kind_Name (${Self.type.name} (${property.self_arg_name})));

% elif not property.abstract and not property.external:
${gdb_helper('property-start',
             property.qualname,
             '{}:{}'.format(property.location.file, property.location.line))}
pragma Warnings (Off, "is not referenced");
${"overriding" if property.overriding else ""} function ${property.name}
  ${helpers.argument_list(property, property.dispatching)}
   return ${property.type.name}
is
   ## We declare a variable Self, that has the named class wide access type
   ## that we can use to dispatch on other properties and all.
   Self : ${Self.type.name} := ${Self.type.name}
     (${property.self_arg_name});
   ${gdb_helper('bind', 'self', 'Self')}

   % if property._has_self_entity:
   Ent : ${Self.type.entity.name} :=
     ${Self.type.entity.name}'(Info => E_Info, El => Self);
   % endif

   % for arg in property.arguments:
   ${gdb_helper('bind', arg.name.lower, arg.name.camel_with_underscores)}
   % endfor

   Property_Result : ${property.type.name} := ${property.type.nullexpr};

   ## For each scope, there is one of the following subprograms that finalizes
   ## all the ref-counted local variables it contains, excluding variables from
   ## children scopes.
   <% all_scopes = property.vars.all_scopes %>
   % for scope in all_scopes:
      % if scope.has_refcounted_vars():
         procedure ${scope.finalizer_name};
      % endif
   % endfor

   ${property.vars.render()}

   % for scope in all_scopes:
      % if scope.has_refcounted_vars():
         procedure ${scope.finalizer_name} is
         begin
            ## Finalize the local variable for this scope
            % for var in scope.variables:
               % if var.type.is_refcounted:
                  Dec_Ref (${var.name});
               % endif
            % endfor
         end ${scope.finalizer_name};
      % endif
   % endfor

   % if property.memoized:
         <%
            key_length = 1 + len(property.arguments)
            if property.uses_entity_info:
               key_length += 1
         %>
         use Memoization_Maps;
         Mmz_Map : Map renames Node.Unit.Memoization_Map;
         Mmz_Cur : Cursor;
         Mmz_K   : Mmz_Key :=
           (Property => ${property.memoization_enum},
            Items    => new Mmz_Key_Array (1 ..  ${key_length}));
         Mmz_Val : Mmz_Value := (Kind => Mmz_Property_Error);
   % endif

begin
   % if property.memoized:
      ## If memoization is enabled for this property, look for an already
      ## computed result for this property.

      Mmz_K.Items (1) := (Kind => ${property.struct.memoization_kind},
                          As_${property.struct.name} => Self);
      % for i, arg in enumerate(property.arguments, 2):
         Mmz_K.Items (${i}) := (Kind => ${arg.type.memoization_kind},
                                As_${arg.type.name} => ${arg.name});
         % if arg.type.is_refcounted:
            Inc_Ref (Mmz_K.Items (${i}));
         % endif
      % endfor
      % if property.uses_entity_info:
         Mmz_K.Items (${key_length}) :=
           (Kind => ${T.entity_info.memoization_kind},
            As_${T.entity_info.name} => ${property.entity_info_name});
      % endif

      declare
         use Memoization_Maps;
         Inserted : Boolean;
      begin
         Mmz_Map.Insert (Mmz_K, Mmz_Val, Mmz_Cur, Inserted);

         ## Once we got past the last statement:
         ##
         ## * Either the insertion succeeded, in which case the only ownership
         ##   share for Mmz_K got transfered to Mmz_Map.
         ##
         ## * Either is failed, in which case Mmz_K is no longer useful: we
         ##   must destroy it.

         if not Inserted then
            Destroy (Mmz_K.Items);
            Mmz_Val := Memoization_Maps.Element (Mmz_Cur);
            if Mmz_Val.Kind = Mmz_Property_Error then
               raise Property_Error;
            else
               Property_Result := Mmz_Val.As_${property.type.name};
               % if property.type.is_refcounted:
                  Inc_Ref (Property_Result);
               % endif
               return Property_Result;
            end if;
         end if;
      end;
   % endif

   ${scopes.start_scope(property.vars.root_scope)}
   ${property.constructed_expr.render_pre()}

   Property_Result := ${property.constructed_expr.render_expr()};
   % if property.type.is_refcounted:
      Inc_Ref (Property_Result);
   % endif
   ${scopes.finalize_scope(property.vars.root_scope)}

   % if property.memoized:
      ## If memoization is enabled for this property, save the result for later
      ## re-use.
      Mmz_Val := (Kind => ${property.type.memoization_kind},
                    As_${property.type.name} => Property_Result);
      Mmz_Map.Replace_Element (Mmz_Cur, Mmz_Val);
      % if property.type.is_refcounted:
         Inc_Ref (Property_Result);
      % endif
   % endif

   return Property_Result;

% if property.vars.root_scope.has_refcounted_vars(True):
   exception
      when Property_Error =>
         % for scope in all_scopes:
            % if scope.has_refcounted_vars():
               ${scope.finalizer_name};
            % endif
         % endfor

         % if property.memoized:
            Mmz_Map.Replace_Element (Mmz_Cur, Mmz_Val);
         % endif

         raise;
% endif
end ${property.name};
${gdb_helper('end', property.qualname)}
% endif
