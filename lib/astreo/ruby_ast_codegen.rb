require_relative 'code'
require_relative 'indent'

module Astreo

  class RubyAstCodeGen < Visitor

    def initialize
      @verbose=true
      @verbose=false
      @super_type_of={}
    end

    def generate_ast ast,args=nil
      copy_astreo
      ast.accept(self)
    end

    def copy_astreo
      astreo_path=__dir__
      system("cp #{astreo_path}/astreo_native_types.rb .")
      system("cp #{astreo_path}/code.rb .")
    end

    def visitModul mod,args=nil
      code=Code.new
      name=mod.name.accept(self)
      code << "require_relative 'astreo_native_types'"
      code.newline
      code << "module #{name}"
      code.indent=2
      #code << "include Astreo"
      mod.definitions.collect{|defi| code << defi.accept(self)}
      code.indent=0
      code.newline
      code << "end # module"
      return code.finalize
    end

    def visitDefinition definition,args=nil
      code=Code.new
      type=definition.name.accept(self)
      code.newline
      super_class=@super_type_of[type] ? @super_type_of[type] : "Astreo::AstNode"
      code << "class #{type} < #{super_class}"
      code.indent=2
      case definition.type
      when ProdType
        attrs=definition.type.fields.collect{|field| field.name.to_s}
        code << "attr_accessor #{attrs.map{|e| ":"+e}.join(',')}"
      when SumType
        attrs=definition.type.fields.collect{|field| field.name.to_s}
        code << "attr_accessor #{attrs.map{|e| ":"+e}.join(',')}"
        code_sum=definition.type.accept(self,type)
      end
      code << constructor(definition.type.fields)
      code.indent=0
      code << "end"
      code.newline
      (code << code_sum) if code_sum
      code
    end

    def constructor fields
      code=Code.new
      params=fields.collect{|field| field.name.to_s}
      pinits=fields.collect do |field|
        field.repetitivity.to_s=="*" ? "[]" : "nil"
      end
      args=params.zip(pinits).collect{|e| e.join("_=")}
      code << "def initialize #{args.join(',')}"
      code.indent=2
      ivars=params.map{|e| "@"+e}
      code << ivars.join(",")+" = "+params.map{|e| e+"_"}.join(",")
      code.indent=0
      code << "end"
      code
    end

    def visitSumType type,super_type
      @super_type_of||={}
      code=Code.new
      type.constructors.each do |constructor|
        if constructor.fields.empty? #then remember it has a super_type
          @super_type_of[constructor.name.to_s]=super_type
        end
        code << constructor.accept(self,super_type) if constructor.fields.any?
      end
      if type.fields.any?
        fields=type.fields.each{|field| field.accept(self)}
      end
      code
    end

    def visitProdType type,args=nil
      attrs=type.fields.collect{|field| field.accept(self)}
      "attr_accessor #{attrs.join(',')}"
    end

    def visitConstructor constructor,super_type
      code=Code.new
      name=constructor.name.accept(self)
      code << "class #{name} < #{super_type}"
      constructor.fields.each{|field| field.accept(self)}
      code << "end"
      code.newline
      code
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
