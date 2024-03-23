# frozen_string_literal: true

module CodePraise
  module Mapper
    # Find the testcase in test file by using AST (ruby-parser gem)
    module TestCaseParser
      def self.parse(code)
        ast = Parser::Ruby31.parse(code.dump)
        test_cases = []
        find_test_cases(ast, test_cases)
        test_cases.map do |test_case|
          {
            message: test_message(test_case),
            first_line: test_case.loc.first_line,
            last_line: test_case.loc.last_line,
            top_describe: find_describe(ast).scan(/'([\w ]*)'|"([\w ]*)"|describe (\w+)/).flatten.reject(&:nil?).first
          }
        end
      end

      def self.find_describe(ast)
        return unless ast.is_a?(Parser::AST::Node)

        if ast.type == :block && ast.children[0].to_a[1] == :describe
          return ast.children[0].loc.expression.source_line
        else
          ast.children.map do |child|
            find_describe(child)
          end.flatten.reject(&:nil?).first
        end
      end

      def self.find_test_cases(ast, result)
        return unless ast.is_a?(Parser::AST::Node)

        if ast.children[0].is_a?(Parser::AST::Node) && ast.children[0].to_a[1] == :it
          result << ast
        else
          ast.children.each do |child|
            find_test_cases(child, result)
          end
        end
      end

      def self.test_message(test_case)
        test_case.children[0].loc.expression.source
      end
    end
  end
end
