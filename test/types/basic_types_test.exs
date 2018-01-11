defmodule BasicTypesTest do
  use ExUnit.Case

  alias Exchema.Types, as: T
  import Exchema, only: [is?: 2]

  test "integer" do
    assert is?(1, T.Integer)
    refute is?(1.0, T.Integer)
    refute is?("1", T.Integer)
  end

  test "float" do
    assert is?(1.0, T.Float)
    refute is?(1, T.Float)
    refute is?("1", T.Float)
  end

  test "number" do
    assert is?(1, T.Number)
    assert is?(1.0, T.Number)
    refute is?("1", T.Number)
  end

  test "string" do
    assert is?("string", T.String)
    refute is?(1, T.String)
  end

  test "boolean" do
    assert is?(true, T.Boolean)
    assert is?(false, T.Boolean)
    refute is?("not", T.Boolean)
  end

  test "atom" do
    assert is?(true, T.Atom)
    assert is?(nil, T.Atom)
    assert is?(:atom, T.Atom)
    refute is?("not", T.Atom)
  end

  test "tuple" do
    assert is?({}, T.Tuple)
    assert is?({1}, T.Tuple)
    assert is?({1,2}, T.Tuple)
    refute is?([1,2], T.Tuple)
  end
end
