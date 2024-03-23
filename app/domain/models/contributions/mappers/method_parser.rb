# frozen_string_literal: true

require 'parser/ruby31'

module CodePraise
  module Mapper
    # Find all method in a file
    module MethodParser
      def self.parse_methods(line_entities)
        ast = Parser::Ruby31.parse(line_of_code(line_entities).dump)
        all_methods_hash(ast, line_entities)
      end

      def self.line_of_code(line_entities)
        line_entities.map(&:code).join("\n")   
      end

      def self.all_methods_hash(ast, line_entities)
        methods_ast = []
        find_methods_tree(ast, methods_ast)

        dsf_array = distinguish_success_or_fail_entities(methods_ast, line_entities)
        dsf_array = adjust_dsf_array(methods_ast, line_entities, dsf_array)

        result = []
        dsf_array.each_with_index do |item, index|
          method_ast = methods_ast[index]
          result.push(name: method_name(method_ast),
                      lines: line_entities[item[0]..item[1]],
                      type: method_type(method_ast))
        end
        result
        # methods_ast.inject([]) do |result, method_ast|
        #   if method_ast.class == Hash
        #     result.push(name: method_ast[:name],
        #                 lines: line_entities[dsf_array[index][0]..dsf_array[index][1]],
        #                 type: method_ast[:type])
        #   else
        #     result.push(name: method_name(method_ast),
        #               lines: select_entities(method_ast, line_entities),
        #               type: method_type(method_ast))
        #   end
        #   index += 1
        #   result
        # end
      end

      def self.select_entities(methods_ast, line_entities)
        success_parse_entity = []
        methods_ast.each{ |method_ast|
          if method_ast.class != Hash
            first_no = method_ast.loc.first_line - 1
            last_no = method_ast.loc.last_line - 1
            success_parse_entity.append([first_no, last_no])
          end
        }
        success_parse_entity
      end

      private

      def self.distinguish_success_or_fail_entities(methods_ast, line_entities)
        success_parse_entity = select_entities(methods_ast, line_entities)
        return success_parse_entity if !methods_ast.to_s.include?('unknow method')

        adjust_success_array(success_parse_entity)
      end

      def self.method_type(method_ast)
        if method_ast.is_a?(Hash)
          method_ast[:type]
        else
          method_ast.type.to_s
        end
      end

      def self.method_name(method_ast)
        if method_ast.is_a?(Hash)
          method_ast[:name]
        else
          method_ast.loc.expression.source_line
        end
      end

      def self.adjust_dsf_array(methods_ast, line_entities, dsf_array)
        if methods_ast[0].instance_of?(Hash)
          begin
            head_pointer = dsf_array[0][0]
            dsf_array.insert(0, [0, head_pointer - 1])
          rescue NoMethodError
            dsf_array.insert(0, [0, line_entities.length - 1])
          end
        end
        dsf_array
      end

      def self.adjust_success_array(success_parse_entity)
        (success_parse_entity.length - 1).downto(1) do |i|
          current_end = success_parse_entity[i - 1][1]
          next_start = success_parse_entity[i][0]
      
          if current_end + 1 != next_start && current_end + 1 !=  next_start - 1
            success_parse_entity.insert(i, [current_end + 1, next_start - 1])
          end
        end
        success_parse_entity
      end

      def self.find_methods_tree(ast, methods_ast)
        return nil unless ast.is_a?(Parser::AST::Node)

        if %i[def block defs].include?(ast.type)
          methods_ast.append(ast)
        else
          ast.children.each do |child_ast|
            child_ast = Parser::Ruby31.parse(child_ast) if child_ast.instance_of?(String)
            find_methods_tree(child_ast, methods_ast)
            rescue Parser::SyntaxError => e
              puts "Parsing error :
              #{e.message}"
              methods_ast.append({'name': 'unknow method', 'lines': child_ast, 'type': 'SyntaxError'})
          end
        end
      end

      private_class_method :find_methods_tree, :method_name, :method_type
    end
  end
end
