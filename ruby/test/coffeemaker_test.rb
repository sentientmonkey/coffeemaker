require "minitest/autorun"
require "minitest/pride"
require "./lib/coffeemaker"

class MockCoffeeMakerAPI < CoffeeMakerAPI
  attr_accessor(
    :boiler_status,
    :warmer_plate_status,
    :brew_button_status,
    :boiler_state,
    :warmer_state
  )

  def initialize
  end

  def set_defaults!
    self.brew_button_status = BrewButtonStatus::NOT_PUSHED
    self.warmer_plate_status = WarmerPlateStatus::POT_EMPTY
    self.boiler_status = BoilerStatus::NOT_EMPTY
  end
end

class CoffeeMakerTest < Minitest::Test
  def setup
    @api = MockCoffeeMakerAPI.new
    @api.set_defaults!

    @subject = CoffeeMaker.new @api
  end

  def test_will_turn_off_boiler_when_nothing_pressed
    @subject.update
    assert_equal BoilerState::OFF, @api.boiler_state
  end

  def test_will_brew_when_button_pressed
    @api.brew_button_status = BrewButtonStatus::PUSHED
    @subject.update
    assert_equal BoilerState::ON, @api.boiler_state
  end

  def test_will_not_brew_when_warmer_is_empty
    @api.brew_button_status = BrewButtonStatus::PUSHED
    @api.warmer_plate_status = WarmerPlateStatus::WARMER_EMPTY
    @subject.update
    assert_equal BoilerState::OFF, @api.boiler_state
  end

  def test_will_not_brew_when_pot_is_full
    @api.brew_button_status = BrewButtonStatus::PUSHED
    @api.warmer_plate_status = WarmerPlateStatus::POT_NOT_EMPTY
    @subject.update
    assert_equal BoilerState::OFF, @api.boiler_state
  end

  def test_will_not_brew_when_boiler_is_empty
    @api.brew_button_status = BrewButtonStatus::PUSHED
    @api.boiler_status = BoilerStatus::EMPTY
    @subject.update
    assert_equal BoilerState::OFF, @api.boiler_state
  end

  def test_will_keep_coffee_warm_when_coffeepot_has_coffee
    @api.warmer_plate_status = WarmerPlateStatus::POT_NOT_EMPTY
    @subject.update
    assert_equal WarmerState::ON, @api.warmer_state
  end

  def test_will_shut_off_warmer_when_pot_is_empty
    @api.warmer_plate_status = WarmerPlateStatus::POT_EMPTY
    @subject.update
    assert_equal WarmerState::OFF, @api.warmer_state
  end
end
