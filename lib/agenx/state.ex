defmodule Agenx.State do
  alias __MODULE__
  alias Agenx.State.Action

  defstruct [:goal, :context, previous_actions: []]

  def new(goal) do
    %State{
      goal: goal,
      context: "",
      previous_actions: []
    }
  end

  def add_action(%State{} = state, action) do
    %State{
      state
      | previous_actions: [action | state.previous_actions]
    }
  end

  def to_string(%State{} = state) do
    previous_actions =
      state.previous_actions
      |> Enum.take(10)
      |> Enum.reverse()
      |> Enum.map(&Action.to_string/1)
      |> Enum.join("\n")

    """
    Goal: #{state.goal}
    Context: #{state.context}
    Previous actions:
    #{previous_actions}
    """
  end
end
