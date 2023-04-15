defmodule Agenx do
  @moduledoc """
  Documentation for `Agenx`.
  """

  require Logger

  alias Agenx.OpenAI

  @log_prefix "Agenx"

  defmodule State do
    defstruct [:goal, :context, previous_actions: []]

    defmodule Action do
      defstruct [:name, :result]

      def new(name, result \\ nil) do
        %Action{
          name: name,
          result: result
        }
      end

      def add_result(%Action{} = action, result) do
        %Action{
          action
          | result: result
        }
      end

      def to_string(%Action{} = action) do
        "#{action.name} (#{action.result})"
      end
    end

    def new(goal) do
      %State{
        goal: goal,
        context: "",
        previous_actions: []
      }
    end

    def add_action(%State{} = state, action) do
      %State{
        state
        | previous_actions: [action | state.previous_actions]
      }
    end

    def to_string(%State{} = state) do
      previous_actions =
        state.previous_actions
        |> Enum.take(10)
        |> Enum.reverse()
        |> Enum.map(&Action.to_string/1)
        |> Enum.join("\n")

      """
      Goal: #{state.goal}
      Context: #{state.context}
      Previous actions:
      #{previous_actions}
      """
    end
  end

  def start(goal) do
    state = State.new(goal)
    do_work(state)
  end

  defp do_work(state) do
    with {:ok, action} <- next_action(state),
         {:ok, result} <- perform_action(action) do
      action = State.Action.add_result(action, result)
      state = State.add_action(state, action)

      if done?(state) do
        {:ok, state}
      else
        do_work(state)
      end
    end
  end

  defp next_action(state) do
    prompt = """
    #{State.to_string(state)}

    In one sentence, what is the next action to take to achieve your goal?
    """

    Logger.debug("[#{@log_prefix}]\n#{prompt}")

    case OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Next action: #{text}")
        {:ok, text |> String.trim() |> State.Action.new()}

      {:error, error} ->
        {:error, error}
    end
  end

  defp perform_action(%State.Action{} = action) do
    prompt = """
    #{action.name}

    In one sentence, what is the result of this action?
    """

    Logger.debug("[#{@log_prefix}]\n#{prompt}")

    case OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Result: #{text}")
        {:ok, String.trim(text)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp done?(state) do
    prompt = """
    #{State.to_string(state)}

    Is this goal achieved? (YES/NO)
    """

    Logger.debug("[#{@log_prefix}]\n#{prompt}")

    case OpenAI.completion(%{prompt: prompt, temperature: 0}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Done? #{text}")
        String.downcase(text) =~ "yes"

      {:error, error} ->
        {:error, error}
    end
  end
end
