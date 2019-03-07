require "./lib/coffeemaker_api.rb"

class CoffeeMaker
  def initialize api
    @api = api
    @boiler = Boiler.new api
    @warmer = Warmer.new api
  end

  def update
    @boiler.update
    @warmer.update
  end

  class Hardware
    def initialize api
      @api = api
    end

    def update
      raise "implement"
    end
  end

  class Boiler < Hardware
    def update
      @api.boiler_state = if ready_to_brew?
                            BoilerState::ON
                          else
                            BoilerState::OFF
                          end
    end

    private

    def ready_to_brew?
      @api.brew_button_status == BrewButtonStatus::PUSHED &&
        @api.warmer_plate_status == WarmerPlateStatus::POT_EMPTY &&
        @api.boiler_status == BoilerStatus::NOT_EMPTY
    end
  end

  class Warmer < Hardware
    def update
      @api.warmer_state = if has_coffee?
                            WarmerState::ON
                          else
                            WarmerState::OFF
                          end
    end

    private

    def has_coffee?
      @api.warmer_plate_status == WarmerPlateStatus::POT_NOT_EMPTY
    end
  end
end
