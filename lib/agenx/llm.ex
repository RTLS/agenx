defmodule Agenx.LLM do
  require Logger

  alias Agenx.{OpenAI, State}

  @log_prefix inspect(__MODULE__)

  def update_sub_goals(%State{} = state) do
    prompt =
      """
      PREVIOUS TASKS:
      #{format_previous_actions(state)}
      END OF TASKS

      FUTURE TASKS:
      #{format_current_sub_goals(state)}
      END OF TASKS

      Consider the ultimate objective of the AI: #{state.goal}.

      You are a task prioritization AI. You are tasked with cleaning, formatting and reprioritizing FUTURE TASKS.

      Return the result as a numbered list, like:
      #. First task
      #. Second task

      The starting task is number #{length(state.previous_actions) + 1}.

      CLEANED FUTURE TASKS:
      #{length(state.previous_actions) + 1}:
      """
      |> String.trim()

    case OpenAI.completion(%{prompt: prompt, max_tokens: 2048, stop: ["END", "\n\n"]}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Updated sub goals:\n#{text}")

        sub_goals =
          text
          |> String.trim()
          |> String.split("\n")
          |> Enum.map(&String.trim/1)

        {:ok, %State{state | sub_goals: sub_goals}}

      {:error, error} ->
        {:error, error}
    end
  end

  defp format_current_sub_goals(%State{sub_goals: []}) do
    "None"
  end

  defp format_current_sub_goals(%State{} = state) do
    state.sub_goals
    |> Enum.join("\n")
  end

  defp format_previous_actions(%State{previous_actions: []}) do
    "None"
  end

  defp format_previous_actions(%State{} = state) do
    state.previous_actions
    |> Enum.take(5)
    |> Enum.reverse()
    |> Enum.map(fn %State.Action{} = action -> action.name end)
    |> Enum.join("\n")
  end

  def done?(state) do
    prompt = """
    #{State.to_string(state)}

    Is this goal achieved? (YES/NO)
    """

    case OpenAI.completion(%{prompt: prompt, temperature: 0}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Done? #{text}")
        String.downcase(text) =~ "yes"

      {:error, error} ->
        {:error, error}
    end
  end

  @spec finish(%State{}) :: {:ok, String.t()} | {:error, any()}
  def finish(%State{} = state) do
    prompt = """
    #{State.to_string(state)}

    Print the result of the goal:
    """

    case OpenAI.completion(%{prompt: prompt, max_tokens: 2048}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Final result: #{text}")
        {:ok, String.trim(text)}

      {:error, error} ->
        {:error, error}
    end
  end
end
