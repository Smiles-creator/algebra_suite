module AlgebraSuite
  # Базовый класс для всех узлов
  class BooleanNode
    def simplify
      self 
    end
  end

  class Variable < BooleanNode
    attr_reader :name

    def initialize(name)
      @name = name.to_s.upcase
    end

    def to_s
      @name
    end
    
    def ==(other)
      other.is_a?(Variable) && @name == other.name
    end
  end

  class Not < BooleanNode
    attr_reader :operand

    def initialize(operand)
      raise ArgumentError, "Operand must be BooleanNode" unless operand.is_a?(BooleanNode)
      @operand = operand
    end

    def to_s
      "(NOT #{@operand})"
    end

    def ==(other)
      other.is_a?(Not) && @operand == other.operand
    end
  end


  class BinaryOperation < BooleanNode
    attr_reader :left, :right

    def initialize(left, right)
      raise ArgumentError, "Operands must be BooleanNode" unless left.is_a?(BooleanNode) && right.is_a?(BooleanNode)
      @left = left
      @right = right
    end

    def ==(other)
      other.class == self.class && @left == other.left && @right == other.right
    end
  end

  class And < BinaryOperation
    def to_s
      "(#{@left} AND #{@right})"
    end
  end

 
  class Or < BinaryOperation
    def to_s
      "(#{@left} OR #{@right})"
    end
  end
end