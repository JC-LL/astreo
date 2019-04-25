require_relative 'code'

module Astreo

  class AstNode
    def accept(visitor, arg=nil)
      name = self.class.name.split(/::/)[1]
      visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end

    def sexp
      name = self.class.name.split(/::/)[1]
      attributes= instance_variables.collect do |ivname|
        attr_name=ivname.to_s[1..-1]
        ivar=self.instance_variable_get(ivname)
        case ivar
        when Array
          attr_value=ivar.map{|e| e.sexp}.join(" ")
        else
          attr_value=ivar.respond_to?(:sexp) ?  ivar.sexp : ivar.to_s
        end
        "(#{attr_name} #{attr_value})"
      end
      code=Code.new
      code << "(#{name} #{attributes.join(" ")})"
      code.to_s
    end
  end

  class NativeType < AstNode
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end

    def sexp
      tok.to_s
    end
  end

  class IDENT < NativeType
  end

  class INT < NativeType
  end

  class FLOAT < NativeType
  end

  class STRING < NativeType
  end

  class BOOL < NativeType
  end
end
