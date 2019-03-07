
module WarmerPlateStatus
  WARMER_EMPTY = :warmer_empty
  POT_EMPTY = :pot_empty
  POT_NOT_EMPTY = :pot_not_empty
end

module BoilerStatus
  EMPTY = :empty
  NOT_EMPTY = :not_empty
end

module BrewButtonStatus
  PUSHED = :pushed
  NOT_PUSHED = :not_pushed
end

module BoilerState
  ON = :on
  OFF = :off
end

module WarmerState
  ON = :on
  OFF = :off
end

module IndicatorState
  ON = :on
  OFF = :off
end

module ReliefValveState
  OPEN = :open
  CLOSED = :closed
end

class CoffeeMakerAPI
  def initialize
    raise "abstract base class"
  end

  # This function returns the status of the warmer-plate
  # sensor. This sensor detects the presence of the pot
  # and whether it has coffee in it.
  def warmer_plate_status; end

  # This function returns the status of the boiler switch.
  # The boiler switch is a float switch that detects if
  # there is more than 1/2 cup of water in the boiler.
  def boiler_status; end

  # This function returns the status of the brew button.
  # The brew button is a momentary switch that remembers
  # its state. Each call to this function returns the
  # remembered state and then resets that state to
  # NOT_PUSHED.
  #
  # Thus, even if this function is polled at a very slow
  # rate, it will still detect when the brew button is
  # pushed.
  def brew_button_status; end

  # This function turns the heating element in the boiler
  # on or off.
  def boiler_state=(boiler_state); end

  # This function turns the heating element in the warmer
  # plate on or off.
  def warmer_state=(warmer_state); end

  # This function turns the indicator light on or off.
  # The indicator light should be turned on at the end
  # of the brewing cycle. It should be turned off when
  # the user presses the brew button.
  def indicator_state=(indicator_state); end

  # This function opens and closes the pressure-relief
  # valve. When this valve is closed, steam pressure in
  # the boiler will force hot water to spray out over
  # the coffee filter. When the valve is open, the steam
  # in the boiler escapes into the environment, and the
  # water in the boiler will not spray out over the filter.
  def relief_valve_state=(relief_valve_state); end
end
