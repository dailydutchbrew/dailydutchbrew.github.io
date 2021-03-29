# frozen_string_literal: true

require 'yaml'
require 'date'

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
BETBACK = 'BETBACK'

betback_win = 0
betback_loss = 0
betback_push = 0
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
monthly_mls = []
prev_monthly_w = 0
prev_monthly_l = 0
prev_monthly_p = 0
week_w = 0
week_l = 0
week_p = 0

def calculate_american_odds_payout(units, odds)
  if odds.positive?
    (units * (odds.abs / 100.0)) + units
  else
    (units / (odds.abs / 100.0).to_f) + units
  end
end

# 0 is Sunday, range to 6 would be Saturday
def get_previous_sunday(date)
  date - ((date.wday - 0) % 7)
end

current_month = "12"
bets.each do |bet|
  units = bet['units']

  type = bet['type']
  if type == BANK
    bank += units
    account_units -= units
    next
  end

  date = bet['date']
  is_current_week = false
  is_current_week = true if Date.strptime(date, '%m/%d/%Y') >= get_previous_sunday(DateTime.now).to_date

  month = date.split('/').first
  unless month == current_month
    current_month_record = {
      'month' => current_month,
      'record' => "#{win - prev_monthly_w}-#{loss - prev_monthly_l}-#{push - prev_monthly_p}"
    }
    monthly_mls << current_month_record
    prev_monthly_w = win
    prev_monthly_l = loss
    prev_monthly_p = push
    current_month = month
  end
  # account_units += units if type == BONUS

  line = bet['line']
  result = bet['result']
  potential_payout = calculate_american_odds_payout(units, line)

  case result
  when WIN
    if type == PARLAY
      parlay_win += 1
    elsif type == BETBACK
      betback_win += 1
    else
      win += 1
      week_w += 1 if is_current_week
    end
    account_units += (potential_payout - units)
  when LOSS
    if type == PARLAY
      parlay_loss += 1
    elsif type == BETBACK
      betback_loss += 1
    else
      loss += 1
      week_l += 1 if is_current_week
    end
    account_units -= units
  when PUSH
    if type == PARLAY
      parlay_push += 1
    elsif type == BETBACK
      betback_push += 1
    else
      push += 1
      week_p += 1 if is_current_week
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

# Log monthly record here again, as month has not ended.
current_month_record = {
  'month' => current_month,
  'record' => "#{win - prev_monthly_w}-#{loss - prev_monthly_l}-#{push - prev_monthly_p}"
}
monthly_mls << current_month_record

totals = {
  'win' => win,
  'loss' => loss,
  'push' => push,
  'parlay_win' => parlay_win,
  'parlay_loss' => parlay_loss,
  'parlay_push' => parlay_push,
  'betback_win' => betback_win,
  'betback_loss' => betback_loss,
  'betback_push' => betback_push,
  'pending' => pending,
  'win_pct' => (win / (win + loss).to_f).round(3),
  'void' => void,
  'total_units' => total_units,
  'account_units' => account_units.round(2),
  'pending_units' => pending_units,
  'bank' => bank,
  'futures' => futures,
  'non_future_pending' => non_future_pending,
  'monthly_mls' => monthly_mls,
  'week_w' => week_w,
  'week_l' => week_l,
  'week_p' => week_p
}

puts totals.inspect

File.open('../_data/totals.yml', 'w') { |f| f.write(totals.to_yaml) }
