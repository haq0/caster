defmodule CasterTest do
  use ExUnit.Case
  doctest Caster

  test "greets the world" do
    assert Caster.hello() == :world
  end
end
