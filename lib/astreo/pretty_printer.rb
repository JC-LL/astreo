require_relative 'code'
require_relative 'indent'
require_relative 'visitor'
require_relative 'formater'

module Astreo

  class PrettyPrinter < Visitor

    include Indent

    attr_accessor :code

    def initialize
      @ind=-2
      @verbose=true
    end

    def visit ast,args=nil
      @code=Code.new
      ast.accept(self)
      str=@code.finalize
      formated_code=Formater.new.format(str)
      return formated_code.finalize
    end

    def visitModul mod,args=nil
      name=mod.name.accept(self)
      code << "-- generated automatically by Astreo ASDL tool"
      code << "module #{name} {"
      code.indent=2
      mod.definitions.each{|definition|
        code << definition.accept(self)
      }
      code.indent=0
      code << "}"
    end

    def visitDefinition definition,args=nil
      name=definition.name.accept(self)
      type=definition.type.accept(self)
      "#{name} = #{type}"
    end

    def visitSumType type,args=nil
      constructors=type.constructors.collect{|constructor| constructor.accept(self)}
      ret=constructors=constructors.join(' | ')
      if type.fields.any?
        fields=type.fields.collect{|field| field.accept(self)}
        ret+=" attributes (#{fields.join(",")})"
      end
    end

    def visitProdType type,args=nil
      fields=type.fields.collect{|field| field.accept(self)}
      "("+fields.join(",")+")"
    end

    def visitConstructor constructor,args=nil
      name=constructor.name.accept(self)
      fields=constructor.fields.collect{|field| field.accept(self)}
      fields=fields.join(",")
      parenth="(#{fields})" if fields.size>0
      "#{name}#{parenth}"
    end

    def visitField field,args=nil
      type=field.type.accept(self)
      rep=field.repetitivity.accept(self) if field.repetitivity
      name=field.name.accept(self)
      "#{type}#{rep} #{name}"
    end

    def visitName name,args=nil
      name.to_s
    end

    def visitMark mark,args=nil
      mark.tok.to_s
    end
  end #class Visitor
end #module
