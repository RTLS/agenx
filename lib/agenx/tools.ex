defmodule Agenx.Tools do
  require Logger

  alias Agenx.{
    OpenAI,
    State
  }

  @tools %{
    "Ask a Human" => Agenx.Tools.UserInput,
    "Generate Text" => Agenx.Tools.LLM
  }

  @spec choose(State.t(), String.t()) :: {:ok, module()} | {:error, any()}
  def choose(%State{} = state, sub_goal) do
    prompt = """
    You are a tool-choosing AI.

    Tool List:
    #{tools_list()}

    Keep in mind the ultimate objective for the AI:
    #{state.goal}

    Choose the best tool from the list above to perform the following task:
    #{sub_goal}

    Tool:
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

  @spec perform_action(module(), State.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def perform_action(tool, %State{} = state, sub_goal) do
    tool.perform_action(state, sub_goal)
  end

  defp tools_list do
    @tools
    |> Enum.map(fn {name, _} -> "- #{to_string(name)}" end)
    |> Enum.join("\n")
  end
end
