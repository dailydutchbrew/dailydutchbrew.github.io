# frozen_string_literal: true

class Record
  attr_accessor :win, :loss, :push, :pending, :void, :name, :rules, :units

  def initialize(
    name: 'default',
    rules: []
  )
    @win = 0
    @loss = 0
    @push = 0
    @pending = 0
    @void = 0
    @units = 0
    @name = name
    @rules = rules
  end

  def rules_match?(event)
    rules.all? { |rule| rule.valid?(event) }
  end

  def win_pct
    (win / (win + loss).to_f).round(3)
  end
end
