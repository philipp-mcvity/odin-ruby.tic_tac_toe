#!/usr/bin/env ruby
# frozen_string_literal: true

# handels Input
module Input
  def input_get
    good = false
    until good == true
      input_raw = gets.chomp.downcase
      case input_raw.match?(/^[abc][123]$/)
      when true then good = true
      else puts "> invalid input\n  feasible: a-c, 1-3 \n \
 input-style: a1 or A1\n> choose again:"
      end
    end
    input_eva(input_raw)
  end

  def input_eva(input_raw)
    column = case input_raw[0]
             when 'a' then 0
             when 'b' then 1
             else 2
             end
    row = input_raw[1].to_i - 1
    [column, row]
  end
end

def input_yes_no
  good = false
  until good == true
    input = gets.chomp.downcase
    case input.match?(/^[yn]$/)
    when true then good = true
    else yield
    end
  end
  input
end

# draws and tracks the board
class Grid
  def initialize
    @h0 = ['', '', '']
    @h1 = ['', '', '']
    @h2 = ['', '', '']
    @field = [@h0, @h1, @h2]
    reset_arrys
  end

  def draw_field
    puts
    print "   |  A   B   C\n"
    print "---|-----------\n"
    print " 1 |  #{value(0, 0)}   #{value(1, 0)}   #{value(2, 0)}\n"
    print " 2 |  #{value(0, 1)}   #{value(1, 1)}   #{value(2, 1)}\n"
    print " 3 |  #{value(0, 2)}   #{value(1, 2)}   #{value(2, 2)}\n\n"
  end

  private

  def value(column, row)
    @field[column][row].empty? ? ' ' : @field[column][row]
  end

  def field(column, row)
    @field[column][row]
  end

  protected

  def field_set(column, row, mark)
    if @field[column][row].empty?
      @field[column][row] = mark
      reset_arrys
      true
    else
      false
    end
  end

  def reset_arrys
    @v0 = [@field[0][0], @field[1][0], @field[2][0]]
    @v1 = [@field[0][1], @field[1][1], @field[2][1]]
    @v2 = [@field[0][2], @field[1][2], @field[2][2]]
    @d1 = [@field[0][0], @field[1][1], @field[2][2]]
    @d2 = [@field[2][0], @field[1][1], @field[0][2]]
    @all_arrays = [@h0, @h1, @h2, @v0, @v1, @v2, @d1, @d2]
  end

  def victory?
    victory = false
    reset_arrys
    @all_arrays.each do |ary|
      next if ary.any?(&:empty?)
      next if ary.uniq.length == 2

      victory = true if ary.uniq.length == 1
    end
    victory
  end
end

# instantiates the game
class Game < Grid
  include Input
  attr_reader :grid, :round, :player

  def initialize
    @grid = Grid.new
    @grid.draw_field
    @round = 1
    @player = 2
    play_round
  end

  def play_round
    puts "Player #{players_turn} - place #{players_mark}"
    cell = input_get
    evaluate_move(cell[0], cell[1])
    evaluate_next
  end

  def evaluate_move(column, row)
    if @grid.field_set(column, row, players_mark)
      @round += 1
      @grid.draw_field
    else
      @grid.draw_field
      puts "already marked\n> choose again:"
      players_turn
    end
  end

  def evaluate_next
    if @grid.victory?
      puts "Victory! Player #{player}  > #{players_mark} <  wins!\n"
      new_game
    elsif @round < 10
      play_round
    else
      puts 'Draw!'
      new_game
    end
  end

  def new_game
    puts 'new game? [y/n]'
    if input_yes_no do
      puts "> invalid input\n  new game?\n  y = yes, new game\n  n = no, exit\n\
> please enter 'y' or 'n':"
    end == 'y'
      5.times { |i| puts i == 3 ? '*******new game*******' : '' }
      initialize
    end
  end

  private

  def players_turn
    @player = (@player == 1 ? 2 : 1)
  end

  def players_mark
    @player == 1 ? 'x' : 'o'
  end
end

Game.new
