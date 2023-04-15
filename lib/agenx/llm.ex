defmodule Agenx.LLM do
  require Logger

  alias Agenx.{OpenAI, State}

  @log_prefix inspect(__MODULE__)

  def next_action(state) do
    prompt = """
    #{State.to_string(state)}

    In one sentence, what is the next action to take to achieve your goal?
    """

    case OpenAI.completion(%{prompt: prompt}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Next action: #{text}")
        {:ok, text |> String.trim() |> State.Action.new()}

      {:error, error} ->
        {:error, error}
    end
  end

  def update_sub_goals(%State{} = state) do
    prompt = """
    #{State.to_string(state)}

    Re-prioritize your sub-goals, add any new ones, and remove any completed ones.

    Order your sub-goals from most important (1.) to least important (n.), and separate them with a newline.

    Each goal should be about a sentence.
    """

    case OpenAI.completion(%{prompt: prompt, max_tokens: 2048}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Sub goals:\n#{text}")
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

    case OpenAI.completion(%{prompt: prompt, temperature: 0}) do
      {:ok, %{"choices" => [%{"text" => text}]}} ->
        Logger.info("[#{@log_prefix}] Done? #{text}")
        String.downcase(text) =~ "yes"

      {:error, error} ->
        {:error, error}
    end
  end

  def finish(%State{} = state) do
    prompt = """
    #{State.to_string(state)}

    Summarize the goal and the conclusion in a few sentences.
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
