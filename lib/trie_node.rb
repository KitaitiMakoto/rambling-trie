class TrieNode
  attr_reader :letter, :children

  def initialize(word)
    @letter = nil
    @is_terminal = false
    @children = {}

    unless word.nil?
      @letter = word.slice!(0)
      @is_terminal = word.empty?
      add_branch_from(word)
    end

  end

  def terminal=(terminal)
    @is_terminal = terminal
  end

  def terminal?
    @is_terminal
  end

  def add_branch_from(word)
    unless word.empty?
      first_letter = word.slice(0)

      if @children.has_key?(first_letter)
        word.slice!(0)
        @children[first_letter].add_branch_from(word)
      else
        @children[first_letter] = TrieNode.new(word)
      end
    end
  end

  def has_child?(word)
    return true if word.empty?

    first_letter = @letter

    return @children[first_letter].has_child?(word) if @children.has_key?(first_letter)
    false
  end
end
