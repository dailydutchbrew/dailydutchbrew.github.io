# frozen_string_literal: true

class Record
  attr_accessor :win, :loss, :push, :pending, :void

  def initialize(win: 0, loss: 0, push: 0, pending: 0, void: 0)
    @win = win
    @loss = loss
    @push = push
    @pending = pending
    @void = void
  end
end
