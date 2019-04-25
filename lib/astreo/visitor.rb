require_relative 'code'
require_relative 'indent'

module Astreo

  class Visitor

    include Indent

    attr_accessor :code

    def initialize
      @ind=-2
      @verbose=true
      @verbose=false
    end

    def visit ast,args=nil
      ast.accept(self)
    end

    def visitModul mod,args=nil
      indent "visitModul"
      mod.name.accept(self)
      mod.definitions.each{|defi| defi.accept(self)}
      dedent
    end

    def visitDefinition definition,args=nil
      indent "visitDefinition"
      definition.name.accept(self)
      definition.type.accept(self)
      dedent
    end

    def visitSumType type,args=nil
      indent "visitSumType"
      type.constructors.each{|constructor| constructor.accept(self)}
      type.fields.each{|field| field.accept(self)} if type.fields.any?
      dedent
    end

    def visitProdType type,args=nil
      indent "visitProdType"
      type.fields.each{|field| field.accept(self)}
      dedent
    end

    def visitConstructor constructor,args=nil
      indent "visitConstructor"
      constructor.name.accept(self)
      constructor.fields.each{|field| field.accept(self)}
      dedent
    end

    def visitField field,args=nil
      indent "visitField"
      field.type.accept(self)
      field.repetitivity.accept(self) if field.repetitivity
      field.name.accept(self)
      dedent
    end

    def visitName name,args=nil
      indent "visitName '#{name.to_s}'"
      dedent
    end

    def visitMark mark,args=nil
      indent "visitMark"
      mark.tok.to_s
      dedent
    end
  end #class Visitor
end #module
