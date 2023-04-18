defmodule Agenx.Tools.UserInput do
  alias Agenx.OpenAI
  alias Agenx.State

  @spec perform_action(State.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def perform_action(%State{} = state, sub_goal) do
    prompt = """
    You are an AI that can ask one (1) question to a human.

    The ultimate objective for your team is:
    #{state.goal}

    Recently completed tasks:
    #{format_previous_actions(state)}

    Your current task:
    #{sub_goal}

    Question:
    """

    case OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        text = String.trim(text)

        IO.puts(text)
        response = IO.gets("Response: ")

        {:ok,
         String.trim("""
         I asked the user: #{text}
         User response: #{String.trim(response)}
         """)}

      {:error, error} ->
        {:error, error}
    end
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
