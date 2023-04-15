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
    with {:ok, sub_goals} <- LLM.update_sub_goals(state),
         state <- %{state | sub_goals: sub_goals},
         {:ok, action} <- LLM.next_action(state),
         {:ok, result} <- perform_action(state, action) do
      action = State.Action.add_result(action, result)
      state = State.add_action(state, action)

      if LLM.done?(state) do
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

  defp perform_action(%State{} = state, %State.Action{} = action) do
    with {:ok, tool} <- Tools.choose(state, action),
         {:ok, result} <- Tools.perform_action(tool, state, action) do
      {:ok, result}
    end
  end
end
