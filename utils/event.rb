# frozen_string_literal: true

require 'date'

class Event
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

  attr_reader :type, :sport, :line, :units, :description, :result, :date

  def initialize(data:)
    @type = data['type']
    @sport = data['sport']
    @line = data['line']
    @units = data['units']
    @description = data['description']
    @result = data['result']
    @date = data['date']
  end

  def current_week?
    Date.strptime(date, '%m/%d/%Y') >= get_previous_sunday(DateTime.now).to_date
  end

  def potential_payout
    calculate_american_odds_payout(units, line)
  end

  private

  # 0 is Sunday, range to 6 would be Saturday
  def get_previous_sunday(date)
    date - ((date.wday - 0) % 7)
  end

  def calculate_american_odds_payout(units, odds)
    if odds.positive?
      (units * (odds.abs / 100.0)) + units
    else
      (units / (odds.abs / 100.0).to_f) + units
    end
  end
end
