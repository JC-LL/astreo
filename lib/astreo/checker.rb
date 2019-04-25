require_relative 'code'
require_relative 'indent'

module Astreo

  class Checker < Visitor

    def initialize
      @verbose=true
      @verbose=false
    end

    def check ast,args=nil
      puts " -NIY"
      ast.accept(self)
    end

    # check that :
    # - Types and subtypes are unique.

    def visitModul mod,args=nil
      mod.name.accept(self)
      mod.definitions.each{|defi| defi.accept(self)}
    end

    def visitDefinition definition,args=nil
      definition.name.accept(self)
      definition.type.accept(self)
    end

    def visitSumType type,args=nil
      type.constructors.each{|constructor| constructor.accept(self)}
    end

    def visitProdType type,args=nil
      type.fields.each{|field| field.accept(self)}
    end

    def visitConstructor constructor,args=nil
      constructor.name.accept(self)
      constructor.fields.each{|field| field.accept(self)}
    end

    def visitField field,args=nil
      field.type.accept(self)
      field.repetitivity.accept(self) if field.repetitivity
      field.name.accept(self)
    end

    def visitName name,args=nil
      name.to_s
    end

    def visitMark mark,args=nil
      mark.tok.to_s
    end
  end #class Checker
end #module
