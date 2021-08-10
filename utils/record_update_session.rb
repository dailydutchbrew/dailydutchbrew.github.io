# frozen_string_literal: true

require_relative 'event'

class RecordUpdateSession
  attr_reader :records

  def initialize(records)
    @records = records
  end

  def update_records(event)
    records.each do |record|
      case event.result
      when Event::WIN
        if record.rules_match?(event)
          record.win += 1
          record.units += event.potential_payout - event.units
        end
      when Event::LOSS
        if record.rules_match?(event)
          record.loss += 1
          record.units -= event.units
        end
      when Event::PUSH
        if record.rules_match?(event)
          record.push += 1
#          record.units += event.units
        end
      when Event::VOID
        if record.rules_match?(event)
          record.void += 1
#          record.units += event.units
        end
      when Event::PENDING
        if record.rules_match?(event)
          record.pending += 1
#          record.units -= event.units
        end
      end
    end
  end
end
