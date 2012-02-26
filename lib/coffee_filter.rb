require 'coffee_script'
class CoffeeFilter < TextFilter
  def filter(text)
    CoffeeScript.compile text
  end
end