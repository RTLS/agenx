# Agenx

Baby AGI in Elixir.

## How To Use

Ensure that your OpenAI API key is set as an environment variable. Set this in your `.zshrc` or equivalent:

```bash
export OPENAI_API_KEY="..."
```

Then in your terminal:

```bash
mix deps.get
iex -S mix
```

Then in the iex shell:

```elixir
Agenx.start("some goal")
```

