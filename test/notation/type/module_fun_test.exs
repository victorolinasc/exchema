defmodule Notation.Type.ModuleFunTest do
  use ExUnit.Case

  defmodule Type do
    import Exchema.Notation
    type &is_integer/1
  end

  test "it generates an exchema type" do
    assert :erlang.function_exported(Type, :__type__, 1)
  end

  test "it executes the function to check the type" do
    assert Exchema.is?(1, Type)
    refute Exchema.is?(:a, Type)
  end
end