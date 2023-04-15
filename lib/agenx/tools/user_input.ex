defmodule Agenx.Tools.UserInput do
  alias Agenx.OpenAI
  alias Agenx.State

  def perform_action(%State{} = state, %State.Action{} = action) do
    prompt = """
    State:
    #{State.to_string(state)}

    You are trying to #{action.name}

    You may ask the user one (1) question for input. What would you like to ask?
    """

    case OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        text = String.trim(text)

        IO.puts(text)
        response = IO.gets("Response: ")

        {:ok,
         """
           I asked the user: #{text}
           User response: #{response}
         """}

      {:error, error} ->
        {:error, error}
    end
  end
end
