# frozen_string_literal: true

class EventRule
  def initialize(event_attr, event_attr_value, include_parlay: false)
    @event_attr = event_attr
    @event_attr_value = event_attr_value
    @include_parlay = include_parlay
  end

  def valid?(event)
    return false if @include_parlay == false && (event.type == 'PARLAY' || event.type == 'BETBACK')
    event.send(@event_attr) == @event_attr_value
  end
end
