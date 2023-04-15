defmodule Agenx.LLM do
  require Logger

  alias Agenx.{OpenAI, State}

  @log_prefix inspect(__MODULE__)

  def next_action(state) do
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

  def perform_action(%State.Action{} = action) do
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

  def done?(state) do
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
