# frozen_string_literal: true

require 'yaml'

bets = YAML.load_file('raw_data.yml')

WIN = 'WIN'
LOSS = 'LOSS'
PUSH = 'PUSH'
PENDING = 'PENDING'
VOID = 'VOID'
BANK = 'BANK'
FUTURE = 'F'
BONUS = 'BONUS'

win = 0
loss = 0
push = 0
pending = 0
void = 0
pending_units = 0
total_units = 0
account_units = 0
bank = 0
futures = []
non_future_pending = []

def calculate_american_odds_payout(units, odds)
  if odds.positive?
    (units * (odds.abs / 100.0)) + units
  else
    (units / (odds.abs / 100.0).to_f) + units
  end
end

bets.each do |bet|
  units = bet['units']

  if bet['type'] == BANK
    bank += units
    account_units -= units
    next
  end

  if bet['type'] == BONUS
    account_units += units
  end

  line = bet['line']
  result = bet['result']
  potential_payout = calculate_american_odds_payout(units, line)

  case result
  when WIN
    win += 1
    account_units += (potential_payout - units)
  when LOSS
    loss += 1
    account_units -= units
  when PUSH
    push += 1
    account_units += units
  when PENDING
    pending += 1
    account_units -= units
    pending_units += units

    payload = {
      'sport' => bet['sport'],
      'units' => units,
      'description' => bet['description'],
      'line' => "%+d" % bet['line']
    }
    if bet['type'] == FUTURE
      futures << payload
    else
      non_future_pending << payload
    end
  when VOID
    void += 1
    account_units += units
  end
  total_units += units
end

totals = {
  'win' => win,
  'loss' => loss,
  'push' => push,
  'pending' => pending,
  'win_pct' => (win / (win + loss).to_f).round(3),
  'void' => void,
  'total_units' => total_units,
  'account_units' => account_units.round(2),
  'pending_units' => pending_units,
  'bank' => bank,
  'futures' => futures,
  'non_future_pending' => non_future_pending
}

puts totals.inspect

File.open('../_data/totals.yml', 'w') { |f| f.write(totals.to_yaml) }
