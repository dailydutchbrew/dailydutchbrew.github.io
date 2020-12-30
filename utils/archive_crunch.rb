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

def calculate_american_odds_payout(units, odds)
  if odds.positive?
    (units * (odds.abs / 100.0)) + units
  else
    (units / (odds.abs / 100.0).to_f) + units
  end
end

bets.each do |bet|
  if bet['type'] == BANK
    bank += bet['units']
    next
  end

  line = bet['line']
  units = bet['units']
  result = bet['result']
  potential_payout = calculate_american_odds_payout(units, line)
  case result
  when WIN
    win += 1
    net_units += potential_payout
  when LOSS
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
  'bank' => bank
}

puts totals.inspect

File.open('../_data/archive_totals.yml', 'w') { |f| f.write(totals.to_yaml) }
