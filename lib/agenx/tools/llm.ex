defmodule Agenx.Tools.LLM do
  alias Agenx.State
  alias Agenx.State.Action

  def perform_action(%State{} = state, %Action{} = action) do
    prompt = """
    State:
    #{State.to_string(state)}

    Please enter a result for #{action.name}:
    """

    case Agenx.OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => result}]}} ->
        {:ok, String.trim(result)}

      {:error, error} ->
        {:error, error}
    end
  end
end
