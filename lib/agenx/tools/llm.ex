defmodule Agenx.Tools.LLM do
  require Logger

  alias Agenx.State

  @log_prefix inspect(__MODULE__)

  @spec perform_action(State.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def perform_action(%State{} = state, sub_goal) do
    prompt = """
    You are a text-generation AI.

    The ultimate objective for your team is:
    #{state.goal}

    Recently completed tasks:
    #{format_previous_actions(state)}

    Your current task:
    #{sub_goal}

    Text:
    """

    case Agenx.OpenAI.completion(%{prompt: prompt, max_tokens: 2048}) do
      {:ok, %{"choices" => [%{"text" => result}]}} ->
        Logger.debug("[#{@log_prefix}] Generated text: #{result}")

        {:ok, String.trim(result)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp format_previous_actions(%State{previous_actions: []}) do
    "None"
  end

  defp format_previous_actions(%State{} = state) do
    state.previous_actions
    |> Enum.map(fn action ->
      """
      - #{action.name}
        #{action.result}
      """
    end)
    |> Enum.join("\n")
  end
end
