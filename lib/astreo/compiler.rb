require_relative 'ast'
require_relative 'version'
require_relative 'code'
require_relative 'parser'
require_relative 'visitor'
require_relative 'pretty_printer'
require_relative 'checker'
require_relative 'ruby_ast_codegen'

module Astreo

  class Compiler

    attr_accessor :options
    attr_accessor :ast
    attr_accessor :base_name

    def initialize
      @options={}
    end

    def header
      puts "Astreo (#{VERSION})- (c) JC Le Lann 2019" unless options[:mute]
    end

    def compile filename
      header
      puts "[WARNING] compiler : options forced to VERBOSE"
      @options[:verbose]=true
      @verbose=@options[:verbose] #ugly
      puts "=> compiling '#{filename}'" unless options[:mute]
      @ast=parse(filename)
      visit
      pretty_print
      checking
      ruby_codegen
      return true
    end

    def parse filename
      @base_name=File.basename(filename, ".ast")
      code=IO.read(filename)
      puts "=> building ast #{filename}"
      @ast=Parser.new.parse(code)
    end

    def gen_dot
      dotname="#{base_name}.dot"
      puts "=> generating dot #{dotname}" unless options[:mute]
      dot=DotPrinter.new.print(ast)
      dot.save_as dotname
    end

    def visit
      puts "=> dummy visit" unless options[:mute]
      Visitor.new.visit(ast)
    end

    def pretty_print
      puts "=> pretty_print" unless options[:mute]
      code=PrettyPrinter.new.visit(ast)
      pp_fname=@base_name+"_pp.ast"
      File.open(pp_fname,'w'){|f| f.puts code}
      puts "...saved as #{pp_fname}" unless options[:mute]
    end

    def checking
      puts "=> checking" unless options[:mute]
      Checker.new.check(ast)
    end

    def ruby_codegen

      generator=RubyAstCodeGen.new
      code=generator.generate_ast(ast)
      dot_ruby=@base_name+"_ast.rb"
      puts "=> generating Ruby  AST         : #{dot_ruby}"
      File.open(dot_ruby,'w'){|f| f.puts code}
      puts "=> generating Ruby .sexp parser : NIY"
      puts "=> generating Ruby .asdl parser : NIY"
    end

  end
end
