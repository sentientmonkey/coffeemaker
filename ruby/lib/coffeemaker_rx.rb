require "./lib/coffeemaker_api.rb"
require "observer"

class CoffeeMaker
  include Observable

  def initialize api
    add_hardware api
    add_events api
  end

  def add_hardware api
    Boiler.new self, api
    Indicator.new self, api
    Warmer.new self, api
    ReliefValve.new self, api
  end

  def observer type, &blk
    @events << [type, blk]
  end

  def add_events api
    @events = []
    observer(:warmer_plate_status) { api.warmer_plate_status }
    observer(:boiler_status) { api.boiler_status }
    observer(:brew_button_status) { api.brew_button_status }
  end

  def update
    @events.each do |type, blk|
      changed
      notify_observers type, blk.call
    end
  end

  class HardwareObserver
    def initialize coffeemaker, api
      @api = api
      coffeemaker.add_observer self
    end

    def update event, value
      method_name = "on_#{event}"
      send method_name, value if respond_to? method_name
    end
  end

  class Boiler < HardwareObserver
    def on_boiler_status value
      @has_water = value == BoilerStatus::NOT_EMPTY
    end

    def on_warmer_plate_status value
      @has_empty_pot = value == WarmerPlateStatus::POT_EMPTY
    end

    def on_brew_button_status value
      if @has_water &&
         @has_empty_pot &&
         value == BrewButtonStatus::PUSHED
        @api.boiler_state = BoilerState::ON
      else
        @api.boiler_state = BoilerState::OFF
      end
    end
  end

  class Indicator < HardwareObserver
    def initialize *args
      @is_brewing = false
      @fresh_pot = false
      @has_water = false
      super
    end

    def on_boiler_status value
      @has_water = value == BoilerStatus::NOT_EMPTY
      if @is_brewing && value == BoilerStatus::EMPTY
        @api.indicator_state = IndicatorState::ON
        @is_brewing = false
        @fresh_pot = true
      end
    end

    def on_brew_button_status value
      if @has_water && value == BrewButtonStatus::PUSHED
        @is_brewing = true
      end
    end

    def on_warmer_plate_status value
      if @fresh_pot && value == WarmerPlateStatus::WARMER_EMPTY
        @api.indicator_state = IndicatorState::OFF
        @fresh_pot = false
      end
    end
  end

  class Warmer < HardwareObserver
    def on_warmer_plate_status value
      case value
      when WarmerPlateStatus::POT_NOT_EMPTY
        @api.warmer_state = WarmerState::ON
      when WarmerPlateStatus::POT_EMPTY,
           WarmerPlateStatus::WARMER_EMPTY
        @api.warmer_state = WarmerState::OFF
      end
    end
  end

  class ReliefValve < HardwareObserver
    def on_warmer_plate_status value
      if value == WarmerPlateStatus::POT_EMPTY
        @api.relief_valve_state = ReliefValveState::CLOSED
      else 
        @api.relief_valve_state = ReliefValveState::OPEN
      end
    end
  end
end
