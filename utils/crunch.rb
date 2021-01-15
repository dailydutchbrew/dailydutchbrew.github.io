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
PARLAY = 'PARLAY'

parlay_win = 0
parlay_loss = 0
parlay_push = 0
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

  type = bet['type']
  if type == BANK
    bank += units
    account_units -= units
    next
  end

  # account_units += units if type == BONUS

  line = bet['line']
  result = bet['result']
  potential_payout = calculate_american_odds_payout(units, line)

  case result
  when WIN
    if type == PARLAY
      parlay_win += 1
    else
      win += 1
    end
    account_units += (potential_payout - units)
  when LOSS
    if type == PARLAY
      parlay_loss += 1
    else
      loss += 1
    end
    account_units -= units
  when PUSH
    if type == PARLAY
      parlay_push += 1
    else
      push += 1
    end
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
  'parlay_win' => parlay_win,
  'parlay_loss' => parlay_loss,
  'parlay_push' => parlay_push,
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
