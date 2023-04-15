defmodule Agenx.Tools do
  require Logger

  alias Agenx.{
    OpenAI,
    State
  }

  @tools %{
    "User Input" => Agenx.Tools.UserInput,
    "Large Language Model" => Agenx.Tools.LLM
  }

  @spec choose(State.t(), State.Action.t()) :: {:ok, module()} | {:error, any()}
  def choose(%State{} = _state, %State.Action{} = action) do
    prompt = """
    Tool List:
    #{tools_list()}

    Please choose a tool from the tool list to perform this action:
      #{action.name}:
    """

    case OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => tool_name}]}} ->
        {_, tool} =
          @tools
          |> Enum.sort_by(fn {name, _} -> String.jaro_distance(name, tool_name) end)
          |> List.last()

        Logger.info("Chose tool: #{tool_name} => #{tool}")

        {:ok, tool}

      {:error, error} ->
        {:error, error}
    end
  end

  def perform_action(tool, %State{} = state, %State.Action{} = action) do
    tool.perform_action(state, action)
  end

  defp tools_list do
    @tools
    |> Enum.map(fn {name, _} -> "- #{to_string(name)}" end)
    |> Enum.join("\n")
  end
end
