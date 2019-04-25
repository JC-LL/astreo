module Astreo
  class Ast
    def accept(visitor, arg=nil)
      name = self.class.name.split(/::/)[1]
      visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end
  end

  class Modul  < Ast
    attr_accessor :name,:definitions
    def initialize
      @definitions=[]
    end
  end

  class Definition < Ast
    attr_accessor :name,:type
  end

  class Type < Ast
    attr_accessor :fields
    def initialize
      @fields=[]
    end
  end

  class SumType < Type
    attr_accessor :constructors
    def initialize
      super()
      @constructors=[]
    end
  end

  class ProdType < Type
    def initialize
      super()
    end
  end

  class Constructor < Ast
    attr_accessor :name,:fields
    def initialize
      @fields=[]
    end
  end

  class Attributes < Ast
    attr_accessor :fields
    def initialize
      @fields=[]
    end
  end

  class Field < Ast
    attr_accessor :type,:repetitivity,:name
    def initialize
      @repetitivity=nil
    end
  end

  class Name < Ast
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end

    def to_s
      tok.to_s
    end
  end

  class Mark < Ast
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end

    def to_s
      tok.to_s
    end
  end

  #======== primitives =======
  class Identifier < Ast
  end

  class Bool < Ast
  end

  class Byte < Ast
  end

  class Int < Ast
  end

  class Char <Ast
  end

  class String < Ast
  end

end
