# frozen_string_literal: true

require_relative 'event'
require_relative 'record'
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

non_future_pending = []
monthly_mls = []
betback_record = Record.new
betback_record = Record.new
parlay_record = Record.new
ml_p_record = Record.new
prev_month_record = Record.new
week_record = Record.new
pending_units = 0
total_units = 0
account_units = 0
bank = 0
futures = []

current_month = "12"
bets.each do |bet|
  event = Event.new(data: bet)
  units = event.units

  if event.type == BANK
    bank += units
    account_units -= units
    next
  end

  date = event.date

  month = date.split('/').first
  unless month == current_month
    current_month_record = {
      'month' => current_month,
      'record' => "#{ml_p_record.win - prev_month_record.win}-#{ml_p_record.loss - prev_month_record.loss}-#{ml_p_record.push - prev_month_record.push}"
    }
    monthly_mls << current_month_record
    prev_month_record.win = ml_p_record.win
    prev_month_record.loss = ml_p_record.loss
    prev_month_record.push = ml_p_record.push
    current_month = month
  end

  result = event.result
  potential_payout = event.potential_payout

  case result
  when WIN
    if event.type == PARLAY
      parlay_record.win += 1
    elsif event.type == BETBACK
      betback_record.win += 1
    else
      ml_p_record.win += 1
      week_record.win += 1 if event.current_week?
    end
    account_units += (potential_payout - units)
  when LOSS
    if event.type == PARLAY
      parlay_record.loss += 1
    elsif event.type == BETBACK
      betback_record.loss += 1
    else
      ml_p_record.loss += 1
      week_record.loss += 1 if event.current_week?
    end
    account_units -= units
  when PUSH
    if event.type == PARLAY
      parlay_record.push += 1
    elsif event.type == BETBACK
      betback_record.push += 1
    else
      ml_p_record.push += 1
      week_record.push += 1 if event.current_week?
    end
    account_units += units
  when PENDING
    ml_p_record.pending += 1
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
    ml_p_record.void += 1
    account_units += units
  end
  total_units += units
end

# Log monthly record here again, as month has not ended.
current_month_record = {
  'month' => current_month,
  'record' => "#{ml_p_record.win - prev_month_record.win}-#{ml_p_record.loss - prev_month_record.loss}-#{ml_p_record.push - prev_month_record.push}"
}
monthly_mls << current_month_record

totals = {
  'win' => ml_p_record.win,
  'loss' => ml_p_record.loss,
  'push' => ml_p_record.push,
  'parlay_win' => parlay_record.win,
  'parlay_loss' => parlay_record.loss,
  'parlay_push' => parlay_record.push,
  'betback_win' => betback_record.win,
  'betback_loss' => betback_record.loss,
  'betback_push' => betback_record.push,
  'pending' => ml_p_record.pending,
  'win_pct' => (ml_p_record.win / (ml_p_record.win + ml_p_record.loss).to_f).round(3),
  'void' => ml_p_record.void,
  'total_units' => total_units,
  'account_units' => account_units.round(2),
  'pending_units' => pending_units,
  'bank' => bank,
  'futures' => futures,
  'non_future_pending' => non_future_pending,
  'monthly_mls' => monthly_mls,
  'week_w' => week_record.win,
  'week_l' => week_record.loss,
  'week_p' => week_record.push
}

puts totals.inspect

File.open('../_data/totals.yml', 'w') { |f| f.write(totals.to_yaml) }
