module AlgebraSuite
  # Базовый класс для всех узлов синтаксического дерева (AST).
  # Определяет общий интерфейс для упрощения выражений.
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
      raise ArgumentError, "Operand must be a BooleanNode" unless operand.is_a?(BooleanNode)
      @operand = operand
    end

    def to_s
      "(NOT #{@operand})"
    end

    def ==(other)
      other.is_a?(Not) && @operand == other.operand
    end


    def simplify
      simplified_operand = @operand.simplify
      
      return simplified_operand.operand if simplified_operand.is_a?(Not)
      
      if simplified_operand.is_a?(Variable)
        return Variable.new('FALSE') if simplified_operand.name == 'TRUE'
        return Variable.new('TRUE') if simplified_operand.name == 'FALSE'
      end

      Not.new(simplified_operand)
    end
  end

  # Базовый класс для бинарных операций (имеют левого и правого операнда).
  class BinaryOperation < BooleanNode
    attr_reader :left, :right

    def initialize(left, right)
      raise ArgumentError, "Operands must be BooleanNodes" unless left.is_a?(BooleanNode) && right.is_a?(BooleanNode)
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

    def simplify
      l = @left.simplify
      r = @right.simplify

      return Variable.new('FALSE') if contains_false?(l, r)
      return r if true?(l)
      return l if true?(r)
      return l if l == r
      return Variable.new('FALSE') if contradiction?(l, r)

      And.new(l, r)
    end

    private

    def contains_false?(l, r)
      (l.is_a?(Variable) && l.name == 'FALSE') || (r.is_a?(Variable) && r.name == 'FALSE')
    end

    def true?(node)
      node.is_a?(Variable) && node.name == 'TRUE'
    end

    def contradiction?(l, r)
      (l.is_a?(Not) && l.operand == r) || (r.is_a?(Not) && r.operand == l)
    end
  end


  class Or < BinaryOperation
    def to_s
      "(#{@left} OR #{@right})"
    end

    def simplify
      l = @left.simplify
      r = @right.simplify

      return Variable.new('TRUE') if contains_true?(l, r)
      return r if false?(l)
      return l if false?(r)
      return l if l == r
      return Variable.new('TRUE') if tautology?(l, r)

      Or.new(l, r)
    end

    private

    def contains_true?(l, r)
      (l.is_a?(Variable) && l.name == 'TRUE') || (r.is_a?(Variable) && r.name == 'TRUE')
    end

    def false?(node)
      node.is_a?(Variable) && node.name == 'FALSE'
    end

    def tautology?(l, r)
      (l.is_a?(Not) && l.operand == r) || (r.is_a?(Not) && r.operand == l)
    end
  end

  # Парсер выражений методом рекурсивного спуска.
  # Преобразует строку вида "A AND (B OR C)" в дерево объектов AST.
  class Parser
    def initialize
      @tokens = []
      @pos = 0
    end

    def parse(expression)
      tokenize(expression)
      @pos = 0
      return nil if @tokens.empty?

      result = parse_or

      raise SyntaxError, "Unexpected token '#{current_token}' at position #{@pos}" if @pos < @tokens.size

      result
    end

    private

    def tokenize(expression)
      @tokens = []
      expression.scan(/\w+|[()]/) do |match|
        token = match.upcase
        case token
        when 'AND', 'OR', 'NOT', 'TRUE', 'FALSE', '(', ')'
          @tokens << token
        else
          @tokens << "VAR:#{token}"
        end
      end
    end

    def current_token
      @tokens[@pos]
    end

    def consume(expected = nil)
      token = current_token
      raise SyntaxError, "Expected #{expected}, got #{token || 'END OF INPUT'}" if expected && token != expected
      
      @pos += 1
      token
    end

    def parse_or
      left = parse_and
      while current_token == 'OR'
        consume('OR')
        right = parse_and
        left = Or.new(left, right)
      end
      left
    end

    def parse_and
      left = parse_not
      while current_token == 'AND'
        consume('AND')
        right = parse_not
        left = And.new(left, right)
      end
      left
    end

    
    def parse_not
      if current_token == 'NOT'
        consume('NOT')
        return Not.new(parse_not)
      end
      parse_primary
    end

    def parse_primary
      token = current_token
      raise SyntaxError, "Unexpected end of expression" if token.nil?

      if token == '('
        consume('(')
        expr = parse_or
        consume(')')
        return expr
      end

      if token&.start_with?('VAR:')
        name = token.sub('VAR:', '')
        consume
        return Variable.new(name)
      end

      if ['TRUE', 'FALSE'].include?(token)
        consume
        return Variable.new(token)
      end

      raise SyntaxError, "Unexpected token: #{token}"
    end
  end

  # Исключение, возникающее при синтаксической ошибке во входном выражении
  class SyntaxError < StandardError; end

 
  # Принимает строку, парсит её, упрощает дерево и возвращает результат строкой.
  class BooleanSimplifier
    def self.simplify_expression(expression_string)
      parser = Parser.new
      ast = parser.parse(expression_string)
      return "" if ast.nil?

      simplified_ast = ast.simplify
      
      loop do
        next_ast = simplified_ast.simplify
        break if next_ast.to_s == simplified_ast.to_s
        simplified_ast = next_ast
      end

      simplified_ast.to_s
    end
  end
end