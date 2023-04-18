defmodule Agenx do
  @moduledoc """
  Documentation for `Agenx`.
  """

  require Logger

  alias Agenx.{
    LLM,
    State,
    Tools
  }

  @log_prefix "Agenx"

  def start(goal) do
    Logger.info("[#{@log_prefix}] Starting goal: #{goal}")

    goal
    |> State.new()
    |> loop()
  end

  defp loop(state, retries \\ 0)

  defp loop(state, retries) when retries >= 3 do
    Logger.info("[#{@log_prefix}] Failed to achieve goal after #{retries} retries")
    {:error, state}
  end

  defp loop(state, retries) do
    with {:ok, state} <- LLM.update_sub_goals(state),
         {:ok, state} <- perform_action(state) do
      if state.sub_goals == [] do
        Logger.info("[#{@log_prefix}] Goal achieved!")
        LLM.finish(state)
      else
        loop(state)
      end
    else
      {:error, error} ->
        Logger.error("[#{@log_prefix}] Error: #{error}")

        loop(state, retries + 1)
    end
  end

  defp perform_action(%State{} = state) do
    [next_sub_goal | rest_sub_goals] = state.sub_goals

    with {:ok, tool} <- Tools.choose(state, next_sub_goal),
         {:ok, result} <- Tools.perform_action(tool, state, next_sub_goal) do
      action = %State.Action{name: next_sub_goal, result: result}

      {:ok,
       %State{
         state
         | sub_goals: rest_sub_goals,
           previous_actions: [action | state.previous_actions]
       }}
    end
  end
end
