require "./lib/coffeemaker_api.rb"

class CoffeeMaker
  def initialize api
    @api = api
  end

  def update
    if ready_to_brew?
      @api.boiler_state = BoilerState::ON
    else
      @api.boiler_state = BoilerState::OFF
    end
  end

  private

  def ready_to_brew?
    @api.brew_button_status == BrewButtonStatus::PUSHED &&
      @api.warmer_plate_status == WarmerPlateStatus::POT_EMPTY &&
      @api.boiler_status == BoilerStatus::NOT_EMPTY
  end
end
