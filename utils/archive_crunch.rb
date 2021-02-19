# frozen_string_literal: true

require 'yaml'

bets = YAML.load_file('archive_data.yml')

WIN = 'WIN'
LOSS = 'LOSS'
PUSH = 'PUSH'
PENDING = 'PENDING'
BANK = 'BANK'

win = 0
loss = 0
push = 0
pending = 0
total_units = 0
net_units = 0
bank = 0
three = 0
three_w = 0
three_l = 0
four = 0
four_w = 0
four_l = 0
five = 0
five_w = 0
five_l = 0

def calculate_american_odds_payout(units, odds)
  if odds.positive?
    (units * (odds.abs / 100.0)) + units
  else
    (units / (odds.abs / 100.0).to_f) + units
  end
end

bets.each do |bet|
  is_three = false
  is_five = false
  is_four = false
  if bet['type'] == BANK
    bank += bet['units']
    next
  end

  if bet['description'].split(',').count == 3
    three += 1
    is_three = true
  end
  if bet['description'].split(',').count == 4
    four += 1
    is_four = true
  end
  if bet['description'].split(',').count == 5
    five += 1
    is_five = true
  end

  line = bet['line']
  units = bet['units']
  result = bet['result']
  potential_payout = calculate_american_odds_payout(units, line)
  case result
  when WIN
    if is_three
      puts bet['description']
      three_w += 1
    end
    if is_five
      puts bet['description']
      five_w += 1
    end
    if is_four
      puts bet['description']
      four_w += 1
    end
    win += 1
    net_units += potential_payout
  when LOSS
    if is_three
      puts bet['description']
      three_l += 1
    end
    if is_five
      puts bet['description']
      five_l += 1
    end
    if is_four
      puts bet['description']
      four_l += 1
    end
    loss += 1
    net_units -= units
  when PUSH
    push += 1
    net_units += units
  when PENDING
    pending += 1
  end

  total_units += units
end

totals = {
  'win' => win,
  'loss' => loss,
  'push' => push,
  'pending' => pending,
  'total_units' => total_units,
  'net_units' => net_units.round(2),
  'bank' => bank,
  'three' => three,
  'three_w' => three_w,
  'three_l' => three_l,
  'five' => five,
  'five_w' => five_w,
  'five_l' => five_l,
  'four' => four,
  'four_w' => four_w,
  'four_l' => four_l
}

puts totals.inspect

File.open('../_data/archive_totals.yml', 'w') { |f| f.write(totals.to_yaml) }
