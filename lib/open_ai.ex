defmodule Agenx.OpenAI do
  use Tesla

  @openai_api_key Application.compile_env!(:agenx, :openai_api_key)

  @completions_defaults %{
    model: "text-davinci-003",
    temperature: 0.7,
    n: 1,
    max_tokens: 128
  }

  @image_generation_defaults %{
    model: "image-alpha-001",
    num_images: 1,
    size: "512x512",
    response_format: "url"
  }

  @embeddings_defaults %{
    model: "text-embedding-ada-002"
  }

  plug(Tesla.Middleware.BaseUrl, "https://api.openai.com/v1")

  plug(Tesla.Middleware.Headers, [
    {"Authorization", "Bearer #{@openai_api_key}"},
    {"Content-Type", "application/json"}
  ])

  plug(Tesla.Middleware.JSON)

  @doc """
  Call the OpenAI Completion API with the given parameters.
  """
  def completion(%{prompt: _} = params) do
    params = Map.merge(@completions_defaults, params)

    "/completions"
    |> post(params)
    |> handle_response()
  end

  @doc """
  Call the OpenAI Image Generation API with the given parameters.
  """
  def image_generation(%{prompt: _} = params) do
    params = Map.merge(@image_generation_defaults, params)

    "/images/generations"
    |> post(params)
    |> handle_response()
  end

  @doc """
  Call the embeddings API with the given parameters.
  """
  def embeddings(%{input: _} = params) do
    params = Map.merge(@embeddings_defaults, params)

    "/embeddings"
    |> post(params)
    |> handle_response()
  end

  defp handle_response({:ok, %{status: 200, body: body}}), do: {:ok, body}
  defp handle_response({:ok, %{status: status, body: body}}), do: {:error, {status, body}}
  defp handle_response({:error, error}), do: {:error, error}
end
