defmodule Agenx.State do
  alias __MODULE__
  alias Agenx.State.Action

  @type t :: %State{
          goal: String.t(),
          sub_goals: [String.t()],
          previous_actions: [Action.t()]
        }

  defstruct [:goal, :sub_goals, previous_actions: []]

  @spec new(String.t()) :: t()
  def new(goal) do
    %State{
      goal: goal,
      sub_goals: [],
      previous_actions: []
    }
  end

  @spec add_action(t(), Action.t()) :: t()
  def add_action(%State{} = state, action) do
    %State{
      state
      | previous_actions: [action | state.previous_actions]
    }
  end

  @spec to_string(t()) :: String.t()
  def to_string(%State{} = state) do
    previous_actions =
      state.previous_actions
      |> Enum.take(10)
      |> Enum.reverse()
      |> Enum.map(&Action.to_string/1)
      |> Enum.join("\n")

    sub_goals =
      state.sub_goals
      |> Enum.join("\n")

    """
    Goal: #{state.goal}

    Sub Goals:
    #{sub_goals}

    Previous actions:
    #{previous_actions}
    """
  end
end
