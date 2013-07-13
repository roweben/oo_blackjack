class Card
  attr_reader :face, :suit

  def initialize(face, suit)
    @face = face
    @suit = suit
  end

  def to_s
    face + " of " + get_suit
  end

  def get_suit
    case suit
      when 'H' then 'Hearts'
      when 'C' then 'Clubs'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
    end
  end

end

class Deck
  attr_accessor :cards

  def initialize
   @cards = []
   create_deck
  end

  def create_deck
    suits = ['H', 'C', 'D', 'S']
    faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
    puts
    puts "Creating new deck!"
    suits.each do |suit|
      faces.each do |face|
        self.cards.push Card.new(face, suit)
      end
    end
  end

  def deal_one
    if cards.size > 0
      cards.delete_at(rand(cards.size))
    else
      create_deck
      deal_one
    end
  end
end

class Hand
  attr_reader :cards
  attr_accessor :hide_first_card

  def initialize(p_or_d)
    @cards = []
    @hide_first_card = p_or_d.name == 'Dealer' ? true : false
  end

  def to_s
    y=0
    cards.each do |card|
      if y==0
        puts (hide_first_card==true) ? '1st card is hidden' : card.to_s
      else
        puts card.to_s        
      end
      y += 1
    end    
  end
end

class Player
  attr_reader :name
  attr_accessor :hand

  def initialize
    @hand = Hand.new(self)
    @name = self.is_a?(Dealer) ? 'Dealer' : ask_for_name
  end

  def ask_for_name
    puts 
    print "Player, what is your name?  "
    name = gets.chomp
    puts "Greetings to our player, #{name}."
    name
  end

  def show_hand
    puts #blank line
    participant = self.is_a?(Dealer) ? 'Dealer' : name
    puts "#{participant}'s hand is:"
    hand.to_s
  end

  def cards
    hand.cards
  end

end

class Dealer < Player

end

class Blackjack
  attr_accessor :player, :dealer, :deck, :more_to_hand
  def initialize(player, dealer)
    @player = player
    @dealer = dealer
    @more_to_hand = true
    @deck = Deck.new
  end

  def start_game
    play_a_hand = true
    puts()
    puts "Hello #{player.name}, let's play Blackjack!"
    while play_a_hand
      deal_first_four_cards
      if self.more_to_hand
        player_turn(player)
      end
      if self.more_to_hand
        dealer_turn
      end
      if self.more_to_hand
        player_turn(dealer)
      end
      if self.more_to_hand
        announce_winner
      end
      puts
      print "#{player.name}, would you like to play another hand?  Y/N:  "
      y_n = gets.chomp
      if y_n.upcase == 'Y'
        player.hand = Hand.new(player)
        dealer.hand = Hand.new(dealer)
        self.more_to_hand = true
      else
        play_a_hand = false
      end
    end
  end

  private
  def deal_first_four_cards
      player.cards.push deck.deal_one
      player.show_hand
      dealer.cards.push deck.deal_one
      dealer.show_hand
      player.cards.push deck.deal_one
      player.show_hand
        #are player's first two cards Blackjack
      if is_blackjack?(calculate_hand_value(player.cards))
        puts blackjack_message(player.name)
      end
      if more_to_hand
        dealer.cards.push deck.deal_one
        dealer.show_hand
          #are dealer's first two cards Blackjack
        if is_blackjack?(calculate_hand_value(dealer.cards))
          dealer.hand.hide_first_card = false
          puts
          puts blackjack_message(dealer.name)
          dealer.show_hand
        end
      end
  end

  def player_turn(p_or_d)
    new_card = true 
    while new_card==true && more_to_hand
      puts()
      puts "#{p_or_d.name}, your hand total is #{calculate_hand_value(p_or_d.cards)}."
      print "Would you like another card, Y/N:  "
      y_n = gets.chomp
      if y_n.upcase == 'Y'
        p_or_d.cards.push deck.deal_one
        p_or_d.show_hand
        new_card = continue_play?(calculate_hand_value(p_or_d.cards), p_or_d.name)
      else
        new_card = false
      end
    end
 end

  def dealer_turn
    while calculate_hand_value(dealer.cards) < 17
      puts
      puts "Dealer takes another card."
      dealer.cards.push deck.deal_one
      more_to_hand = continue_play?(calculate_hand_value(dealer.cards), dealer.name)
      if !more_to_hand
        dealer.hand.hide_first_card = false
      end
      dealer.show_hand
    end
    if dealer.hand.hide_first_card == true
      dealer.hand.hide_first_card = false
      dealer.show_hand
    end
  end

  def announce_winner
    puts
    puts "SUMMARY OF HAND:"
    if calculate_hand_value(dealer.cards) > calculate_hand_value(player.cards) 
      puts "Our winner:  Congrats to Dealer!!!"
      puts "Winning hand of #{calculate_hand_value(dealer.cards)} vs. #{calculate_hand_value(player.cards)} for you, #{player.name}."
    elsif calculate_hand_value(dealer.cards) < calculate_hand_value(player.cards) 
      puts "Our winner:  Congrats to #{player.name.upcase}!!!"
      puts "Winning hand of #{calculate_hand_value(player.cards)} vs. #{calculate_hand_value(dealer.cards)} for the dealer."
    else
      puts "The hand is a push."
    end
  end

  def ace_count(cards)
    count=0
    cards.each do |card|
      if card.face == 'Ace'
        count += 1      
      end
    end
    count
  end

  def calculate_hand_value(cards)
    value = 0
    cards.each do |card|
      value += get_card_value(card.face)
    end
    # while value of hand is > 21 and
    # there are aces reduce value by 10
    num_aces = ace_count(cards)
    while value > 21 && num_aces > 0
      value -= 10
      num_aces -= 1
    end
    value
  end

  def get_card_value(face)
    if face.size < 3
      return face.to_i
    elsif face.size > 3
      return 10
    else
      return 11
    end
  end

 def is_blackjack?(value)
    if value == 21
      self.more_to_hand = false
      return true
    else
      return false
    end
  end

  def blackjack_message(name)
    "Congrats, #{name}, BLACKJACK!!!"
  end

  def is_busted?(value)
    if value > 21
      self.more_to_hand = false
      return true
    else
      return false
    end
  end

  def is_busted_message(value, name)
    "Sorry, #{name}, your total is #{value} -- you're busted!"
  end

  def continue_play?(value, name)
    if is_blackjack?(value)==true
      puts blackjack_message(name)
      return false
    elsif is_busted?(value)==true
      puts is_busted_message(value, name)
      return false
    else
      return true
    end
  end
end

blackjack = Blackjack.new(Player.new, Dealer.new)
blackjack.start_game

# game is a deck of cards, a dealer and a player
#deck is created at time of new Blackjack
                                      #and deck is assigned to dealer

# now the dealer needs to deal four cards, one at a time, to create two hands


# now dealer has two cards and player has two cards
# one of dealer cards is hidden
#puts "Value of #{player.name}'s hand:  #{game.calculate_hand_value(player.cards)}"
#puts "Value of Dealer's hand:  #{game.calculate_hand_value(dealer.cards)}"
# does player have Blackjack?

# if no Blackjack, ask if player wants a new card
# if so, hand value needs to be recalculated to include new card
# is player hand blackjack, busted, or does player want new card
# repeat until player 