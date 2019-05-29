require_relative 'lexer'
require_relative 'ast'
require_relative 'indent'
require_relative 'pretty_printer'
require_relative 'generic_parser'

module Astreo

  class Parser < GenericParser

    attr_accessor :tokens,:str
    include Indent

    def initialize
      @ppr=PrettyPrinter.new
      @verbose=false
      #@verbose=true
    end

    #............ parsing methods ...........
    def parse str
      begin
        @str=str
        @tokens=Lexer.new.tokenize(str)
        @tokens=@tokens.reject!{|tok| tok.is_a? [:comment,:newline]}
        ast=parse_module()
        #pp ast
      rescue Exception => e
        puts "PARSING ERROR : #{e}"
        puts "in C source at line/col #{showNext.pos}"
        puts e.backtrace
        abort
      end
    end

    def parse_module
      ret=Modul.new
      expect :module
      ret.name=Name.new(expect :name)
      expect :lbrace
      while !showNext.is_a?(:rbrace)
        ret.definitions << parse_definition
      end
      expect :rbrace
      ret
    end

    def parse_definition
      ret=Definition.new
      ret.name=Name.new(expect :name)
      expect :assign
      ret.type=parse_type()
      ret
    end

    def parse_type
      case showNext.kind
      when :lparen
        ret=parse_product_type
      else
        ret=parse_sum_type
      end
      ret
    end

    def parse_product_type
      ret=ProdType.new
      ret.fields << parse_fields
      ret.fields.flatten!
      ret
    end

    def parse_sum_type
      ret=SumType.new
      ret.constructors << parse_constructor
      while showNext.is_a? :or
        acceptIt
        ret.constructors << parse_constructor
      end
      if showNext.is_a? :attributes
        acceptIt
        ret.fields=parse_fields
      end
      ret
    end

    def parse_constructor
      ret=Constructor.new
      ret.name=Name.new(expect :name)
      if showNext.is_a? :lparen
        ret.fields << parse_fields
      end
      ret.fields.flatten!
      ret
    end

    def parse_fields
      ret=[]
      expect :lparen
      ret << parse_field
      while showNext.is_a? :comma
        acceptIt
        ret << parse_field
      end
      expect :rparen
      ret
    end

    def parse_field
      ret=Field.new
      ret.type=Name.new(expect :name)
      case showNext.kind
      when :qmark
        ret.repetitivity=Mark.new(acceptIt)
      when :star
        ret.repetitivity=Mark.new(acceptIt)
      end
      if showNext.is_a? :name
        ret.name=Name.new(acceptIt)
      end
      ret
    end

  end#class Parser
end #module
