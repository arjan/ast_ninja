defmodule AstNinjaWeb.AstLive do
  use AstNinjaWeb, :live_view

  alias AstNinja.{AstInput, Parsers, Snippets}

  @max_chars 10_000
  @parse_timeout 2_000

  @repo_link "https://github.com/arjan/ast_ninja"
  @slides_link "https://docs.google.com/presentation/d/15_xKuL_H4Eu-EkGarxVixCk192858avE1ef1gmcVKoc/edit?usp=sharing"

  @panels [
    %{
      id: "ast",
      title: "AST",
      subtitle: "Code.string_to_quoted/2",
      opts: [
        {:check, "existing_atoms", "existing_atoms_only"},
        {:check, "formatter_metadata", "formatter metadata"},
        {:check, "columns", "columns"},
        {:check, "token_metadata", "token metadata"}
      ]
    },
    %{
      id: "tokens",
      title: "Tokens",
      subtitle: ":elixir_tokenizer.tokenize/3",
      opts: [
        {:check, "existing_atoms", "existing_atoms_only"},
        {:check, "safe_atoms", "existing_atoms_only: :safe"},
        {:check, "check_terminators", "don't check terminators"}
      ]
    },
    %{
      id: "to_string",
      title: "AST → String",
      subtitle: "Macro.to_string/1 and friends",
      opts: [
        {:radio, "Method", ["naive", "naive + formatter", "formatter_metadata", "with comments"]}
      ]
    },
    %{id: "json_ast", title: "JSON", subtitle: "the AST as a JSON tree", opts: []},
    %{
      id: "format_algebra",
      title: "Algebra",
      subtitle: "Code.quoted_to_algebra/2",
      opts: []
    },
    %{id: "filter_demo", title: "Filter → SQL", subtitle: "AST to SQL demo", opts: []},
    %{
      id: "int_parser",
      title: "leex / yecc",
      subtitle: "integer expression parser",
      opts: []
    }
  ]

  @panel_ids Enum.map(@panels, & &1.id)

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        panels: @panels,
        code: Snippets.default(),
        code_is_ast: false,
        opts: %{},
        result: %{},
        max_chars: @max_chars,
        repo_link: @repo_link,
        slides_link: @slides_link
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    panel = if params["panel"] in @panel_ids, do: params["panel"], else: hd(@panel_ids)
    {:noreply, socket |> assign(panel: panel) |> run()}
  end

  @impl true
  def handle_event("edit", %{"code" => code} = params, socket) do
    code_is_ast = params["code_is_ast"] == "true"

    if String.length(code) > @max_chars do
      {:noreply, put_flash(socket, :error, "Input is limited to #{@max_chars} characters.")}
    else
      {:noreply, socket |> assign(code: code, code_is_ast: code_is_ast) |> run()}
    end
  end

  def handle_event("select_panel", %{"panel" => panel}, socket) when panel in @panel_ids do
    {:noreply, push_patch(socket, to: ~p"/?#{[panel: panel]}")}
  end

  def handle_event("select_panel", _params, socket), do: {:noreply, socket}

  def handle_event("snippet", %{"snippet" => title}, socket) do
    case Snippets.get(title) do
      nil -> {:noreply, socket}
      code -> {:noreply, socket |> assign(code: code) |> run()}
    end
  end

  def handle_event("format", _params, socket) do
    code = socket.assigns.code |> Code.format_string!() |> IO.iodata_to_binary()
    {:noreply, socket |> assign(code: code <> "\n") |> run()}
  rescue
    _ -> {:noreply, put_flash(socket, :error, "Can't format: the code has a syntax error.")}
  end

  def handle_event("set_opts", params, socket) do
    %{panel: panel, opts: opts} = socket.assigns
    panel_opts = params |> Map.get("opts", %{}) |> Map.new(fn {k, v} -> {k, opt_value(v)} end)
    {:noreply, socket |> assign(opts: Map.put(opts, panel, panel_opts)) |> run()}
  end

  defp opt_value("true"), do: true
  defp opt_value("false"), do: false
  defp opt_value(v), do: v

  # Parsing happens in a supervised task, so a pathological input can neither
  # block nor crash the LiveView process.
  defp run(socket) do
    %{code: code, code_is_ast: code_is_ast, panel: panel, opts: opts} = socket.assigns

    result =
      case source(code, code_is_ast) do
        {:ok, source} -> parse(panel, source, Map.get(opts, panel, %{}))
        {:error, reason} -> %{error: reason}
      end

    assign(socket, result: keep_last_output(result, socket.assigns), result_panel: panel)
  end

  # While the code is (temporarily) broken, keep showing the last good output, dimmed.
  defp keep_last_output(%{error: _} = result, %{result_panel: panel, panel: panel, result: last}) do
    Map.merge(Map.take(last, [:code, :ast]), result)
  end

  defp keep_last_output(result, _assigns), do: result

  defp source(code, false), do: {:ok, code}
  defp source(code, true), do: AstInput.to_code(code)

  defp parse(panel, code, opts) do
    task =
      Task.Supervisor.async_nolink(AstNinja.TaskSupervisor, fn ->
        Parsers.mod(panel).parse(code, opts)
      end)

    case Task.yield(task, @parse_timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, result} -> result
      {:exit, _reason} -> %{error: "The parser crashed on this input."}
      nil -> %{error: "Parsing took longer than #{div(@parse_timeout, 1000)}s and was stopped."}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-dvh flex-col">
      <header class="flex h-14 shrink-0 items-center gap-3 border-b border-line bg-panel/80 px-4 backdrop-blur">
        <div class="flex items-center gap-2.5">
          <span class="grid size-8 place-items-center rounded-lg bg-gradient-to-br from-violet-500 to-fuchsia-500 font-mono text-sm font-bold text-white shadow-md shadow-violet-500/30">
            {"{}"}
          </span>
          <h1 class="text-[15px] font-semibold tracking-tight">AST Ninja</h1>
        </div>
        <nav class="ml-auto flex items-center gap-1">
          <a href={@slides_link} target="_blank" rel="noopener noreferrer" class="nav-link">
            <.icon name="slides" /> <span class="hidden md:inline">Slides</span>
          </a>
          <a href={@repo_link} target="_blank" rel="noopener noreferrer" class="nav-link">
            <.icon name="github" /> <span class="hidden md:inline">GitHub</span>
          </a>
          <button
            type="button"
            class="nav-link"
            phx-click={JS.dispatch("ast:toggle-theme")}
            aria-label="Toggle light/dark mode"
            title="Toggle light/dark mode"
          >
            <.icon name="sun" class="size-4 theme-dark-only" />
            <.icon name="moon" class="size-4 theme-light-only" />
          </button>
          <button type="button" class="nav-link" phx-click={show_help()} aria-label="About">
            <.icon name="help" />
          </button>
        </nav>
      </header>

      <main class="grid min-h-0 flex-1 grid-rows-2 gap-3 p-3 lg:grid-cols-2 lg:grid-rows-1">
        <section class="card">
          <div class="card-head">
            <h2 class="card-title">Source</h2>
            <form id="snippet-form" phx-change="snippet" class="ml-auto">
              <select name="snippet" class="select" aria-label="Load an example">
                <option value="" selected>Examples…</option>
                <option :for={title <- Snippets.titles()} value={title}>{title}</option>
              </select>
            </form>
            <button type="button" phx-click="format" class="btn" title="mix format">
              <.icon name="sparkles" class="size-3.5" /> Format
            </button>
          </div>
          <form id="editor-form" phx-change="edit" class="flex min-h-0 flex-1 flex-col">
            <textarea
              id="editor"
              name="code"
              phx-debounce="250"
              phx-hook=".TabIndent"
              maxlength={@max_chars}
              spellcheck="false"
              autocapitalize="off"
              autocomplete="off"
              class="editor"
            >{@code}</textarea>
            <div class="card-foot">
              <.toggle name="code_is_ast" checked={@code_is_ast} label="Source is an AST" />
              <span class="ml-auto font-mono text-[11px] text-ink-faint">
                {String.length(@code)} / {@max_chars}
              </span>
            </div>
          </form>
        </section>

        <section class="card">
          <div class="card-head">
            <h2 class="card-title">Output</h2>
            <form id="panel-form" phx-change="select_panel" class="ml-auto">
              <select name="panel" class="select" aria-label="Choose output">
                <option :for={p <- @panels} value={p.id} selected={p.id == @panel}>{p.title}</option>
              </select>
            </form>
          </div>
          <.output panel={Enum.find(@panels, &(&1.id == @panel))} result={@result} opts={@opts[@panel] || %{}} code_is_ast={@code_is_ast} />
        </section>
      </main>

      <.help_dialog />
      <.flash_group flash={@flash} />
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".TabIndent">
      export default {
        mounted() {
          this.el.addEventListener("keydown", (e) => {
            if (e.key !== "Tab" || e.shiftKey || e.metaKey || e.ctrlKey || e.altKey) return
            e.preventDefault()
            const { selectionStart: start, selectionEnd: end, value } = this.el
            this.el.value = value.slice(0, start) + "  " + value.slice(end)
            this.el.selectionStart = this.el.selectionEnd = start + 2
            this.el.dispatchEvent(new Event("input", { bubbles: true }))
          })
        }
      }
    </script>
    """
  end

  attr :panel, :map, required: true
  attr :result, :map, required: true
  attr :opts, :map, required: true
  attr :code_is_ast, :boolean, required: true

  defp output(assigns) do
    ~H"""
    <div class="flex items-baseline gap-2 border-b border-line px-4 py-2">
      <span class="font-mono text-xs text-ink-muted">{@panel.subtitle}</span>
      <span
        :if={@result[:equal] && !@code_is_ast}
        class="ml-auto inline-flex items-center gap-1 rounded-full bg-emerald-500/15 px-2 py-0.5 text-[11px] font-medium text-emerald-500"
      >
        <.icon name="check" class="size-3" /> output equals input
      </span>
      <span
        :for={{k, v} <- @result[:metadata] || %{}}
        class="ml-auto rounded-full bg-accent/15 px-2 py-0.5 font-mono text-[11px] text-accent"
      >
        {k}: {v}
      </span>
    </div>

    <div :if={@result[:error]} class="callout callout-error">
      <.icon name="x" class="mt-0.5 size-4 shrink-0" />
      <span class="font-mono">{error_text(@result.error)}</span>
    </div>

    <ul :if={@result[:warnings] not in [nil, []]} class="callout callout-warning flex-col">
      <li :for={w <- @result.warnings} class="font-mono">
        <span :if={w.line} class="opacity-70">line {w.line}:</span> {w.message}
      </li>
    </ul>

    <pre class={["output", @result[:error] && "opacity-40"]}><code class="makeup">{highlight(@result)}</code></pre>

    <form :if={@panel.opts != []} id={"opts-#{@panel.id}"} phx-change="set_opts" class="card-foot flex-wrap gap-x-4 gap-y-2">
      <.panel_opt :for={opt <- @panel.opts} opt={opt} values={@opts} />
    </form>
    """
  end

  attr :opt, :any, required: true
  attr :values, :map, required: true

  defp panel_opt(%{opt: {:check, name, label}} = assigns) do
    assigns = assign(assigns, name: name, label: label)

    ~H"""
    <.toggle name={"opts[#{@name}]"} checked={@values[@name] == true} label={@label} />
    """
  end

  defp panel_opt(%{opt: {:radio, name, choices}} = assigns) do
    assigns =
      assign(assigns, name: name, choices: choices, current: assigns.values[name] || hd(choices))

    ~H"""
    <div class="flex flex-wrap items-center gap-1 rounded-lg bg-canvas p-0.5">
      <label :for={c <- @choices} class={["segment", c == @current && "segment-active"]}>
        <input type="radio" name={"opts[#{@name}]"} value={c} checked={c == @current} class="sr-only" />
        {c}
      </label>
    </div>
    """
  end

  defp help_dialog(assigns) do
    ~H"""
    <div
      id="help"
      class="fixed inset-0 z-40 hidden place-items-center bg-black/50 p-4 backdrop-blur-sm"
      phx-click={hide_help()}
      phx-window-keydown={hide_help()}
      phx-key="Escape"
    >
      <div
        class="max-w-md rounded-2xl border border-line bg-panel p-6 shadow-2xl"
        phx-click={%JS{}}
        role="dialog"
        aria-modal="true"
        aria-labelledby="help-title"
      >
        <h2 id="help-title" class="text-lg font-semibold">What is this?</h2>
        <p class="mt-3 text-sm leading-relaxed text-ink-muted">
          <b class="text-ink">AST Ninja</b>
          is a tool built for the talk “The Elixir Parser under the Microscope”, presented at ElixirConf EU 2019 in Prague.
          Type some Elixir(ish) code on the left and inspect what the tokenizer and parser make of it on the right.
        </p>
        <button type="button" class="btn mt-5" phx-click={hide_help()}>Close</button>
      </div>
    </div>
    """
  end

  defp show_help,
    do:
      JS.show(
        to: "#help",
        display: "grid",
        transition: {"ease-out duration-150", "opacity-0", "opacity-100"}
      )

  defp hide_help,
    do: JS.hide(to: "#help", transition: {"ease-in duration-100", "opacity-100", "opacity-0"})

  defp highlight(%{code: code}) when is_binary(code), do: makeup(code)

  defp highlight(%{ast: ast}) do
    ast |> Jason.encode!(pretty: true) |> makeup()
  rescue
    _ -> "This AST contains terms (such as tuples) that have no JSON representation."
  end

  defp highlight(_), do: ""

  # Makeup escapes the source text itself, so the result is safe to mark raw.
  defp makeup(text), do: raw(Makeup.highlight_inner_html(text, lexer: Makeup.Lexers.ElixirLexer))

  defp error_text(e) when is_binary(e), do: e
  defp error_text(e) when is_integer(e), do: <<e::utf8>>
  defp error_text({prefix, suffix}) when is_binary(prefix), do: prefix <> error_text(suffix)
  defp error_text(e) when is_list(e), do: Enum.map_join(e, &error_text/1)
  defp error_text(e), do: inspect(e)
end
