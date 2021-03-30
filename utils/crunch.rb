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

betback_win = 0
betback_loss = 0
betback_push = 0
parlay_win = 0
parlay_loss = 0
parlay_push = 0
ml_p_record = Record.new
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
      'record' => "#{ml_p_record.win - prev_monthly_w}-#{ml_p_record.loss - prev_monthly_l}-#{ml_p_record.push - prev_monthly_p}"
    }
    monthly_mls << current_month_record
    prev_monthly_w = ml_p_record.win
    prev_monthly_l = ml_p_record.loss
    prev_monthly_p = ml_p_record.push
    current_month = month
  end

  result = event.result
  potential_payout = event.potential_payout

  case result
  when WIN
    if event.type == PARLAY
      parlay_win += 1
    elsif event.type == BETBACK
      betback_win += 1
    else
      ml_p_record.win += 1
      week_w += 1 if event.current_week?
    end
    account_units += (potential_payout - units)
  when LOSS
    if event.type == PARLAY
      parlay_loss += 1
    elsif event.type == BETBACK
      betback_loss += 1
    else
      ml_p_record.loss += 1
      week_l += 1 if event.current_week?
    end
    account_units -= units
  when PUSH
    if event.type == PARLAY
      parlay_push += 1
    elsif event.type == BETBACK
      betback_push += 1
    else
      ml_p_record.push += 1
      week_p += 1 if event.current_week?
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
  'record' => "#{ml_p_record.win - prev_monthly_w}-#{ml_p_record.loss - prev_monthly_l}-#{ml_p_record.push - prev_monthly_p}"
}
monthly_mls << current_month_record

totals = {
  'win' => ml_p_record.win,
  'loss' => ml_p_record.loss,
  'push' => ml_p_record.push,
  'parlay_win' => parlay_win,
  'parlay_loss' => parlay_loss,
  'parlay_push' => parlay_push,
  'betback_win' => betback_win,
  'betback_loss' => betback_loss,
  'betback_push' => betback_push,
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
  'week_w' => week_w,
  'week_l' => week_l,
  'week_p' => week_p
}

puts totals.inspect

File.open('../_data/totals.yml', 'w') { |f| f.write(totals.to_yaml) }
