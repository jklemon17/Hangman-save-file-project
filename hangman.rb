require "yaml"
class SecretWord
  attr_reader :value
  def initialize(*word)
    if word[0].nil?
      words = File.readlines "5desk.txt"
      hangman_list = words.select{|x| x.strip.length > 4 && x.strip.length <13}
      @value = hangman_list[rand(hangman_list.length)].strip
    else
      @value = word[0]
    end
  end
end

class Game
  attr_reader :answer
  attr_accessor :incorrect, :win, :state, :lose, :remaining

  def initialize(*q)
    q[0].nil? ? @answer = SecretWord.new : @answer = SecretWord.new(q[0])
    @correct = []
    @incorrect = []
    @remaining = 6
    @state = "_ " * @answer.value.length
    puts "The secret word has #{@answer.value.length} letters."
    #puts @state
  end

  def gallows(number)
    case number
    when 6
"        ___
       |   |
           |
           |
           |
         __|__
"
    when 5
"        ___
       |   |
       o   |
           |
           |
         __|__
"
    when 4
"        ___
       |   |
       o   |
       |   |
           |
         __|__
"
    when 3
"        ___
       |   |
       o   |
      /|   |
           |
         __|__
"
    when 2
"        ___
       |   |
       o   |
      /|\\  |
           |
         __|__
"
    when 1
"        ___
       |   |
       o   |
      /|\\  |
      /    |
         __|__
"
    when 0
"        ___
       |   |
       o   |
      /|\\  |
      / \\  |
         __|__
"
    end
  end

  def guess(letter)
    if letter == "save"
      self.save
    elsif @answer.value.downcase.index(letter)
      start = 0
      while @answer.value.downcase.index(letter,start) && start < (@answer.value.length) do
        start = @answer.value.downcase.index(letter,start) + 1
        @state[(start - 1) * 2] = letter
      end
      puts "Correct!"
    else
      puts "Incorrect!"
      @incorrect << letter
      @remaining -= 1
    end
  end

  def win_or_lose?
    @win = true unless @state.index("_")
    @lose = true unless @remaining > 0
  end

  def print_state
    puts self.gallows(@remaining)
    puts ""
    print "Incorrect guesses: #{@incorrect}\n" if @incorrect.length > 0
    puts "Incorrect guesses remaining: #{@remaining}"
    puts ""
    puts @state
  end

  def save
    File.open('savegame', 'w') {|f| f.write(YAML.dump(self)) }
  end
end

def play_again?
  puts "Would you like to play another game? Y/N"
  answer = gets.chomp.downcase
  $quit = true if answer == "n"
end

until $quit == true
  puts "Load a saved game? Y/N"
  answer = gets.chomp.downcase
  if answer != "y"
    currentGame = Game.new
  elsif File.exists? 'savegame'
    currentGame = YAML.load(File.read('savegame'))
  else
    puts "No saved data found. Starting a new game."
    currentGame = Game.new
  end

  until currentGame.win == true || currentGame.lose == true do
    currentGame.print_state
    puts "Guess a letter: "
    guess = gets.chomp.downcase
    currentGame.guess(guess)
    currentGame.print_state
    currentGame.win_or_lose?
    #serialized_game = YAML.dump(currentGame)
    #puts serialized_game
  end

  if currentGame.win == true
    puts "Congratulations, you win!"
    play_again?
  else
    puts "Sorry, you lose. Try again!"
    play_again?
  end
end
