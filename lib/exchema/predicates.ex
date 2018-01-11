defmodule Exchema.Predicates do
  @moduledoc """
  Exschema default predicates library
  """

  @doc """
  Executes a function and check the result.
  The result can be either `true`, `false`, `:ok` or `{:error, err}`

  If the result is `true` or `:ok` the predicate will succeed.
  If it is `false` it will fail with default `{:error, :invalid}` value.
  It can be given a specific error `{:error, error}` if wanted

  ## Examples

      iex> Exchema.Predicates.fun(1, &is_integer/1)
      :ok

      iex> Exchema.Predicates.fun("1", &is_integer/1)
      {:error, :invalid}

      iex> Exchema.Predicates.fun(1, &(&1 > 0))
      :ok

      iex> Exchema.Predicates.fun(0, &(&1 > 0))
      {:error, :invalid}

      iex> Exchema.Predicates.fun(1, fn _ -> {:error, :custom_error} end)
      {:error, :custom_error}

  """
  def fun(val, fun) do
    case fun.(val) do
      true ->
        :ok
      :ok ->
        :ok
      false ->
        {:error, :invalid}
      {:error, e} ->
        {:error, e}
    end
  end

  @doc """
  Checks wheter a value is a list.
  It can also check the types of the elemsts of the list by
  passing the `:element_type` param.

  ## Examples

      iex> Exchema.Predicates.list("", [])
      {:error, :not_a_list}

      iex> Exchema.Predicates.list([], [])
      :ok

      iex> Exchema.Predicates.list(["",1,""], element_type: Exchema.Types.Integer)
      {:error, {
        :nested_errors,
        [
          {0, [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]},
          {2, [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}
        ]}
      }

      iex> Exchema.Predicates.list([1,2,3], element_type: Exchema.Types.Integer)
      :ok

  """
  def list(list, _) when not is_list(list) do
    {:error, :not_a_list}
  end
  def list(list, opts) do
    case Keyword.get(opts, :element_type) do
      nil ->
        :ok
      type ->
        list
        |> Enum.with_index
        |> Enum.map(fn {e, idx} -> {idx, Exchema.errors(e, type)} end)
        |> Enum.filter(fn {_, err} -> length(err) > 0 end)
        |> nested_errors
    end
  end

  defp nested_errors(errors, error_key \\ :nested_errors)
  defp nested_errors([], _), do: :ok
  defp nested_errors(errors, error_key) do
    {:error, {error_key, errors}}
  end

  @doc """
  Checks whether or not the given value is a struct or a specific struct.

  Note: It's named `is_struct` to avoid conflict with `Kernel.struct`.

  ## Examples

      iex> Exchema.Predicates.is_struct(%{}, [])
      {:error, :not_a_struct}

      iex> Exchema.Predicates.is_struct(nil, [])
      {:error, :not_a_struct}

  Also, keep in mind that many internal types are actually structs

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, nil)
      :ok

      iex> Exchema.Predicates.is_struct(NaiveDateTime.utc_now, nil)
      :ok

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, DateTime)
      :ok

      iex> Exchema.Predicates.is_struct(DateTime.utc_now, NaiveDateTime)
      {:error, :invalid_struct}

      iex> Exchema.Predicates.is_struct(NaiveDateTime.utc_now, DateTime)
      {:error, :invalid_struct}

  """
  def is_struct(%{__struct__: _}, nil), do: :ok
  def is_struct(%{__struct__: real}, expected) when expected == real, do: :ok
  def is_struct(%{__struct__: _}, _), do: {:error, :invalid_struct}
  def is_struct(_, _), do: {:error, :not_a_struct}

  @doc """
  Checks a map for its key types, value types or specific value types (for a given key).

  ## Examples

      iex> Exchema.Predicates.map("", [])
      {:error, :not_a_map}

      iex> Exchema.Predicates.map(%{}, [])
      :ok

      iex > Exchema.Predicates.map(%{1 => "value"}, [key: Exchema.Types.Integer])
      :ok

      iex > Exchema.Predicates.map(%{"key" => 1}, [values: Exchema.Types.Integer])
      :ok

      iex > Exchema.Predicates.map(%{"key" => 1}, [keys: Exchema.Types.Integer])
      {:error, {
        :key_errors,
        [{"key", [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}]
      }}

      iex > Exchema.Predicates.map(%{1 => "value"}, [values: Exchema.Types.Integer])
      {:error, {
        :value_errors,
        [{"value", [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}]
      }}

      iex> Exchema.Predicates.map(%{foo: :bar}, fields: [foo: Exchema.Types.Integer])
      {:error, {
        :nested_errors,
        [{:foo, [{{Exchema.Predicates, :is}, :integer, :not_an_integer}]}]
      }}
  """
  defdelegate map(input, opts), to: Exchema.Predicates.Map

  @doc """
  Checks against system guards like `is_integer` or `is_float`.

  ## Examples

      iex> Exchema.Predicates.is(1, :integer)
      :ok

      iex> Exchema.Predicates.is(1.0, :float)
      :ok

      iex> Exchema.Predicates.is(1, :nil)
      {:error, :not_nil}

      iex> Exchema.Predicates.is(1, :atom)
      {:error, :not_an_atom}

      iex> Exchema.Predicates.is(nil, :binary)
      {:error, :not_a_binary}

      iex> Exchema.Predicates.is(nil, :bitstring)
      {:error, :not_a_bitstring}

      iex> Exchema.Predicates.is(nil, :boolean)
      {:error, :not_a_boolean}

      iex> Exchema.Predicates.is(nil, :float)
      {:error, :not_a_float}

      iex> Exchema.Predicates.is(nil, :function)
      {:error, :not_a_function}

      iex> Exchema.Predicates.is(nil, :integer)
      {:error, :not_an_integer}

      iex> Exchema.Predicates.is(nil, :list)
      {:error, :not_a_list}

      iex> Exchema.Predicates.is(nil, :map)
      {:error, :not_a_map}

      iex> Exchema.Predicates.is(nil, :number)
      {:error, :not_a_number}

      iex> Exchema.Predicates.is(nil, :pid)
      {:error, :not_a_pid}

      iex> Exchema.Predicates.is(nil, :port)
      {:error, :not_a_port}

      iex> Exchema.Predicates.is(nil, :reference)
      {:error, :not_a_reference}

      iex> Exchema.Predicates.is(nil, :tuple)
      {:error, :not_a_tuple}

  """
  # Explicit nil case becasue Kernel.is_nil is a macro
  def is(nil, nil), do: :ok
  def is(_, nil), do: {:error, :not_nil}
  def is(val, key) do
    if apply(Kernel, :"is_#{key}", [val]) do
      :ok
    else
      {:error, is_error_msg(key)}
    end
  end

  defp is_error_msg(:atom), do: :not_an_atom
  defp is_error_msg(:integer), do: :not_an_integer
  defp is_error_msg(key), do: :"not_a_#{key}"
end