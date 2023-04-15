defmodule Agenx.State.Action do
  alias __MODULE__

  defstruct [:name, :result]

  @type t :: %Action{
          name: String.t(),
          result: String.t()
        }

  @spec new(String.t()) :: t()
  @spec new(String.t(), String.t() | nil) :: t()
  def new(name, result \\ nil) do
    %Action{
      name: name,
      result: result
    }
  end

  @spec add_result(t(), String.t()) :: t()
  def add_result(%Action{} = action, result) do
    %Action{action | result: result}
  end

  @spec to_string(t()) :: String.t()
  def to_string(%Action{} = action) do
    "#{action.name} (#{action.result})"
  end
end
