require "./lib/coffeemaker_api.rb"

class CoffeeMaker
  def initialize api
    @event_bus = []
    boiler = Boiler.new api, @event_bus
    warmer = Warmer.new api, @event_bus
    light = Light.new api, @event_bus
    relief_valve = ReliefValve.new api, @event_bus
    @hardware = [
      boiler,
      warmer,
      light,
      relief_valve
    ]
  end

  def update
    @hardware.each(&:update)
    @event_bus.clear
  end

  class Hardware
    def initialize api, event_bus
      @api = api
      @event_bus = event_bus
    end

    def update
      raise "implement"
    end

    private

    def pot_missing?
      @api.warmer_plate_status == WarmerPlateStatus::WARMER_EMPTY
    end
  end

  class Boiler < Hardware
    def update
      boiler_state = next_boiler_state
      if boiler_state == BoilerState::ON
        @brewing = true
      elsif @brewing
        @brewing = false
        @event_bus << :coffee_brewed
      end
      @api.boiler_state = boiler_state
    end

    private

    def next_boiler_state
      if ready_to_brew?
        BoilerState::ON
      else
        BoilerState::OFF
      end
    end

    def ready_to_brew?
      @api.brew_button_status == BrewButtonStatus::PUSHED &&
        @api.warmer_plate_status == WarmerPlateStatus::POT_EMPTY &&
        @api.boiler_status == BoilerStatus::NOT_EMPTY
    end
  end

  class Warmer < Hardware
    def update
      @api.warmer_state = next_warmer_state
    end

    private

    def next_warmer_state
      if has_coffee?
        WarmerState::ON
      else
        WarmerState::OFF
      end
    end

    def has_coffee?
      @api.warmer_plate_status == WarmerPlateStatus::POT_NOT_EMPTY
    end
  end

  class Light < Hardware
    def update
      if @event_bus.include? :coffee_brewed
        @api.indicator_state = IndicatorState::ON
        @fresh_pot = true
      elsif @fresh_pot && pot_missing?
        @api.indicator_state = IndicatorState::OFF
        @fresh_pot = false
      end
    end
  end

  class ReliefValve < Hardware
    def update
      @api.relief_valve_state = next_relief_valve_state
    end

    private

    def next_relief_valve_state
      if pot_missing?
        ReliefValveState::OPEN
      else
        ReliefValveState::CLOSED
      end
    end
  end
end
