defmodule Agenx.State.Action do
  alias __MODULE__

  defstruct [:name, :result]

  def new(name, result \\ nil) do
    %Action{
      name: name,
      result: result
    }
  end

  def add_result(%Action{} = action, result) do
    %Action{
      action
      | result: result
    }
  end

  def to_string(%Action{} = action) do
    "#{action.name} (#{action.result})"
  end
end
